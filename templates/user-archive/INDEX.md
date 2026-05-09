# User Archive Index

> Last updated: {timestamp} by {agent-id}
> Git commit: {commit-hash}

## Quick Navigation

| Directory | Content | Update Frequency | Last Updated |
|-----------|---------|-----------------|-------------|
| `00-master-profile.md` | Condensed user profile (fast-read) | Every conversation | - |
| `01-profile/` | Detailed 7-dimension truth profile | Weekly | - |
| `02-projects/` | Project archives (active/completed/failed) | Per project change | - |
| `03-relationships/` | Relationship graph | Monthly | - |
| `04-timeline/` | Life timeline & decisions | Per major event | - |
| `05-knowledge/` | Skills, interests, learning log | Quarterly | - |
| `06-life/` | Daily patterns, habits, preferences | Monthly | - |
| `07-childhood/` | Childhood & formative events | Once + updates | - |
| `08-conversations/` | Conversation history summaries | Daily | - |
| `09-agent-interactions/` | Agent interaction logs | Per interaction | - |
| `10-reports/` | Generated reports (contradictions, mentoring) | Per report | - |
| `99-meta/` | Scan state, git log, system metadata | Per scan | - |

## Status Overview

### Profile Completeness
- Identity: {0-100}%
- Physical Reality: {0-100}%
- True Goals: {0-100}%
- Cognitive Constraints: {0-100}%
- Physical Constraints: {0-100}%
- Motivation: {0-100}%
- Path Facts: {0-100}%
- Traits: {0-100}%

### Active Projects ({count})
(See `02-projects/INDEX.md` for full list)

### Recent Contradictions ({count})
(See `10-reports/contradictions.md`)

### Pending Questions ({count})
(See `01-profile/11-pending-questions.md`)

## For Agents: How to Use This Archive

1. **First read**: Always start with `00-master-profile.md` for a quick overview
2. **Deep dive**: Read relevant sections in `01-profile/` for detailed information
3. **Before acting**: Check `02-projects/INDEX.md` for active project context
4. **After acting**: Update `09-agent-interactions/{your-id}.md` with a summary
5. **Commit changes**: Run `git add . && git commit -m "[{agent-id}] {summary}"`

## Git Management

- Init: `git init` (done by install.sh)
- Commit format: `[{agent-id}] {description}`
- Never force-push. Resolve conflicts by keeping both versions with markers.
- Check `git log --oneline -10` before making changes to see recent updates.
