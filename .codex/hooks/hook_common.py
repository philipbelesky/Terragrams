import re
from typing import Any


def collect_paths(value: Any) -> set[str]:
    paths: set[str] = set()

    if isinstance(value, dict):
        for key, item in value.items():
            if key in {"file", "path", "file_path"} and isinstance(item, str):
                paths.add(item)
            paths.update(collect_paths(item))
        return paths

    if isinstance(value, list):
        for item in value:
            paths.update(collect_paths(item))
        return paths

    if isinstance(value, str):
        for match in re.finditer(r"^\*\*\* (?:Add|Update|Delete) File: (.+)$", value, re.MULTILINE):
            paths.add(match.group(1).strip())

    return paths


def hook_input_paths(payload: dict[str, Any]) -> set[str]:
    return collect_paths(payload.get("tool_input", payload))


def should_run_for_paths(paths: set[str], extensions: tuple[str, ...]) -> bool:
    return not paths or any(path.endswith(extensions) for path in paths)
