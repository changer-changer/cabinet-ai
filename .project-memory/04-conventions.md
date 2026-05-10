# Technical Conventions

**Last Updated**: 2026-05-10
**Version**: 4.0
**Status**: `active`

---

## Critical Rule

**ANY deviation from this document requires explicit user approval AND immediate document update.**

---

## 文件职责分工（OpenClaw Bootstrap）

| 文件 | 定位 | 内容 | 不应包含 |
|------|------|------|---------|
| **SOUL.md** | "我是谁" | 人格、语气、思维框架、核心信念 | 操作规程、state-board 更新、cron 配置 |
| **AGENTS.md** | "我怎么工作" | 操作规程、状态维护、通信命令、团队注册表 | 人格描述、思维模型详细展开 |
| **TOOLS.md** | "我的环境" | 命令速查、路径、session 扫描范围 | 操作流程、人格 |
| **IDENTITY.md** | "我叫什么" | 名字、emoji、头像、一句话描述 | 长篇描述 |
| **USER.md** | "我帮谁" | 用户基本信息 | 档案内容（档案在 user-archive/） |
| **HEARTBEAT.md** | "我定期查什么" | 短清单或 tasks: 块 | 长篇内容 |

### 关键约束
- 每文件上限 12,000 字符
- 总计上限 60,000 字符
- 子 agent 只加载 AGENTS.md 和 TOOLS.md（通信命令必须在这两个文件里）
- TEAM_REGISTRY.md 不是标准文件，不会自动加载（团队注册表放在 AGENTS.md 里）

---

## Cron 配置规范

- **机制**：直接写入 `~/.openclaw/cron/jobs.json`，不是 `openclaw cron add` CLI
- **格式**：JSON `{version: 1, jobs: [{id, name, enabled, schedule, sessionTarget, payload, delivery}]}`
- **幂等**：按 name 去重，保留已有 jobs
- **验证**：写入后用 `node -e "JSON.parse(...)"` 验证格式

---

## allowFrom 规范

- **格式**：JSON 数组 `[8434568597]`，不是字符串 `'[8434568597]'`
- **命令**：必须加 `--strict-json` 标志
- `openclaw config set "channels.$PLATFORM.accounts.xxx.allowFrom" "[$USER_PLATFORM_ID]" --strict-json`

---

## Git 规范

- **提交格式**：`[{agent-id}] {description}`
- **Archive 初始化**：`[SYSTEM] Initialize user archive`
- **不 force-push**：冲突时保留双方版本并标注

---

## user-archive 规范

- **只写入事实**，不写入感受、情感、主观评价
- **心理限制作为物理限制记录**
- **无法验证的信息标注"未验证"**
- **每次写入后 git commit**

---

## Convention Evolution Timeline

### 2026-05-10 — SOUL/AGENTS 职责分离

- **Change**: SOUL.md 只放人格，AGENTS.md 放操作规程
- **Reason**: OpenClaw 源码验证了文件加载机制，操作规程放在 SOUL.md 浪费 token
- **Impact**: 所有模板重写

### 2026-05-10 — Cron JSON 直写

- **Change**: 从 `openclaw cron add` CLI 改为直接写入 jobs.json
- **Reason**: 真实机制是 JSON 文件，CLI 命令可能不存在或格式不同
- **Impact**: install.sh configure_cron() 重写

### 2026-05-09 — allowFrom --strict-json

- **Change**: 所有 allowFrom 配置加 --strict-json
- **Reason**: 不加标志会存为字符串而非 JSON 数组
- **Impact**: install.sh 4 处修改
