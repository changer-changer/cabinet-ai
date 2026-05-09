# TOOLS.md — TruthSeeker

## 用户资料库路径

```
~/.openclaw/workspace-truth-seeker/user-archive/
```

## 常用命令

### Git 提交
```bash
cd ~/.openclaw/workspace-truth-seeker/user-archive
git add .
git commit -m "[truth-seeker] {description}"
```

### 通知 UserAvatar
```bash
openclaw agent --agent user-avatar --message "用户资料已更新，关键变化：{summary}。请读取 00-master-profile.md 和 01-profile/ 相关章节。" --session isolated
```

### 增量读取 Session JSONL
```bash
# 从指定偏移量读取新增内容
tail -c +{lastFileSize+1} ~/.openclaw/agents/{agent-id}/sessions/{session-file}.jsonl

# 提取用户消息
grep '"type":"user_message"' ~/.openclaw/agents/{agent-id}/sessions/{session-file}.jsonl | tail -n {delta-lines}
```

### 检查文件修改时间
```bash
ls -lt ~/.openclaw/workspace/memory/*.md | head -5
ls -lt ~/.openclaw/workspace-*/memory/*.md | head -5
```

## 资料库文件速查

| 文件 | 用途 | 更新频率 |
|------|------|---------|
| `INDEX.md` | 资料库总索引 | 按需 |
| `00-master-profile.md` | 快速画像 | 每次对话后 |
| `01-profile/00-identity.md` | 身份信息 | 首次 + 变更 |
| `01-profile/01-physical-reality.md` | 物理现状 | 对话中更新 |
| `01-profile/02-true-goals.md` | 目标真相 | 对话中更新 |
| `01-profile/03-cognitive-constraints.md` | 认知限制 | 对话中更新 |
| `01-profile/04-physical-constraints.md` | 物理限制 | 对话中更新 |
| `01-profile/05-motivation.md` | 动机事实 | 对话中更新 |
| `01-profile/06-path-facts.md` | 路径事实 | 对话中更新 |
| `01-profile/07-traits.md` | 特质分析 | 对话中更新 |
| `01-profile/08-turning-points.md` | 转折点 | 重大事件 |
| `01-profile/09-confidence.md` | 置信度 | 定期评估 |
| `01-profile/10-changelog.md` | 更新日志 | 每次更新 |
| `01-profile/11-pending-questions.md` | 待确认问题 | 持续更新 |
| `08-conversations/YYYY-MM/YYYY-MM-DD-summary.md` | 对话摘要 | 每日 |
| `09-agent-interactions/truth-seeker.md` | 工作日志 | 每次交互 |
| `10-reports/contradictions.md` | 矛盾报告 | 被动扫描后 |
| `99-meta/scan-state.md` | 扫描状态 | 每次扫描后 |

## Session 扫描范围

| Agent | Session 位置 |
|-------|-------------|
| main | `~/.openclaw/agents/main/sessions/*.jsonl` |
| truth-seeker | `~/.openclaw/agents/truth-seeker/sessions/*.jsonl` |
| user-avatar | `~/.openclaw/agents/user-avatar/sessions/*.jsonl` |
| elite-advisor | `~/.openclaw/agents/elite-advisor/sessions/*.jsonl` |
| external-connector | `~/.openclaw/agents/external-connector/sessions/*.jsonl` |
