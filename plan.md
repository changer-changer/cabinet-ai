# TruthTeam v4.0 — Cognitive Evolution System with State-Aware Archive

## Summary

Build TruthTeam: a 4-Agent cognitive evolution system on OpenClaw where AI agents act as independent cognitive subjects. The v4.0 upgrade introduces a **state-aware user archive** with real-time status boards, **proactive EliteAdvisor supervision** that actively seeks out user activity, a **live contradiction heatmap**, and **cognitive evolution tracking**.

## Core Philosophy

**AI should not believe users.** Users' stated goals are often wrong, self-deceptive, or socially performative. TruthTeam agents mine for truth through adversarial-but-friendly inquiry, maintain a comprehensive evidence-based user archive, and actively supervise each other.

## Goals

1. **Primary**: Deploy 4 agents (TruthSeeker, UserAvatar, EliteAdvisor, ExternalConnector) with state-aware archive and proactive supervision.
2. **Secondary**: Create a live, self-updating user archive where any agent can see "what changed since last time" without reading full history.
3. **Tertiary**: Implement creative enhancements: contradiction heatmap, cognitive evolution tracker, thinking-mode injection, decision time machine, red-team mode.

## Architecture (OpenClaw-Verified)

```
User (Walker)
    ↓ direct conversation (telegram/feishu)
TruthSeeker  →  writes/updates  →  user-archive/
                                      ↓
UserAvatar  ←  reads state-board  ────┘
    ↓ assigns tasks
ExternalConnector  →  external tools/APIs/other agents
    ↓ returns results
UserAvatar  →  reports to User

EliteAdvisor  ←  reads ALL sessions (visibility:all) + state-board
    ↓ proactive outreach
    ↓ thinking-mode injection
    ↓ red-team challenges
```

### Verified OpenClaw Mechanisms

| Mechanism | How It Works | File Location |
|-----------|-------------|---------------|
| Agent config | `openclaw.json` → `agents.list` | `~/.openclaw/openclaw.json` |
| Auto-loaded persona | `boot-md` hook loads `SOUL.md` on session start | `workspace-{agent}/SOUL.md` |
| Auto-loaded rules | `boot-md` hook loads `AGENTS.md` | `workspace-{agent}/AGENTS.md` |
| Cron jobs | Direct JSON in `cron/jobs.json` | `~/.openclaw/cron/jobs.json` |
| Cron state | `cron/jobs-state.json` tracks last run/next run | `~/.openclaw/cron/jobs-state.json` |
| Session logs | `.jsonl` files with full message history | `agents/{id}/sessions/*.jsonl` |
| Session trajectory | `.trajectory.jsonl` with trigger type, workspace | `agents/{id}/sessions/*.trajectory.jsonl` |
| Session index | `sessions.json` maps keys to session IDs | `agents/{id}/sessions/sessions.json` |
| Cross-agent visibility | `tools.sessions.visibility: "all"` | `openclaw.json` |
| Agent-to-agent comms | `openclaw agent --agent <id> --message "..."` | Bash command |
| Channel bindings | `bindings` array in `openclaw.json` | `openclaw.json` |
| Memory system | `memory/dreaming/` + `.dreams/` auto-managed | `workspace/memory/` |

## State-Aware User Archive

### Design Principle: Never Read Full History

Instead of agents reading entire directories on every session, the archive maintains **state files** that summarize "what changed."

```
user-archive/
├── 00-master-profile.md          # Condensed user portrait (fast read)
├── 01-profile/
│   ├── INDEX.md                  # File manifest + last 5 changes
│   ├── 00-identity.md
│   ├── 01-physical-reality.md
│   ├── 02-true-goals.md
│   ├── ...
│   └── 11-pending-questions.md
├── 02-projects/
│   ├── INDEX.md                  # Active/completed/failed project list
│   ├── active/
│   │   └── {project-name}.md
│   └── completed/
├── 03-relationships/
│   └── INDEX.md
├── 04-timeline/
│   └── INDEX.md
├── 05-knowledge/
│   └── INDEX.md
├── 06-life/
│   └── INDEX.md
├── 07-childhood/
│   └── INDEX.md
├── 08-conversations/
│   └── YYYY-MM/
│       └── YYYY-MM-DD-summary.md
├── 09-agent-interactions/
│   ├── INDEX.md
│   ├── truth-seeker.md
│   ├── user-avatar.md
│   ├── elite-advisor.md
│   └── external-connector.md
├── 10-reports/
│   ├── INDEX.md
│   ├── contradictions.md         # LIVE contradiction heatmap
│   ├── elite-advisor/            # Mentoring reports
│   └── user-avatar/              # Action reports
├── 11-decisions/                 # Decision Time Machine
│   └── YYYY-MM/
│       └── {decision-id}.md
└── 99-meta/
    ├── state-board.md            # ← CORE: global status dashboard
    ├── last-updated.md           # Index of latest changes
    ├── evolution-log.md          # Quarterly cognitive evolution
    ├── scan-state.md             # TruthSeeker scan checkpoint
    └── elite-advisor-last-round.md  # Last supervision timestamp
```

### 99-meta/state-board.md (Global Status Dashboard)

Every agent MUST update its own block after significant actions. EliteAdvisor reads ONLY this file to know "what happened since last round."

```markdown
# Global State Board
# Updated by: each agent after significant action
# Read by: EliteAdvisor every 12h, all agents on startup

## TruthSeeker
| Field | Value |
|-------|-------|
| last_update | 2026-05-10T14:00:00Z |
| last_action | Updated 01-profile/02-true-goals.md |
| files_changed | `01-profile/02-true-goals.md` |
| key_finding | User redefined "financial freedom" from 1M to 500K |
| confidence_delta | +0.15 |
| pending_alert | None |
| new_contradictions | C-003 (time planning: 3-day plan for 2-week task) |

## UserAvatar
| Field | Value |
|-------|-------|
| last_update | 2026-05-10T10:30:00Z |
| last_action | Completed tech survey for Project X |
| files_changed | `02-projects/active/project-x.md` |
| key_finding | Recommended tech stack B over A |
| pending_alert | Awaiting user confirmation on stack choice |
| decisions_made | DEC-2026-0510-001 (chose stack B, confidence 0.78) |

## ExternalConnector
...

## Cross-Agent Observations
| Time | Agent | Event | Severity |
|------|-------|-------|----------|
| 09:15 | truth-seeker | User expressed anxiety about Project X | Yellow |
| 11:00 | user-avatar | Auto-action completed without issues | Green |
```

### Directory INDEX.md Pattern

Each subdirectory has an INDEX.md that serves as a "table of contents + changelog":

```markdown
# 01-profile/ Index

## Files
| File | Summary | Last Update | Updated By |
|------|---------|-------------|------------|
| 00-identity.md | Basic identity facts | 2026-05-01 | truth-seeker |
| 02-true-goals.md | Goal redefinition: 1M→500K | 2026-05-10 | truth-seeker |

## Recent Changes (last 5)
1. [2026-05-10 14:00] truth-seeker: Updated 02-true-goals.md
2. [2026-05-08 09:00] truth-seeker: Added 08-turning-points.md
...
```

## Agent Roles (v4.0)

### TruthSeeker — Truth Miner + Archive Maintainer

**Core belief**: User output ≠ facts. Every statement needs verification.

**Key duties**:
- Mine user truth through 7-dimension framework
- Maintain `01-profile/`, `08-conversations/`
- Update `99-meta/state-board.md` after each conversation
- Generate and maintain **live contradiction heatmap** (`10-reports/contradictions.md`)
- Cron every 6h: incremental scan of all agent sessions for new contradictions

### UserAvatar — Autonomous Decision-Maker

**Core belief**: Make the right decisions for the user, not the decisions the user would make.

**Key duties**:
- Read `99-meta/state-board.md` + `00-master-profile.md` before every action
- Maintain `02-projects/`, `09-agent-interactions/user-avatar.md`
- Create **decision snapshots** for major decisions (`11-decisions/`)
- Update `99-meta/state-board.md` after every action
- Cron every 12h (06:00, 18:00): auto-action round

### EliteAdvisor — Proactive Supervisor + Mentor

**Core belief**: The best mentor doesn't wait to be asked. They show up before you know you need them.

**Key duties**:
- **Proactive supervision**: Every 12h, read `state-board.md`, scan recent sessions, identify issues
- **Active outreach**: If issues found, directly message user via `openclaw agent --agent main --message ...`
- **Thinking-mode injection**: Generate temporary thinking lenses for other agents (`INJECTIONS/`)
- **Red-team mode**: Monthly challenge another agent's output
- Maintain `10-reports/elite-advisor/`, update `99-meta/state-board.md`
- **Communicate with TruthSeeker**: Before giving advice on user issues, ask TruthSeeker for background via A2A

### ExternalConnector — Execution Hub

**Core belief**: Be the single point of contact between the team and the external world.

**Key duties**:
- Execute tasks dispatched by UserAvatar
- Maintain external contacts in `03-relationships/`
- Update `09-agent-interactions/external-connector.md`
- Update `99-meta/state-board.md` after task completion

## Creative Enhancements

### 1. Contradiction Heatmap (Live File)

TruthSeeker maintains `10-reports/contradictions.md` as a continuously updated heatmap:

```markdown
# Contradiction Heatmap
last_updated: 2026-05-10T18:00:00Z
next_scan: 2026-05-11T00:00:00Z

## Overview
| Dimension | Count | Avg Severity | 7-day Trend |
|-----------|-------|-------------|-------------|
| Goal authenticity | 3 | 🔴 8.2 | Worsening |
| Ability assessment | 2 | 🟡 5.5 | Stable |
| Time planning | 5 | 🔴 9.1 | Worsening |
| Motivation consistency | 1 | 🟢 3.0 | Improving |

## Active Contradictions
| ID | Dimension | Severity | Confidence | Found | Status |
|----|-----------|----------|------------|-------|--------|
| C-001 | Goal authenticity | 🔴 9.5 | High | 05-01 | **Unresolved** |
| | | | | | Claims financial freedom goal, zero financial actions in 30d |
```

### 2. Cognitive Evolution Tracker (Quarterly)

TruthSeeker generates quarterly reports at `10-reports/evolution/QX-YYYY.md`:

```markdown
# Cognitive Evolution Q2-2026

## Bias Trends
| Bias Type | Q1 Freq | Q2 Freq | Change |
|-----------|---------|---------|--------|
| Overcommitment | 12 | 7 | ↓ 42% |
| Survivorship bias | 3 | 5 | ↑ 67% ⚠️ |
| Confirmation bias | 8 | 4 | ↓ 50% |

## Goal Drift
| Time | Stated Goal | Inferred True Goal | Drift |
|------|-------------|-------------------|-------|
| Apr | Financial freedom | Research-focused | 30% |
| May | Financial freedom | Side-project curious | 10% |
```

### 3. Thinking-Mode Injection

EliteAdvisor can create temporary thinking lenses in other agents' workspaces:

```markdown
<!-- workspace-user-avatar/INJECTIONS/musk-first-principles.md -->
---
inject_until: 2026-05-11T06:00:00Z
scope: project-x-tech-decision
---
## Active Lens: Musk First Principles
Before deciding: Is this constraint a physical law or a convention?
```

### 4. Decision Time Machine

UserAvatar creates decision snapshots before major choices:

```markdown
<!-- 11-decisions/2026-05-10-choose-tech-stack.md -->
---
decision_id: DEC-2026-0510-001
context_hash: a3f7d2
confidence: 0.78
---
## Options Considered
| Option | Expected Value | Risk | Fit |
|--------|---------------|------|-----|
| A | ... | ... | 85% |
| B | ... | ... | 62% |
## Reasoning
1. ...
## Outcome (to be filled)
```

### 5. Red-Team Mode (Monthly)

EliteAdvisor triggers monthly "devil's advocate" challenges:
- Pick one agent's recent output
- Generate attack report from adversarial perspective
- Force agent to defend or fix

## Cron Configuration (Verified OpenClaw Format)

```json
// ~/.openclaw/cron/jobs.json
{
  "version": 1,
  "jobs": [
    {
      "id": "...",
      "name": "tt-truth-seeker-monitor",
      "description": "TruthSeeker 6h scan: read session indices, detect contradictions, update heatmap",
      "enabled": true,
      "schedule": { "kind": "cron", "expr": "0 */6 * * *" },
      "sessionTarget": "isolated",
      "wakeMode": "now",
      "payload": {
        "kind": "agentTurn",
        "message": "【被动监控】读取 99-meta/scan-state.md，扫描agents/*/sessions/sessions.json找新session，读最后20行检测矛盾，更新 contradictions.md 和 state-board.md",
        "lightContext": true
      },
      "delivery": { "mode": "none" }
    },
    {
      "id": "...",
      "name": "tt-elite-advisor-round",
      "description": "EliteAdvisor 12h proactive supervision: read state-board, scan sessions, identify issues, outreach",
      "enabled": true,
      "schedule": { "kind": "cron", "expr": "0 */12 * * *" },
      "sessionTarget": "isolated",
      "wakeMode": "now",
      "payload": {
        "kind": "agentTurn",
        "message": "【定时巡视】1)读99-meta/state-board.md 2)扫描agents/*/sessions找最近12h用户活动 3)读取相关session详情 4)如发现问题，向用户推送建议 5)生成报告写入10-reports/elite-advisor/ 6)更新99-meta/elite-advisor-last-round.md",
        "lightContext": true
      },
      "delivery": { "mode": "none" }
    },
    {
      "id": "...",
      "name": "tt-user-avatar-action",
      "description": "UserAvatar 12h autonomous action",
      "enabled": true,
      "schedule": { "kind": "cron", "expr": "0 6,18 * * *" },
      "sessionTarget": "isolated",
      "wakeMode": "now",
      "payload": {
        "kind": "agentTurn",
        "message": "【自主行动】读取99-meta/state-board.md和00-master-profile.md，执行预设目标相关行动，更新state-board.md",
        "lightContext": true
      },
      "delivery": { "mode": "none" }
    }
  ]
}
```

## Tasks

### Phase 1: State-Aware Archive Foundation

- [ ] Rewrite `install.sh`: add cron JSON injection, fix allowFrom format (array not string), add backup logic
- [ ] Create archive skeleton with all INDEX.md and 99-meta/state-board.md
- [ ] Write `templates/user-archive/99-meta/state-board.md` template
- [ ] Write `templates/user-archive/INDEX.md` template with directory navigation
- [ ] Update TruthSeeker SOUL.md: add state-board maintenance duties, contradiction heatmap spec
- [ ] Update UserAvatar SOUL.md: add decision time machine, state-board duties
- [ ] Update EliteAdvisor SOUL.md: add proactive supervision flow, thinking-mode injection, red-team mode
- [ ] Update ExternalConnector SOUL.md: add state-board duties

### Phase 2: Live Reporting Systems

- [ ] Implement `10-reports/contradictions.md` heatmap template and update spec in TruthSeeker SOUL.md
- [ ] Implement `10-reports/evolution/` quarterly tracker spec
- [ ] Implement `11-decisions/` decision snapshot spec in UserAvatar SOUL.md
- [ ] Implement `workspace-{agent}/INJECTIONS/` spec in EliteAdvisor SOUL.md

### Phase 3: Proactive Supervision Integration

- [ ] Verify EliteAdvisor cron payload message instructs proper session scanning
- [ ] Add EliteAdvisor → TruthSeeker A2A communication spec in both SOUL.md files
- [ ] Add EliteAdvisor → User direct outreach spec (via main agent)
- [ ] Implement red-team mode spec (monthly trigger)

### Phase 4: Verification

- [ ] Test install.sh creates archive skeleton correctly
- [ ] Test cron jobs are injected into `~/.openclaw/cron/jobs.json`
- [ ] Verify all agents' SOUL.md reference state-board.md
- [ ] End-to-end: simulate conversation → state-board update → EliteAdvisor read

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Token budget on session scanning | High | Read only sessions.json indices + last 20 lines, not full files |
| Agents don't maintain state-board | High | SOUL.md mandates it; EliteAdvisor checks for stale state-board |
| Git merge conflicts on archive | Low | Each agent owns different files; state-board uses append-friendly format |
| Cron job JSON syntax errors | High | install.sh validates with node before writing |
| Gateway restart needed for cron | Medium | Document restart requirement clearly |

## Success Criteria

1. `install.sh` creates full archive skeleton + cron jobs in one run.
2. After any agent action, `99-meta/state-board.md` is updated within the same session.
3. EliteAdvisor 12h cron triggers and produces a supervision report without human prompting.
4. TruthSeeker contradiction heatmap shows at least one tracked contradiction with severity score.
5. Any agent can understand full system state by reading only `state-board.md` + relevant `INDEX.md`.
