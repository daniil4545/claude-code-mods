# claude-code-mods

A personal collection of [Claude Code](https://claude.com/claude-code) mods and skins: copies of other authors' work in one plugin marketplace, to switch on and off from one place and adapt later.

Each copy keeps its author's license and an `UPSTREAM.md` with the source and commit it was taken from.

## Install

```
/plugin marketplace add daniil4545/claude-code-mods
/plugin install readable-layout@daniil-mods
```

Swap in any name from the tables below. Switch a mod off with `/plugin disable <name>@daniil-mods`, back on with `/plugin enable`. Run `/reload-plugins` after a change.

## Mods

| Mod | Folder | What it does | Author | Status |
|---|---|---|---|---|
| readable-layout | [mods/readable-layout](mods/readable-layout) | Your messages and Claude's answers in labeled bordered boxes, short notes as dim lines, a rule with the duration at the end of each turn, coloured bold text | [GarvitNangru](https://github.com/GarvitNangru/claude-code-mods) | In use |
| mermaid-inline | [mods/mermaid-inline](mods/mermaid-inline) | Draws mermaid blocks as box art inline in the transcript | [galElmalah](https://github.com/galElmalah/claude-mods) | In use, colour off by default |
| ui-themes | [mods/ui-themes](mods/ui-themes) | Prompt and reply on coloured padded backgrounds, themed markdown, matching status line, `/ui-theme` picker | [yugal1107](https://github.com/yugal1107/ui-themes) | Tried, replaced by readable-layout |
| agent-monitor | [mods/agent-monitor](mods/agent-monitor) | Plan progress bar above the prompt and a pane with every subagent: model, effort, context, estimated cost, time | [GarvitNangru](https://github.com/GarvitNangru/claude-code-mods) | Not tried |
| prompt-queue | [mods/prompt-queue](mods/prompt-queue) | `/q <text>` holds a prompt while Claude works and sends it when the turn ends; upstream name `claude-queue` | [galElmalah](https://github.com/galElmalah/claude-mods) | Not tried |
| codevibez | [mods/codevibez](mods/codevibez) | Plain English in place of raw tool rows, failures and deletions never softened, a summary line at the end of each turn; `/codevibez` switches to raw rows, `/codevibez story` opens the session story | [leonhong18](https://github.com/leonhong18/codevibez) | In use |
| cc-notebook | [mods/cc-notebook](mods/cc-notebook) | `/iui` draws each answer as a picture with Typst: LaTeX math, diagrams, plots and charts; `/lab` adds Python notebooks. Needs kitty, Ghostty or iTerm2 3.6+; replaces readable-layout's answer boxes while on | [AbdoKnbGit](https://github.com/AbdoKnbGit/cc-notebook) | Trying |

## Skins

Themes for the built-in `/theme` command. They also recolour mods that use theme colours, such as the readable-layout borders.

| Skin | Folder | What it does | Author | Status |
|---|---|---|---|---|
| ember | [skins/ember](skins/ember) | Warm, soft dark theme; theme file only, no code | [GarvitNangru](https://github.com/GarvitNangru/claude-code-mods) | Not tried |
| firelight | [skins/firelight](skins/firelight) | Coal, Smoulder (dark) and Ash (light); also recolours the terminal via OSC codes while selected | [GarvitNangru](https://github.com/GarvitNangru/claude-code-mods) | Not tried |

## Worth a look, not copied

- [tomstagl/cctop](https://github.com/tomstagl/cctop): btop-style live dashboard of context, tokens, cost, limits, tools and agents in a pane beside the session. A Rust app with its own plugin, so it stays a link.

## Notes

- Two mods that both replace `AssistantMessage` rendering and do not call `next` compete: only one of them draws the reply. readable-layout and mermaid-inline work together, because mermaid-inline rewrites the text and passes it on.
- Order matters: mods run in the order of `enabledPlugins` in `~/.claude/settings.json`, and a reinstall moves a mod to the end. Keep `mermaid-inline@daniil-mods` above `readable-layout@daniil-mods`, or diagrams show as source.
- agent-monitor registers a `progress` tool and adds guidance to every request: a few hundred tokens per request plus one tool call per plan step.

## Bigger catalogs

- [karanb192/awesome-claude-code-mods](https://github.com/karanb192/awesome-claude-code-mods): 5,000+ mods with what each one can access
- [wh000wh000/awesome-claude-mods](https://github.com/wh000wh000/awesome-claude-mods): evidence-graded index, rebuilt every 2 hours

## License

The repository's own files are [MIT](LICENSE). Each mod and skin keeps its author's license in its folder.
