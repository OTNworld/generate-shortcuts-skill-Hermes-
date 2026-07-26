#!/usr/bin/env python3
"""Minimal JSON Schema subset checker (stdlib only) for skill catalogs / results.

Supports: type, const, enum, required, properties, items, minimum, minLength,
minItems, additionalProperties (bool or ignored object), $ref to #/$defs/...,
and allOf is NOT supported (keep schemas simple).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


def resolve_ref(root: dict, ref: str) -> dict:
    if not ref.startswith("#/"):
        raise ValueError(f"unsupported $ref {ref}")
    cur: Any = root
    for part in ref[2:].split("/"):
        cur = cur[part]
    return cur


def check(instance: Any, schema: dict, root: dict, path: str = "$") -> list[str]:
    errors: list[str] = []
    if "$ref" in schema:
        return check(instance, resolve_ref(root, schema["$ref"]), root, path)

    if "const" in schema and instance != schema["const"]:
        errors.append(f"{path}: expected const {schema['const']!r}, got {instance!r}")
        return errors

    if "enum" in schema and instance not in schema["enum"]:
        errors.append(f"{path}: {instance!r} not in enum {schema['enum']}")

    t = schema.get("type")
    type_map = {
        "object": dict,
        "array": list,
        "string": str,
        "integer": int,
        "number": (int, float),
        "boolean": bool,
        "null": type(None),
    }
    if t is not None:
        allowed = t if isinstance(t, list) else [t]
        ok = False
        for name in allowed:
            py = type_map[name]
            if name == "integer" and isinstance(instance, bool):
                continue
            if isinstance(instance, py):
                ok = True
                break
        if not ok:
            errors.append(f"{path}: type want {allowed}, got {type(instance).__name__}")
            return errors

    if isinstance(instance, dict) and "properties" in schema:
        req = schema.get("required") or []
        for key in req:
            if key not in instance:
                errors.append(f"{path}: missing required {key!r}")
        props = schema["properties"]
        for key, val in instance.items():
            if key in props:
                errors.extend(check(val, props[key], root, f"{path}.{key}"))
            else:
                ap = schema.get("additionalProperties", True)
                if ap is False:
                    errors.append(f"{path}: additional property {key!r} not allowed")

    if isinstance(instance, list) and "items" in schema:
        if "minItems" in schema and len(instance) < schema["minItems"]:
            errors.append(f"{path}: minItems {schema['minItems']}, got {len(instance)}")
        item_schema = schema["items"]
        for i, val in enumerate(instance):
            errors.extend(check(val, item_schema, root, f"{path}[{i}]"))

    if isinstance(instance, str) and "minLength" in schema:
        if len(instance) < schema["minLength"]:
            errors.append(f"{path}: minLength {schema['minLength']}")

    if isinstance(instance, (int, float)) and not isinstance(instance, bool):
        if "minimum" in schema and instance < schema["minimum"]:
            errors.append(f"{path}: minimum {schema['minimum']}")

    return errors


def validate_file(data_path: Path, schema_path: Path) -> list[str]:
    data = json.loads(data_path.read_text(encoding="utf-8"))
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    return check(data, schema, schema)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("data", type=Path)
    ap.add_argument("schema", type=Path)
    args = ap.parse_args()
    errs = validate_file(args.data, args.schema)
    if errs:
        for e in errs:
            print(f"FAIL {e}", file=sys.stderr)
        return 1
    print(f"OK  {args.data} ⊨ {args.schema.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
