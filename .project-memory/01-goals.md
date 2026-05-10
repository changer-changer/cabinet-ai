# Project Goals & Requirements

## Current State

**Last Updated**: 2026-05-10
**Current Phase**: v4.0 Implementation
**Overall Progress**: 70%

## Vision

TruthTeam: 一个 4-Agent 认知进化系统，部署在 OpenClaw 平台上。AI agent 作为独立认知主体，不盲信用户输入，通过对抗式友好追问挖掘真相，维护基于证据的用户档案，并主动互相监督。

核心哲学：**AI should not believe users.** 用户的表面目标往往是错的、自欺的、社交表演性的。

## Requirements Timeline

### 2026-05-10 — v4.0: State-Aware Archive + Proactive Supervision

- **Type**: `feature`
- **Description**: 引入 state-aware 用户档案（state-board.md + INDEX.md 模式）、EliteAdvisor 主动巡视、矛盾热力图、认知进化追踪、决策时间机器
- **Rationale**: 解决"agent 不维护档案"和"token 爆炸"问题
- **Status**: `in-progress`
- **Priority**: `P0-critical`
- **Notes**: 已完成模板重构（SOUL.md vs AGENTS.md 职责分离）、install.sh cron 重写、state-board 模板创建

### 2026-05-09 — v3.0: Multi-Agent Architecture

- **Type**: `feature`
- **Description**: 4-Agent 架构（TruthSeeker、UserAvatar、EliteAdvisor、ExternalConnector），用户档案系统，被动监控
- **Rationale**: 单 agent 无法同时完成真相挖掘、自主执行、质量监督
- **Status**: `completed`
- **Priority**: `P0-critical`
- **Related Commits**: `25d59c1`, `3541f67`, `0406e07`

### 2026-05-09 — install.sh Engineering Fixes

- **Type**: `fix`
- **Description**: 修复 4 个工程问题：set -e 错误处理、allowFrom JSON 数组格式、config 备份、sed 转义
- **Rationale**: 部署脚本可靠性
- **Status**: `completed`
- **Priority**: `P1-high`

---

## Feature Registry

| Feature | Status | Priority | Added Date | Notes |
|---------|--------|----------|------------|-------|
| 4-Agent 架构 | completed | P0 | 2026-05-09 | SOUL.md + AGENTS.md |
| 用户档案系统 | completed | P0 | 2026-05-09 | user-archive/ 多文件结构 |
| 被动监控 (6h cron) | in-progress | P0 | 2026-05-09 | cron JSON 重写完成 |
| EliteAdvisor 主动巡视 | in-progress | P0 | 2026-05-10 | SOUL/AGENTS 重构完成 |
| state-board.md | in-progress | P0 | 2026-05-10 | 模板已创建 |
| 矛盾热力图 | in-progress | P1 | 2026-05-10 | 模板已创建 |
| 决策时间机器 | in-progress | P1 | 2026-05-10 | 模板已创建 |
| 认知进化追踪 | planned | P2 | 2026-05-10 | 季度报告模板已创建 |
| 思维注入 (INJECTIONS) | planned | P2 | 2026-05-10 | EliteAdvisor 能力 |
| 红队模式 | planned | P2 | 2026-05-10 | 月度对抗挑战 |

## Constraints & Non-Goals

- **Constraint**: 必须在 OpenClaw 平台上运行，不能自建基础设施
- **Constraint**: 单用户 MVP，不支持多用户/团队
- **Non-Goal**: 实时群聊监听（需要平台 webhook/bot）
- **Non-Goal**: 外部数据库后端（档案只用 Git-tracked Markdown）
- **Non-Goal**: UI 仪表板
