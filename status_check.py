#!/usr/bin/env python3
"""
UAT status check — ping the UAT base URL before running tests.
Exits 0 if reachable, 1 if down (with a clear message so CI can abort early).

Usage:
    python status_check.py
    python status_check.py --url https://other-env.example.com
    python status_check.py --timeout 10 --retries 3
"""

from __future__ import annotations

import argparse
import sys
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone, timedelta

DEFAULT_URL = "https://customer.uat.graydev.in"
DEFAULT_TIMEOUT = 10   # seconds per attempt
DEFAULT_RETRIES = 2    # total attempts (1 initial + retries)
RETRY_DELAY = 5        # seconds between attempts

IST = timezone(timedelta(hours=5, minutes=30))
UAT_DOWN_START = 21   # 9 PM IST
UAT_DOWN_END = 7      # 7 AM IST


def is_uat_maintenance_window() -> bool:
    now = datetime.now(IST)
    return now.hour >= UAT_DOWN_START or now.hour < UAT_DOWN_END


def ping(url: str, timeout: int) -> tuple[bool, int | None, str]:
    """Returns (reachable, http_status_or_None, detail_message)."""
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return True, resp.status, f"HTTP {resp.status}"
    except urllib.error.HTTPError as e:
        # 4xx/5xx are still reachable — server responded
        return True, e.code, f"HTTP {e.code} ({e.reason})"
    except urllib.error.URLError as e:
        return False, None, str(e.reason)
    except OSError as e:
        return False, None, str(e)


def main() -> int:
    parser = argparse.ArgumentParser(description="Ping UAT before running Robot Framework tests.")
    parser.add_argument("--url", default=DEFAULT_URL, help="Base URL to check")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help="Request timeout in seconds")
    parser.add_argument("--retries", type=int, default=DEFAULT_RETRIES, help="Number of attempts")
    args = parser.parse_args()

    url = args.url.rstrip("/")
    now_ist = datetime.now(IST).strftime("%Y-%m-%d %H:%M IST")

    print(f"[status_check] {now_ist}")
    print(f"[status_check] Checking: {url}")

    if is_uat_maintenance_window():
        now_h = datetime.now(IST).hour
        print(
            f"[status_check] WARNING: Current time ({now_h:02d}:xx IST) is inside the UAT "
            f"maintenance window ({UAT_DOWN_START}:00–{UAT_DOWN_END:02d}:00 IST). "
            "UAT is typically down during this period."
        )

    for attempt in range(1, args.retries + 1):
        reachable, status, detail = ping(url, args.timeout)
        label = f"Attempt {attempt}/{args.retries}"

        if reachable:
            print(f"[status_check] {label} — OK ({detail})")
            return 0

        print(f"[status_check] {label} — UNREACHABLE ({detail})")
        if attempt < args.retries:
            print(f"[status_check] Retrying in {RETRY_DELAY}s …")
            time.sleep(RETRY_DELAY)

    print(
        f"\n[status_check] FAIL: {url} is not reachable after {args.retries} attempt(s).\n"
        "  • UAT is down 9 PM – 7 AM IST. Check the current time.\n"
        "  • Confirm VPN / network access if running outside CI.\n"
        "Aborting — no point running tests against a down environment."
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
