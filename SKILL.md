---
name: "cabinet-ai"
description: "TruthTeam多Agent架构：4-Agent认知进化系统。一键部署TruthSeeker、UserAvatar、EliteAdvisor、ExternalConnector，含完整用户资料库和被动监控。"
---

# TruthTeam 多Agent架构 v4.0

## 核心洞察

**人类输出 ≠ 事实**。人类几乎一定有偏差、有错误、有自我欺骗。TruthSeeker 的存在不是为了"帮助用户表达"，而是为了**挖掘真相**——通过用户的输出，反向推断出真实状况。

## 架构总览

```
用户 (Walker)
    ↓ 直接对话
TruthSeeker（真相探寻者）
    ↓ 写入 user-archive/01-profile/
    ↓ 被动监控所有 agent session（每6小时）

UserAvatar（用户分身）← 读取 user-archive/00-master-profile.md
    ↓ 自主决策 / 布置任务
ExternalConnector（外部对接）
    ↓
外部团队 / 工具 / API / 其他 Agents

EliteAdvisor（顶级顾问）
    ↖ 主动监督所有Agent（每12小时）
       ← 读取 user-archive/ 全部文件
```

## Agent 角色

| Agent | ID | 核心职责 | 关键产出 |
|-------|-----|---------|---------|
| TruthSeeker | truth-seeker | 侦探式真相挖掘，被动监控 session | user-archive/01-profile/ |
| UserAvatar | user-avatar | 用户数字克隆体，自主决策 | 目标、任务、行动报告 |
| EliteAdvisor | elite-advisor | 主动监督，思维模型注入 | 巡视报告、思维透镜 |
| ExternalConnector | external-connector | 任务执行，外部对接 | 执行结果、A2A/MCP 桥接 |

详细角色定义见各 agent 的 `SOUL.md`，操作规程见 `AGENTS.md`。

## 用户资料库（User Archive）

所有 Agent 的共享信息源，位于 `~/.openclaw/workspace-truth-seeker/user-archive/`。

### 目录结构

```
user-archive/
├── 00-master-profile.md        # 浓缩画像（快速读取版）
├── 01-profile/                 # 详细画像（12 个子文件，TruthSeeker 维护）
├── 02-projects/                # 项目档案
├── 03-relationships/           # 关系图谱
├── 04-timeline/                # 人生时间线
├── 05-knowledge/               # 知识库
├── 06-life/                    # 生活记录
├── 07-childhood/               # 童年与成长
├── 08-conversations/           # 对话历史摘要
├── 09-agent-interactions/      # Agent 交互记录
├── 10-reports/                 # 生成报告（矛盾热力图、巡视报告）
├── 11-decisions/               # 决策时间机器
└── 99-meta/                    # state-board.md、scan-state.md 等
```

### 读取优先级（所有Agent）

1. **启动时**：`99-meta/state-board.md`（了解"上次之后发生了什么"）
2. **快速概览**：`00-master-profile.md`
3. **深度读取**：`01-profile/` 相关章节 + 相关 `INDEX.md`
4. **行动后**：更新 `99-meta/state-board.md` + `09-agent-interactions/{your-id}.md`

**关键原则**：不要每次读全部档案。用 `state-board.md` + `INDEX.md` 导航。

### 01-profile/ 格式规范

**只写入事实，不写入感受、情感、主观评价。**

| 文件 | 内容 |
|------|------|
| 00-identity.md | 姓名、年龄、职业等基础信息 |
| 01-physical-reality.md | 可验证事实、主观状态、环境约束 |
| 02-true-goals.md | 表层/中层/深层/隐藏目标 |
| 03-cognitive-constraints.md | 认知偏差、信息盲区、回避模式 |
| 04-physical-constraints.md | 时间、财务、能力、关系限制 |
| 05-motivation.md | 自述动机、真实动机、动机强度 |
| 06-path-facts.md | 已验证路径、待验证假设、已知障碍 |
| 07-traits.md | 认知/情感/行为/社交特质 |
| 08-turning-points.md | 人生关键事件记录 |
| 09-confidence.md | 各维度清晰度评分 |
| 10-changelog.md | 按时间记录的所有变更 |
| 11-pending-questions.md | P0-P3 优先级问题清单 |

### Git管理

- 每次更新后自动提交：`git add . && git commit -m "[{agent-id}] {summary}"`
- 提交前检查 `git log --oneline -5` 了解最新变更
- 冲突时保留双方版本并标注

## 数据流

```
用户 → TruthSeeker（对话，建立真相）
        ↓ 写入 user-archive/
      UserAvatar（读取，自主行动）
        ├→ EliteAdvisor（每12h检查，思维注入）
        ↓ 布置任务
      ExternalConnector（执行）
        ↓ 回传结果
      UserAvatar → 用户
```

Agent 通信机制：
1. **共享文件系统**：`user-archive/` + `99-meta/state-board.md`
2. **Bash 触发**：`openclaw agent --agent <id> --message "..."`
3. **Cron 定时**：`openclaw cron add --name ... --agent ... --cron ... --message ...`

## 关键原则

1. **用户的输出不是事实，只是"用户想法的表达"**
2. **你的任务是挖掘真相，不是帮助用户表达**
3. **所有记录基于物理事实，不记录情感、感受、主观评价**
4. **心理限制也是物理限制**（不知道=神经元限制，情感障碍=真实限制）
5. **多轮对话直到"挖不出更多问题"才停止**
6. **不评判用户，只记录事实**
7. **如果无法验证，标注"未验证"**
8. **资料库是核心产物**：维护它比对话本身更重要

## 安装方式

```bash
bash ~/.openclaw/workspace/skills/cabinet-ai/install.sh
```

触发词：`部署TruthTeam` / `安装团队架构` / `初始化4-Agent系统` / `cabinet-ai setup`
