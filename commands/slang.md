---
description: Alias for /new-slang — learn a language in the margin of your work
argument-hint: "setup · global · here · wtf <term> · decode <text> · audit <copy> · check <text> · drill · off [card|all]"
allowed-tools: ["Skill", "Read", "Bash", "AskUserQuestion", "Edit"]
---

# /slang → New Slang

Alias kept for muscle memory. Behave exactly as `/new-slang` with the same `$ARGUMENTS`:

1. Load the `new-slang:new-slang` skill (fallback: `new-slang`).
2. If `~/.claude/newslang-config.json` does not exist, run the skill's onboarding first —
   whatever `$ARGUMENTS` says, including empty. Never pick a language for the user.
3. Otherwise route per the table in `commands/new-slang.md`, and observe the same
   non-negotiables and the same three-way `off` (`off` = this chat · `off card` = the ambient
   card · `off all` = everything).

**Invocation:** `$ARGUMENTS`
