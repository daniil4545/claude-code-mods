# claude-code-mods

A personal shortlist of [Claude Code](https://claude.com/claude-code) mods worth a look: plugins built on Claude Code's function hooks that change what you see in the terminal or what the session does.

For now this repository is a catalog with notes. Mods I adapt for my own setup will land here later as a plugin marketplace.

## Mods

| Mod | Source | What it does | License | Status |
|---|---|---|---|---|
| Readable Layout | [GarvitNangru/claude-code-mods](https://github.com/GarvitNangru/claude-code-mods/tree/main/mods/readable-layout) | Your messages and Claude's answers in labeled bordered boxes, short notes as dim lines, a rule with the duration at the end of each turn, coloured bold text | MIT | In use |
| mermaid-inline | [galElmalah/claude-mods](https://github.com/galElmalah/claude-mods) | Draws mermaid blocks as box art inline in the transcript | MIT | In use |
| ui-themes | [yugal1107/ui-themes](https://github.com/yugal1107/ui-themes) | Prompt and reply on coloured padded backgrounds, themed markdown, matching status line, `/ui-theme` picker | MIT | Tried, replaced by Readable Layout |
| Agent Monitor | [GarvitNangru/claude-code-mods](https://github.com/GarvitNangru/claude-code-mods/tree/main/mods/agent-monitor) | Plan progress bar above the prompt and a pane with every subagent: model, effort, context, estimated cost, time | MIT | Not installed |
| cctop | [tomstagl/cctop](https://github.com/tomstagl/cctop) | btop-style live dashboard of context, tokens, cost, limits, tools and agents in a pane beside the session | MIT | Not reviewed |
| claude-queue | [galElmalah/claude-mods](https://github.com/galElmalah/claude-mods) | `/q <text>` holds a prompt while Claude works and sends it when the turn ends | MIT | Not reviewed |

## Skins

Themes for the built-in `/theme` command. They also recolour mods that use theme colours, such as the Readable Layout borders.

| Skin | Source | What it does | License | Status |
|---|---|---|---|---|
| Ember | [GarvitNangru/claude-code-mods](https://github.com/GarvitNangru/claude-code-mods/tree/main/skins/ember) | Warm, soft dark theme; theme file only, no code | MIT | Not installed |
| Firelight | [GarvitNangru/claude-code-mods](https://github.com/GarvitNangru/claude-code-mods/tree/main/skins/firelight) | Coal, Smoulder (dark) and Ash (light); also recolours the terminal via OSC codes while selected | MIT | Not installed |

## Notes

- Two mods that both replace `AssistantMessage` rendering and do not call `next` compete: only one of them draws the reply. Readable Layout and mermaid-inline work together, because mermaid-inline rewrites the text and passes it on.
- Agent Monitor registers a `progress` tool and adds guidance to every request: a few hundred tokens per request plus one tool call per plan step.

## Bigger catalogs

- [karanb192/awesome-claude-code-mods](https://github.com/karanb192/awesome-claude-code-mods): 5,000+ mods with what each one can access
- [wh000wh000/awesome-claude-mods](https://github.com/wh000wh000/awesome-claude-mods): evidence-graded index, rebuilt every 2 hours

## License

[MIT](LICENSE)
