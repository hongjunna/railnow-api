"""RailNow API quick start for Python 3.8+ (standard library only).

Usage: RAILNOW_API_KEY=jl_... python3 quickstart.py
"""

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

API_KEY = os.environ.get("RAILNOW_API_KEY")
BASE = "https://railnow.runvia.app/api/v1"


def railnow(path, **params):
    query = urllib.parse.urlencode({"lang": "en", **params})
    request = urllib.request.Request(f"{BASE}{path}?{query}", headers={"X-API-Key": API_KEY})
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        if error.code == 429:
            sys.exit(f"Rate limit exceeded. Retry after {error.headers.get('Retry-After')} seconds.")
        sys.exit(f"{error.code} {error.read().decode()}")


if not API_KEY:
    sys.exit("Set RAILNOW_API_KEY to the key from https://railnow.runvia.app/developer")

# Every active train on Line 2, with its current or next station.
line = railnow("/train/lines/1002/trains", simple="true")
print(f"Line 2 at {line['nowTime']}: {len(line['trains'])} trains")
for train in line["trains"]:
    status = train.get("trainStatus") or {}
    where = status.get("currentStation") or status.get("nextStation") or "-"
    print(f"  {train['trainNo']:>6}  {status.get('status', '-'):<10} {where}")
