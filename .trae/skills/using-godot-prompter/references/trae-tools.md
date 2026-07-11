# Trae IDE Tool Mapping

Skills use Claude Code tool names as the canonical reference. When you encounter these in a skill, use your Trae equivalent:

| Skill references | Trae IDE equivalent |
|-----------------|---------------------|
| `Read` (file reading) | `Read` |
| `Write` (file creation) | `Write` |
| `Edit` (file editing) | `SearchReplace` |
| `Bash` (run commands) | `RunCommand` |
| `Grep` (search file content) | `Grep` |
| `Glob` (search files by name) | `Glob` |
| `Skill` tool (invoke a skill) | `Skill` — use the skill name without prefix (e.g., `Skill: "state-machine"`) |
| `WebFetch` | `WebFetch` |
| `Task` tool (dispatch subagent) | `Task` — subagent types: `search` (codebase exploration), `general_purpose_task` (multi-step coding) |
| `TodoWrite` (task tracking) | `TodoWrite` |
| `WebSearch` | `WebSearch` |

## Skill Invocation in Trae

Skills are placed in `.trae/skills/<skill-name>/SKILL.md` and are auto-discovered. The AI agent uses the `description` frontmatter to determine when to invoke a skill.

To explicitly invoke a skill, use the `Skill` tool with just the skill name:

```
Skill: "state-machine"
```

Not `godot-prompter:state-machine` — Trae skills don't use namespace prefixes.

## Agent Support

Trae's `Task` tool supports two subagent types:
- `search` — Fast codebase exploration (equivalent to Claude Code's grep/glob exploration agents)
- `general_purpose_task` — Multi-step coding tasks (equivalent to Claude Code's general-purpose subagents)

The 9 GodotPrompter agent definitions (`agents/*.md`) are **not directly installable** in Trae, as Trae doesn't support custom agent registration via markdown files. However, when using `Task` with `general_purpose_task`, include the relevant agent's guidance in the task description.
