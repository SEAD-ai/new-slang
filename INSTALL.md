# Install

## Full install (recommended)

Skills, the `/new-slang` command, and the ambient status-line card:

```bash
claude plugin marketplace add SEAD-ai/new-slang
claude plugin install new-slang@new-slang
```

Then, in any session:

```
/new-slang setup
```

Four questions — language, level, channels, density — plus a fifth, scope, if you
turn on in-answer immersion. Answers are written to `~/.claude/newslang-config.json`.
The config lives outside the plugin, so it survives updates.

## Wiring the ambient card

`/new-slang setup` offers to do this for you. To do it by hand, add to
`~/.claude/settings.json`:

**Plugin install** — the cache path contains a version hash that changes on
every update, so point at the newest one dynamically:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"$(ls -td ~/.claude/plugins/cache/new-slang/new-slang/*/ | head -1)newslang/statusline.sh\"",
  "refreshInterval": 6
}
```

**Clone install** — a stable path, no indirection:

```json
"statusLine": {
  "type": "command",
  "command": "~/path/to/slang/newslang/statusline.sh",
  "refreshInterval": 6
}
```

`refreshInterval: 6` matches the card rotation — that's what keeps the card
moving while Claude is still working. Heads-up: a custom status line hides some
footer hints, including `esc to interrupt`.

## Making immersion global

The ambient card is global the moment you wire the status line — it runs in every
session, in every project. The **in-answer** channel is not: by default it only
speaks up in chats where New Slang is actually invoked.

To make it global too, answer `global` to the scope question (or run
`/new-slang global`). That is delivered by a `SessionStart` hook.

**Plugin install** — nothing to do. `hooks/hooks.json` ships with the plugin and is
registered on install.

**Clone / skills-only install** — add the hook to `~/.claude/settings.json` yourself:

```json
"hooks": {
  "SessionStart": [
    { "hooks": [ { "type": "command",
      "command": "bash ~/path/to/new-slang/newslang/inanswer.sh" } ] }
  ]
}
```

Two things worth knowing before you switch it on:

- It costs roughly **600–950 tokens of context per session**, every session — the
  language decides where in that range you land, with Japanese highest. The ambient
  card is still free; this channel is not.
- It is on **everywhere** — work repos, screen shares, pairing. `/new-slang off`
  quiets it for the current conversation; `/new-slang off all` turns it off for good.

The hook is silent and free whenever scope is `session`, the in-answer channel is
off, or no config exists — it prints nothing and exits 0.

## Other ways in

**Skills only** (conversational channels, no ambient card, no `/new-slang` command):

```bash
npx skills add SEAD-ai/new-slang
```

Works with Claude Code, Codex, Cursor, Windsurf, Cline, and other
skills-compatible agents.

**Clone** (everything, tracked by git):

```bash
git clone https://github.com/SEAD-ai/new-slang.git
```

Copy `skills/new-slang` into `~/.claude/skills/`, and point
your `statusLine` at `newslang/statusline.sh` as above.

## Update

```bash
claude plugin update new-slang@new-slang   # plugin installs
git pull                             # clone installs
```

Your config survives both. The dynamic statusLine command above survives plugin
updates; a hardcoded cache path does not.

## Verify

```
/new-slang wtf mid
```

You should get a definition with a register flag.

If `/new-slang` is not recognized, you are on the pre-rename `slang` plugin —
migrate (below). The verb is now `/new-slang`; `/slang` survives only as the
namespaced `/new-slang:slang` alias.

To verify the ambient card without waiting for a session restart:

```bash
echo '{}' | bash "$(ls -td ~/.claude/plugins/cache/new-slang/new-slang/*/ | head -1)newslang/statusline.sh"
```

Two lines out — status, then a card — means it's working.

## Use

```
/new-slang setup             re-run onboarding
/new-slang                   turn on the in-answer channel for this chat
/new-slang global            in-answer in every session, no invocation needed
/new-slang here              in-answer only where New Slang is invoked
/new-slang wtf <term>        define one term, with its register flag
/new-slang decode <text>     translate an inbound message, including tone
/new-slang audit <copy>      check copy before it ships
/new-slang check <text>      vibe check your own writing
/new-slang drill             5 rapid questions
/new-slang off               quiet immersion in this chat only
/new-slang off card          stop the ambient card everywhere
/new-slang off all           stop everything, hook included
```

`off` is three different things, so it always tells you which one it did. A bare
`off` leaves the status-line card running.

Plain language works too: "switch to Spanish", "go pro", "what does magari
mean", "decode this Slack message".

## Migrating from the old `slang` plugin

This repo was `SEAD-ai/slang` and the plugin was `slang@slang`. GitHub redirects
the old URLs, but the plugin identity changed, so update by reinstalling:

```bash
claude plugin uninstall slang@slang
claude plugin marketplace remove slang
claude plugin marketplace add SEAD-ai/new-slang
claude plugin install new-slang@new-slang
```

Your `~/.claude/newslang-config.json` survives. If your `statusLine` points at
the old cache path (`.../cache/slang/slang/...`), update it to the dynamic
command above. A manual copy at `~/.claude/skills/slang` is superseded — remove
it so two things don't answer to `/slang`.

## Uninstall

```bash
claude plugin uninstall new-slang@new-slang
rm -f ~/.claude/newslang-config.json
```

And remove the `statusLine` block from `~/.claude/settings.json` — plus the
`SessionStart` hook, if you added one by hand for a clone install.
