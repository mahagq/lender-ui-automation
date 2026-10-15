"""
Robot Framework listener that writes a per-run journey report answering:
  WHERE did it fail (journey stage, page URL, keyword path)
  WHAT failed (the step + raw error)
  WHY (plain-English likely cause + what to check)

Usage:
  robot --listener libraries/failure_reporter.py --outputdir results/x tests/e2e/smoke_e2e_tests.robot

Outputs in the output dir (pass or fail):
  journey_report.html  - self-contained, screenshot embedded
  journey_report.json  - machine-readable (for Slack/CI summaries)
"""
import base64
import html
import json
import re
import time
from pathlib import Path

from robot.api import logger  # noqa: F401
from robot.libraries.BuiltIn import BuiltIn

ROBOT_LISTENER_API_VERSION = 3

# (regex on error text, headline, likely cause / what to check)
_RULES = [
    (r"Can't connect to MySQL|OperationalError|Lost connection to MySQL",
     "Database unreachable",
     "The DB used for KYC/mandate/selfie/address-proof bypass could not be reached. "
     "Check VPN/network, DB_HOST in .env.db (use app-dev-mysql.non-prod.graydev.in), and credentials."),
    (r"foreign key constraint",
     "DB bypass data mismatch",
     "An insert referenced an ID that does not exist on this DB instance. IDs differ per environment; "
     "prefer tracker-only bypass or look the ID up instead of hardcoding."),
    (r"Target page, context or browser has been closed",
     "Browser closed mid-run",
     "The browser window was closed or crashed during the run (manual close, machine sleep, or crash). Re-run."),
    (r"strict mode violation",
     "Selector matches multiple elements",
     "The locator is ambiguous (e.g. substring match). Use an exact match (:text-is) or a more specific selector."),
    (r"Bypass .* failed|Bypass .* rolled back|Selfie DB bypass rolled back|KYC DB bypass",
     "DB bypass step failed",
     "A DB bypass keyword raised an error. See the raw error for the SQL/table involved; "
     "check the lender name mapping (gq_internal_lender_master) and app_id."),
    (r"Timeout \d+ms exceeded.*waiting for locator|locator\.waitFor: Timeout|waiting for .* to be visible",
     "Expected element/page never appeared",
     "The UI did not reach the expected state in time. Compare 'Page URL at failure' with the expected step: "
     "slow backend (bureau/lender decision), stale selector after a UI change, or the app auto-skipped or "
     "jumped to a different step (often a reused PAN/mobile carrying old tracker state)."),
    (r"should be active|URL should|Location should be|should contain.*url",
     "Landed on an unexpected page",
     "Navigation went to a different route than the keyword expected. The loan-execution guard routes by "
     "customer_tracker state - check the page URL at failure and whether a step was auto-skipped."),
    (r"Element .* not found|not attached|Element is not (visible|enabled)",
     "Element not interactable",
     "The element exists but is not visible/enabled, or was re-rendered. Check for an overlay/modal or a "
     "validation error on the page (see 'Visible page text')."),
    (r"Wait Until Keyword Succeeded|Keyword .* failed after retrying",
     "Retries exhausted",
     "A retried step never succeeded; the underlying error is in the raw message."),
]


_NET_HOOK = """() => {
  if (window.__gqPatched) return 'already';
  window.__gqPatched = true;
  const noise = ['google','analytics','sentry','hotjar','clarity','mixpanel','segment','doubleclick','facebook','clevertap','gtm'];
  const exts = ['.png','.jpg','.jpeg','.svg','.gif','.css','.js','.woff','.woff2'];
  const skip = {test: (u) => { u = String(u).toLowerCase(); const path = u.split('?')[0];
    return noise.some(n => u.indexOf(n) >= 0) || exts.some(x => path.endsWith(x)); }};
  const save = (e) => { try {
    const a = JSON.parse(sessionStorage.getItem('__gqNet') || '[]'); a.push(e);
    sessionStorage.setItem('__gqNet', JSON.stringify(a.slice(-100))); } catch (_) {} };
  const abs = (u) => { try { return new URL(u, location.href).href; } catch (_) { return String(u); } };
  const hdrs = (h) => { const o = {}; try {
    if (!h) return o;
    if (typeof h.forEach === 'function' && !Array.isArray(h)) h.forEach((v, k) => { o[k] = v; });
    else if (Array.isArray(h)) h.forEach(p => { o[p[0]] = p[1]; });
    else Object.keys(h).forEach(k => { o[k] = h[k]; });
  } catch (_) {} return o; };
  const bodyStr = (b) => (typeof b === 'string') ? b.slice(0, 4000) : (b ? '[non-text body: ' + Object.prototype.toString.call(b) + ']' : '');
  const rec = (m, u, s, ms, b, rh, rb) => save({m, u: String(u).split('?')[0], full: abs(u), s, ms,
    b: String(b || '').slice(0, 300), rh: rh || {}, rb: rb || '', at: new Date().toISOString(), page: location.pathname});
  const of = window.fetch;
  window.fetch = async function (input, init) {
    const isReq = input && typeof input === 'object' && 'url' in input;
    const url = isReq ? input.url : input;
    const method = (init && init.method) || (isReq && input.method) || 'GET';
    const rh = Object.assign({}, isReq ? hdrs(input.headers) : {}, hdrs(init && init.headers));
    const rb = bodyStr(init && init.body);
    const t = Date.now();
    try {
      const r = await of.apply(this, arguments);
      if (r.status >= 400 && !skip.test(url)) {
        let b = ''; try { b = await r.clone().text(); } catch (_) {}
        rec(method, url, r.status, Date.now() - t, b, rh, rb);
      }
      return r;
    } catch (err) { if (!skip.test(url)) rec(method, url, 0, Date.now() - t, err, rh, rb); throw err; }
  };
  const xo = XMLHttpRequest.prototype.open, xs = XMLHttpRequest.prototype.send,
        xh = XMLHttpRequest.prototype.setRequestHeader;
  XMLHttpRequest.prototype.open = function (m, u) { this.__m = m; this.__u = u; this.__h = {}; return xo.apply(this, arguments); };
  XMLHttpRequest.prototype.setRequestHeader = function (k, v) { (this.__h = this.__h || {})[k] = v; return xh.apply(this, arguments); };
  XMLHttpRequest.prototype.send = function (body) {
    const t = Date.now(), rb = bodyStr(body);
    this.addEventListener('loadend', () => {
      if ((this.status >= 400 || this.status === 0) && !skip.test(this.__u || ''))
        rec(this.__m, this.__u, this.status, Date.now() - t, this.status ? this.responseText : 'network error', this.__h, rb);
    });
    return xs.apply(this, arguments);
  };
  return 'patched';
}"""

# library keywords after which the hook is (re)installed; it is idempotent per document
_HOOK_AFTER = {"go to", "reload", "new page", "new context", "click"}


_SENSITIVE = ("authorization", "cookie", "x-api-key", "x-auth-token", "token")


def _curl(a, include_secrets=False):
    """Build a curl command for a captured failed request. Secrets are redacted by default."""
    import shlex
    parts = ["curl", "-i", "-X", a.get("m", "GET"), shlex.quote(a.get("full") or a["u"])]
    for k, v in (a.get("rh") or {}).items():
        if k.lower() in ("content-length", "host", "user-agent"):
            continue
        if not include_secrets and any(t in k.lower() for t in _SENSITIVE):
            v = "<REDACTED>"
        parts += ["-H", shlex.quote("%s: %s" % (k, v))]
    if a.get("rb"):
        parts += ["--data-raw", shlex.quote(a["rb"])]
    return " ".join(parts)


def _classify(message):
    for pattern, headline, cause in _RULES:
        if re.search(pattern, message or "", re.IGNORECASE | re.DOTALL):
            return headline, cause
    return ("Unclassified failure",
            "No known pattern matched. Read the raw error and the visible page text/screenshot.")


class failure_reporter:
    def __init__(self):
        self.stack = []
        self.in_teardown = False
        self.stages = []
        self.failures = []   # candidate failures: dict
        self.screenshot = None
        self.page = {}
        self.meta = {}
        self.test_name = ""
        self.t0 = None
        self.out_dir = None
        self.api_failures = []

    # ---------- helpers ----------
    def _bi(self):
        return BuiltIn()

    def _var(self, name, default=""):
        try:
            v = self._bi().get_variable_value("${%s}" % name, default)
            return default if v is None else v
        except Exception:
            return default

    def _snapshot_meta(self):
        for key, var in (("app_id", "JOURNEY_APP_ID"), ("mobile", "JOURNEY_MOBILE"),
                         ("lender", "JOURNEY_LENDER"), ("pan", "APP_PAN_NUMBER"),
                         ("dob", None)):
            if var:
                v = self._var(var, "")
                if v not in ("", None):
                    self.meta[key] = str(v)
        if "lender" not in self.meta:
            self.meta["lender"] = str(self._var("LENDER_NAME", ""))

    def _install_net_hook(self):
        try:
            self._bi().run_keyword_and_ignore_error("Evaluate JavaScript", None, _NET_HOOK)
        except Exception:
            pass

    def _harvest_net(self):
        """Pull failed API calls recorded by the page hook (kept in sessionStorage)."""
        try:
            status, raw = self._bi().run_keyword_and_ignore_error(
                "Evaluate JavaScript", None,
                "() => { const v = sessionStorage.getItem('__gqNet') || '[]';"
                " sessionStorage.removeItem('__gqNet'); return v; }")
            if status == "PASS" and raw:
                self.api_failures.extend(json.loads(raw))
        except Exception:
            pass

    def _capture_page(self):
        """Best-effort capture of URL, visible text and a screenshot. Never raises."""
        bi = self._bi()
        try:
            status, url = bi.run_keyword_and_ignore_error("Get Url")
            if status == "PASS":
                self.page["url"] = url
        except Exception:
            pass
        try:
            status, txt = bi.run_keyword_and_ignore_error(
                "Evaluate JavaScript", None,
                "() => { const alerts = [...document.querySelectorAll("
                "'[role=alert],[role=status],[data-sonner-toast],[class*=toast],[class*=error]')]"
                ".map(e => e.innerText).filter(Boolean).join(' | ');"
                " return JSON.stringify({alerts: alerts.slice(0, 600),"
                " body: document.body.innerText.replace(/\\s+/g,' ').slice(0, 1200)}); }")
            if status == "PASS" and txt:
                self.page.update(json.loads(txt))
        except Exception:
            pass
        try:
            fname = "failure_%s" % time.strftime("%H%M%S")
            status, path = bi.run_keyword_and_ignore_error("Take Screenshot", fname)
            if status == "PASS" and path:
                self.screenshot = str(path)
        except Exception:
            pass

    # ---------- listener hooks ----------
    def start_suite(self, data, result):
        if self.out_dir is None:
            try:
                self.out_dir = Path(self._bi().get_variable_value("${OUTPUT DIR}"))
            except Exception:
                self.out_dir = Path(".")

    def start_test(self, data, result):
        self.stack, self.stages, self.failures = [], [], []
        self.in_teardown, self.screenshot, self.page, self.meta = False, None, {}, {}
        self.api_failures = []
        self.test_name = data.name
        self.t0 = time.time()

    def start_keyword(self, data, result):
        if str(getattr(data, "type", "")).upper() == "TEARDOWN":
            self.in_teardown = True
        if not self.in_teardown:
            owner = getattr(data, "owner", None)
            self.stack.append("%s.%s" % (owner, data.name) if owner else data.name)

    def end_keyword(self, data, result):
        if self.in_teardown:
            return
        depth = len(self.stack)
        name = (data.name or "").lower()

        if name == "set test variable" and data.args and "JOURNEY_STAGE" in str(data.args[0]):
            stage = self._var("JOURNEY_STAGE", "")
            if stage:
                self.stages.append({"stage": str(stage), "t": round(time.time() - self.t0, 1)})
            self._snapshot_meta()

        if name in _HOOK_AFTER and not result.failed:
            self._install_net_hook()

        if depth == 1:
            self._harvest_net()

        if result.failed:
            msg = result.message or ""
            self.failures.append({"path": list(self.stack), "message": msg,
                                  "t": round(time.time() - self.t0, 1)})
            # top-level test-body keyword failed => this is the failure that fails the test
            if depth == 1 and self.screenshot is None:
                self._snapshot_meta()
                self._capture_page()

        if self.stack:
            self.stack.pop()

    def end_test(self, data, result):
        self._snapshot_meta()
        failed = result.status == "FAIL"
        message = result.message or ""
        culprit = None
        if failed:
            first_line = message.splitlines()[0] if message else ""
            for f in self.failures:
                if first_line and first_line[:80] in f["message"]:
                    culprit = f
                    break
            if culprit is None and self.failures:
                culprit = self.failures[-1]

        headline, cause = _classify(message) if failed else ("", "")
        report = {
            "test": self.test_name,
            "status": result.status,
            "duration_s": round(time.time() - self.t0, 1) if self.t0 else None,
            "meta": self.meta,
            "stages_reached": self.stages,
            "last_stage": self.stages[-1]["stage"] if self.stages else "Login / Start",
            "where": {
                "failing_step": culprit["path"][-1] if culprit else "",
                "keyword_path": culprit["path"] if culprit else [],
                "page_url": self.page.get("url", ""),
                "at_seconds": culprit["t"] if culprit else None,
            },
            "what": message,
            "why": {"headline": headline, "likely_cause": cause},
            "page": {"alerts": self.page.get("alerts", ""), "visible_text": self.page.get("body", "")},
            "screenshot": self.screenshot,
            "api_failures": self.api_failures,
        }
        if failed and self.api_failures:
            worst = [a for a in self.api_failures if a["s"] >= 500 or a["s"] == 0] or self.api_failures
            a = worst[-1]
            report["why"]["api_note"] = (
                "%d API call(s) failed during the run. Last relevant: %s %s -> %s%s. "
                "If this happened just before the failure, the backend error is the likely root cause."
                % (len(self.api_failures), a["m"], a["u"], a["s"] or "network error",
                   (" " + a["b"][:120]) if a.get("b") else ""))
        out = self.out_dir or Path(".")
        import os
        incl = os.environ.get("FAILURE_REPORT_INCLUDE_AUTH") == "1"
        for a in self.api_failures:
            a["curl"] = _curl(a, incl)
            a.pop("rh", None)
        if self.api_failures:
            try:
                (out / "api_failures_curl.sh").write_text(
                    "#!/bin/sh\n# Failed API calls captured during the run (secrets redacted unless "
                    "FAILURE_REPORT_INCLUDE_AUTH=1)\n\n" + "\n\n".join(
                        "# %s %s -> %s\n%s" % (a["m"], a["u"], a["s"] or "network error", a["curl"])
                        for a in self.api_failures) + "\n")
            except Exception:
                pass
        try:
            (out / "journey_report.json").write_text(json.dumps(report, indent=2))
            (out / "journey_report.html").write_text(self._render(report))
            print("\nJourney report: %s" % (out / "journey_report.html"))
        except Exception as exc:  # reporting must never break the run
            print("failure_reporter: could not write report: %s" % exc)

    # ---------- rendering ----------
    def _render(self, r):
        e = html.escape
        ok = r["status"] == "PASS"
        color = "#16a34a" if ok else "#dc2626"
        meta = r["meta"]

        def row(k, v):
            return "<tr><th>%s</th><td>%s</td></tr>" % (e(k), e(str(v or "-")))

        stages = "".join(
            "<li><b>%s</b> <span class=t>+%ss</span></li>" % (e(s["stage"]), s["t"])
            for s in r["stages_reached"]) or "<li>No stage reached</li>"
        api_rows = "".join(
            "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%sms</td><td>%s</td>"
            "<td><button onclick=\"cp(%d)\">Copy cURL</button></td></tr>"
            "<tr><td colspan=7><details><summary>cURL</summary><pre id=c%d>%s</pre></details></td></tr>" % (
                e(a.get("at", "")[11:19]), e(a["m"]), e(a["u"]), a["s"] or "ERR", a["ms"],
                e(a.get("b", "")), n, n, e(a.get("curl", "")))
            for n, a in enumerate(r.get("api_failures", [])))
        api_html = ("<h2>API failures during run (%d)</h2><p class=t>Secrets (Authorization/Cookie) are "
                    "redacted in the cURL; also saved as api_failures_curl.sh next to this report.</p>"
                    "<table><tr><th>Time (UTC)</th><th>Method</th><th>URL</th><th>Status</th>"
                    "<th>Took</th><th>Response</th><th></th></tr>%s</table>"
                    "<script>function cp(n){var t=document.getElementById('c'+n).innerText;"
                    "if(navigator.clipboard){navigator.clipboard.writeText(t).catch(function(){fb(t)})}else{fb(t)}}"
                    "function fb(t){var a=document.createElement('textarea');a.value=t;document.body.appendChild(a);"
                    "a.select();document.execCommand('copy');a.remove()}</script>"
                    % (len(r["api_failures"]), api_rows)) if api_rows else \
            "<h2>API failures during run</h2><p>None captured.</p>"
        img = ""
        if r["screenshot"] and Path(r["screenshot"]).exists():
            b64 = base64.b64encode(Path(r["screenshot"]).read_bytes()).decode()
            img = "<h2>Screenshot at failure</h2><img src='data:image/png;base64,%s'>" % b64

        if ok:
            body = "<p>All steps completed.</p>"
        else:
            w = r["where"]
            path = " &rarr; ".join(e(p) for p in w["keyword_path"])
            body = """
<h2>Where</h2><table>%s%s%s%s</table>
<p class=t>Keyword path: %s</p>
<h2>What</h2><pre>%s</pre>
<h2>Why (likely cause)</h2><p><b>%s</b></p><p>%s</p><p>%s</p>
<h2>What the page was showing</h2><table>%s%s</table>
%s""" % (
                row("Journey stage reached", r["last_stage"]),
                row("Failing step", w["failing_step"]),
                row("Page URL at failure", w["page_url"]),
                row("Time into run", "%ss" % w["at_seconds"] if w["at_seconds"] is not None else ""),
                path, e(r["what"]), e(r["why"]["headline"]), e(r["why"]["likely_cause"]),
                e(r["why"].get("api_note", "")),
                row("Alerts / toasts", r["page"]["alerts"]),
                row("Visible page text", r["page"]["visible_text"]), img)

        return """<!doctype html><html><head><meta charset=utf-8><title>Journey report</title><style>
body{font:14px system-ui;margin:24px;max-width:1000px;color:#111}
.banner{background:%s;color:#fff;padding:14px 18px;border-radius:8px;font-size:18px}
table{border-collapse:collapse;width:100%%;margin:8px 0}th{text-align:left;width:220px;background:#f3f4f6}
th,td{border:1px solid #e5e7eb;padding:6px 10px;vertical-align:top}
pre{background:#fef2f2;border:1px solid #fecaca;padding:10px;white-space:pre-wrap;word-break:break-word}
img{max-width:100%%;border:1px solid #ddd}.t{color:#6b7280;font-size:12px}h2{margin-top:22px}
</style></head><body>
<div class=banner>%s &mdash; %s</div>
<h2>Run</h2><table>%s%s%s%s%s%s</table>
%s
%s
<h2>Journey stages reached</h2><ol>%s</ol>
</body></html>""" % (
            color, "PASSED" if ok else "FAILED at: " + e(r["last_stage"]), e(r["test"]),
            row("App ID", meta.get("app_id")), row("Lender", meta.get("lender")),
            row("PAN", meta.get("pan")), row("Mobile", meta.get("mobile")),
            row("Duration", "%ss" % r["duration_s"]), row("Status", r["status"]),
            body, api_html, stages)
