# 99-meta/ Index
# Purpose: system-level metadata for the archive

## Files
| File | Purpose | Updated By | Frequency |
|------|---------|------------|-----------|
| state-board.md | Global status dashboard (team shared memory) | All agents | Every significant action |
| last-updated.md | Index of latest changes across archive | Any agent | On change |
| scan-state.md | TruthSeeker scan checkpoint | TruthSeeker | Every 6h cron |
| evolution-log.md | Quarterly cognitive evolution tracking | TruthSeeker | Quarterly |
| elite-advisor-last-round.md | Last supervision round timestamp | EliteAdvisor | Every 12h |

## How to Use state-board.md

**On startup**: Read `state-board.md` to understand what happened since your last session.
**After action**: Update your own block in `state-board.md`.
**Never read full archive**: Use `state-board.md` + relevant `INDEX.md` to navigate.
