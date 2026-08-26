---
name: Bug report
about: The skill misbehaves — wrong mode, ignored boundary, broken command
title: "[bug] "
labels: bug
---

**What happened:**

**What you expected:**

**Repro** — the prompt or command you used:

```
```

**Agent and version** (Claude Code, Codex, Cursor, …):

**Which tier were you in** (`lite` / `full` / `brainrot`)?

---

Boundary violations are the highest-priority bugs here. The skill should **never** use slang in code, commit messages, PR text, client-facing copy, security warnings, or exact error strings. If it did, please say so explicitly — that's a correctness failure, not a style one.
