# OmniState v1.2.0

**Persistent Memory** and **Token Optimization** system for AI coding sessions.
Supports **opencode**, **Antigravity (Gemini)**, and **Kilocode**.

Inspired by **[Agora-Code](https://github.com/thebnbrkr/agora-code)**. Limits context window ingestion (saving thousands of tokens) by tracking tasks and progress through automated summaries and optimizations.

## 🚀 Key Features

- **Multi-Platform**: Works with opencode, Antigravity, and Kilocode out of the box
- **Visual Dashboard**: Premium HTML dashboard (`/dashboard-omnistate`) with real-time metrics
- **Intelligent Archiving**: Auto-moves completed tasks to keep context lean
- **Context Purge**: Cleans the AI context window on startup to prevent distractions
- **Token Savings**: Estimates and visualizes how many tokens OmniState saves per session

## 📦 Install

One-time global install, available in all projects.

```bash
# Linux / macOS
git clone https://github.com/spupuz/OmniState.git ~/OmniState
cd ~/OmniState && bash update.sh

# Windows (PowerShell)
git clone https://github.com/spupuz/OmniState.git $HOME\OmniState
cd $HOME\OmniState; .\update.ps1
```

### opencode Setup

After installing, add the skills path to your `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["~/.agents/skills"]
  },
  "instructions": ["AGENTS.md", "AI_POLICY.md", "CONTEXT.md", "project-summary.md"]
}
```

Or copy the included `opencode.json` to your project root.

## 🛠️ Usage

| Command | When | What it does |
|---------|------|-------------|
| `/cost-setup` | First time only | Initializes memory files, git protection, cost routing |
| `/start-session` | Start of session | Context purge, loads summaries, shows status |
| `/snapshot-session` | End of session | Archives tasks, distills progress, creates chunk |
| `/dashboard-omnistate` | Any time | Generates visual HTML dashboard with metrics |

### Quick Start

1. **Init**: Run `/cost-setup` in your project
2. **Start**: Run `/start-session` at the beginning of each session
3. **Save**: Run `/snapshot-session` at the end to persist state
4. **View**: Open `omnistate-dashboard.html` in a browser

## 🌐 Platform Compatibility

| Platform | Skills Location | Config |
|----------|----------------|--------|
| **opencode** | `.opencode/skills/` or `~/.agents/skills/` | `opencode.json` |
| **Antigravity** | `~/.gemini/antigravity/plugins/omnistate/` | Knowledge Items |
| **Kilocode** | `.kilo/commands/` | Synced via workflow sync |

## 💻 SSH / Remote Host One-Liner

```bash
export REPO_DIR=~/OmniState; [ -d $REPO_DIR ] || git clone https://github.com/spupuz/OmniState.git $REPO_DIR; cd $REPO_DIR && git pull && bash update.sh
```

---

## 📋 Changelog

### v1.2.0 (current)
- **opencode support**: Native skills in `.opencode/skills/` with `SKILL.md` format
- **Multi-platform**: Unified installer supports opencode, Antigravity, and Kilocode
- **Config**: Added `opencode.json` with `$schema` validation
- **Plugin manifest**: Updated `plugin.json` with `platforms` and `opencode` fields

### v1.1.3
- **DOM optimization**: `DocumentFragment` batch insertion for dashboard (~80% faster)
- **Security**: `textContent` instead of `innerHTML` (XSS prevention)

### v1.1.2
- **Documentation**: Auto-generated AGENTS.md, AI_POLICY.md, CONTEXT.md
- **dist/ restructuring**: Cleaner separation of source and distributed assets

### v1.1.1
- **Background sync**: Auto GitHub self-update and cross-project workflow sync
- **Archiving**: Auto-archive completed tasks
- **Dashboard refresh**: Triggered automatically on snapshot

---

*OmniState - Persistent Memory and Token-Efficient Development.*
