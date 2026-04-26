# My Title  
This continues on the next line.
# AI Vibe Coding Over Arching Rules For The Project  
(Over Arching Rules)

# 📘 Safe Documentation Rules for GitHub/VSCode Viewable Documentation

This section defines **documentation-specific rules** for AI-generated Markdown, ensuring all outputs render correctly on GitHub, remain readable, and are safe for copy-paste usage.

---

## 🧭 1. Markdown Structure Rules

- Use a clear heading hierarchy:
  - One `# H1` per file
  - Follow order: `## → ### → ####`
- Never skip heading levels
- Keep sections logically grouped and consistent

---

## 🧾 2. Code Block Rules

- ALWAYS specify a language in code blocks:
  - `html`
  - `css`
  - `javascript`
  - `python`

- Never use unlabeled code fences (```)

- All code must be properly fenced using the correct language tag
---

## 📦 3. Copy-Paste Readiness Rule

- All examples must be:
  - runnable OR
  - clearly labeled as "example snippet"
- Avoid partial or incomplete code unless explicitly requested

---

## 🧠 4. Explanation vs Code Separation

- NEVER mix explanation text inside code blocks
- All explanations must be outside fenced code sections
- Code blocks must contain ONLY code

---

## 📄 5. File Completeness Rule

When generating files (.md, .html, .js, etc.):
- Output must be complete and self-contained
- No missing dependencies unless explicitly stated
- No “placeholder logic” unless labeled

---

## 🌐 6. GitHub Rendering Safety Rule (CRITICAL)

When writing Markdown:

### Rule A — No raw HTML for display
- Do NOT output raw HTML tags like `<header>` for documentation display

### Rule B — Safe representation methods:
Use one of:
- Inline code: `header`
- Escaped HTML: &lt;header&gt;
- Code blocks for full examples

### Rule C — Pre-output validation
Before final output:
- Ask: “Will GitHub render this incorrectly?”
- If YES → fix before responding

---

## 🔗 7. Link Formatting Rule

- Always use proper Markdown links:
  - `[text](https://example.com)`
- Avoid raw URLs unless explicitly requested

---

## 📊 8. Table Safety Rule

- Ensure all Markdown tables:
  - are properly aligned
  - use consistent `|` structure
- Escape pipes (`|`) inside table content if needed

---

## 🧩 9. Diagram Rule (Optional)

- Prefer Mermaid diagrams:
```mermaid
graph TD
A --> B
```
- Avoid ASCII diagrams unless requested

---

## ✍️ 10. Documentation Style Rule

- Keep explanations:
  - concise
  - direct
  - non-redundant
- Avoid repeating the same idea in multiple ways

---

## ⚡ 11. AI Output Expectations

- Provide complete, usable documentation
- Ensure consistency across all sections
- Avoid unnecessary complexity or over-explaining
- Prioritize clarity and correctness over verbosity

---

## 📌 Summary Principle

> All documentation must be **GitHub-safe, structurally consistent, and free of rendering ambiguity.**
