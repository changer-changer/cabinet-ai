# Git Conventions

## Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: 新功能
- `fix`: 修复
- `refactor`: 重构（不改变行为）
- `docs`: 文档更新
- `chore`: 工具/配置变更

### Scopes
- `install`: install.sh 相关
- `template`: 模板文件（SOUL.md, AGENTS.md 等）
- `archive`: user-archive 相关
- `skill`: SKILL.md 相关
- `memory`: .project-memory/ 相关

### Examples
```
feat(template): add v4.0 state-board and INDEX.md templates
fix(install): rewrite cron to write jobs.json directly
refactor(template): move operational content from SOUL.md to AGENTS.md
docs(memory): initialize project memory system
```

## Agent-Attributed Commits

user-archive/ 目录下的提交使用 agent 归属格式：
```
[truth-seeker] Updated 01-profile/02-true-goals.md
[elite-advisor] Generated supervision report 2026-05-10-14
[user-avatar] Decision snapshot DEC-2026-0510-001
[external-connector] Task completed: search for X
[SYSTEM] Initialize user archive
```

## Branch Strategy

- `master`: 主分支，所有 PR 合入此处
- 不使用 feature branches（单人项目）
- 直接在 master 上 commit

## Rules

- 不 force-push
- 不修改已 push 的 commit
- 冲突时保留双方版本并标注
- 提交前检查 `git log --oneline -5`
