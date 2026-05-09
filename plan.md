<!-- /autoplan restore point: /home/cuizhixing/.gstack/projects/changer-changer-cabinet-ai/master-autoplan-restore-20260509-113814.md -->
# TruthTeam Multi-Agent System — Implementation Plan

## Summary

Build TruthTeam: a 4-Agent cognitive evolution system where AI agents act as independent cognitive subjects that do not blindly trust user input. Instead, they actively mine for truth, detect self-deception, and align with the user's real goals rather than stated wishes.

## Goals

1. **Primary**: Deploy a 4-Agent team (TruthSeeker, UserAvatar, EliteAdvisor, ExternalConnector) within an OpenClaw runtime.
2. **Secondary**: Create a comprehensive user archive (multi-file knowledge base) that persists across sessions and agents.
3. **Tertiary**: Implement passive monitoring, cron-driven supervision, and agent-to-agent communication protocols.

## Scope

### In Scope

- **Agent Personas**: SOUL.md + AGENTS.md for all 4 agents with distinct roles and belief systems.
- **User Archive System**: Expanded from single `user_profile.md` to a structured multi-file knowledge base with indexing, Git versioning, and usage guidelines.
- **TruthSeeker Passive Monitoring**: Cron-triggered scan (every 6h) with incremental reads, contradiction detection, and structured reporting.
- **EliteAdvisor Supervision**: Cron-triggered reviews (every 12h) with mentor reports, risk assessment, and multi-model thinking injection.
- **UserAvatar Autonomy**: Goal-setting, task assignment, and 12h auto-action reports.
- **ExternalConnector Execution Hub**: Task dispatch, external API/tool integration (A2A/MCP), and result aggregation.
- **Agent Communication Protocol**: Explicit inter-agent messaging rules in each SOUL.md.
- **Installation Script**: One-shot `install.sh` for full deployment.
- **Git Versioning**: Automatic commits for archive changes with agent-attributed commit messages.

### Out of Scope (Deferred)

- Real-time group chat monitoring (requires platform-specific webhooks/bots).
- External database backend (archive lives in Git-tracked Markdown files only).
- UI dashboard for archive browsing.
- Multi-user / team support (single-user MVP).
- Third-party service integrations beyond A2A/MCP (e.g., Slack, Notion, calendar APIs).

## Architecture

```
User (Walker)
    ↓ direct conversation
TruthSeeker  →  writes  →  user_archive/
                              ↓
UserAvatar  ←  reads  ───────┘
    ↓ assigns tasks
ExternalConnector  →  external teams / tools / APIs
    ↓ returns results
UserAvatar  →  reports to User

EliteAdvisor  ←  supervises all Agent task streams (cron every 12h)
```

### Agent Responsibilities

| Agent | Role | Key Output | Cron |
|-------|------|------------|------|
| **TruthSeeker** | Truth mining + passive monitoring | `user_archive/`, contradiction reports | 6h scan |
| **UserAvatar** | Autonomous decision-making | Goals, task assignments, action reports | 12h auto-action |
| **EliteAdvisor** | Active supervision + mentoring | Quality audits, mentor reports, risk warnings | 12h review |
| **ExternalConnector** | Execution hub + gateway | Task execution reports, A2A/MCP bridging | On-demand |

### User Archive Structure

```
user_archive/
  INDEX.md              # Directory structure, file descriptions, update frequencies
  user_profile.md       # Core 7-dimension truth-mining summary
  projects/             # Ongoing, completed, failed projects
  relationships/        # Key relationships (supporters, drainers, neutrals)
  timeline/             # Life milestones, decisions, turning points
  knowledge/            # Skills, interests, learning records
  life/                 # Daily patterns, habits, preferences
  childhood/            # Background, formative events
  conversations/        # Summary of important conversations
  agent_interactions/   # Per-agent interaction summaries
  .git/                 # Version control for all archive files
```

### Communication Protocol

- Agent-to-Agent: A2A protocol (natural language over structured channels)
- Agent-to-Tool: MCP protocol
- Agent-to-Human: Natural language
- Each agent's SOUL.md must explicitly reference the archive and other agents by name.

## Tasks

### Phase 1: Foundation (Week 1)

- [ ] **T1.1** Finalize all 4 SOUL.md files with truth-seeking philosophy, archive awareness, and inter-agent communication rules.
- [ ] **T1.2** Finalize all 4 AGENTS.md files with team registry (consistent across all agents).
- [ ] **T1.3** Write `SKILL.md` update: full user archive schema, architecture, and data flows.
- [ ] **T1.4** Create `user_archive/` directory skeleton + `INDEX.md` with usage guide.
- [ ] **T1.5** Update `install.sh` to create agent workspaces and archive directory.

### Phase 2: Monitoring & Supervision (Week 2)

- [ ] **T2.1** Implement TruthSeeker passive monitoring spec:
  - Incremental read logic (timestamp-based)
  - Contradiction detection heuristics
  - Structured contradiction report format
  - Cron configuration (6h)
- [ ] **T2.2** Implement EliteAdvisor supervision spec:
  - Read user archive + agent action logs
  - Multi-model thinking injection (Musk/Bezos/黄仁勋/张一鸣/Jobs/Buffett/Thiel/Munger)
  - Mentor report format
  - Supervision report format
  - Cron configuration (12h)
- [ ] **T2.3** Implement UserAvatar auto-action spec:
  - Goal-setting criteria
  - Task assignment logic
  - 12h auto-action report format
  - Cron configuration (12h)

### Phase 3: Integration & Polish (Week 3)

- [ ] **T3.1** Integrate ExternalConnector execution pipeline (task → dispatch → result → report).
- [ ] **T3.2** Add Git auto-commit hooks for archive changes (agent-attributed commits).
- [ ] **T3.3** Write archive usage guide (`INDEX.md` expanded with examples).
- [ ] **T3.4** End-to-end test: simulate a full cycle (user input → TruthSeeker → archive → EliteAdvisor → UserAvatar → ExternalConnector → result).
- [ ] **T3.5** Polish `install.sh`, add error handling and idempotency checks.

### Phase 4: Deployment (Week 4)

- [ ] **T4.1** Test `install.sh` on a clean environment.
- [ ] **T4.2** Update README.md with setup instructions.
- [ ] **T4.3** Update PROMOTION.md with competition submission copy.
- [ ] **T4.4** Tag release version in `_meta.json`.

## Timeline

| Week | Milestone |
|------|-----------|
| Week 1 | All personas defined, archive skeleton created, SKILL.md updated |
| Week 2 | Monitoring and supervision specs implemented |
| Week 3 | Integration complete, end-to-end test passes |
| Week 4 | Deployment ready, documentation complete |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Token budget overflow on archive reads | High | Incremental reads, summaries, structured indexing |
| Agent conflicts or loops | Medium | Explicit communication rules, EliteAdvisor arbitration |
| Git merge conflicts on archive | Low | Auto-commit strategy, single-writer per file |
| Platform limitations (OpenClaw) | Medium | Validate against OpenClaw Gateway API before implementation |

## Success Criteria

1. `install.sh` runs end-to-end without errors on a fresh machine.
2. All 4 agents can be listed via `openclaw agent list` after install.
3. TruthSeeker produces a contradiction report after 6h cron trigger.
4. EliteAdvisor produces a mentor report after 12h cron trigger.
5. Archive files are Git-tracked with agent-attributed commits.
6. Any agent can read the archive and understand the user's full context.

---

## /autoplan CEO Review Findings

### CEO Dual Voices — Consensus Table

| Dimension | Claude Subagent | Codex | Consensus |
|-----------|----------------|-------|-----------|
| 1. Premises valid? | 3 CRITICAL flaws in core premises | N/A (unavailable) | Claude ONLY — flagged |
| 2. Right problem to solve? | Misdiagnosed — adversarial framing alienates users | N/A | Claude ONLY — flagged |
| 3. Scope calibration correct? | 4-week timeline unrealistic; archive overbuilt | N/A | Claude ONLY — flagged |
| 4. Alternatives sufficiently explored? | No 1-agent baseline; no memory framework benchmark | N/A | Claude ONLY — flagged |
| 5. Competitive/market risks covered? | Underestimates OpenAI Operator, Claude projects | N/A | Claude ONLY — flagged |
| 6. 6-month trajectory sound? | Archive becomes garbage; cron spams; no learning loop | N/A | Claude ONLY — flagged |

**Source: subagent-only** (Codex unavailable due to API 404)

### Top 12 Findings from Claude Subagent

| # | Finding | Severity | Classification |
|---|---------|----------|---------------|
| 1 | Misdiagnosed problem: adversarial framing alienates users | CRITICAL | User Challenge |
| 2 | "AI knows true goals" is epistemically arrogant | CRITICAL | User Challenge |
| 3 | 6-month regret: garbage archive, spammy cron, no learning | CRITICAL | User Challenge |
| 4 | Simpler alternatives (1-agent, memory frameworks) never analyzed | HIGH | Taste Decision |
| 5 | Competitive risk: slower than Operator, Claude projects, etc. | HIGH | Taste Decision |
| 6 | Multi-file Markdown archive is unworkable (concurrency, tokens, drift) | HIGH | User Challenge |
| 7 | A2A/MCP protocols are placeholder text with no spec | HIGH | User Challenge |
| 8 | EliteAdvisor has no enforcement power (decorative supervisor) | HIGH | User Challenge |
| 9 | Passive monitoring spec is technically incoherent | HIGH | User Challenge |
| 10 | Install script hardcodes Telegram ID, references wrong agents | MEDIUM | Mechanical |
| 11 | "Cognitive evolution" is just Markdown logging | MEDIUM | User Challenge |
| 12 | 4-week timeline is fantasy for 50+ undefined sub-tasks | MEDIUM | Taste Decision |

### Decision Audit Trail (CEO Phase)

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|---------------|-----------|-----------|----------|
| 1 | CEO | Accept Premise 1 (AI should not believe users) with caveat: reframe to transparency | User Challenge | P6 | Subagent says adversarial framing is destructive; but user's core insight (AI sycophancy) is valid | Adversarial tone |
| 2 | CEO | Keep 4-Agent architecture for competition; benchmark 1-agent post-competition | Taste | P5 | Subagent says 1-agent might achieve 80%; but 4-Agent is the competition differentiator | 1-agent baseline for MVP |
| 3 | CEO | Collapse archive from 10+ subdirs to 3 core files + index; defer childhood/timeline | User Challenge | P2 | Subagent says multi-file Markdown is unworkable; this keeps MVP functional | Full 10-subdir archive |
| 4 | CEO | Remove passive monitoring from MVP; replace with explicit user-triggered review | User Challenge | P5 | Subagent says spec is technically incoherent with OpenClaw APIs | 6h cron passive scan |
| 5 | CEO | Define real A2A message schema (JSON over files) or admit single-agent-with-personas | User Challenge | P5 | Subagent says current "protocol" is README, not engineering | Placeholder A2A/MCP |
| 6 | CEO | Give EliteAdvisor hard approval gates for high-stakes actions | User Challenge | P1 | Subagent says decorative supervisor has no value; hard gates make it real | Soft advice-only supervision |
| 7 | CEO | Fix install.sh hardcoded IDs and wrong agent bindings | Mechanical | P5 | Obvious bug; no alternatives | — |
| 8 | CEO | Remove "cognitive evolution" claim unless real feedback loop implemented | User Challenge | P5 | Subagent says accumulation ≠ evolution; honesty over hype | Keep marketing claim |
| 9 | CEO | Redefine Week 1: 1 agent, 1 feature, 1 test | Taste | P3 | Subagent says 4-week timeline is fantasy; this is pragmatic | Original 4-week timeline |


---

## /autoplan Design Review Findings

### Design Dual Voices — Consensus Table

| Dimension | Claude Subagent | Codex | Consensus |
|-----------|----------------|-------|-----------|
| 1. Information hierarchy serves user? | 3 issues (1 CRITICAL) | N/A | Claude ONLY — flagged |
| 2. Missing states specified? | 5 issues (2 CRITICAL) | N/A | Claude ONLY — flagged |
| 3. User journey / emotional arc sound? | 3 issues (1 CRITICAL) | N/A | Claude ONLY — flagged |
| 4. Specific UI decisions vs generic? | 4 issues (1 CRITICAL) | N/A | Claude ONLY — flagged |
| 5. Design decisions that will haunt implementer? | 5 issues (2 CRITICAL) | N/A | Claude ONLY — flagged |

**Source: subagent-only** (Codex unavailable)

### Top 20 Design Findings

| # | Finding | Severity | Category |
|---|---------|----------|----------|
| 1 | No onboarding after install — user dropped into interrogation | CRITICAL | Information Hierarchy |
| 2 | Archive schema conflict: CEO decision vs SOUL.md vs install.sh | HIGH | Information Hierarchy |
| 3 | README opens with insult despite CEO flag | HIGH | Information Hierarchy |
| 4 | No first-contact template or consent gate for TruthSeeker | CRITICAL | Missing States |
| 5 | No "empty archive" state — Agents act on `...` templates | HIGH | Missing States |
| 6 | No Agent-unavailable / Gateway-down error states | HIGH | Missing States |
| 7 | Contradiction reports written to file but user notification unspecified | MEDIUM | Missing States |
| 8 | Binary "truth exhausted" state with no gradation | MEDIUM | Missing States |
| 9 | Emotional arc = install → interrogation → surveillance, no trust build | CRITICAL | User Journey |
| 10 | 12h reports have no tone spec, no opt-out, no feedback loop | HIGH | User Journey |
| 11 | EliteAdvisor 9:00 check is hardcoded, no timezone or scheduling UI | MEDIUM | User Journey |
| 12 | A2A/MCP protocols are named but never defined | CRITICAL | Specificity |
| 13 | 7-dimension framework has no trigger map or interaction pattern | HIGH | Specificity |
| 14 | $100 threshold is arbitrary, hardcoded, not user-configurable | MEDIUM | Specificity |
| 15 | install.sh bindings include 5 ghost agents | MEDIUM | Specificity |
| 16 | Git auto-commit has no conflict resolution or locking strategy | HIGH | Haunting Decision |
| 17 | Passive monitoring was removed by CEO but still in SOUL.md | CRITICAL | Haunting Decision |
| 18 | `openclaw agent --message` semantics (sync vs async) undefined | HIGH | Haunting Decision |
| 19 | No user interaction model for 4-bot setup | HIGH | Haunting Decision |
| 20 | TEAM_REGISTRY.md path ambiguous across Agents | MEDIUM | Haunting Decision |

### Decision Audit Trail (Design Phase)

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|---------------|-----------|-----------|----------|
| 1 | Design | Add onboarding stage to install.sh with Agent role cards | Mechanical | P1 | Critical gap; no alternatives | — |
| 2 | Design | Define FIRST_CONTACT.md template with consent gate | Mechanical | P1 | Critical gap; no alternatives | — |
| 3 | Design | Add "archive readiness" check to every Agent startup | Mechanical | P1 | Critical gap; no alternatives | — |
| 4 | Design | Add error-state templates for Agent-unavailable scenarios | Mechanical | P1 | Critical gap; no alternatives | — |
| 5 | Design | Define contradiction notification template + channel | Taste | P5 | Completeness vs effort tradeoff | — |
| 6 | Design | Replace binary truth state with progress indicator | Mechanical | P5 | Obvious improvement | — |
| 7 | Design | Add trust-building phase before investigation phase | Taste | P1 | Subagent strongly recommends; changes core UX | Direct interrogation |
| 8 | Design | Add report preferences to user profile | Mechanical | P1 | Critical for user control | — |
| 9 | Design | Make EliteAdvisor scheduling user-configurable | Mechanical | P5 | Obvious improvement | — |
| 10 | Design | Define A2A JSON schema or remove protocol claims | User Challenge | P5 | CEO also flagged; architecture decision | Placeholder protocols |
| 11 | Design | Add dimension trigger map to TruthSeeker AGENTS.md | Mechanical | P5 | Obvious improvement | — |
| 12 | Design | Move $100 threshold to user profile template | Mechanical | P5 | Obvious improvement | — |
| 13 | Design | Remove ghost agents from install.sh bindings | Mechanical | P5 | Obvious bug fix | — |
| 14 | Design | Add GIT_STRATEGY.md with locking convention | Mechanical | P1 | Critical for concurrent writes | — |
| 15 | Design | Remove passive monitoring from SOUL.md for MVP | User Challenge | P5 | CEO also decided this; implementation lag | Keep in SOUL.md |
| 16 | Design | Document openclaw agent --message semantics in SKILL.md | Mechanical | P5 | Critical for implementation | — |
| 17 | Design | Add User Interaction Model section to SKILL.md | Mechanical | P1 | Critical for 4-bot UX | — |
| 18 | Design | Define shared workspace path for TEAM_REGISTRY.md | Mechanical | P5 | Critical for Agent coordination | — |

---

## /autoplan Eng Review Findings

### Eng Dual Voices — Consensus Table

| Dimension | Claude Subagent | Codex | Consensus |
|-----------|----------------|-------|-----------|
| 1. Architecture sound? | 5 CRITICAL, 6 HIGH flaws | N/A | Claude ONLY — flagged |
| 2. Test coverage sufficient? | 0% automated coverage | N/A | Claude ONLY — flagged |
| 3. Performance risks addressed? | Cron simultaneity, token overflow flagged | N/A | Claude ONLY — flagged |
| 4. Security threats covered? | Hardcoded ID, credential exposure, binding overwrite | N/A | Claude ONLY — flagged |
| 5. Error paths handled? | No cleanup trap, no idempotency, weak verification | N/A | Claude ONLY — flagged |
| 6. Deployment risk manageable? | Path mismatch, no backup, no rollback | N/A | Claude ONLY — flagged |

**Source: subagent-only** (Codex unavailable)

### Top 18 Eng Findings

| # | Finding | Severity | Category |
|---|---------|----------|----------|
| 1 | Hardcoded Telegram ID (8434568597) | CRITICAL | Security |
| 2 | Bindings overwrite destroys existing config | CRITICAL | Data Loss |
| 3 | No openclaw.json backup despite claims | CRITICAL | Reliability |
| 4 | Path mismatch: install.sh vs SOUL.md | CRITICAL | Architecture |
| 5 | `set -e` without cleanup trap | CRITICAL | Reliability |
| 6 | No input sanitization for sed templates | HIGH | Security |
| 7 | Cron jobs fire simultaneously, no jitter | HIGH | Reliability |
| 8 | A2A protocol is placeholder fiction | HIGH | Architecture |
| 9 | EliteAdvisor has no enforcement power | HIGH | Architecture |
| 10 | No Git locking for concurrent writes | HIGH | Reliability |
| 11 | Session JSONL scan is technically incoherent | HIGH | Architecture |
| 12 | No idempotency checks | MEDIUM | Reliability |
| 13 | Bot tokens in plaintext shell history | MEDIUM | Security |
| 14 | Team registry duplicated, will drift | MEDIUM | Maintainability |
| 15 | Zero automated tests | MEDIUM | Quality |
| 16 | `verify_installation()` is weak | MEDIUM | Quality |
| 17 | Inconsistent cron documentation | LOW | Documentation |
| 18 | Skill hash unverified | LOW | Security |

### Decision Audit Trail (Eng Phase)

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|---------------|-----------|-----------|----------|
| 1 | Eng | Replace hardcoded Telegram ID with interactive prompt | Mechanical | P1 | Security vulnerability; no alternatives | — |
| 2 | Eng | Merge bindings instead of overwriting | Mechanical | P1 | Data loss risk; no alternatives | — |
| 3 | Eng | Add openclaw.json backup at start of install.sh | Mechanical | P1 | Reliability; no alternatives | — |
| 4 | Eng | Align install.sh paths with SOUL.md (user-archive/ subdir) | Mechanical | P1 | Architecture broken; no alternatives | — |
| 5 | Eng | Add trap cleanup handler for ERR/EXIT | Mechanical | P1 | Reliability; no alternatives | — |
| 6 | Eng | Escape sed metacharacters in template rendering | Mechanical | P1 | Security; no alternatives | — |
| 7 | Eng | Add randomized jitter to cron schedules | Mechanical | P1 | Performance; no alternatives | — |
| 8 | Eng | Define A2A JSON schema or remove claims | User Challenge | P5 | Architecture fiction; both CEO and Design flagged | Placeholder A2A |
| 9 | Eng | Implement hard approval gates for EliteAdvisor | User Challenge | P1 | Decorative supervision has no value; need enforcement | Advice-only supervision |
| 10 | Eng | Add git commit retry with locking | Mechanical | P1 | Concurrency; no alternatives | — |
| 11 | Eng | Remove/fix session JSONL scan spec | User Challenge | P5 | Technically incoherent; CEO also flagged removal | Keep as-is |
| 12 | Eng | Add idempotency checks for all install steps | Mechanical | P1 | Reliability; no alternatives | — |
| 13 | Eng | Use `read -s` for bot token input | Mechanical | P1 | Security; no alternatives | — |
| 14 | Eng | Generate AGENTS.md from single registry source | Taste | P5 | DRY principle; medium effort | Manual updates |
| 15 | Eng | Add ShellCheck + dry-run mode + schema validation | Taste | P1 | Zero tests is unacceptable; boil the lake | No tests |
| 16 | Eng | Strengthen verify_installation with real health checks | Mechanical | P5 | Quality; no alternatives | — |
| 17 | Eng | Align all cron docs to consistent schedule constants | Mechanical | P5 | Documentation fix; no alternatives | — |
| 18 | Eng | Add skill hash verification in install.sh | Taste | P5 | Supply chain security; low effort | Skip hash check |


---

## /autoplan DX Review Findings

### DX Dual Voices — Consensus Table

| Dimension | Claude Subagent | Codex | Consensus |
|-----------|----------------|-------|-----------|
| 1. Getting started < 5 min? | No — 2-4h realistic TTHW | N/A | Claude ONLY — flagged |
| 2. API/CLI naming guessable? | Ghost agents, path mismatches | N/A | Claude ONLY — flagged |
| 3. Error messages actionable? | `set -e` without trap, no problem/cause/fix | N/A | Claude ONLY — flagged |
| 4. Docs findable & complete? | Dangerous curl-pipe-bash, no working examples | N/A | Claude ONLY — flagged |
| 5. Upgrade path safe? | No idempotency, overwrites config | N/A | Claude ONLY — flagged |
| 6. Dev environment friction-free? | 4 bots required, no dry-run, no --help | N/A | Claude ONLY — flagged |

**Source: subagent-only** (Codex unavailable)

### DX Scorecard

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| 1. First Run Experience | 1/10 | Hostile README, hardcoded ID breaks install, no onboarding, 4 bots required |
| 2. API/CLI Consistency | 3/10 | Ghost agents in bindings, path mismatches, mixed CN/EN, undefined semantics |
| 3. Error Handling | 1/10 | `set -e` without trap, no problem/cause/fix/docs pattern, silent sed failures |
| 4. Documentation Quality | 4/10 | Good architecture diagrams but dangerous curl-pipe-bash, no working examples |
| 5. Escape Hatches | 2/10 | Almost nothing is configurable at runtime; must edit templates and reinstall |
| 6. Progressive Disclosure | 1/10 | No basic mode, no dry-run, no --help, immediate 4-bot demand |
| 7. Feedback Loops | 2/10 | No immediate feedback after install; value requires waiting 6-12h for cron |
| 8. Community/Onboarding | 1/10 | No Discord/forum link, no issue templates, no contributing guide |

**Overall DX Score: 1.9/10** | **TTHW: 2-4 hours** | **Target TTHW: 10 minutes**

### Top DX Findings

| # | Finding | Severity |
|---|---------|----------|
| C1 | Hardcoded Telegram ID `8434568597` in all 4 `allowFrom` fields | CRITICAL |
| C2 | Bindings overwrite destroys existing config (includes 5 ghost agents) | CRITICAL |
| C3 | No `openclaw.json` backup despite claims | CRITICAL |
| C4 | Path mismatch: install.sh creates `user_profile.md` but SOUL.md expects `user-archive/` | CRITICAL |
| C5 | `set -e` without cleanup trap | CRITICAL |
| C6 | No input sanitization for sed templates | CRITICAL |
| C7 | Passive monitoring removed by CEO decision but still in SOUL.md and install.sh | CRITICAL |
| C8 | A2A/MCP protocols are placeholder fiction with no spec | CRITICAL |
| C9 | No onboarding — user dropped into interrogation | CRITICAL |
| C10 | README opens with insult despite design review flag | CRITICAL |
| H1 | Cron jobs fire simultaneously with no jitter | HIGH |
| H2 | No idempotency checks — running twice breaks everything | HIGH |
| H3 | `verify_installation()` is weak — no health checks | HIGH |
| H4 | Team registry duplicated across 4 AGENTS.md files — will drift | HIGH |
| H5 | User profile template is 900+ lines — exceeds context window | HIGH |
| H6 | No "empty archive" state — Agents act on `...` templates | HIGH |
| H7 | `openclaw agent --message` semantics undefined | HIGH |
| H8 | EliteAdvisor has no enforcement power (decorative supervisor) | HIGH |
| H9 | No Git locking for concurrent writes | HIGH |
| H10 | No dry-run mode for install.sh | HIGH |

### Decision Audit Trail (DX Phase)

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|---------------|-----------|-----------|----------|
| 1 | DX | Fix hardcoded Telegram ID (prompt user) | Mechanical | P1 | Security vulnerability; unusable for anyone except author | — |
| 2 | DX | Merge bindings instead of overwrite | Mechanical | P1 | Data loss; no alternatives | — |
| 3 | DX | Add openclaw.json backup | Mechanical | P1 | Reliability; no alternatives | — |
| 4 | DX | Align paths (user-archive/ subdir) | Mechanical | P1 | Broken deployment; no alternatives | — |
| 5 | DX | Add trap cleanup for ERR/EXIT | Mechanical | P1 | Reliability; no alternatives | — |
| 6 | DX | Escape sed metacharacters | Mechanical | P1 | Security; no alternatives | — |
| 7 | DX | Add randomized cron jitter | Mechanical | P1 | Performance; no alternatives | — |
| 8 | DX | Remove passive monitoring from SOUL.md for MVP | User Challenge | P5 | Technically incoherent; CEO also decided this | Keep in SOUL.md |
| 9 | DX | Define A2A JSON schema or remove claims | User Challenge | P5 | Placeholder fiction; CEO and Design also flagged | Keep placeholder |
| 10 | DX | Add onboarding with consent gate | Mechanical | P1 | Critical UX gap; no alternatives | — |
| 11 | DX | Rewrite README opening | Mechanical | P1 | Alienating tone; no alternatives | — |
| 12 | DX | Add idempotency checks | Mechanical | P1 | Reliability; no alternatives | — |
| 13 | DX | Add `read -s` for bot tokens | Mechanical | P1 | Security; no alternatives | — |
| 14 | DX | Add `--dry-run` and `--help` flags | Mechanical | P1 | DX standard; no alternatives | — |
| 15 | DX | Support environment variables for CI | Taste | P5 | Automation use case; medium effort | Interactive only |

---

## Cross-Phase Themes

**Theme 1: A2A/MCP Protocol Fiction** — flagged in CEO (#7), Design (#12), Eng (#8), DX (#C8). Four independent reviews all identified that the A2A/MCP protocol claims are placeholder text with no actual specification. **High-confidence signal.**

**Theme 2: Passive Monitoring Incoherence** — flagged in CEO (#9), Design (#17), Eng (#11), DX (#C7). All four phases independently concluded that the session JSONL scan spec is technically broken or should be removed from MVP. **High-confidence signal.**

**Theme 3: Hardcoded Security Vulnerabilities** — flagged in CEO (#10), Eng (#1, #2, #3), DX (#C1-C6). Three phases identified the hardcoded Telegram ID, binding overwrite, missing backup, and sed sanitization as critical security/reliability issues. **High-confidence signal.**

**Theme 4: EliteAdvisor Decorative Supervision** — flagged in CEO (#8), Eng (#9), DX (#H8). Three phases identified that EliteAdvisor has no enforcement power, making the "active supervision" claim marketing fiction. **High-confidence signal.**

**Theme 5: Archive Path Mismatch** — flagged in CEO (#6), Design (#2), Eng (#4), DX (#C4). All four phases identified that install.sh, SOUL.md, and SKILL.md disagree on where archive files live. **High-confidence signal.**

**Theme 6: Adversarial Framing Alienates Users** — flagged in CEO (#1, #3), Design (#3, #9), DX (#C9, #C10). Three phases identified that the "人类太蠢了" framing and interrogation-first UX are destructive to user trust. **High-confidence signal.**

