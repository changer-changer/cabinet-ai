# Global State Board
# Updated by: each agent after significant action
# Read by: EliteAdvisor every 12h, all agents on startup
# Purpose: team shared memory — "what changed since last time"

## TruthSeeker
| Field | Value |
|-------|-------|
| last_update | — |
| last_action | — |
| files_changed | — |
| key_finding | — |
| confidence_delta | — |
| pending_alert | None |
| new_contradictions | None |

## UserAvatar
| Field | Value |
|-------|-------|
| last_update | — |
| last_action | — |
| files_changed | — |
| key_finding | — |
| pending_alert | None |
| decisions_made | None |

## ExternalConnector
| Field | Value |
|-------|-------|
| last_update | — |
| last_action | — |
| files_changed | — |
| key_result | — |
| pending_alert | None |
| external_contacts | None |

## EliteAdvisor
| Field | Value |
|-------|-------|
| last_update | — |
| last_action | — |
| key_advice | — |
| pending_alert | None |
| red_team_target | None |

## Cross-Agent Observations
| Time | Agent | Event | Severity |
|------|-------|-------|----------|
| — | — | — | — |
