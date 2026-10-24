# Upstream

- Source: https://github.com/galElmalah/claude-mods/tree/b1c6e49/claude-mermaid
- Commit: `b1c6e49`
- License: MIT, see [LICENSE](LICENSE)

Local changes:

- Renamed to mermaid-inline; colour off by default, because Claude Code 2.1.290 refuses ANSI escapes in a rewritten AssistantMessage text.
- Adapts to the window: a left-to-right flowchart too wide for the terminal is drawn top-down; a diagram that fits no layout stays as source instead of cut art.
- The margin covers readable-layout's answer frame, so the art no longer wraps inside it.
