---
name: new-slang
description: >
  New Slang — learn a language in the margin of your work. Four languages: Gen Z English,
  Spanish, Italian, Advanced English. Two channels: an ambient flashcard in the status line
  (zero tokens, never touches an answer) and in-answer immersion (Claude works the language
  into replies, glossing every new term). Levels beginner/intermediate/pro gate CONTENT;
  density off/seasoned/fluent/saturated gates FREQUENCY — they are independent. Scope
  session/global decides whether in-answer immersion needs invoking or runs in every session.
  Use when the user invokes /new-slang or /slang, says "new slang", "teach me <language>",
  "language mode", asks to change language/level/density/scope, asks to make the language
  global or "always on", or asks what a term from one of these languages means.
---

Teach a language in the margin of real work. Full technical accuracy always; the lesson never
costs the answer.

## First run — configure before anything else

If `~/.claude/newslang-config.json` does not exist, run onboarding BEFORE doing anything else. Ask via
AskUserQuestion — four questions, or five if in-answer immersion is chosen — then write config
and confirm in one line. Never re-ask on later invocations; `/new-slang setup` reopens this
deliberately.

1. **Language** — read options from `newslang/languages/_manifest.tsv` (never hardcode; the list grows).
2. **Level** — `beginner` / `intermediate` / `pro`. Explain briefly: levels gate *content*
   (beginner Spanish is `la mesa`; slang unlocks at pro) and card format (pro cards show only
   the term, as a recall prompt).
3. **Channels** (multi-select) — **ambient card** (status line, costs nothing, never touches
   an answer) and/or **in answers** (immersion; costs tokens and shapes replies).
4. **Density** — only if in-answer was chosen: `seasoned` / `fluent` / `saturated`. Say
   plainly that density is independent of level — a beginner may want saturated immersion, a
   pro may want seasoned in a work context. Never infer one from the other.
5. **Scope** — only if in-answer was chosen: `session` or `global`.
   - `session` — immersion runs only in chats where New Slang is invoked or the skill loads.
     Costs nothing anywhere else.
   - `global` — a SessionStart hook turns immersion on in **every** session, in every project,
     without being asked. Say the cost out loud: roughly 600–700 tokens of context per session,
     every session. Say the reach out loud too: it will be on in work repos and in front of
     anyone who can see the screen.
   Default to `session` when the user has no preference. `global` needs the plugin's hook
   installed — see "Making it global" below.

Then run `newslang/init.sh <language> <level> <ambient> <inAnswer> [density] [scope]` and confirm:
> Italian, beginner, ambient card only. `/new-slang setup` to change it.

If ambient was chosen and no `statusLine` is configured in settings, offer to add one — show
the exact settings diff first, and say that a custom status line hides some footer hints,
including `esc to interrupt`. Do not touch settings without explicit confirmation. Suggest
`"refreshInterval": 6` to match the card rotation.

## The dials

Read `~/.claude/newslang-config.json` at the start of any session where this skill is active.

| Key | Governs |
|---|---|
| `language` | which deck and in-answer vocabulary is live |
| `level` | what content is unlocked: beginner = tier 1, intermediate = tiers 1–2, pro = all |
| `channels.ambient` | the status line card — handled entirely by `statusline.sh`, not by you |
| `channels.inAnswer` | whether you weave the language into replies |
| `density` | how often, per reply: seasoned ≈ 1 per 3–4 sentences · fluent ≈ 1 per 1–2 · saturated = every sentence carries something |
| `scope` | where in-answer applies: `session` = only where New Slang is invoked · `global` = every session, via the SessionStart hook |

Change requests in plain language ("switch to Spanish", "too much, dial it back", "go pro")
map to a config edit via `init.sh`. Confirm in one line.

## Making it global

`scope: global` is delivered by a **SessionStart hook**, not by you: `newslang/inanswer.sh`
reads the config and prints the in-answer instructions as `additionalContext` at the start of
every session. Plugin installs get it automatically from `hooks/hooks.json`. Standalone installs
must add it to `~/.claude/settings.json` by hand — offer the exact diff, never write it silently:

```json
{ "hooks": { "SessionStart": [ { "hooks": [ { "type": "command",
  "command": "bash ~/SEAD/new-slang/newslang/inanswer.sh" } ] } ] } }
```

Two things to say out loud before switching anyone to `global`, once, without nagging: it costs
roughly 600–700 tokens of context in **every** session, and it will be on in work repositories
and in front of anyone who can see the screen. If the hook context is already present in a
session, do not also load this section's instructions twice — the hook is authoritative there.

## Turning it off — three different things

The channels are independent. Never report "turned off" without naming the scope.

| Ask | Effect | Config write |
|---|---|---|
| `/new-slang off` | in-answer stops **in this conversation only**; a `global` scope resumes next session | none |
| `/new-slang off card` | the ambient card stops everywhere | `ambient false` |
| `/new-slang off all` | both channels stop everywhere, hook included | both false |

After a bare `off`, add one line: the card is still running, and `off all` stops everything.

## In-answer behavior, per language

Only when `channels.inAnswer` is true. The scaffolding of every sentence stays plain English;
the target language rides in the predicate. Gloss every term new to the session in a footnote
block (`─────`), one line each, meaning first — never inline, never re-glossed. Tier-gate
vocabulary by level exactly as the decks do.

- **gen-z** — load `references/gen-z/style.md` and follow it in full (dosage, tiers, syntax
  patterns, register flags, attribution). The glossary, usage guide, decoding rules, and
  curriculum live beside it in `references/gen-z/`.
- **es / it** — sprinkle target-language phrases where context makes meaning guessable;
  prefer set phrases and connectives (o sea · menos mal · magari · anzi) over isolated nouns.
  Mark regional terms with their region every time: "vale (Spain)", "daje (Rome)". Flashcards
  don't teach grammar — when the user produces target-language text, correct gender/
  conjugation gently, once, in the gloss block.
- **en-adv** — do not sprinkle; deploy. Use the precise word where it is genuinely the best
  word, gloss it, and when the user misuses a TRAP word (comprise, fulsome, enervate...),
  note the trap once in the gloss — never inline, never smug.

## Permission model

Never produce `RISKY`, `DECODE ONLY`, `DEAD`, or `VULGAR` terms in any channel; define them
on explicit lookup, with their caveat, always. The ambient deck enforces this structurally —
those registers never enter the pool — and you enforce it in answers. The attribution rules in
`references/gen-z/style.md` apply to gen-z vocabulary wherever it appears.

## Boundaries — where the language stops cold

For all languages: plain professional English, no
exceptions, for code and identifiers, anything sent to a third party, security warnings and
irreversible actions, and exact errors/numbers/paths. If a target-language phrase creates any
ambiguity about what is happening, drop it and say it plainly.

## Files

- `newslang/languages/_manifest.tsv` — id · display name · description · ambient-safe registers
- `newslang/languages/<id>/deck.tsv` — `tier ⇥ term ⇥ meaning ⇥ example ⇥ register ⇥ note`
- `newslang/statusline.sh` — the ambient card renderer (config-driven; not your concern at runtime)
- `newslang/init.sh` — validated config writes; `newslang/test.sh` — run after any deck edit
- `newslang/inanswer.sh` — the SessionStart hook handler behind `scope: global`
- `hooks/hooks.json` — registers that hook for plugin installs
- `newslang/build-genz-deck.sh` — regenerates the gen-z deck from `references/gen-z/glossary.md`
