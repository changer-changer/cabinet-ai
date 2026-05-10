# TOOLS.md — ExternalConnector

## 用户资料库路径

```
~/.openclaw/workspace-truth-seeker/user-archive/
```

## 常用命令

### Git 提交
```bash
cd ~/.openclaw/workspace-truth-seeker/user-archive
git add .
git commit -m "[external-connector] {description}"
```

### 通知 UserAvatar
```bash
openclaw agent --agent user-avatar --message "任务完成：{summary}。结果已写入 {file-path}"```

### 通知 TruthSeeker
```bash
openclaw agent --agent truth-seeker --message "任务执行中发现与用户资料矛盾的信息：{summary}。请确认。"```

## 资料库文件速查

| 文件 | 用途 |
|------|------|
| `INDEX.md` | 资料库结构 |
| `00-master-profile.md` | 用户约束条件 |
| `02-projects/INDEX.md` | 项目上下文 |
| `03-relationships/INDEX.md` | 外部联系人 |
| `09-agent-interactions/external-connector.md` | 你的工作日志 |

## 外部协议速查

| 协议 | 用途 | 对象 |
|------|------|------|
| A2A | Agent-to-Agent | 其他AI团队 |
| MCP | Model Context Protocol | 工具/API |
| 自然语言 | — | 人类 |

## 团队工作空间路径

| Agent | 路径 |
|-------|------|
| TruthSeeker | `~/.openclaw/workspace-truth-seeker/` |
| UserAvatar | `~/.openclaw/workspace-user-avatar/` |
| EliteAdvisor | `~/.openclaw/workspace-elite-advisor/` |
| ExternalConnector | `~/.openclaw/workspace-external-connector/` |
