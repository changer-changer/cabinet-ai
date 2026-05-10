# Project Changelog

## 2026-05-10 — v4.0 模板重构

### SOUL.md / AGENTS.md 职责分离
- **What**: 调查了 OpenClaw 源码，确认 8 个 bootstrap 文件的加载机制和职责分工
- **Why**: SOUL.md 塞了操作规程（state-board 更新、巡视流程），导致每次 turn 浪费 token 在不相关的内容上
- **How**: SOUL.md 只保留人格和思维框架，所有操作规程移到 AGENTS.md
- **Files**: 所有 4 个 agent 的 SOUL.md 和 AGENTS.md

### 关键发现
- OpenClaw 源码 `loadWorkspaceBootstrapFiles()` 定义了 8 个标准文件：AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, HEARTBEAT.md, BOOTSTRAP.md, MEMORY.md
- 每个 agent turn 都注入这 8 个文件到 system prompt
- 子 agent 只加载 AGENTS.md 和 TOOLS.md
- TEAM_REGISTRY.md 不是标准文件，不会自动加载
- 每文件上限 12,000 字符，总计上限 60,000 字符

### install.sh 重写
- **What**: `configure_cron()` 从 `openclaw cron add` CLI 改为直接写入 `~/.openclaw/cron/jobs.json`
- **Why**: 真实的 OpenClaw cron 机制是 JSON 文件，不是 CLI 命令
- **How**: 用 node 做 JSON 合并，按 name 幂等去重

### 新模板文件
- `99-meta/state-board.md` — 全局状态看板
- `99-meta/last-updated.md`, `evolution-log.md`, `elite-advisor-last-round.md`
- `01-profile/INDEX.md`, `10-reports/INDEX.md`, `11-decisions/INDEX.md`, `99-meta/INDEX.md`
- `11-decisions/` 目录 + 决策快照模板

---

## 2026-05-09 — v3.0 初始架构

### 4-Agent 系统
- **What**: 创建 TruthSeeker、UserAvatar、EliteAdvisor、ExternalConnector 四个 agent 的 SOUL.md 和 AGENTS.md
- **Why**: 单 agent 无法同时完成真相挖掘、自主执行、质量监督
- **Files**: templates/*/SOUL.md, templates/*/AGENTS.md

### 用户档案系统
- **What**: 创建 user-archive/ 多文件结构（01-profile 到 99-meta）
- **Why**: 单文件 user_profile.md 无法支持增量更新和并发读取
- **Files**: templates/user-archive/

### install.sh
- **What**: 一键部署脚本，支持 OpenClaw agent 注册、channel 配置、cron 设置
- **Files**: install.sh

---

## 2026-05-09 — install.sh 工程修复

- **Fix 1**: `set -e` + `trap ERR` 错误处理
- **Fix 2**: `allowFrom` 改为 `--strict-json` 确保 JSON 数组格式
- **Fix 3**: 添加 `backup_openclaw_config()` 备份函数
- **Fix 4**: `SAFE_TEAM_NAME` 等变量预处理避免 sed 转义问题
