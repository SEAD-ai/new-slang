# Contributing

Slang rots. This repo is wrong the moment it's merged, and stays wrong at an accelerating rate. Contributions that fight that decay are the most valuable kind.

## The most useful PR is a burial

**Marking a term `[DEAD]` is worth more than adding a new one.** A user who doesn't know a new word sounds a little behind. A user who confidently deploys a dead word gets clocked. The downside is asymmetric, so the `[DEAD]` list in `glossary.md` §10 is the highest-value section in the repo.

If you're under 25 and something in here made you wince: that wince is the contribution. Open an issue and say which line.

## Adding a term

Terms live in `skills/slang/references/glossary.md`, grouped by **communicative function** — approval, criticism, gossip, reactions — not alphabetically. That's deliberate: functional grouping is how you retrieve a word mid-sentence, and alphabetical lists are only good for decoding.

Every entry needs:

| Field | Notes |
|---|---|
| **Term** | The form people actually type, including deliberate misspellings (`tuff`, not `tough`) |
| **Meaning** | One line. Plain English. |
| **Example** | A real sentence. Not "That is very slang!" |
| **Register flag** | `[SAFE]` `[CASUAL]` `[RISKY]` `[DECODE ONLY]` `[DEAD]` |
| **Origin** | Only when it governs usage — AAVE, ballroom, gaming, a specific creator |

### Register flags, precisely

- `[SAFE]` — fine in a casual work Slack at a normal company
- `[CASUAL]` — friends and group chats, not work
- `[RISKY]` — vulgar, insulting, or carries an edge the user may not intend
- `[DECODE ONLY]` — understand it, never say it. Gen Alpha terms, or insults that aren't yours to throw.
- `[DEAD]` — actively marks the speaker as out of touch

**Be strict with `[SAFE]`.** The default audience is an adult professional who will take the flag literally and say the word to a colleague. When torn between `[SAFE]` and `[CASUAL]`, choose `[CASUAL]`.

## Adding a syntax pattern

Higher value than a term, and rarer. Patterns live in `usage-guide.md` §2.

Vocabulary expires in months; constructions last years. If you've spotted a productive template — one that generates new sentences rather than being a fixed phrase — that belongs here. Include the slot type (noun? clause? whole scenario?) and three genuinely different examples.

## House rules

1. **No listicle padding.** If a term only exists in "50 Gen Z words for parents" articles and nobody says it, it doesn't go in.
2. **Never claim something is trending.** The repo deliberately makes no currency claims — models have knowledge cutoffs and merges have lag. Describe meaning and register, not popularity.
3. **Gen Alpha stays `[DECODE ONLY]`.** No exceptions. The split between comprehension and production is the whole thesis; a PR that softens it will be declined.
4. **State origins once, plainly, without lecturing.** One clause, then move on. The skill is not a lesson in etiquette and shouldn't read like one.
5. **Don't sanitize the crude ones.** An adult who says "gyatt" or "zesty" at work without knowing what it means is exactly who this repo exists to protect. Define them accurately, flag them hard.
6. **Examples should be about work, code, and ordinary adult life** — that's the actual usage context, and it's where register mistakes get expensive.

## Reporting a bad call

Open an issue with the [term report](https://github.com/SEAD-ai/slang/issues/new/choose) template. The most useful reports:

- "This is dead" — with roughly when it died, if you know
- "This flag is wrong" — a `[SAFE]` that isn't safe is a bug with real consequences
- "This definition is subtly off" — subtly-wrong usage is worse than no usage
- "This decoding is wrong" — the tone tables in `decoding.md` are the highest-stakes content here, since people act on them

## Testing a change

There's no test suite; it's prose. But before opening a PR:

1. Install the skill locally (see [INSTALL.md](./INSTALL.md))
2. Run `/slang wtf <your term>` and confirm it surfaces correctly
3. Run `/slang drill` and confirm nothing contradicts the guides
4. Read your entry out loud. If it sounds like a brand wrote it, rewrite it.

## Scope

In scope: terms, patterns, register flags, decoding tables, curriculum, brand-copy rules.

Out of scope: other languages' slang (worth a separate repo), regional dialect guides, and anything that turns this into a general-purpose writing assistant. The skill does one thing.
