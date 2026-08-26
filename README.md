<p align="center">
  <strong>it's giving fluent</strong>
</p>

<p align="center">
  A Claude Code skill that speaks current internet slang — and teaches it to you while it does.<br>
  <strong>Decode what your younger colleagues actually mean.</strong> Stop shipping dead slang in client copy.<br>
  Gen Z to speak. Gen Alpha to decode only. Know the difference or get clocked.
</p>

<p align="center">
  <a href="#see-it">See it</a> ·
  <a href="#install">Install</a> ·
  <a href="#the-trap">The trap</a> ·
  <a href="#what-its-actually-for">Why</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#whats-inside">Inside</a> ·
  <a href="#license">License</a>
</p>

---

## See it

Same question — "why is my build failing?" — at three tiers:

| Tier | Response |
|---|---|
| **lite** | "Your lockfile is stale — that's the whole issue. Regenerate it and you're good." |
| **full** | "lockfile is stale, that's it. that's the bug. regenerate it and you're so back 💀" |
| **brainrot** | "not the lockfile committing crimes 😭 this thing has negative aura. delete it, `npm i`, touch grass, we move" |

Every response that uses a term you haven't seen yet appends a gloss:

```
─────
**cooked** — in trouble, doomed. "we're cooked" = we're screwed.
**it's so back** — things have turned around. Paired opposite of "it's so over."
```

That's the mechanic: **the persona mode is the lesson.** You don't study a word list, you absorb terms in context and get a footnote. The skill is instructed to deliberately stretch past your known vocabulary each response, so it escalates as you keep up.

## Install

```bash
npx skills add SEAD-ai/slang
```

<details>
<summary><strong>Other ways in</strong></summary>

**Claude Code plugin:**

```bash
claude plugin marketplace add SEAD-ai/slang && claude plugin install slang@slang
```

**Manual** — clone and drop into your skills directory:

```bash
git clone https://github.com/SEAD-ai/slang.git
cp -R slang/skills/slang ~/.claude/skills/
```

**Project-scoped** — commit it into a repo at `.claude/skills/slang/` so your whole team gets it.

</details>

Then just `/slang`, or say "slang mode", "decode this", "vibe check this".

## The trap

**Gen Z is not the newest generation, and this is the thing that gets people humiliated.**

| Cohort | Born | Age in 2026 | Their slang | Can you say it? |
|---|---|---|---|---|
| **Gen Z** | 1997–2012 | 14–29 | rizz, ate, delulu, it's giving, cooked, glazing | **yes** — this is the target |
| **Gen Alpha** | 2013–2024 | 2–13 | 6-7, skibidi, gyatt, fanum tax, sigma | **decode only** — never say these |
| Gen Beta | 2025– | 0–1 | (infants) | n/a |

Most slang leaking into adult awareness right now — "6-7", "skibidi", "gyatt" — is **Gen Alpha**. That's elementary and middle schoolers. Gen Z finds it cringe too.

An adult saying "6-7" isn't behind the times. It's **worse than using no slang at all.** ("6-7" was Dictionary.com's 2025 Word of the Year and means nothing at all — it's a membership signal, not a word.)

The skill enforces the split: Gen Alpha terms are flagged `[DECODE ONLY]` and it will stop you from deploying one.

## What it's actually for

Being honest about the value split, because the fun part isn't the useful part:

| | Worth |
|---|---|
| **Speaking it** | Entertainment. Little professional value. This is the toy. |
| **Decoding it** | Real and immediate. You work with people who write this way and you're misreading tone in **both** directions. |
| **Punctuation + emoji semantics** | The highest-value thing here, and it involves zero slang. |
| **Copy auditing** | Directly commercial if any client work targets a younger audience. |

### The punctuation thing

These are **semantic** differences, not style preferences:

| You write | You mean | They read |
|---|---|---|
| `Ok.` | acknowledgment | cold, annoyed, conversation over |
| `ok` | acknowledgment | neutral, fine |
| `Thanks.` | thanks | you did something wrong |
| `Sure.` | agreement | resentful compliance |
| 👍 | got it | **dismissive** — "this conversation is over" |
| 🙂 | friendly | thinly veiled displeasure |
| 😂 | laughing | you are over 35 |
| 💀 😭 | morbid / sad | **laughing** |

A terminal period on a short casual message reads as anger to anyone under 30. If you manage young people, the 👍 habit alone is quietly costing you — it reads as curt dismissal, not efficient acknowledgment.

### Phrases that don't mean what they look like

- **"that's crazy"** — usually polite disengagement. They're done talking, not agreeing.
- **"mid"** — a genuine negative judgment. People hear the casualness and miss that their work was just called mediocre.
- **"no because…"** — not disagreement. It's sincere escalation: "wait, seriously."
- **"I fear…"** — softened bad news, mock-formal.
- **"let him cook"** — leave him alone, he knows what he's doing.
- **"unc"** — you're acting old. Usually aimed at you.

## Commands

| Command | Does |
|---|---|
| `/slang` | Turn it on. Answers your real questions in slang, glossing new terms. |
| `/slang lite \| full \| brainrot \| off` | Set the tier. `lite` is work-Slack safe. |
| `/slang decode <text>` | **Inbound translation, including tone.** The most useful one. |
| `/slang audit <copy>` | Check brand/marketing copy before it ships. Flags dead terms, register mismatch, misuse, origin risk, 6-month shelf life. |
| `/slang check <text>` | Vibe check *your* writing. Scored /10, names the specific tell that outs you. |
| `/slang wtf <term>` | Define, with register flag and what it's commonly mistaken for. |
| `/slang drill` | 5 rapid questions. Mixes decode, produce, register judgment. |
| `/slang curriculum` | Where you are, what's next. |

## What's inside

```
skills/slang/
├── SKILL.md              modes, tiers, gloss rule, boundaries
└── references/
    ├── glossary.md       the dictionary, grouped by function
    ├── usage-guide.md    dosage, syntax patterns, the tells
    ├── decoding.md       tone reading + brand copy rules
    └── practice.md       4-week curriculum, drill banks
```

**The glossary is grouped by what you're trying to say** — approval, criticism, gossip, reactions — not alphabetically, because that's how you retrieve a word mid-sentence. Every entry carries a register flag: `[SAFE]` `[CASUAL]` `[RISKY]` `[DECODE ONLY]` `[DEAD]`. The `[DEAD]` list matters most: *yeet*, *on fleek*, *bae*, *adulting* are doing you more damage than not knowing new words.

**Fluency lives in syntax, not vocabulary.** Words go stale in months; constructions last years. The skill teaches ~10 productive patterns:

```
it's giving ___        →  "it's giving unpaid intern"
not me ___ing          →  "not me pushing to main on a friday"
the way ___            →  "the way this repo has zero tests"
I fear ___             →  "I fear the migration didn't run"
___ era                →  "in my refactoring era"
___-coded / ___-core   →  "that UI is 2014-coded"
X and Y'd              →  "ate and left no crumbs"
```

That last one is the point. **"Ate and left no crumbs" isn't a phrase to memorize — it's a construction.** Learn the shape and you generate them yourself. That's the difference between a phrasebook and fluency.

### Dosage is the whole game

> ❌ "No cap fam, that deck absolutely slaps, it's giving main character energy fr fr, you ate and left no crumbs bestie 💯🔥"
>
> ✅ "that deck ate"

One slang move per 1–2 sentences, in the predicate, delivered **deadpan**. Enthusiasm is what kills it. If nobody reacts, you did it right.

## Two things worth knowing

**On attribution.** A large share of this vocabulary is [AAVE](https://en.wikipedia.org/wiki/African-American_Vernacular_English) or comes from Black queer ballroom and drag culture — *ate, slay, serving, tea, periodt, no cap, gagged, giving.* The skill states origins once, plainly, without lecturing. The practical line: **borrow words, not a voice.** Individual borrowed words in your own natural register is ordinary language contact. Switching into a broad accent is not.

**On freshness.** This vocabulary rotates on a months-to-a-year cycle and any model has a knowledge cutoff, so the skill is instructed **never to claim a term is currently trending.** The durable heuristic it gives you instead:

> **If a brand used it in an ad, it's dead.**

Not because brands are uncool, but because slang's value *is* in-group membership — a brand using a term is definitionally an outsider, so adoption kills it. Which is also why chasing recency backfires for you personally: as an adult, you are structurally the outsider. **Precision reads as fluent. Recency reads as desperate.** Being an adult who uses "mid" perfectly is cool. Being an adult who uses "6-7" is not, no matter how current it is.

## Contributing

Slang rots. PRs that mark a term `[DEAD]` are as valuable as ones that add terms — arguably more. See [CONTRIBUTING.md](./CONTRIBUTING.md), or open a [term report](https://github.com/SEAD-ai/slang/issues/new/choose).

## License

MIT — see [LICENSE](./LICENSE).

Built at [SEAD](https://sead.ai). Structure inspired by [caveman](https://github.com/JuliusBrussee/caveman), which is a genuinely good idea and worth your time.
