# OmniState Skills

Available skills for persistent memory and token optimization.

## Skills

| Skill | Description | When to use |
|-------|-------------|-------------|
| `/cost-setup` | Initialize project memory and git protection | First time in a project |
| `/start-session` | Load session state with minimal tokens | Start of each session |
| `/snapshot-session` | Archive tasks, distill progress, save chunk | End of session |
| `/dashboard-omnistate` | Generate visual HTML dashboard | Any time |

## Required Files

For proper operation, these files should exist in the project root:
- `omnistate.config.json` — Configuration
- `project-summary.md` — Architecture index
- `tasks-history.json` — Task tracking
- `AGENTS.md` — Agent definitions
- `AI_POLICY.md` — AI interaction rules
- `CONTEXT.md` — Project context

All files are auto-created by `/cost-setup` and git-ignored by default.
