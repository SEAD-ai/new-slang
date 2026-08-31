<h1 align="center">New Slang</h1>

<p align="center">
  <strong>the vocabulary you weren't taught — at either end</strong>
</p>

<p align="center">
  A Claude Code plugin that teaches you a language in the margin of your work.<br>
  A flashcard rotates in your status line while Claude thinks. Costs nothing, touches nothing.<br>
  Gen Z English · Spanish · Italian · Advanced English — more coming.
</p>

<p align="center">
  Named for <a href="https://en.wikipedia.org/wiki/New_Slang">the Shins song</a>. It'll change your life.
</p>

<p align="center">
  <a href="#see-it">See it</a> ·
  <a href="#install">Install</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="#the-languages">Languages</a> ·
  <a href="#the-trap">The trap</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#whats-inside">Inside</a>
</p>

---

## See it

While you work, the status line at the bottom of Claude Code carries a card. Every six seconds, a new one:

```
~/my-project · Opus 5 · 91% ctx
▸ Italian  attualmente — currently  "attualmente vivo a Roma"  [CORE]
```

```
▸ Spanish  sobremesa — the talk that lingers after a meal  [CORE]
```

```
▸ Advanced English  fulsome — excessive to the point of insincerity  [TRAP]
```

No tokens spent. No answers touched. At **pro** level the cards flip to recall prompts — `recall: in gamba` — and the answer is in your head or it isn't.

Turn on the second channel and Claude also weaves the language into its replies, glossing every new term in a footnote:

```
─────
**cooked** — in trouble, doomed. "we're cooked" = we're screwed.
**magari** — maybe / if only. As an exclamation it means "I wish."
```

## Install

**Full install** (skills + `/new-slang` command + the ambient card engine):

```bash
claude plugin marketplace add SEAD-ai/new-slang
claude plugin install new-slang@new-slang
```

Then in any session:

```
/new-slang setup
```

It asks four things — language, level, channels, density — and offers to wire the status line for you. That's the whole setup. See [INSTALL.md](./INSTALL.md) for the manual status-line wiring, clone installs, and `npx skills add` (conversational skill only — no ambient card), and migrating from the old `slang` plugin.

## How it works

Three independent dials, set once at `/new-slang setup` and changeable any time in plain language ("switch to Spanish", "go pro", "too much, dial it back"):

| Dial | Governs | Values |
|---|---|---|
| **Language** | which deck is live | gen-z · es · it · en-adv |
| **Level** | what content is unlocked, and card format | beginner · intermediate · pro |
| **Density** | how often it appears in Claude's answers | off · seasoned · fluent · saturated |

Two of these are deliberately **not** the same dial. A beginner may want saturated immersion — that's how second languages are actually acquired. A pro may want one term per paragraph in a work context. Level gates *content*; density gates *frequency*; the skill never infers one from the other.

**Levels gate content, not just difficulty.** Beginner Spanish is `la mesa` and the pedir/preguntar trap. Slang — `qué chido`, `daje`, verlan — unlocks at pro. Slang is the top tier of every language, not a separate toy.

## The languages

| Language | Tier 1 teaches | Tier 3 unlocks |
|---|---|---|
| **Gen Z English** | work-safe internet register | the full casual layer |
| **Spanish** | core traps (pedir vs preguntar, el agua) | regional slang, tagged by country — `vale (Spain)`, `no manches (MX)` |
| **Italian** | false friends (`attualmente` ≠ actually, `i parenti` ≠ parents) | Roman and Milanese slang — `daje`, `che sbatti` |
| **Advanced English** | words everyone misuses (`comprise`, `peruse`, `enervate`) | the precise formal register — `specious`, `anodyne`, `lapidary` |

Advanced English is the same product pointed the other way: Gen Z is the informal register textbooks skip, Advanced English is the precise register daily use erodes. `[TRAP]` flags mark words that mean the opposite of what most people think.

**Safety is structural.** Every term carries a register flag, and terms whose caveats need room — `[RISKY]`, `[DECODE ONLY]` — never enter the ambient rotation, where a glance would strip the qualifier. They're defined on explicit lookup, caveat attached, always.

## The trap

The flagship rule, for the Gen Z deck: **Gen Z is not the newest generation.**

| Cohort | Born | Their slang | Can you say it? |
|---|---|---|---|
| **Gen Z** | 1997–2012 | rizz, ate, delulu, it's giving, cooked | **yes** — this is the target |
| **Gen Alpha** | 2013–2024 | 6-7, skibidi, gyatt, fanum tax, sigma | **decode only** — never say these |

Most slang leaking into adult awareness right now is Gen Alpha — elementary schoolers. An adult saying "6-7" isn't behind the times; it's **worse than using no slang at all.** The skill enforces the split and will stop you from deploying a `[DECODE ONLY]` term.

The same generational care applies inward: much of the Gen Z lexicon is AAVE or ballroom-origin, the skill states origins plainly, and **there is no "AAVE mode" and never will be** — generational and institutional registers are in scope, ethnic and regional voices are decode-only, permanently, enforced by the file layout rather than a paragraph of prose.

### The punctuation thing

Still the highest-value content in here, and it involves zero slang. These are semantic, not stylistic:

| You write | You mean | They read |
|---|---|---|
| `Ok.` | acknowledgment | cold, annoyed, conversation over |
| `Thanks.` | thanks | you did something wrong |
| 👍 | got it | dismissive |
| 😂 | laughing | you are over 35 |
| 💀 😭 | morbid / sad | **laughing** |

### Dosage is the whole game

> ❌ "No cap fam, that deck absolutely slaps, it's giving main character energy fr fr 💯🔥"
>
> ✅ "that deck ate"

One move per 1–2 sentences, in the predicate, deadpan. If nobody reacts, you did it right.

## Commands

| Command | Does |
|---|---|
| `/new-slang setup` | The four questions. Also runs automatically on first use. |
| `/new-slang` | Turn on the in-answer channel with your configured language. |
| `/new-slang wtf <term>` | Define, with register flag and what it's commonly mistaken for. |
| `/new-slang decode <text>` | **Inbound translation, including tone.** The most useful one. |
| `/new-slang audit <copy>` | Check brand/marketing copy before it ships — dead terms, register mismatch, origin risk. |
| `/new-slang check <text>` | Vibe check *your* writing. Scored /10, names the tell that outs you. |
| `/new-slang drill` | 5 rapid questions. |
| `/new-slang off` | Back to normal. |

Natural language works everywhere: "what does magari mean", "switch to Spanish", "vibe check this", "decode this Slack message".

## What's inside

```
skills/new-slang/
├── SKILL.md              the router — onboarding, dials, per-language in-answer rules
└── references/gen-z/     the Gen Z authority — mechanics, glossary, syntax patterns, tone decoding, curriculum
newslang/
├── statusline.sh         the ambient card renderer (config-driven, <50ms, no network)
├── languages/            one deck per language: tier ⇥ term ⇥ meaning ⇥ example ⇥ register ⇥ note
├── init.sh               validated config writes → ~/.claude/newslang-config.json
└── test.sh               33 checks — run it after any deck edit
```

Vocabulary is the easy half. What the decks actually encode is **register judgment** — which words are safe where, which are regional, which are traps — and the Gen Z skill teaches ~10 productive syntax patterns (`it's giving ___`, `not me ___ing`) because constructions outlive words by years.

## Contributing

Decks rot — Gen Z fastest, Advanced English barely at all. Marking a term `[DEAD]` is worth more than adding one. New languages welcome: one directory, one TSV, and `newslang/test.sh` must stay green. See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT — see [LICENSE](./LICENSE).

Built at [SEAD](https://sead.ai). Structure inspired by [caveman](https://github.com/JuliusBrussee/caveman). Named for the song that Natalie Portman promised would change your life — this is a smaller claim, but it's checkable.
