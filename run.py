#!/usr/bin/env python3
"""
GrayQuest E2E Runner
Usage: python run.py

Commands:
  run <PAN> for <LENDER>
  run <PAN> for <LENDER> manual kyc
  run <PAN> for <LENDER> loan <amount>
  run <PAN> for <LENDER> salary <amount>
  run <PAN> for <LENDER> plan <plan name>
  resume <APP_ID> mobile <MOBILE>
  status
  help
  exit
"""

import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path

BASE = Path(__file__).parent
ROBOT = BASE / "env/bin/robot"
RESULTS = BASE / "results"

KNOWN_LENDERS = {
    "mirae": "Mirae",
    "csb": "CSB",
    "ratnaafin": "Ratnaafin",
    "tata": "Tata Capital Limited",
    "idfc": "IDFC",
    "prefr": "Prefr",
}

DEFAULT_PLAN = {
    "mirae": "Mirae-11-EMI-1dp - 0IRR - Signoff",
    "ratnaafin": "RCPL-dlg-prod-4",
}


def resolve_lender(text):
    t = text.lower().strip()
    for key, full in KNOWN_LENDERS.items():
        if key in t:
            return full, key
    return text.strip(), text.lower().strip()


def make_email():
    return f"maha.{int(time.time())}{os.getpid() % 9999}@th.com"


def run_robot(label, variables: dict, test="smoke"):
    out_dir = RESULTS / label
    out_dir.mkdir(parents=True, exist_ok=True)
    test_file = str(BASE / "tests/e2e/smoke_e2e_tests.robot" if test == "smoke"
                    else BASE / "tests/e2e/nach_resume_tests.robot")
    cmd = [str(ROBOT), "--outputdir", str(out_dir)]
    for k, v in variables.items():
        cmd += ["--variable", f"{k}:{v}"]
    cmd.append(test_file)
    print(f"\n▶  Running: {' '.join(cmd[-10:])}\n   Output dir: {out_dir}\n")
    result = subprocess.run(cmd, capture_output=False)
    return out_dir, result.returncode


def read_summary(out_dir):
    xml_path = out_dir / "output.xml"
    if not xml_path.exists():
        return None
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        summary = {}
        for msg in root.iter("msg"):
            txt = msg.text or ""
            for field in ["APP ID", "MOBILE", "LENDER", "STAGE", "RESULT", "ERROR"]:
                if txt.startswith(f"{field}:"):
                    summary[field] = txt[len(field)+1:].strip()
        return summary
    except Exception:
        return None


def show_status(n=10):
    dirs = sorted(RESULTS.glob("*/output.xml"), key=lambda p: p.stat().st_mtime, reverse=True)
    rows = []
    for p in dirs[:n]:
        s = read_summary(p.parent)
        if s and s.get("APP ID", "(not reached)") != "(not reached)":
            rows.append(s)
    if not rows:
        print("No completed applications found.")
        return
    print(f"\n{'APP ID':<10} {'MOBILE':<14} {'LENDER':<30} {'STAGE'}")
    print("-" * 80)
    for r in rows:
        print(f"{r.get('APP ID','?'):<10} {r.get('MOBILE','?'):<14} {r.get('LENDER','?'):<30} {r.get('STAGE','?')}")
    print()


def parse_run_command(cmd_str):
    """Parse: run <PAN> for <LENDER> [manual kyc] [loan <N>] [salary <N>] [plan <text>]"""
    m = re.match(r'run\s+([A-Z0-9]+)\s+for\s+(.+)', cmd_str, re.IGNORECASE)
    if not m:
        return None, "Usage: run <PAN> for <LENDER> [options]"

    pan = m.group(1).upper()
    rest = m.group(2)

    # Extract options from rest
    manual_kyc = bool(re.search(r'\bmanual\s*kyc\b', rest, re.IGNORECASE))
    rest = re.sub(r'\bmanual\s*kyc\b', '', rest, flags=re.IGNORECASE)

    loan_m = re.search(r'\bloan\s+(\d+)', rest, re.IGNORECASE)
    loan = loan_m.group(1) if loan_m else None
    if loan_m:
        rest = rest[:loan_m.start()] + rest[loan_m.end():]

    salary_m = re.search(r'\bsalary\s+(\d+)', rest, re.IGNORECASE)
    salary = salary_m.group(1) if salary_m else None
    if salary_m:
        rest = rest[:salary_m.start()] + rest[salary_m.end():]

    plan_m = re.search(r'\bplan\s+(.+)', rest, re.IGNORECASE)
    plan = plan_m.group(1).strip() if plan_m else None
    if plan_m:
        rest = rest[:plan_m.start()]

    lender_text = rest.strip().rstrip(',').strip()
    lender_full, lender_key = resolve_lender(lender_text)

    variables = {
        "LENDER_NAME": lender_full,
        "APP_PAN_NUMBER": pan,
        "APP_EMAIL": make_email(),
    }
    if manual_kyc:
        variables["MANUAL_KYC"] = "True"
    if loan:
        variables["APP_LOAN_AMOUNT"] = loan
    if salary:
        variables["APP_MONTHLY_SALARY"] = salary
    if plan:
        variables["APP_PLAN_ID_MIRAE"] = plan  # stored in MIRAE var, used by all via override
        # For non-mirae lenders override the plan via a generic approach
        variables["APP_PLAN_OVERRIDE"] = plan

    label = f"{lender_key}_{pan.lower()}_{int(time.time())}"
    return {"label": label, "variables": variables, "pan": pan, "lender": lender_full}, None


def parse_resume_command(cmd_str):
    """Parse: resume <APP_ID> mobile <MOBILE>"""
    m = re.match(r'resume\s+(\d+)\s+mobile\s+(\d+)', cmd_str, re.IGNORECASE)
    if not m:
        return None, "Usage: resume <APP_ID> mobile <MOBILE>"
    app_id, mobile = m.group(1), m.group(2)
    variables = {
        "RESUME_APP_ID": app_id,
        "RESUME_MOBILE": mobile,
    }
    label = f"resume_{app_id}_{int(time.time())}"
    return {"label": label, "variables": variables, "app_id": app_id, "mobile": mobile}, None


def main():
    print("=" * 60)
    print("  GrayQuest E2E Runner")
    print("  Type 'help' for commands, 'exit' to quit")
    print("=" * 60)

    while True:
        try:
            cmd = input("\n> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nBye.")
            break

        if not cmd:
            continue

        low = cmd.lower()

        if low in ("exit", "quit", "q"):
            print("Bye.")
            break

        elif low == "help":
            print("""
Commands:
  run <PAN> for <LENDER>
  run <PAN> for <LENDER> manual kyc
  run <PAN> for <LENDER> loan <amount>
  run <PAN> for <LENDER> salary <amount>
  run <PAN> for <LENDER> plan <plan name>
  resume <APP_ID> mobile <MOBILE>
  status              — show last 10 apps with IDs
  exit

Examples:
  run BJNPS1878R for Mirae
  run BBYPB1408H for Mirae manual kyc loan 99999
  run AKLPC7106Q for Ratnaafin plan RCPL-dlg-prod-4
  resume 908668 mobile 9698752174
""")

        elif low.startswith("status"):
            show_status()

        elif low.startswith("resume"):
            parsed, err = parse_resume_command(cmd)
            if err:
                print(f"Error: {err}")
                continue
            print(f"Resuming app {parsed['app_id']} with mobile {parsed['mobile']} ...")
            out_dir, code = run_robot(parsed["label"], parsed["variables"], test="resume")
            summary = read_summary(out_dir)
            if summary:
                print(f"\n{'='*50}")
                for k, v in summary.items():
                    print(f"  {k}: {v}")
                print(f"{'='*50}")

        elif low.startswith("run"):
            parsed, err = parse_run_command(cmd)
            if err:
                print(f"Error: {err}")
                continue
            print(f"Running {parsed['pan']} for {parsed['lender']} ...")
            if parsed["variables"].get("MANUAL_KYC") == "True":
                print("  ⏸  Manual KYC mode — browser will pause at KYC for you to enter details.")
            out_dir, code = run_robot(parsed["label"], parsed["variables"])
            summary = read_summary(out_dir)
            if summary:
                print(f"\n{'='*50}")
                for k, v in summary.items():
                    print(f"  {k}: {v}")
                print(f"{'='*50}")

        else:
            print(f"Unknown command: '{cmd}'. Type 'help' for usage.")


if __name__ == "__main__":
    main()
