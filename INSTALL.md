# Install

## Quickest

```bash
npx skills add SEAD-ai/slang
```

Works with Claude Code, Codex, Cursor, Windsurf, Cline, and other skills-compatible agents.

## Claude Code plugin

```bash
claude plugin marketplace add SEAD-ai/slang
claude plugin install slang@slang
```

## Manual

Clone and copy the skill directory:

```bash
git clone https://github.com/SEAD-ai/slang.git
cp -R slang/skills/slang ~/.claude/skills/
```

You should end up with:

```
~/.claude/skills/slang/
├── SKILL.md
└── references/
    ├── glossary.md
    ├── usage-guide.md
    ├── decoding.md
    └── practice.md
```

## Project-scoped

To give a whole team the skill, commit it into the repo at `.claude/skills/slang/`:

```bash
mkdir -p .claude/skills
cp -R /path/to/slang/skills/slang .claude/skills/
git add .claude/skills/slang && git commit -m "add slang skill"
```

Anyone working in that repo picks it up automatically.

## Verify

Start a session and run:

```
/slang wtf mid
```

You should get a definition with a register flag.

If you get **"No slang command or skill available here"** while `/slang` still appears in the command
palette, you are on a version before the `/slang` command shipped. Update:

```bash
claude plugin update slang@slang
```

Slash commands come from a plugin's `commands/` directory. A plugin's *skills* are namespaced
`plugin:skill` and are normally model-invoked, so a skill alone does not create a bare `/slang`
entry point — which is why the plugin install and the `~/.claude/skills/` install used to behave
differently. Both now route through the same command.

If it still fails, check that `SKILL.md` sits directly inside a directory named `slang` and that the
YAML frontmatter at the top is intact.

## Use

```
/slang                          turn it on
/slang lite                     work-Slack safe tier
/slang decode <text>            translate an inbound message, including tone
/slang audit <copy>             check brand copy before it ships
/slang check <text>             vibe check your own writing
/slang wtf <term>               define one term
/slang drill                    5 rapid questions
/slang off                      back to normal
```

Natural language works too — "slang mode", "what does glazing mean", "vibe check this", "decode this Slack message for me".

## Uninstall

```bash
rm -rf ~/.claude/skills/slang
```

Or, if installed as a plugin:

```bash
claude plugin uninstall slang@slang
```
