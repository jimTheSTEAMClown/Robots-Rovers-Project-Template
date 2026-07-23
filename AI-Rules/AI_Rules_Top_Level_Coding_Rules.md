# AI Coding Rules — Overarching Standards

**Scope:** Applies to all languages and projects. Language-specific rules live in separate files (`AI_Coding_Python_Rules.md`, `AI_Coding_PHP_Rules.md`, `AI_Coding_Java_Rules.md`, etc.) and take precedence over this file when they conflict.

**Audience:** This file instructs an AI code generator, not a human reader. Every rule is a directive, not documentation.

Jim The STEAM Clown's Edition of AI Rules: 

---

## 1. Core Design Philosophy

- Prioritize readability over cleverness. Code is read far more than it is written.
- Code and examples must be teachable to high school / early college students.
- Favor modular, testable components over monolithic scripts.
- Every file has one clear responsibility. If it can't be summarized in one sentence, split it.
- Ground every abstract concept in a real-world analogy when explaining it.
- Choose the simplest design that correctly solves the problem. No speculative abstraction, no unrequested frameworks.

## 2. Decision Hierarchy

When tradeoffs exist, resolve in this order:

1. Correctness
2. Safety
3. Security
4. Maintainability
5. Readability
6. Testability
7. Extensibility
8. Performance
9. Conciseness

Performance is never optimized before correctness and readability are established.

## 3. Change Policy

Do **not**, unless explicitly requested:

- Rename files, functions, classes, or public APIs
- Move or restructure directories
- Replace libraries, frameworks, or existing working code
- Introduce new dependencies
- Change existing architecture
- Delete functionality
- Make edits beyond the scope of the request

Default to the smallest targeted diff that fulfills the request. Do not rewrite adjacent code "while you're in there."

## 4. Naming & Structure Conventions

- Names describe purpose. No `x`, `tmp`, `foo`, `data2`.
- Avoid abbreviations unless universal (`ID`, `URL`, `HTTP`, `JSON`, `GPIO`, `PID`, `API`).
- Booleans: `is_`, `has_`, `can_`, `should_`, `enable_`, `allow_`.
- Collections: plural nouns (`students`, `sensor_readings`).
- Constants: `UPPER_SNAKE_CASE`, never a bare magic number.
- Functions: one task, descriptive verb name (`read_distance_cm()`, not `go()`).
- Comments explain **why**, not what. Delete comments that restate the code.
- Configuration is never embedded in executable logic — constants, thresholds, paths, and URLs live in config, not inline.

## 5. Architecture Rules

- Design responsibilities, interfaces, and data flow before writing implementation code.
- Separate: presentation, business/control logic, I/O, networking, storage, configuration, logging, testing.
- Apply SOLID, DRY, KISS, YAGNI as defaults, not as buzzwords to cite — just follow them.
- Prefer dependency injection over internal instantiation of dependencies, when the language and project size warrant it.
- Never ignore or silently swallow exceptions/errors. Handle, log, or raise — never `except: pass`.
- Validate all external input (user input, API responses, config files, sensor data) — never trust it implicitly.
- Never hardcode secrets, tokens, or keys.

## 6. AI Communication Standards

- No sycophancy. No unearned praise, no "great question," no filler enthusiasm.
- Be direct. Lead with the answer or the fix, not a preamble.
- Clearly distinguish: **fact**, **recommendation**, **assumption**, **opinion**, **alternative**, **risk**, **unknown**. Never present an assumption as a fact.
- State assumptions explicitly before or alongside the code that depends on them.
- If a request is ambiguous, state the interpretation being used and proceed — don't stall on questions that can be answered by a reasonable default.
- Flag when a request conflicts with these rules, and say why, rather than silently complying or silently refusing.

## 7. Before Generating Code

1. Identify the request's actual scope — what must change, what must not.
2. Identify affected files and their existing architectural layer.
3. Reuse existing project code before writing new code.
4. Identify assumptions and dependencies required.
5. Generate the smallest correct solution.

## 8. Self-Check Before Finishing

- Is it correct?
- Is it secure?
- Is it readable by a student on first read?
- Can it be tested?
- Did I duplicate existing code?
- Did I preserve existing architecture and naming?
- Did I stay inside the requested scope (see Section 3)?
- Are assumptions stated?

## 9. Language, Platform & Hardware Specific Rules

These files governs architecture, philosophy, naming, and AI behavior across all projects. For syntax, idioms, formatting, and toolchain-specific conventions.
- Report, in the chat, when a rule file is applied from the [AI_Rules_Manifest.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Manifest.md) file
- Honor any hierarchical application of rules and report when a rule is overloaded by another rule
- Report any Rule conflicts & ask for a user directed resolution. Don't guess

### Language Specific Rules

- [AI_Coding_Python_Rules.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Python_Language_Projects.md)
- `AI_Coding_PHP_Rules.md`
- `AI_Coding_C-PlusPlus_Rules.md`
- `AI_Coding_Java_Rules.md`

### Web Project Specific Rules

- [AI-Rules/AI_Rules_Web_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Web_Projects.md)
- `AI_Coding_PHP_Rules.md`
- `AI_Coding_CSS_Rules.md`
- `AI_Coding_JavaScript_Rules.md`
 
### Hardware Specific Rules

- `AI_Coding_Embedded_Robotics_Rules.md` (hardware abstraction, GPIO/serial/bus rules — applies across languages when the target has physical hardware)

### Hardware Device/Platform Specific Rules

- `AI_Coding_RaspberryPi_Rules.md` (planned)
- `AI_Coding_Arduino_Rules.md` (planned)

Where a language- or platform-specific file conflicts with this document, the more specific file wins for its scope.

