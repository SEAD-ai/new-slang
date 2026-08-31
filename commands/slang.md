---
description: Alias for /new-slang — language mode, decode, audit, drill, vibe-check
argument-hint: "setup · wtf <term> · decode <text> · audit <copy> · check <text> · drill · off"
allowed-tools: ["Skill", "Read"]
---

# /slang → New Slang

Alias kept for muscle memory. Behave exactly as `/new-slang` with the same `$ARGUMENTS`: load the
`new-slang:new-slang` skill (fallback: `new-slang`), run onboarding if `~/.claude/newslang-config.json`
is missing or `$ARGUMENTS` is `setup`, and follow the routing table in `commands/new-slang.md`.
