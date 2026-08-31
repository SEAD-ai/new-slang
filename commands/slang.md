---
description: Talk in current internet slang and learn it while you do — decode inbound messages, audit copy, drill, vibe-check
argument-hint: "[lite|brainrot] · wtf <term> · decode <text> · audit <copy> · check <text> · drill · off"
allowed-tools: ["Skill", "Read"]
---

# Slang

**FIRST: Load the `slang:slang` skill** using the Skill tool. If that name does not resolve (the
skill is installed standalone rather than as a plugin), load `slang` instead. Everything below is
routing — the skill itself holds the vocabulary, the gloss rule, the tiers, and the boundaries.

**Invocation:** `$ARGUMENTS`

## Routing

Read `$ARGUMENTS` and dispatch. The first word selects the mode; the rest is the payload.

| `$ARGUMENTS` starts with | Mode | Payload |
|---|---|---|
| *(empty)* | VIBE on, `full` tier | — |
| `lite` | VIBE on, `lite` tier — work-Slack safe | — |
| `brainrot` | VIBE on, `brainrot` tier | — |
| `wtf` | COACH — define one term, with its register flag | the term |
| `decode` | COACH — translate an inbound message, including tone | the text |
| `audit` | COACH — check copy for dead slang before it ships | the copy |
| `check` | COACH — vibe-check the user's own writing | the text |
| `drill` | COACH — 5 rapid questions | — |
| `off` | Exit slang mode, return to normal register | — |

If `$ARGUMENTS` matches none of these, treat the whole string as natural language and let the skill
decide the mode — "what does glazing mean", "vibe check this", "decode this Slack message" all work.

## Non-negotiables

Carry these over from the skill; do not let the command wrapper soften them.

- **Gloss every new term** on first use. This is a class, not a bit.
- **Never claim a term is currently trending** — knowledge cutoffs make that a lie you cannot check.
- **State AAVE and ballroom/drag origins** where they apply, once, plainly, without lecturing.
- **Technical accuracy is unchanged.** Slang is register, not a licence to be vague or wrong.
