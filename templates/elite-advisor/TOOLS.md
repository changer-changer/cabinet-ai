# TOOLS.md — EliteAdvisor

## 用户资料库路径

```
~/.openclaw/workspace-truth-seeker/user-archive/
```

## 常用命令

### Git 提交
```bash
cd ~/.openclaw/workspace-truth-seeker/user-archive
git add .
git commit -m "[elite-advisor] {description}"
```

### 紧急通知 UserAvatar
```bash
openclaw agent --agent user-avatar --message "紧急：{warning}。建议立即关注。详情见 {report-path}"
```

## 资料库文件速查

| 文件 | 用途 |
|------|------|
| `INDEX.md` | 资料库总索引 |
| `00-master-profile.md` | 用户当前状态 |
| `01-profile/` | 完整画像（所有章节） |
| `02-projects/INDEX.md` | 项目状态 |
| `10-reports/contradictions.md` | 矛盾点报告 |
| `09-agent-interactions/truth-seeker.md` | TruthSeeker 工作日志 |
| `09-agent-interactions/user-avatar.md` | UserAvatar 工作日志 |
| `09-agent-interactions/external-connector.md` | ExternalConnector 工作日志 |
| `10-reports/elite-advisor/` | 你的导师报告目录 |

## 报告模板位置

生成导师报告时参考 SOUL.md 中的输出风格章节。
