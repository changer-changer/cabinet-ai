# User Archive — 使用指南

## 什么是用户资料库？

用户资料库是整个 TruthTeam 的**唯一事实来源**。它不是可选的附加功能，而是团队运作的**核心中枢**。

## 设计原则

1. **只存事实，不存感受** — 所有记录基于可验证的信息
2. **置信度标注** — 每条事实标注置信度（高/中/低/未验证）
3. **版本控制** — Git 管理所有变更，可追溯历史
4. **增量更新** — Agent 只更新变化的部分，不重复写入
5. **结构感知** — INDEX.md 始终反映当前结构状态

## 目录说明

### `00-master-profile.md` — 主画像（快速读取）
- 供所有 Agent 首次读取时使用
- 包含最核心的用户事实（身份、目标、限制、当前状态）
- 每次对话后由 TruthSeeker 更新

### `01-profile/` — 详细画像（七维真相框架）
- TruthSeeker 的核心工作产物
- 包含用户身份、物理现状、目标真相、认知限制、物理限制、动机、路径、特质等
- 每次重大对话后更新

### `02-projects/` — 项目档案
- `active/`：进行中项目
- `completed/`：已完成项目
- `failed/`：失败项目
- 每个项目一个 Markdown 文件，包含目标、进展、障碍、决策记录

### `03-relationships/` — 关系图谱
- 支持者、消耗者、中立者分类
- 每个关系标注：影响程度、互动频率、信任度

### `04-timeline/` — 时间线
- 人生重要节点、决策记录、转折点
- 按时间顺序排列

### `05-knowledge/` — 知识库
- 用户技能清单、兴趣领域、学习记录

### `06-life/` — 生活记录
- 日常模式、习惯、偏好

### `07-childhood/` — 童年与成长
- 成长背景、关键经历、形成性事件

### `08-conversations/` — 对话历史摘要
- 按月归档：`YYYY-MM/YYYY-MM-DD-summary.md`
- 每条摘要包含：主题、关键发现、矛盾点、待确认问题

### `09-agent-interactions/` — Agent 交互记录
- 每个 Agent 一个文件：`truth-seeker.md`、`user-avatar.md` 等
- 记录该 Agent 与用户的每次交互摘要

### `10-reports/` — 报告
- `contradictions.md`：TruthSeeker 发现的矛盾点报告
- `elite-advisor/`：导师辅导报告
- `user-avatar/`：自主行动报告

### `99-meta/` — 元数据
- `scan-state.md`：TruthSeeker 被动监控扫描状态
- `git-log.md`：自动提交日志

## 更新规范

### TruthSeeker
- 负责维护 `01-profile/`、`08-conversations/`、`10-reports/contradictions.md`
- 每次对话后更新 `00-master-profile.md`
- 每次扫描后更新 `99-meta/scan-state.md`

### UserAvatar
- 负责维护 `02-projects/`、`04-timeline/`（项目相关决策）
- 生成 `10-reports/user-avatar/` 行动报告
- 读取所有档案制定决策

### EliteAdvisor
- 读取所有档案生成指导报告
- 写入 `10-reports/elite-advisor/`
- 不直接修改用户画像

### ExternalConnector
- 执行任务后将结果写入相关项目文件
- 维护 `09-agent-interactions/external-connector.md`
- 读取 `02-projects/INDEX.md` 了解当前任务上下文

## Git 提交规范

```bash
# 提交格式
[{agent-id}] {change-description}

# 示例
[truth-seeker] Update physical-reality: confirmed user's new job
[user-avatar] Add project: startup-idea-v2
[elite-advisor] Add mentoring report: 2026-05-09
```

## 增量更新策略

1. **读取 INDEX.md** 了解当前结构
2. **读取相关文件** 获取上下文
3. **只修改变化的部分** — 不要重写整个文件
4. **更新 INDEX.md** 中的 "Last Updated" 时间戳
5. **提交** 时附上清晰的描述
