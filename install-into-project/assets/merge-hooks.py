#!/usr/bin/env python3
"""Add the radikalreems workspaceOpen hook to an existing hooks.json. Keep every other hook."""

import json
import sys

CMD = ".cursor/hooks/sync-radikalreems-skills.sh"


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: merge-hooks.py <hooks.json>")
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise SystemExit("hooks.json root must be an object")
    hooks = data.setdefault("hooks", {})
    if not isinstance(hooks, dict):
        raise SystemExit("hooks must be an object")
    wo = hooks.setdefault("workspaceOpen", [])
    if not isinstance(wo, list):
        raise SystemExit("workspaceOpen must be an array")
    if not any(isinstance(h, dict) and h.get("command") == CMD for h in wo):
        wo.append({"command": CMD, "timeout": 60})
    data.setdefault("version", 1)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
