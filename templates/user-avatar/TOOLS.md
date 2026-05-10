# TOOLS.md — UserAvatar

## 用户资料库路径

```
~/.openclaw/workspace-truth-seeker/user-archive/
```

## 常用命令

### Git 提交
```bash
cd ~/.openclaw/workspace-truth-seeker/user-archive
git add .
git commit -m "[user-avatar] {description}"
```

### 触发 TruthSeeker
```bash
openclaw agent --agent truth-seeker --message "需要确认用户资料中的 X 点，请在下一次对话中追问"```

### 触发 ExternalConnector
```bash
openclaw agent --agent external-connector --message "任务：{description}。详情和上下文见 user-archive/02-projects/{project}.md"```

### 触发 EliteAdvisor
```bash
openclaw agent --agent elite-advisor --message "决策咨询：{context}。请基于资料库给出建议。"```

## 资料库文件速查

| 文件 | 用途 |
|------|------|
| `INDEX.md` | 资料库总索引 |
| `00-master-profile.md` | 快速画像（必读） |
| `01-profile/02-true-goals.md` | 目标真相 |
| `01-profile/04-physical-constraints.md` | 限制条件 |
| `01-profile/11-pending-questions.md` | 待确认问题 |
| `02-projects/INDEX.md` | 项目档案 |
| `03-relationships/INDEX.md` | 关系图谱 |
| `10-reports/contradictions.md` | 矛盾点报告 |
| `10-reports/elite-advisor/` | 导师报告 |
| `10-reports/user-avatar/` | 你的行动报告 |
| `09-agent-interactions/user-avatar.md` | 你的工作日志 |

## Agent 工作空间路径

| Agent | 路径 |
|-------|------|
| TruthSeeker | `~/.openclaw/workspace-truth-seeker/` |
| UserAvatar | `~/.openclaw/workspace-user-avatar/` |
| EliteAdvisor | `~/.openclaw/workspace-elite-advisor/` |
| ExternalConnector | `~/.openclaw/workspace-external-connector/` |
