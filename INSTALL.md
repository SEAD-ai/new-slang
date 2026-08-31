# Install

## Full install (recommended)

Skills, the `/slang` command, and the ambient status-line card:

```bash
claude plugin marketplace add SEAD-ai/slang
claude plugin install slang@slang
```

Then, in any session:

```
/slang setup
```

Four questions — language, level, channels, density — written to
`~/.claude/newslang-config.json`. The config lives outside the plugin, so it
survives updates.

## Wiring the ambient card

`/slang setup` offers to do this for you. To do it by hand, add to
`~/.claude/settings.json`:

**Plugin install** — the cache path contains a version hash that changes on
every update, so point at the newest one dynamically:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"$(ls -td ~/.claude/plugins/cache/slang/slang/*/ | head -1)newslang/statusline.sh\"",
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

## Other ways in

**Skills only** (conversational channels, no ambient card, no `/slang` command):

```bash
npx skills add SEAD-ai/slang
```

Works with Claude Code, Codex, Cursor, Windsurf, Cline, and other
skills-compatible agents.

**Clone** (everything, tracked by git):

```bash
git clone https://github.com/SEAD-ai/slang.git
```

Copy `skills/slang` and `skills/new-slang` into `~/.claude/skills/`, and point
your `statusLine` at `newslang/statusline.sh` as above.

## Update

```bash
claude plugin update slang@slang     # plugin installs
git pull                             # clone installs
```

Your config survives both. The dynamic statusLine command above survives plugin
updates; a hardcoded cache path does not.

## Verify

```
/slang wtf mid
```

You should get a definition with a register flag.

If you get **"No slang command or skill available here"** while `/slang` still
appears in the command palette, you are on a version before the `/slang`
command shipped — run `claude plugin update slang@slang`. (Slash commands come
from a plugin's `commands/` directory; a skill alone doesn't create one.)

To verify the ambient card without waiting for a session restart:

```bash
echo '{}' | bash "$(ls -td ~/.claude/plugins/cache/slang/slang/*/ | head -1)newslang/statusline.sh"
```

Two lines out — status, then a card — means it's working.

## Use

```
/slang setup                    the four questions (re-runs onboarding)
/slang                          turn on the in-answer channel
/slang wtf <term>               define one term
/slang decode <text>            translate an inbound message, including tone
/slang audit <copy>             check brand copy before it ships
/slang check <text>             vibe check your own writing
/slang drill                    5 rapid questions
/slang off                      back to normal
```

Plain language works too: "switch to Spanish", "go pro", "what does magari
mean", "decode this Slack message".

## Uninstall

```bash
claude plugin uninstall slang@slang
rm -f ~/.claude/newslang-config.json
```

And remove the `statusLine` block from `~/.claude/settings.json`.
