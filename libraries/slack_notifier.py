"""
Notification library for Robot Framework.
Sends Slack and/or email summary after each E2E test run.

Environment variables:
  SLACK_WEBHOOK_URL  — Slack incoming webhook URL
  EMAIL_FROM         — sender email address (e.g. mahalakshmi.thevar@grayquest.com)
  EMAIL_TO           — recipient email (comma-separated for multiple)
  EMAIL_PASSWORD     — Gmail App Password (or SMTP password)
  EMAIL_SMTP_HOST    — SMTP host (default: smtp.gmail.com)
  EMAIL_SMTP_PORT    — SMTP port (default: 587)
"""
import os
import json
import smtplib
import urllib.request
import urllib.error
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pathlib import Path

# Auto-load .env from project root if present
_env_file = Path(__file__).parent.parent / ".env"
if _env_file.exists():
    for _line in _env_file.read_text().splitlines():
        _line = _line.strip()
        if _line and not _line.startswith("#") and "=" in _line:
            _k, _v = _line.split("=", 1)
            os.environ.setdefault(_k.strip(), _v.strip())


def _build_summary(app_id, pan, mobile, lender, stage, status, error=None):
    is_pass = str(status).upper() == "PASS"
    result_line = "Full application done" if is_pass else f"Failed at: {stage}"
    short_error = ""
    if not is_pass and error and error.strip() and error.strip() != "none":
        short_error = error.strip()[:300]
    return is_pass, result_line, short_error


def send_slack_notification(
    app_id, pan, mobile, lender, stage, status, error=None, webhook_url=None
):
    url = webhook_url or os.environ.get("SLACK_WEBHOOK_URL", "")
    if not url:
        print("SLACK_WEBHOOK_URL not set — skipping Slack notification")
        return

    is_pass, result_line, short_error = _build_summary(app_id, pan, mobile, lender, stage, status, error)
    icon = "✅" if is_pass else "❌"

    lines = [
        f"{icon} *GrayQuest E2E — {'PASS' if is_pass else 'FAIL'}*",
        "",
        f"📋 *Application:* {app_id}",
        f"📱 *Mobile:* {mobile}",
        f"👤 *PAN:* {pan}",
        f"🏦 *Lender:* {lender}",
        f"📍 *Stage:* {stage}",
        f"🔖 *Result:* {result_line}",
    ]
    if short_error:
        lines.append(f"⚠️ *Error:* `{short_error}`")

    payload = {"text": "\n".join(lines)}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            print(f"Slack notification sent (HTTP {resp.status})")
    except urllib.error.URLError as exc:
        print(f"Slack notification failed: {exc}")


def send_email_notification(
    app_id, pan, mobile, lender, stage, status, error=None,
    email_from=None, email_to=None, email_password=None,
    smtp_host=None, smtp_port=None,
):
    sender   = email_from     or os.environ.get("EMAIL_FROM", "")
    receiver = email_to       or os.environ.get("EMAIL_TO", sender)
    password = email_password or os.environ.get("EMAIL_PASSWORD", "")
    host     = smtp_host      or os.environ.get("EMAIL_SMTP_HOST", "smtp.gmail.com")
    port     = int(smtp_port  or os.environ.get("EMAIL_SMTP_PORT", "587"))

    if not sender or not password:
        print("EMAIL_FROM / EMAIL_PASSWORD not set — skipping email notification")
        return

    is_pass, result_line, short_error = _build_summary(app_id, pan, mobile, lender, stage, status, error)
    icon = "✅" if is_pass else "❌"
    subject = f"{icon} GrayQuest E2E — {'PASS' if is_pass else 'FAIL'} | {pan} | {lender}"

    html = f"""
    <html><body style="font-family:Arial,sans-serif;font-size:14px;">
    <h2 style="color:{'#2e7d32' if is_pass else '#c62828'};">{icon} GrayQuest E2E — {'PASS' if is_pass else 'FAIL'}</h2>
    <table cellpadding="8" cellspacing="0" style="border-collapse:collapse;">
      <tr><td><b>📋 Application</b></td><td>{app_id}</td></tr>
      <tr><td><b>📱 Mobile</b></td><td>{mobile}</td></tr>
      <tr><td><b>👤 PAN</b></td><td>{pan}</td></tr>
      <tr><td><b>🏦 Lender</b></td><td>{lender}</td></tr>
      <tr><td><b>📍 Stage</b></td><td>{stage}</td></tr>
      <tr><td><b>🔖 Result</b></td><td>{result_line}</td></tr>
      {"<tr><td><b>⚠️ Error</b></td><td style='color:#c62828;'>" + short_error + "</td></tr>" if short_error else ""}
    </table>
    </body></html>
    """

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = sender
    msg["To"] = receiver
    msg.attach(MIMEText(html, "html"))

    try:
        with smtplib.SMTP(host, port) as server:
            server.ehlo()
            server.starttls()
            server.login(sender, password)
            server.sendmail(sender, receiver.split(","), msg.as_string())
        print(f"Email notification sent to {receiver}")
    except Exception as exc:
        print(f"Email notification failed: {exc}")
