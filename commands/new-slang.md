---
description: Learn a language in the margin of your work — set up, switch language/level/density, decode a term, drill, or turn immersion off
argument-hint: "setup · global · here · wtf <term> · decode <text> · audit <copy> · check <text> · drill · off [card|all]"
allowed-tools: ["Skill", "Read", "Bash", "AskUserQuestion", "Edit"]
---

# New Slang

**Load the `new-slang:new-slang` skill first** (fallback: `new-slang`, for standalone installs).
The skill holds the dials, the gloss rule, the register/permission model, and the boundaries; for
gen-z it loads its `references/gen-z/` authority. Everything below is routing.

**Invocation:** `$ARGUMENTS`

## Before routing: is this a first run?

If `~/.claude/newslang-config.json` does not exist, run the skill's onboarding **before doing
anything else**, whatever `$ARGUMENTS` says — including when it is empty. New Slang asks how it
should work before it works, and it never picks a language on the user's behalf. Onboarding is
four questions (five if in-answer is chosen) via **AskUserQuestion**, then a `newslang/init.sh`
call. Both tools are allowed here; do not skip the questions because a mode looks obvious.

Once the config exists, never re-ask. `/new-slang setup` reopens it deliberately.

## Routing

The first word selects the mode; the rest is the payload.

| `$ARGUMENTS` starts with | Mode | Payload |
|---|---|---|
| *(empty)* | Report the current config in one line, then turn in-answer immersion on **for this conversation** | — |
| `setup` | Re-run onboarding from the top | — |
| `global` | Switch in-answer to `scope: global` — live in every session, no invocation needed | — |
| `here` | Switch in-answer back to `scope: session` — only in chats where New Slang is invoked | — |
| `wtf` | COACH — define one term, with its register flag | the term |
| `decode` | COACH — translate an inbound message, including tone | the text |
| `audit` | COACH — check copy before it ships (dead slang, register mismatch) | the copy |
| `check` | COACH — vibe-check the user's own writing | the text |
| `drill` | COACH — 5 rapid questions from the active deck, at the active level | — |
| `off` | Quiet immersion **for this conversation only** — see below | — |

Anything else is natural language: "switch to Spanish", "too much, dial it back", "go pro",
"what does glazing mean", "decode this Slack message". Let the skill map it to a config edit via
`newslang/init.sh` and confirm in one line.

## `off` means three different things — say which one happened

The channels are independent, and this is the single easiest thing to get wrong. Never report
"turned off" without naming the scope.

| Command | Effect | Config write? |
|---|---|---|
| `off` | In-answer immersion stops **in this conversation**. The status line card keeps running, and if `scope` is `global` the next session starts immersed again. | No |
| `off card` | The ambient status line card stops everywhere. | Yes — `ambient false` |
| `off all` | Both channels stop everywhere, including the SessionStart hook. | Yes — both false |

After a bare `off`, add one line: the card is still running, and `off all` stops everything.

## Non-negotiables

Carry these over from the skill; do not let the command wrapper soften them.

- **Gloss every new term** on first use, in the footnote block, never inline. This is a class, not a bit.
- **Never claim a term is currently trending** — a knowledge cutoff makes that a claim you cannot check.
- **State AAVE and ballroom/drag origins** where they apply, once, plainly, without lecturing.
- **Never produce** `RISKY`, `DECODE ONLY`, `DEAD`, or `VULGAR` terms in any channel; define them on explicit lookup, with their caveat.
- **Technical accuracy is unchanged.** The language is register, not a licence to be vague or wrong, and it stops cold at code, third parties, security warnings, and exact errors.
