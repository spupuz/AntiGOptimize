# OmniState v1.3.0

**Universal Persistent Memory** for any AI coding tool.
Works with opencode, Antigravity, Kilocode, Roo Code, Claude Code, and more.

Tracks tasks, archives progress, and minimizes context window usage — saving thousands of tokens per session.

## Features

- **Universal**: Works with any AI coding tool (opencode, Antigravity, Kilocode, Roo Code, Claude Code)
- **Auto-Update**: Self-updates from GitHub, syncs skills to all detected platforms
- **Visual Dashboard**: HTML dashboard with real-time metrics and token savings
- **Smart Archiving**: Auto-moves completed tasks to keep context lean
- **Context Purge**: Cleans AI context on startup to prevent distractions
- **Git Protection**: Automatically protects memory files from commits

## Install

```bash
# Clone and install globally
git clone https://github.com/spupuz/OmniState.git ~/OmniState
cd ~/OmniState

# Linux / macOS
bash update.sh

# Windows (PowerShell)
.\update.ps1
```

The installer auto-detects your AI coding tools and installs skills to all of them.

### Manual Setup (opencode)

If auto-detection doesn't work, add to your `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["~/.agents/skills"]
  }
}
```

## Usage

| Command | When | What it does |
|---------|------|-------------|
| `/cost-setup` | First time | Creates memory files, git protection, cost routing |
| `/start-session` | Session start | Context purge, loads summaries, shows status |
| `/snapshot-session` | Session end | Archives tasks, distills progress, creates chunk |
| `/dashboard-omnistate` | Any time | Generates visual HTML dashboard |

### Quick Start

1. **Init**: Run `/cost-setup` in your project
2. **Start**: Run `/start-session` at the beginning of each session
3. **Save**: Run `/snapshot-session` at the end to persist state
4. **View**: Open `omnistate-dashboard.html` in a browser

## Platform Support

| Platform | Auto-detected | Skills path |
|----------|:------------:|-------------|
| opencode | ✅ | `~/.agents/skills/` |
| Antigravity | ✅ | `~/.gemini/antigravity/plugins/omnistate/` |
| Kilocode | ✅ | `~/.kilo/commands/` |
| Roo Code | ✅ | `~/.roo/commands/` |
| Claude Code | ✅ | `~/.claude/skills/` |
| Other | — | Copy `.opencode/skills/*` to your tool's skill directory |

## Project Sync

To sync skills to a specific project:

```bash
# Linux / macOS
bash update.sh /path/to/your/project

# Windows
.\update.ps1 C:\path\to\your\project
```

## Files Created in Your Project

| File | Purpose | Git-ignored |
|------|---------|:-----------:|
| `omnistate.config.json` | Configuration | ✅ |
| `project-summary.md` | Architecture index | ✅ |
| `tasks-history.json` | Active + completed tasks | ✅ |
| `tasks-archive.json` | Old archived tasks | ✅ |
| `AGENTS.md` | Agent definitions | ✅ |
| `AI_POLICY.md` | AI interaction rules | ✅ |
| `CONTEXT.md` | Project context | ✅ |
| `chunks/` | Session snapshots | ✅ |
| `omnistate-dashboard.html` | Visual dashboard | ✅ |

## SSH / Remote Host One-Liner

```bash
export REPO_DIR=~/OmniState; [ -d $REPO_DIR ] || git clone https://github.com/spupuz/OmniState.git $REPO_DIR; cd $REPO_DIR && git pull && bash update.sh
```

---

## Changelog

### v1.3.0 (current)
- **Universal**: Works with any AI coding tool, not just specific platforms
- **Auto-detect**: Installer finds all installed AI tools and syncs to all of them
- **Auto-update**: Skills and scripts auto-update from GitHub daily
- **Renamed config**: `antigravity.config.json` → `omnistate.config.json`
- **Platform-agnostic**: No more hardcoded platform names in skills or templates
- **New config**: `omnistate.config.json` with empty model fields (user fills in their own)

### v1.2.0
- opencode native support with `.opencode/skills/` format
- Multi-platform installer

### v1.1.3
- DOM optimization for dashboard (~80% faster)
- XSS prevention with textContent

### v1.1.2
- Auto-generated documentation
- Cleaner dist/ structure

### v1.1.1
- Background sync and auto-update
- Task auto-archiving
- Dashboard auto-refresh

---

*OmniState — Persistent Memory for Any AI.*
