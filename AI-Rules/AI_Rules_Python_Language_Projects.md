# AI Coding Rules — Python

**Scope:** Python-specific syntax, idioms, and tooling. Supplements `AI_Coding_Rules.md` (architecture/philosophy still applies). Hardware-specific rules (GPIO, `gpiozero`/`pigpio`, board numbering) live in `AI_Coding_RaspberryPi_Rules.md` and `AI_Coding_Embedded_Robotics_Rules.md` — not here. This file applies equally to data/text-processing scripts (e.g. knowledge-management tooling) and non-hardware robot logic (planning, parsing, coordination).

**Audience:** This file instructs an AI code generator, not a human reader.

---

## 1. Version & Style

- Target Python 3.12+ unless a project states otherwise.
- Follow PEP 8 (style), PEP 257 (docstrings), PEP 484 (type hints).
- Format with `black` defaults unless the project specifies otherwise. Don't hand-format to fight the formatter.

## 2. Type Hints

- Type hints are required on all function signatures — parameters and return type.
- Use `from __future__ import annotations` or modern built-in generics (`list[str]`, not `List[str]`) for Python 3.12+.
- Use `Optional[X]` / `X | None` explicitly — never let `None` be an undocumented possible return.

```python
def read_lines(path: Path) -> list[str]:
    ...
```

## 3. Imports

- Order: standard library, then third-party, then project-local — each group separated by a blank line.
- No wildcard imports (`from module import *`).
- No unused imports.
- Absolute imports within a project package; avoid deep relative import chains (`from ...x.y import z`).

## 4. Paths & Files

- Use `pathlib.Path`, not `os.path`, for all filesystem paths.
- Never build paths with string concatenation or f-strings — use `Path` joins (`base / "subdir" / "file.txt"`).
- Open files with context managers (`with path.open() as f:`), never bare `open()`/`close()` pairs.

## 5. Dataclasses

- Use `@dataclass` for structured data containers instead of raw dicts or tuples once a shape has more than 2–3 fields.
- Use `@dataclass(frozen=True)` for configuration and any value that should not mutate after creation.
- Don't put business logic in a dataclass beyond simple derived properties — it's a data container, not a service.

```python
@dataclass(frozen=True)
class ScanConfig:
    max_depth: int
    include_hidden: bool = False
```

## 6. Exception Handling

- Never use bare `except:`.
- Catch specific exception types, not `Exception` broadly, unless re-raising or logging at a boundary (e.g. `main()`).
- Never silently swallow an exception (`except X: pass`). Log it, handle it, or re-raise it.
- Raise custom exceptions for domain-specific failure modes rather than overloading `ValueError`/`RuntimeError` project-wide.

```python
try:
    data = parse(raw)
except ParseError as error:
    logger.error("Failed to parse %s: %s", source, error)
    raise
```

## 7. Logging

- Use the `logging` module. Never use `print()` for anything except a genuine CLI-user-facing message or a throwaway educational demo script.
- One logger per module: `logger = logging.getLogger(__name__)`.
- Use `%s`-style lazy formatting in log calls, not f-strings, so string formatting is skipped when the log level is disabled:

```python
logger.debug("Loaded %d records from %s", count, path)
```

## 8. f-strings

- Use f-strings for all user-facing and log-adjacent string construction, not `%` or `.format()`.
- Don't use f-strings for lazy-evaluated logging arguments (see Section 7) — that defeats the lazy evaluation.

## 9. Comprehensions & Generators

- Use list/dict/set comprehensions for simple, single-transformation loops.
- If a comprehension needs a comment to explain it, or nests more than one level, write it as a regular loop instead — readability wins.
- Use generators (`yield`) instead of building full lists in memory when processing large or streaming data (e.g. large text corpora, log files).
- Never use a comprehension purely for a side effect (e.g. `[print(x) for x in items]`) — use a loop.

## 10. Virtual Environments & Dependencies

- Every project uses a virtual environment (`venv`). Never install packages globally.
- Every project has a `requirements.txt` (or `pyproject.toml` dependency list) that is kept current with actual imports.
- Before adding a dependency: check if the standard library or existing project code already solves it.
- Pin versions for reproducibility in deployed/classroom environments; loose ranges are acceptable for actively-developed libraries only when the project explicitly wants that.

## 11. Package Layout

```
project_name/
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── __main__.py
│       ├── core/
│       ├── utils/
│       └── config/
├── tests/
├── docs/
├── requirements.txt
├── README.md
└── .gitignore
```

- `__main__.py` is the entry point; it wires dependencies and calls into `core`, it does not contain business logic itself.
- Every runnable module supports `python -m project_name`.
- Keep the layered structure (HAL/drivers/control/utils/entry point) for robot-adjacent projects even when no hardware is directly touched in a given file — see `AI_Coding_Rules.md` Section 5 and `AI_Coding_Embedded_Robotics_Rules.md`.

## 12. Testing

- Use `pytest`. No `unittest`-style classes unless the project already uses that pattern.
- Test file naming: `test_<module>.py`, mirroring the source tree under `tests/`.
- One behavior per test function; descriptive test names (`test_read_lines_skips_blank_lines`, not `test1`).
- Use `pytest` fixtures for shared setup instead of copy-pasted setup code.
- Mock/inject external dependencies (filesystem, network, hardware interfaces) — tests must not depend on real I/O unless explicitly an integration test marked as such.

## 13. Architecture First

Before writing implementation:

```
Responsibilities
    ↓
Interfaces
    ↓
Dependencies
    ↓
Data Flow
    ↓
Implementation
```

Never reverse this order. This applies to a 40-line script the same as a multi-module package — scale the ceremony to the size of the task, but don't skip the thinking.
