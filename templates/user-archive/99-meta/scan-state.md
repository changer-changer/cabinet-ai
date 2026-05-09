# Scan State — TruthSeeker Passive Monitor

> **DO NOT MODIFY MANUALLY** — This file is managed by TruthSeeker's passive monitoring cron job.

## Last Scan

| Field | Value |
|-------|-------|
| lastScanAt | {ISO-timestamp} |
| scannedBy | truth-seeker |
| sessionsChecked | {count} |
| newContentFound | {count} |
| contradictionsFound | {count} |

## Session Scan Offsets

> For incremental reading of large session JSONL files.

| Agent ID | Session ID | Last File Size (bytes) | Last Line Count |
|----------|-----------|----------------------|----------------|
| main | {session-id} | {bytes} | {lines} |
| truth-seeker | {session-id} | {bytes} | {lines} |
| user-avatar | {session-id} | {bytes} | {lines} |
| elite-advisor | {session-id} | {bytes} | {lines} |
| external-connector | {session-id} | {bytes} | {lines} |

## Scan History (Last 10)

| Time | Sessions | Contradictions | Notes |
|------|----------|---------------|-------|
| {timestamp} | {count} | {count} | {note} |

## Contradictions Queue

> Contradictions found but not yet resolved in conversation.

| ID | Found At | Source | Contradiction | Priority | Status |
|----|----------|--------|--------------|----------|--------|
| 1 | {timestamp} | {agent-id} | {description} | P0/P1/P2 | open/resolved |
