# Project Architecture

## Current Architecture (v4.0 — 2026-05-10)

**Last Updated**: 2026-05-10
**Status**: `evolving`

### System Overview

OpenClaw skill 项目，不是传统软件项目。没有 package manager、build system 或 test suite。"代码"由 Markdown skill 定义、Bash 安装脚本、Agent 人设模板组成，配置 OpenClaw runtime。

### 4-Agent 数据流

```
User (Walker)
    ↓ direct conversation (telegram/feishu)
TruthSeeker  →  writes/updates  →  user-archive/
                                      ↓
UserAvatar  ←  reads state-board  ────┘
    ↓ assigns tasks
ExternalConnector  →  external tools/APIs/other agents
    ↓ returns results
UserAvatar  →  reports to User

EliteAdvisor  ←  reads ALL sessions + state-board
    ↓ proactive outreach
    ↓ thinking-mode injection
    ↓ red-team challenges
```

### Bootstrap 文件加载机制（OpenClaw 源码验证）

每个 agent turn 都注入以下文件到 system prompt：

```
loadWorkspaceBootstrapFiles(dir):
  1. AGENTS.md     ← 操作规程（子 agent 也加载）
  2. SOUL.md       ← 人格、语气、思维框架
  3. TOOLS.md      ← 环境配置（子 agent 也加载）
  4. IDENTITY.md   ← 名字、emoji、头像
  5. USER.md       ← 用户信息
  6. HEARTBEAT.md  ← 定期检查清单（条件加载）
  7. BOOTSTRAP.md  ← 首次运行仪式（加载后删除）
  8. MEMORY.md     ← 持久记忆（仅 DM 且文件存在时）
```

关键限制：
- 每文件上限 12,000 字符
- 总计上限 60,000 字符
- 子 agent 只加载 AGENTS.md 和 TOOLS.md
- HEARTBEAT.md 空文件 = 跳过心跳

### 目录结构

```
cabinet-ai/
├── _meta.json              # Skill 元数据
├── SKILL.md                # 完整架构规范
├── install.sh              # 一键部署脚本
├── skills-lock.json        # 依赖锁定
├── plan.md                 # v4.0 实施计划
│
├── templates/
│   ├── truth-seeker/       # TruthSeeker 模板
│   │   ├── SOUL.md         # 人格：侦探式真相挖掘
│   │   ├── AGENTS.md       # 操作：被动监控、档案维护
│   │   ├── IDENTITY.md     # 身份：真相探寻者
│   │   └── TOOLS.md        # 环境：命令、路径
│   ├── user-avatar/        # UserAvatar 模板
│   ├── elite-advisor/      # EliteAdvisor 模板
│   ├── external-connector/ # ExternalConnector 模板
│   └── user-archive/       # 用户档案模板
│       ├── 00-master-profile.md
│       ├── 01-profile/     # 详细画像（12 个子文件）
│       ├── 02-projects/    # 项目档案
│       ├── 03-relationships/
│       ├── 04-timeline/
│       ├── 05-knowledge/
│       ├── 06-life/
│       ├── 07-childhood/
│       ├── 08-conversations/
│       ├── 09-agent-interactions/
│       ├── 10-reports/     # 矛盾热力图、巡视报告
│       ├── 11-decisions/   # 决策时间机器
│       └── 99-meta/        # state-board、scan-state
```

### Cron 系统

直接写入 `~/.openclaw/cron/jobs.json`（不是 CLI 命令）：

```json
{
  "version": 1,
  "jobs": [{
    "id": "uuid",
    "name": "tt-truth-seeker-monitor",
    "enabled": true,
    "schedule": { "kind": "cron", "expr": "0 */6 * * *" },
    "sessionTarget": "isolated",
    "wakeMode": "now",
    "payload": { "kind": "agentTurn", "message": "...", "lightContext": true },
    "delivery": { "mode": "none" }
  }]
}
```

### Agent 通信机制

1. **共享文件系统**：`user-archive/` + `99-meta/state-board.md`
2. **Bash 触发**：`openclaw agent --agent <id> --message "..." --session isolated|main`
3. **Cron 定时**：JSON 写入 `~/.openclaw/cron/jobs.json`
4. **跨 agent 可见性**：`tools.sessions.visibility: "all"`

## Architecture Evolution Timeline

### 2026-05-10 — v4.0: State-Aware Archive

- **Change**: 引入 state-board.md + INDEX.md 模式，SOUL/AGENTS 职责分离
- **Reason**: agent 不维护档案、token 爆炸、操作规程塞在人格文件里
- **Impact**: 所有 SOUL.md 和 AGENTS.md 重写，新增 9 个模板文件

### 2026-05-09 — v3.0: 4-Agent Architecture

- **Change**: 从单 agent 到 4-Agent 系统
- **Reason**: 单 agent 无法同时完成真相挖掘、自主执行、质量监督
- **Impact**: 新增 4 个 agent 模板、用户档案系统、install.sh
