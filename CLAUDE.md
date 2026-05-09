# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cabinet AI is an OpenClaw skill collection that deploys a 4-Agent cognitive evolution system. It is not a traditional software project — it contains no package manager, build system, or test suite. The "code" consists of Markdown skill definitions, Bash install scripts, and Agent persona templates that configure an OpenClaw runtime.

## Repository Structure

```
_meta.json              # Skill metadata: name, version, install script reference
SKILL.md                # Canonical skill spec: 4-Agent architecture, data flows, user_profile.md schema
install.sh              # One-shot deployment script (requires OpenClaw CLI + running Gateway)
skills-lock.json        # Locked dependency: paul-graham-perspective skill

README.md               # Promotional copy (Chinese)
PROMOTION.md            # Outreach strategy and PR templates for awesome-lists

templates/
  truth-seeker/         # TruthSeeker persona
    SOUL.md             # Core belief system + 7-dimension truth-mining framework
    AGENTS.md           # Per-Agent rules + team registry
  user-avatar/          # UserAvatar persona
    SOUL.md             # Autonomous decision-making scope + genius思维模式
    AGENTS.md           # 12h cron auto-action spec + "definition of good" criteria
  elite-advisor/        # EliteAdvisor persona
    SOUL.md             # 8 top-tier thinking models (Musk/Bezos/黄仁勋/张一鸣/Jobs/Buffett/...)
    AGENTS.md           # Supervision triggers + team registry
  external-connector/   # ExternalConnector persona
    SOUL.md             # Omniscience requirements + task-processing pipeline
    AGENTS.md           # External team linking protocols (A2A/MCP)

.agents/skills/         # Vendored dependency skills (e.g. paul-graham-perspective)
.claude/skills/         # Symlink to .agents/skills
.cortex/skills/         # Symlink to .agents/skills
skills/                 # Symlink to .agents/skills
```

## Architecture

### 4-Agent Data Flow

```
User (Walker)
    ↓ direct conversation
TruthSeeker  →  writes  →  user_profile.md
                              ↓
UserAvatar  ←  reads  ───────┘
    ↓ assigns tasks
ExternalConnector  →  external teams / tools / APIs
    ↓ returns results
UserAvatar  →  reports to User

EliteAdvisor  ←  supervises all Agent task streams (cron every 12–18h)
```

### Agent Responsibilities

| Agent | Role | Key Output |
|-------|------|------------|
| **TruthSeeker** | Detective-style truth mining via 7-dimension framework | `user_profile.md` (facts only, no feelings) |
| **UserAvatar** | Autonomous decision-making with user constraints | Goals, task assignments, 12h auto-action reports |
| **EliteAdvisor** | Active supervision + timed mentoring | Quality audits, advice, risk warnings |
| **ExternalConnector** | Execution hub + external team gateway | Task execution reports, A2A/MCP bridging |

### File Conventions (OpenClaw Auto-Load Mechanism)

- **`SOUL.md`** — Loaded automatically per-Agent workspace. Defines core beliefs, tone, and behavioral patterns.
- **`AGENTS.md`** — Loaded automatically per-Agent workspace. Defines per-Agent rules and the team registry (all 4 Agents listed with IDs, capabilities, workspace paths).
- **`user_profile.md`** — **Must be read manually** by UserAvatar on startup and by EliteAdvisor during checks. Lives in the main workspace. Schema is defined in `SKILL.md`; it has a fixed skeleton (chapters 0–11) plus dynamic modules (12–14) that expand based on user type.
- **`TEAM_REGISTRY.md`** — **Must be read manually** by ExternalConnector on startup. Lives in the main workspace.
- **`MEMORY.md`** + `memory/YYYY-MM-DD.md` — Long-term and daily memory files accessible to all Agents.

### Communication Protocols

- Agent-to-Agent / external team: **A2A protocol**
- Agent-to-tool: **MCP protocol**
- Agent-to-human: Natural language

## Common Commands

### Deploy / Install

```bash
# One-shot deployment (requires OpenClaw CLI and a running Gateway)
bash install.sh
```

The script:
1. Checks for `openclaw` CLI and running Gateway.
2. Prompts for team name, user nickname, and platform (Telegram/Discord/other).
3. Modifies `openclaw.json` (backs up to `openclaw.json.bak`).
4. Creates 4 Agent workspaces under `~/.openclaw/workspace-<agent-id>/`.
5. Sets up cron-scheduled auto-actions (UserAvatar every 12h, EliteAdvisor every 12–18h).
6. Requires a Gateway restart to take effect.

### Verify Deployment

```bash
openclaw gateway status   # Ensure Gateway is running
openclaw agent list       # Verify 4 Agents are registered
```

### Update a Dependency Skill

Dependency skills are locked in `skills-lock.json`. To refresh:
1. Update the hash/source in `skills-lock.json`.
2. Re-run the install or pull the skill via OpenClaw CLI.

## Editing Guidelines

- **SOUL.md** files define the "personality" and belief system. Changes here affect how Agents behave in conversation. Keep the tone and core信念 consistent across edits.
- **AGENTS.md** files contain the team registry. If you add/remove an Agent or change workspace paths, update the registry in **all 4** `AGENTS.md` files so every Agent has a consistent view of the team.
- **SKILL.md** is the single source of truth for the full `user_profile.md` schema and the overall architecture. When updating the schema or adding a new dynamic module, update `SKILL.md` first, then propagate to Agent-specific docs.
- **install.sh** is the only executable code. It is idempotent-aware via `set -e`. If adding new platform options or Agent workspaces, mirror the existing pattern of prompting + config injection + backup.

## Triggers / Entry Points

Users activate this skill with phrases like:
- "部署内阁AI"
- "安装团队架构"
- "初始化4-Agent系统"
- "cabinet-ai setup"
- "设置AI团队"

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
