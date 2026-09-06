#!/usr/bin/env python3
import json
import subprocess
import sys

from hook_common import hook_input_paths, should_run_for_paths

RELEVANT_EXTENSIONS = (".ts", ".js", ".tsx", ".jsx", ".svelte", ".vue", ".astro", ".css")
COMMANDS = (
    ("Formatting", "pnpm format 2>&1 | tail -5"),
    ("Type checking", "pnpm check 2>&1 | tail -20"),
    ("Linting", "pnpm lint 2>&1 | tail -20"),
)


def main() -> int:
    payload = json.load(sys.stdin)
    paths = hook_input_paths(payload)

    if not should_run_for_paths(paths, RELEVANT_EXTENSIONS):
        return 0

    sections: list[str] = []
    for label, command in COMMANDS:
        result = subprocess.run(
            ["bash", "-lc", command],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
        )
        output = result.stdout.strip()
        if output:
            sections.append(f"{label}:\n{output}")

    if sections:
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PostToolUse",
                        "additionalContext": "\n\n".join(sections),
                    }
                }
            )
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
