# OpenClaw Agent Workspace MD 文件机制调查报告

> 调查范围：OpenClaw 2026.4.26 (be8c246) 源代码
> 调查文件：dist/workspace-Ddypv-c6.js, dist/system-prompt-Ble5uzBt.js, dist/heartbeat-CwuZimI4.js, dist/heartbeat-runner-BPAToAzE.js

---

## 一、有哪些 MD 文件会被自动加载？

OpenClaw 在每个 Agent session 启动时，自动从 workspace 目录加载以下文件：

| 文件名 | 常量名 | 加载顺序 | 动态/静态 |
|--------|--------|---------|----------|
| AGENTS.md | DEFAULT_AGENTS_FILENAME | 10 (最先) | 静态 |
| SOUL.md | DEFAULT_SOUL_FILENAME | 20 | 静态 |
| IDENTITY.md | DEFAULT_IDENTITY_FILENAME | 30 | 静态 |
| USER.md | DEFAULT_USER_FILENAME | 40 | 静态 |
| TOOLS.md | DEFAULT_TOOLS_FILENAME | 50 | 静态 |
| BOOTSTRAP.md | DEFAULT_BOOTSTRAP_FILENAME | 60 | 静态 |
| MEMORY.md | DEFAULT_MEMORY_FILENAME | 70 | 静态 |
| HEARTBEAT.md | DEFAULT_HEARTBEAT_FILENAME | 动态 | **动态** |

**关键发现**：
- 共 8 个文件，其中 7 个是静态的，只有 HEARTBEAT.md 是动态的。
- 这些文件由 `loadWorkspaceBootstrapFiles()` 统一读取，然后注入到 system prompt 中。

---

## 二、每个文件什么时候生效？如何生效？

### 2.1 加载时机

**每次 session 启动时**（包括用户发消息触发的新 turn、子 agent 被唤醒、cron 触发），OpenClaw 都会：

1. 调用 `loadWorkspaceBootstrapFiles(dir)` 读取上述 8 个文件
2. 调用 `filterBootstrapFilesForSession(files, sessionKey)` 根据 session 类型过滤
3. 将文件内容按 `CONTEXT_FILE_ORDER` 排序后注入 system prompt

### 2.2 Session 类型过滤（极其重要）

```javascript
const MINIMAL_BOOTSTRAP_ALLOWLIST = new Set([
    DEFAULT_AGENTS_FILENAME,      // AGENTS.md
    DEFAULT_TOOLS_FILENAME,       // TOOLS.md
    DEFAULT_SOUL_FILENAME,        // SOUL.md
    DEFAULT_IDENTITY_FILENAME,    // IDENTITY.md
    DEFAULT_USER_FILENAME         // USER.md
]);

function filterBootstrapFilesForSession(files, sessionKey) {
    if (!sessionKey || !isSubagentSessionKey(sessionKey) && !isCronSessionKey(sessionKey))
        return files;  // main session: 加载全部 8 个
    return files.filter((file) => MINIMAL_BOOTSTRAP_ALLOWLIST.has(file.name));
    // subagent/cron: 只加载 AGENTS.md, TOOLS.md, SOUL.md, IDENTITY.md, USER.md
}
```

| Session 类型 | 加载的文件 |
|-------------|-----------|
| **Main session**（用户直接对话） | 全部 8 个 |
| **Subagent session**（子 agent） | AGENTS.md, TOOLS.md, SOUL.md, IDENTITY.md, USER.md |
| **Cron session**（定时任务） | AGENTS.md, TOOLS.md, SOUL.md, IDENTITY.md, USER.md |

**关键发现**：
- **子 agent 和 cron session 不加载 HEARTBEAT.md, BOOTSTRAP.md, MEMORY.md**
- 这意味着：HEARTBEAT.md 中的内容对 cron 触发的任务不可见！
- 如果 cron 任务需要执行的操作写在 HEARTBEAT.md 中，子 agent 执行时看不到这些指令。

### 2.3 缓存边界（Cache Boundary）

System prompt 被分为两部分，中间用 `<!-- OPENCLAW_CACHE_BOUNDARY -->` 分隔：

```
[静态文件内容]          ← 被缓存，复用率高
<!-- OPENCLAW_CACHE_BOUNDARY -->
[动态文件内容]          ← 每次重新读取
[Heartbeat Section]
[Runtime Section]
```

| 文件类型 | 位置 | 缓存行为 |
|---------|------|---------|
| 静态文件 (AGENTS.md, SOUL.md, IDENTITY.md, USER.md, TOOLS.md, BOOTSTRAP.md, MEMORY.md) | Cache Boundary 之上 | **被缓存**，降低 token 成本 |
| 动态文件 (HEARTBEAT.md) | Cache Boundary 之下 | **每次重新读取**，不缓存 |

**关键发现**：
- HEARTBEAT.md 是唯一不缓存的文件，这意味着它适合放**经常变化的内容**
- 但反过来，它的内容在 prompt 中位置偏后，优先级低于静态文件
- 静态文件因为被缓存，适合放**稳定不变的核心定义**

### 2.4 SOUL.md 的特殊待遇

SOUL.md 是唯一获得额外 system prompt 加持的文件：

```
If SOUL.md is present, embody its persona and tone.
Avoid stiff, generic replies; follow its guidance unless
higher-priority instructions override it.
```

**关键发现**：
- SOUL.md 被系统明确识别为"人格/语气定义"
- 这是真正影响 Agent 对话风格的文件

### 2.5 HEARTBEAT.md 的触发机制

```javascript
const HEARTBEAT_PROMPT = "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.";

// 默认间隔
resolveHeartbeatIntervalMs() => "30m"  // 30分钟
```

触发流程：
1. 每 30 分钟（可配置），Gateway 向 Agent 发送心跳消息：`[OpenClaw heartbeat poll]`
2. Agent 读取 HEARTBEAT.md 内容
3. 如果内容"effectively empty"（只有标题、空列表项、代码围栏），**跳过 API 调用**
4. 否则，将 HEARTBEAT.md 内容 + 心跳提示词注入 prompt
5. Agent 根据 HEARTBEAT.md 的指令执行任务
6. 如果无事可做，回复 `HEARTBEAT_OK`（该回复会被过滤，不显示给用户）

**YAML 任务格式**（心跳支持）：
```yaml
tasks:
  - name: email-check
    interval: 30m
    prompt: "Check for urgent unread emails"
```

**关键发现**：
- HEARTBEAT.md 适合放**周期性检查任务**
- 但如果任务是通过 cron 触发的（不是心跳），Agent 看不到 HEARTBEAT.md 的内容
- 所以 cron 任务的指令不能放在 HEARTBEAT.md 中

### 2.6 内容清理（Sanitize）

所有文件内容在注入 prompt 前都会经过：
1. 移除 `DEFAULT_HEARTBEAT_PROMPT_CONTEXT_BLOCK`（默认心跳提示文本）
2. 压缩连续 3+ 空行为 2 个空行

这意味着：如果你在文件中写了和系统默认一样的心跳提示文本，它会被自动移除。

---

## 三、每个文件的最佳内容分配

基于以上机制，各文件的内容分配建议如下：

### AGENTS.md — 规范层（加载顺序第 1，静态，所有 session 可见）

**应该放什么**：
- Session 启动流程（参考 main workspace 的 AGENTS.md 模式）
- 决策原则、自主范围、权限边界
- 团队注册表（所有 Agent 的信息）
- 操作规范（资料库读取顺序、写入规范）
- 记忆管理规则
- 红线/禁止事项

**不应该放什么**：
- 人格/语气描述（放 SOUL.md）
- 工具命令模板（放 TOOLS.md）
- 周期性任务指令（放 cron 配置或 AGENTS.md 的 cron 段落）

### SOUL.md — 灵魂层（加载顺序第 2，静态，所有 session 可见，有特殊待遇）

**应该放什么**：
- 核心信念、世界观
- 角色定义（身份、使命）
- 语气/风格指导
- 工作哲学（为什么这样工作）
- 思维模式（如 EliteAdvisor 的 8 个思维模型）
- 追问策略/对话风格

**不应该放什么**：
- 具体操作步骤（放 AGENTS.md 或 TOOLS.md）
- Bash 命令模板（放 TOOLS.md）
- 文件路径速查（放 TOOLS.md）

### IDENTITY.md — 身份层（加载顺序第 3，静态，所有 session 可见）

**应该放什么**：
- Agent 名称
- 生物类型/形象
- 气质描述
- Emoji
- 头像路径

### USER.md — 用户层（加载顺序第 4，静态，所有 session 可见）

**应该放什么**：
- 用户基本信息（这个文件在每个 agent workspace 中是独立的，不是共享的）

### TOOLS.md — 工具层（加载顺序第 5，静态，所有 session 可见）

**应该放什么**：
- 环境特定的工具配置
- Bash 命令模板（openclaw agent、git）
- 文件路径速查
- 已安装 skills 清单
- 工具调用示例

**系统明确说明**：
```
"TOOLS.md does not control tool availability; it is user guidance for how to use external tools."
```

### HEARTBEAT.md — 心跳层（动态，**main session  only**，不缓存）

**应该放什么**：
- 周期性检查任务（每 30 分钟执行一次）
- 自检清单
- 短期监控项

**不应该放什么**：
- Cron 任务的指令（cron session 看不到此文件！）
- 长期不变的规则（浪费动态加载的 token）
- 核心信念/角色定义（优先级低，位置靠后）

### BOOTSTRAP.md — 引导层（main session only）

**应该放什么**：
- Agent 首次启动时的初始化任务
- 引导 Agent 完成自我设定
- 首次部署时的检查清单

**生命周期**：
- 首次启动时存在，Agent 读取并执行后删除
- 删除后不再加载

### MEMORY.md — 记忆层（main session only）

**应该放什么**：
- 长期记忆
- 用户个人信息（敏感，只在 main session 加载）

---

## 四、对 TruthTeam 的关键启示

### 启示 1：Cron 任务指令应该放在哪里？

**错误做法**：把 cron 任务的执行步骤写在 HEARTBEAT.md 中
- 原因：cron session 不加载 HEARTBEAT.md

**正确做法**：
- 选项 A：把 cron 任务指令放在 **AGENTS.md** 中（所有 session 可见）
- 选项 B：把 cron 任务指令放在 **SOUL.md** 中（所有 session 可见）
- 选项 C：cron 的 `--message` 参数中包含完整指令（推荐）

结论：**Cron 任务的执行步骤应该放在 AGENTS.md 或 SOUL.md 中，或者完全依赖 cron 的 message 参数。不要放在 HEARTBEAT.md 中。**

### 启示 2：静态文件 vs 动态文件的选择

| 内容类型 | 推荐文件 | 原因 |
|---------|---------|------|
| 核心信念、角色定义 | SOUL.md | 高优先级加载 + 特殊待遇 |
| 操作规范、团队信息 | AGENTS.md | 最高优先级加载 |
| 工具命令、路径速查 | TOOLS.md | 专门用途 |
| 周期性自检任务 | HEARTBEAT.md | 动态加载，适合变化内容 |
| 首次初始化引导 | BOOTSTRAP.md | 一次性使用 |

### 启示 3：子 agent 能看到什么？

当 ExternalConnector 被 UserAvatar 通过 `sessions_spawn` 唤醒时：
- 它能看到：AGENTS.md, SOUL.md, IDENTITY.md, USER.md, TOOLS.md
- 它**看不到**：HEARTBEAT.md, BOOTSTRAP.md, MEMORY.md

这意味着：
- 如果 ExternalConnector 需要知道某些规则，这些规则必须在 AGENTS.md / SOUL.md / TOOLS.md 中
- 不能依赖 HEARTBEAT.md 来传递指令给子 agent

### 启示 4：加载顺序意味着优先级

```
AGENTS.md (10) → SOUL.md (20) → IDENTITY.md (30) → USER.md (40) → TOOLS.md (50)
```

- AGENTS.md 最先加载，适合放**最高优先级**的规则
- SOUL.md 次之，适合放**人格定义**
- TOOLS.md 最后，适合放**参考性内容**

如果 AGENTS.md 和 SOUL.md 有冲突，AGENTS.md 的规则会覆盖 SOUL.md（因为先加载，后加载的可以覆盖）。

---

## 五、当前模板的问题分析

### 问题 1：SOUL.md 过于臃肿

当前 SOUL.md 包含了：
- ✅ 核心信念、角色定义（正确）
- ✅ 七维框架、思维模式（正确）
- ❌ 资料库结构详情（应放 TOOLS.md）
- ❌ 维护职责具体操作（应放 AGENTS.md）
- ❌ 被动监控扫描流程（应放 AGENTS.md 或 cron message）
- ❌ Bash 命令模板（应放 TOOLS.md）
- ❌ 输出格式模板（应放 AGENTS.md）

### 问题 2：AGENTS.md 内容不足

当前 AGENTS.md 只有：
- 决策原则
- 自主范围
- 团队注册表
- 定时任务配置

缺少：
- Session 启动流程（应该定义"每次启动时读什么文件"）
- 资料库读取/写入规范
- 操作规范

### 问题 3：HEARTBEAT.md 缺失

当前没有创建 HEARTBEAT.md 模板。
- 周期性任务（如 TruthSeeker 的被动监控）的指令应该考虑是否适合放这里
- 但如果这些任务是通过 cron 触发的，则不适合放 HEARTBEAT.md

### 问题 4：TOOLS.md 缺失

当前没有创建 TOOLS.md 模板。
- Bash 命令模板、Git 命令、文件路径速查都应该放这里

### 问题 5：cron 任务 vs heartbeat 任务的混淆

当前设计中：
- TruthSeeker 每 6 小时被动监控 → **cron 触发**
- EliteAdvisor 每 12 小时检查 → **cron 触发**
- UserAvatar 每 12 小时自主行动 → **cron 触发**

这些都不是心跳任务（心跳是每 30 分钟）。所以：
- 这些任务的执行步骤**不能**放在 HEARTBEAT.md 中
- 应该放在 AGENTS.md 或 SOUL.md 中，或者完全依赖 cron 的 `--message` 参数

---

## 六、推荐的内容分配方案

### TruthSeeker

| 文件 | 内容 |
|------|------|
| **SOUL.md** | 核心信念、独立性原则、角色定义（侦探式挖掘）、七维框架、真相穷尽标准、独立性与灵活性平衡、主动对话机制、追问策略、关键原则 |
| **AGENTS.md** | Session 启动流程、资料库维护规范、信息源权限、通信协议（不含具体命令）、被动监控概述、团队注册表 |
| **IDENTITY.md** | 真相探寻者、顶级侦探、🔍 |
| **TOOLS.md** | 资料库路径、Git 命令、Bash 触发命令模板、session 扫描命令、文件速查表 |
| **HEARTBEAT.md** | （可选）轻量级自检，如"检查是否有未处理的矛盾点" |

### UserAvatar

| 文件 | 内容 |
|------|------|
| **SOUL.md** | 核心设定（平行世界最优版）、角色定义、核心能力、决策原则、自主范围、定义"好"的标准、主动性发挥、警告 |
| **AGENTS.md** | Session 启动流程、资料库读取规范、通信协议概述、12小时自主行动概述、团队注册表 |
| **IDENTITY.md** | 用户分身、平行世界最优版用户、🎯 |
| **TOOLS.md** | Bash 触发命令模板（TruthSeeker/ExternalConnector/EliteAdvisor）、Git 命令、资料库路径 |
| **HEARTBEAT.md** | （可选）轻量级自检 |

### EliteAdvisor

| 文件 | 内容 |
|------|------|
| **SOUL.md** | 核心信念、角色定义（顶级导师）、8个思维模型、思维切换指南、辅导风格、关键原则 |
| **AGENTS.md** | Session 启动流程、资料库读取规范、监督范围与触发、辅导原则、团队注册表 |
| **IDENTITY.md** | 顶级顾问、复合导师、🧠 |
| **TOOLS.md** | Bash 命令模板、Git 命令、资料库路径 |
| **HEARTBEAT.md** | （可选）轻量级自检 |

### ExternalConnector

| 文件 | 内容 |
|------|------|
| **SOUL.md** | 核心信念、角色定义（神经中枢）、全知全能要求、外部团队链接、工作原则、任务处理流程（高层）、关键原则 |
| **AGENTS.md** | Session 启动流程、资料库读取规范、通信协议概述、汇报机制、团队注册表 |
| **IDENTITY.md** | 外部对接、信息枢纽、🔌 |
| **TOOLS.md** | Bash 命令模板、A2A/MCP 协议速查、Git 命令、资料库路径 |
| **HEARTBEAT.md** | （可选，可能留空） |
