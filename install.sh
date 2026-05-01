#!/bin/bash
# 内阁AI团队一键部署脚本
# 使用方法: bash install.sh
# 
# 重要说明：
# 1. 此脚本由智能体执行，不是由用户直接执行
# 2. 执行前需要确保 OpenClaw CLI 已安装且 Gateway 正在运行
# 3. 执行过程中会修改 openclaw.json，建议先备份
# 4. 执行完成后需要重启 Gateway 才能生效
# 5. 如果遇到问题，可以查看 openclaw.json.bak 备份文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印信息函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查 OpenClaw 是否安装
# 注意：如果未安装，需要提示用户安装
# 安装方法：npm install -g openclaw
# 或者参考文档：https://docs.openclaw.ai

check_openclaw() {
    if ! command -v openclaw &> /dev/null; then
        error "OpenClaw CLI 未安装，请先安装 OpenClaw"
        # 安装命令参考：
        # npm install -g openclaw
        # 或者参考文档：https://docs.openclaw.ai
    fi
    info "OpenClaw 已安装"
}

# 检查 Gateway 是否运行
# 注意：如果 Gateway 未运行，需要启动它
# 启动方法：openclaw gateway start
# 或者：systemctl --user start openclaw-gateway

check_gateway() {
    if ! openclaw gateway status &> /dev/null; then
        error "Gateway 未运行，请先启动 Gateway"
        # 启动命令参考：
        # openclaw gateway start
        # 或者：systemctl --user start openclaw-gateway
    fi
    info "Gateway 运行中"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "脚本目录: $SCRIPT_DIR"

# 询问用户配置
# 注意：此部分需要与用户交互，获取必要信息
# 如果无法交互，可以预设默认值

ask_user_config() {
    echo ""
    echo "=== 内阁AI团队部署配置 ==="
    echo ""
    
    # 询问团队名称
    read -p "团队名称 (默认: 内阁AI): " TEAM_NAME
    TEAM_NAME=${TEAM_NAME:-内阁AI}
    
    # 询问用户昵称
    read -p "AI应该如何称呼你 (默认: 老板): " USER_NAME
    USER_NAME=${USER_NAME:-老板}
    
    # 询问绑定平台
    echo ""
    echo "选择要绑定的平台:"
    echo "1. Telegram (推荐)"
    echo "2. Discord"
    echo "3. 其他 (需手动配置)"
    read -p "请选择 (1-3, 默认: 1): " PLATFORM_CHOICE
    PLATFORM_CHOICE=${PLATFORM_CHOICE:-1}
    
    case $PLATFORM_CHOICE in
        1)
            PLATFORM="telegram"
            info "选择平台: Telegram"
            ;;
        2)
            PLATFORM="discord"
            info "选择平台: Discord"
            ;;
        3)
            PLATFORM="other"
            warn "选择其他平台，需要手动配置 channel 绑定"
            ;;
        *)
            PLATFORM="telegram"
            info "默认平台: Telegram"
            ;;
    esac
    
    # 询问 botToken
    # 注意：botToken 需要从 Telegram @BotFather 获取
    # 获取方法：
    # 1. 在 Telegram 中搜索 @BotFather
    # 2. 发送 /newbot 命令
    # 3. 按照提示设置 bot 名称和用户名
    # 4. 复制提供的 botToken
    
    if [ "$PLATFORM" != "other" ]; then
        echo ""
        echo "请为每个 Agent 提供 $PLATFORM botToken"
        echo "获取方式: 在 Telegram 中找 @BotFather 创建 bot"
        echo ""
        
        read -p "TruthSeeker botToken: " TRUTH_SEEKER_TOKEN
        read -p "UserAvatar botToken: " USER_AVATAR_TOKEN
        read -p "EliteAdvisor botToken: " ELITE_ADVISOR_TOKEN
        read -p "ExternalConnector botToken: " EXTERNAL_CONNECTOR_TOKEN
    fi
    
    echo ""
    info "配置确认:"
    echo "  团队名称: $TEAM_NAME"
    echo "  用户昵称: $USER_NAME"
    echo "  绑定平台: $PLATFORM"
    echo ""
    
    read -p "确认部署? (y/N): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        info "部署已取消"
        exit 0
    fi
}

# 渲染模板
# 注意：模板文件位于 templates/ 目录下
# 包含四个角色的 SOUL.md 和 AGENTS.md

render_templates() {
    info "渲染模板..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    
    # 复制模板
    cp -r "$SCRIPT_DIR/templates/"* "$TEMP_DIR/"
    
    # 替换变量
    find "$TEMP_DIR" -type f -name "*.md" -exec sed -i \
        -e "s/{{TEAM_NAME}}/$TEAM_NAME/g" \
        -e "s/{{USER_NAME}}/$USER_NAME/g" \
        -e "s/{{PLATFORM}}/$PLATFORM/g" \
        {} +
    
    info "模板渲染完成"
}

# 创建 workspace
# 注意：每个 Agent 需要独立的 workspace 目录
# 目录结构：~/.openclaw/workspace-<agentId>

create_workspaces() {
    info "创建 Agent workspaces..."
    
    WORKSPACE_BASE="$HOME/.openclaw"
    
    # 创建目录
    mkdir -p "$WORKSPACE_BASE/workspace-truth-seeker"
    mkdir -p "$WORKSPACE_BASE/workspace-user-avatar"
    mkdir -p "$WORKSPACE_BASE/workspace-elite-advisor"
    mkdir -p "$WORKSPACE_BASE/workspace-external-connector"
    
    # 复制 SOUL.md 和 AGENTS.md
    # 注意：这些文件是 Agent 的灵魂和规范
    # 位于各自 workspace 的根目录
    # OpenClaw 会自动加载 SOUL.md 和 AGENTS.md
    
    cp "$TEMP_DIR/truth-seeker/SOUL.md" "$WORKSPACE_BASE/workspace-truth-seeker/SOUL.md"
    cp "$TEMP_DIR/truth-seeker/AGENTS.md" "$WORKSPACE_BASE/workspace-truth-seeker/AGENTS.md"
    
    cp "$TEMP_DIR/user-avatar/SOUL.md" "$WORKSPACE_BASE/workspace-user-avatar/SOUL.md"
    cp "$TEMP_DIR/user-avatar/AGENTS.md" "$WORKSPACE_BASE/workspace-user-avatar/AGENTS.md"
    
    cp "$TEMP_DIR/elite-advisor/SOUL.md" "$WORKSPACE_BASE/workspace-elite-advisor/SOUL.md"
    cp "$TEMP_DIR/elite-advisor/AGENTS.md" "$WORKSPACE_BASE/workspace-elite-advisor/AGENTS.md"
    
    cp "$TEMP_DIR/external-connector/SOUL.md" "$WORKSPACE_BASE/workspace-external-connector/SOUL.md"
    cp "$TEMP_DIR/external-connector/AGENTS.md" "$WORKSPACE_BASE/workspace-external-connector/AGENTS.md"
    
    info "Workspaces 创建完成"
}

# 注册 Agent
# 注意：openclaw agents add 命令格式
# openclaw agents add <agentId> --workspace <dir> --non-interactive
# 
# 重要：
# 1. 不要使用 --name 参数，该参数不存在
# 2. 不要使用 --bind 参数，binding 需要单独配置
# 3. 必须使用 --non-interactive 参数，否则会进入交互模式
# 4. 注册后会自动创建 agentDir：~/.openclaw/agents/<agentId>/agent

register_agents() {
    info "注册 Agent..."
    
    # 注册 TruthSeeker
    info "注册 TruthSeeker..."
    openclaw agents add truth-seeker \
        --workspace "$HOME/.openclaw/workspace-truth-seeker" \
        --non-interactive
    
    # 注册 UserAvatar
    info "注册 UserAvatar..."
    openclaw agents add user-avatar \
        --workspace "$HOME/.openclaw/workspace-user-avatar" \
        --non-interactive
    
    # 注册 EliteAdvisor
    info "注册 EliteAdvisor..."
    openclaw agents add elite-advisor \
        --workspace "$HOME/.openclaw/workspace-elite-advisor" \
        --non-interactive
    
    # 注册 ExternalConnector
    info "注册 ExternalConnector..."
    openclaw agents add external-connector \
        --workspace "$HOME/.openclaw/workspace-external-connector" \
        --non-interactive
    
    info "Agent 注册完成"
}

# 创建 Channel Accounts 并配置 bindings
# 注意：这是关键步骤，需要同时完成两件事：
# 1. 创建 channel accounts（配置 botToken、dmPolicy、allowFrom）
# 2. 配置 bindings（将 Agent 与 account 绑定）
# 
# 重要：
# 1. allowFrom 需要设置为用户的 Telegram ID
#    获取方法：在 Telegram 中发送消息给 @userinfobot
# 2. dmPolicy 设置为 "allowlist"，只允许特定用户访问
# 3. bindings 必须配置，否则 Agent 无法接收消息
# 
# 配置路径：
# - channels.telegram.accounts.<accountId>.botToken
# - channels.telegram.accounts.<accountId>.dmPolicy
# - channels.telegram.accounts.<accountId>.allowFrom
# - bindings（数组，每个元素包含 agentId 和 match）

create_channel_accounts_and_bindings() {
    info "创建 Channel Accounts 并配置 bindings..."
    
    if [ "$PLATFORM" == "other" ]; then
        warn "其他平台需要手动配置 channel 绑定"
        return
    fi
    
    # 创建 TruthSeeker account
    info "创建 TruthSeeker account..."
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.botToken" "$TRUTH_SEEKER_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.allowFrom" '[8434568597]'
    
    # 创建 UserAvatar account
    info "创建 UserAvatar account..."
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.botToken" "$USER_AVATAR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.allowFrom" '[8434568597]'
    
    # 创建 EliteAdvisor account
    info "创建 EliteAdvisor account..."
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.botToken" "$ELITE_ADVISOR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.allowFrom" '[8434568597]'
    
    # 创建 ExternalConnector account
    info "创建 ExternalConnector account..."
    openclaw config set "channels.$PLATFORM.accounts.external-connector.botToken" "$EXTERNAL_CONNECTOR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.external-connector.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.external-connector.allowFrom" '[8434568597]'
    
    # 配置 bindings
    # 注意：bindings 是数组，每个元素包含 agentId 和 match
    # match 包含 channel 和 accountId
    # 必须包含所有 Agent，包括已有的和新注册的
    
    info "配置 bindings..."
    openclaw config set bindings '[
      {"agentId": "main", "match": {"channel": "telegram", "accountId": "main"}},
      {"agentId": "engineer-musk", "match": {"channel": "telegram", "accountId": "musk"}},
      {"agentId": "scientist", "match": {"channel": "telegram", "accountId": "scientist"}},
      {"agentId": "creator", "match": {"channel": "telegram", "accountId": "creator"}},
      {"agentId": "coder", "match": {"channel": "telegram", "accountId": "coder"}},
      {"agentId": "truth-seeker", "match": {"channel": "telegram", "accountId": "truth-seeker"}},
      {"agentId": "user-avatar", "match": {"channel": "telegram", "accountId": "user-avatar"}},
      {"agentId": "elite-advisor", "match": {"channel": "telegram", "accountId": "elite-advisor"}},
      {"agentId": "external-connector", "match": {"channel": "telegram", "accountId": "external-connector"}}
    ]' --strict-json
    
    info "Channel Accounts 和 bindings 创建完成"
}

# 配置定时任务（cron）
# 注意：cron 配置让 Agent 定期自动执行任务
# 配置路径：cron.jobs 数组
# 
# TruthSeeker：每6小时主动检查，发现用户沉默时主动发消息
# - 检查用户最后回复时间
# - 如果超过6小时，主动发起对话
# - 使用不同策略吸引用户注意力
# 
# UserAvatar：每6小时自主检查，自动布置任务
# - 扫描项目状态
# - 检查目标对齐
# - 发现机会
# - 自动布置任务给 ExternalConnector
# 
# EliteAdvisor：每日指导（每天一次）
# - 每天检查所有 Agent 的状态
# - 每天向用户汇报团队状况
# - 每天提供指导建议
# 
# 注意：cron 使用 sessionTarget: "main" 时，会在主会话中植入消息
# 使用 sessionTarget: "isolated" 时，会在独立会话中执行

configure_cron() {
    info "配置定时任务（cron）..."
    
    # TruthSeeker：每6小时主动检查（检查用户沉默 + 主动发消息）
    info "配置 TruthSeeker 主动检查..."
    openclaw config set cron.jobs '[
      {
        "name": "truth-seeker-active-check",
        "schedule": "0 */6 * * *",
        "agentId": "truth-seeker",
        "sessionTarget": "main",
        "message": "执行主动检查：1.检查用户最后回复时间 2.如果超过6小时无回复，主动发起对话吸引注意力 3.检查user_profile.md是否需要更新 4.发现需要验证的新信息"
      },
      {
        "name": "user-avatar-auto-task",
        "schedule": "0 */6 * * *",
        "agentId": "user-avatar",
        "sessionTarget": "isolated",
        "message": "执行自主任务布置：1.扫描所有项目状态 2.检查目标对齐情况 3.发现机会和风险 4.自动布置任务给ExternalConnector 5.向用户汇报发现和计划"
      },
      {
        "name": "elite-advisor-daily-check",
        "schedule": "0 9 * * *",
        "agentId": "elite-advisor",
        "sessionTarget": "main",
        "message": "执行每日检查：1.读取所有Agent的今日对话和记忆 2.评估团队整体状态 3.发现问题并提供指导建议 4.向用户汇报今日状况和建议"
      }
    ]' --strict-json
    
    info "定时任务配置完成"
    info "TruthSeeker：每6小时主动检查，发现用户沉默时主动发消息"
    info "UserAvatar：每6小时自主检查，自动布置任务"
    info "EliteAdvisor：每天 9:00 执行每日指导"
}

# 配置 Agent-to-Agent 通信
# 注意：这是全局配置，控制哪些 Agent 可以互相调用
# 配置路径：tools.agentToAgent.enabled 和 tools.agentToAgent.allow
# 
# 重要：
# 1. 必须设置 enabled: true
# 2. allow 数组必须包含所有需要通信的 Agent ID
# 3. 修改后需要重启 Gateway 才能生效

configure_agent_communication() {
    info "配置 Agent-to-Agent 通信..."
    
    # 添加内阁AI Agent 到允许列表
    info "更新 agent-to-agent 允许列表..."
    openclaw config set tools.agentToAgent.enabled true
    openclaw config set tools.agentToAgent.allow '["main", "engineer-musk", "scientist", "creator", "coder", "truth-seeker", "user-avatar", "elite-advisor", "external-connector"]'
    
    info "Agent-to-Agent 通信配置完成"
}

# 创建共享文件
# 注意：共享文件放在 TruthSeeker 的 workspace 中
# 因为 TruthSeeker 是信息的入口和出口
# 
# 文件位置：
# - ~/.openclaw/workspace-truth-seeker/TEAM_REGISTRY.md
# - ~/.openclaw/workspace-truth-seeker/user_profile.md
# 
# 其他 Agent 可以通过读取这些文件获取共享信息

create_shared_files() {
    info "创建共享文件..."
    
    # 创建 TEAM_REGISTRY.md 在 TruthSeeker workspace
    cat > "$HOME/.openclaw/workspace-truth-seeker/TEAM_REGISTRY.md" << 'EOF'
# TEAM_REGISTRY.md — 团队注册表

## Agent 注册表

### TruthSeeker
- **ID**: truth-seeker
- **能力**: 用户对话、真相追问、画像生成
- **Workspace**: ~/.openclaw/workspace-truth-seeker
- **状态**: 活跃

### UserAvatar
- **ID**: user-avatar
- **能力**: 自主决策、目标制定、任务布置
- **Workspace**: ~/.openclaw/workspace-user-avatar
- **状态**: 活跃
- **依赖**: user_profile.md

### EliteAdvisor
- **ID**: elite-advisor
- **能力**: 主动监督、思维注入、质量把关
- **Workspace**: ~/.openclaw/workspace-elite-advisor
- **状态**: 活跃
- **监督范围**: TruthSeeker, UserAvatar, ExternalConnector

### ExternalConnector
- **ID**: external-connector
- **能力**: 任务执行、信息中枢、外部对接
- **Workspace**: ~/.openclaw/workspace-external-connector
- **状态**: 活跃
- **掌握信息**: 团队全信息、工具全清单、外部全联系

## 工具注册表

| 工具名 | 类型 | 能力 | 状态 |
|-------|------|------|------|
| (待配置) | | | |

## 外部联系注册表

| 外部团队 | 联系人 | 协议 | 用途 |
|---------|--------|------|------|
| (待配置) | | | |
EOF
    
    # 创建 user_profile.md 在 TruthSeeker workspace（使用增强版模板）
    cat > "$HOME/.openclaw/workspace-truth-seeker/user_profile.md" << 'EOF'
# 用户画像：{用户ID}
## 建立时间：{timestamp}
## TruthSeeker评估：真相挖掘中 ⏳

---

## 0. 核心身份标识

| 项目 | 事实 |
|------|------|
| 姓名 | ... |
| 常用ID | ... |
| 年龄 | ... |
| 学校/工作 | ... |
| 专业/职位 | ... |
| 时区 | ... |

---

## 1. 物理现状 (Physical Reality)

### 1.1 可验证事实

| 项目 | 事实 | 验证方式 | 置信度 |
|------|------|---------|--------|
| 职业/身份 | ... | ... | 高/中/低 |
| 技术栈 | ... | ... | 高/中/低 |
| 硬件设备 | ... | ... | 高/中/低 |
| 财务 | ... | ... | 高/中/低 |
| 时间可支配 | ... | ... | 高/中/低 |
| 技能验证 | ... | ... | 高/中/低 |

### 1.2 主观状态（作为事实记录，标注置信度）

| 状态 | 用户描述 | 置信度 | 评估依据 |
|------|---------|--------|---------|
| 满意度 | ... | 高/中/低 | ... |
| 能量水平 | ... | 高/中/低 | ... |
| 社交欲望 | ... | 高/中/低 | ... |
| 成就感 | ... | 高/中/低 | ... |

### 1.3 环境约束（硬性物理边界）

| 约束 | 具体表现 | 影响程度 |
|------|---------|---------|
| 地理 | ... | ... |
| 家庭 | ... | ... |
| 学校/工作 | ... | ... |
| 健康 | ... | ... |
| 时间窗口 | ... | ... |

---

## 2. 目标真相 (True Goals)

### 2.1 用户表达的目标

> 用户原话

### 2.2 挖掘出的真实目标

| 层级 | 目标 | 证据 |
|------|------|------|
| 表层 | ... | 直接陈述 |
| 中层 | ... | 反复提及 |
| 深层 | ... | 行为模式 |
| 隐藏 | ... | 间接推断 |

### 2.3 目标验证状态

| 维度 | 评估 | 说明 |
|------|------|------|
| SMART | ... | ... |
| 可行性 | ... | ... |
| 认知偏差 | ... | ... |
| 替代路径 | ... | ... |

---

## 3. 认知限制 (Cognitive Constraints)

### 3.1 已识别的认知偏差

| 偏差名称 | 具体表现 | 出现情境 | 频率 |
|---------|---------|---------|------|
| ... | ... | ... | ... |

### 3.2 信息盲区

| 盲区 | 为什么重要 | 如何获取 |
|------|-----------|---------|
| ... | ... | ... |

### 3.3 回避模式（作为事实记录）

| 回避话题 | 出现情境 | 可能原因 |
|---------|---------|---------|
| ... | ... | ... |

---

## 4. 物理限制 (Physical Constraints)

### 4.1 时间限制
- ...

### 4.2 财务限制
- ...

### 4.3 能力限制
- ...

### 4.4 关系限制
- ...

### 4.5 心理限制（作为物理事实）
- ...

---

## 5. 动机事实 (Motivation Facts)

### 5.1 用户自述动机
- ...

### 5.2 挖掘出的真实动机
- ...

### 5.3 动机强度（基于行为证据）

| 动机 | 支持证据 | 反对证据 | 评估 |
|------|---------|---------|------|
| ... | ... | ... | ... |

---

## 6. 路径事实 (Path Facts)

### 6.1 已验证路径

| 路径 | 已完成 | 反馈 | 结果 |
|------|--------|------|------|
| ... | ... | ... | ... |

### 6.2 待验证假设

| 假设 | 验证方法 | 标准 | 截止日期 |
|------|---------|------|---------|
| ... | ... | ... | ... |

### 6.3 已知障碍

| 障碍 | 性质 | 可克服？ | 成本 |
|------|------|---------|------|
| ... | ... | ... | ... |

---

## 7. 特质分析（对话中发现的隐性特质）

### 7.1 认知特质

| 特质 | 表现 | 优势 | 风险 |
|------|------|------|------|
| ... | ... | ... | ... |

### 7.2 情感特质

| 特质 | 表现 | 来源推测 |
|------|------|---------|
| ... | ... | ... |

### 7.3 行为特质

| 特质 | 表现 | 影响 |
|------|------|------|
| ... | ... | ... |

### 7.4 社交特质

| 特质 | 表现 | 解读 |
|------|------|------|
| ... | ... | ... |

---

## 8. 关键转折点记录

| 时间 | 事件 | 意义 |
|------|------|------|
| ... | ... | ... |

---

## 9. 置信度评估

| 维度 | 评分 | 理由 |
|------|------|------|
| 现状清晰度 | 0/10 | ... |
| 目标清晰度 | 0/10 | ... |
| 路径清晰度 | 0/10 | ... |
| 信息完整度 | 0/10 | ... |
| 综合置信度 | 0/10 | ... |

---

## 10. 更新日志 (Changelog)

### {日期}
- **建立画像**：首次创建
- **核心发现**：待填充
- **关键待验证**：待填充

---

## 11. 待确认问题清单

1. [ ] 问题1：...
2. [ ] 问题2：...

---

## 12. 动态定制化模块（Dynamic Customization）

### 12.1 用户专属框架扩展区

**说明**：根据用户独特情况动态添加，不是每个用户都有。

#### 【模块示例：科研工作者】
```markdown
### 科研特质档案
| 维度 | 事实 | 置信度 |
|------|------|--------|
| 研究风格 | 理论偏好/实验偏好/工程偏好 | |
| 创新模式 | 组合式/突破式/改进式/迁移式 | |
| 失败反应 | 归因方式、恢复速度、学习提取 | |
| 合作模式 | 独立/小团队/大团队、沟通风格 | |
| 学术品味 | 对什么类型工作有直觉性厌恶/欣赏 | |

### 科研心理动力学
- **灵感来源**：何时/何地/什么状态下产生好想法
- **写作障碍**：卡在哪里、如何突破
- **审稿创伤**：对批评的敏感度、恢复模式
- **同辈压力**：与谁比较、比较维度、影响程度
```

#### 【模块示例：创业者】
```markdown
### 创业心理档案
| 维度 | 事实 | 置信度 |
|------|------|--------|
| 风险偏好 | 对不确定性的容忍度 | |
| 决策风格 | 直觉型/数据型/混合型 | |
| 领导模式 | 愿景驱动/执行驱动/关系驱动 | |
| 失败恐惧 | 对什么类型的失败最敏感 | |
| 机会识别 | 如何发现机会、验证方式 | |

### 创业能量管理
- **高峰状态**：什么条件下进入心流
- **burnout前兆**：预警信号、恢复周期
- **决策疲劳**：何时出现、如何缓解
- **孤独感处理**：如何面对创业孤独
```

#### 【模块示例：社交焦虑者】
```markdown
### 社交心理动力学
| 维度 | 事实 | 置信度 |
|------|------|--------|
| 焦虑触发 | 具体场景、生理反应、认知内容 | |
| 安全行为 | 回避什么、用什么替代 | |
| 核心恐惧 | 被评价/被拒绝/被忽视/表现不佳 | |
| 社交脚本 | 是否有预设对话流程 | |
| 关系模式 | 亲近-回避-焦虑的混合比例 | |

### 社交能力基线
- **已掌握技能**：能做什么（如：1v1深度对话、书面沟通）
- **发展中技能**：正在练习什么
- **盲区技能**：完全不会/没意识到的
- **社交能量预算**：每天能承受多少社交、什么类型
```

### 12.2 用户自定义标签系统

**说明**：TruthSeeker在对话中发现的用户独特标签，持续更新。

```markdown
### 标签云（Tags）
| 标签 | 发现场景 | 证据 | 置信度 |
|------|---------|------|--------|
| #标签名 | ... | ... | 高/中/低 |

### 特质组合模式
- **核心模式**：标签1 + 标签2 = 「模式名称」
- **矛盾模式**：标签3 + 标签4 = 「矛盾描述」
- **能量模式**：标签5 + 标签6 = 「能量描述」
- **成就模式**：标签7 + 标签8 = 「成就描述」
```

### 12.3 隐性特质深度档案

**说明**：TruthSeeker在对话中捕捉到的、用户未直接表达但反复出现的隐性特质。

```markdown
### 隐性特质档案

#### 特质1：【名称】
- **发现证据**：具体对话片段、行为模式
- **表现形式**：在什么情境下出现、如何表现
- **深层机制**：可能的形成原因、心理动力学
- **功能分析**：这个特质在保护什么、在表达什么
- **影响评估**：对目标/关系/健康的具体影响
- **干预建议**：如何与此特质工作（不是消除，是理解+调整）

#### 特质2：【名称】
...
```

### 12.4 用户专属隐喻系统

**说明**：用户用来理解自己的独特隐喻，反映其认知框架。

```markdown
### 隐喻档案
| 隐喻 | 使用场景 | 反映的认知框架 | 隐含假设 |
|------|---------|--------------|---------|
| ... | ... | ... | ... |

### 隐喻分析
- **主导隐喻类型**：...
- **缺失隐喻类型**：...
- **隐喻冲突**：...
- **隐喻扩展建议**：...
```

### 12.5 用户专属语言模式

**说明**：用户独特的语言习惯，反映其认知和情感模式。

```markdown
### 语言指纹
| 模式 | 示例 | 反映的特质 |
|------|------|-----------|
| ... | ... | ... |

### 语言变化追踪
- **压力信号**：...
- **开放信号**：...
- **能量信号**：...
```

### 12.6 用户专属决策模式

**说明**：用户做决定时的独特模式，包括显性和隐性因素。

```markdown
### 决策档案
| 维度 | 模式 | 证据 |
|------|------|------|
| 信息收集 | ... | ... |
| 选项生成 | ... | ... |
| 评估标准 | ... | ... |
| 决策速度 | ... | ... |
| 执行阻力 | ... | ... |
| 后悔模式 | ... | ... |

### 决策陷阱
- **已知陷阱**：...
- **触发情境**：...
- **早期预警信号**：...
- **绕过策略**：...

### 好决策时刻
- **情境**：...
- **条件**：...
- **可复制性**：...
```

### 12.7 用户专属关系动力学

**说明**：用户在不同关系中的独特模式。

```markdown
### 关系模式档案
| 关系类型 | 模式 | 需求 | 恐惧 | 行为 |
|---------|------|------|------|------|
| 权威 | ... | ... | ... | ... |
| 同辈 | ... | ... | ... | ... |
| 潜在合作者 | ... | ... | ... | ... |
| 亲密关系 | ... | ... | ... | ... |
| 群体 | ... | ... | ... | ... |
| 线上/匿名 | ... | ... | ... | ... |

### 关系需求层次
- **表层需求**：...
- **深层需求**：...
- **隐藏需求**：...
- **恐惧层次**：...

### 关系能力基线
- **擅长**：...
- **困难**：...
- **盲区**：...
- **成长区**：...
```

### 12.8 用户专属能量与状态模式

**说明**：用户独特的能量波动和状态转换模式。

```markdown
### 能量地形图
| 状态 | 触发条件 | 持续时间 | 表现 | 恢复方式 |
|------|---------|---------|------|---------|
| 高能量 | ... | ... | ... | ... |
| 心流 | ... | ... | ... | ... |
| 平稳 | ... | ... | ... | ... |
| 低落 | ... | ... | ... | ... |
| 崩溃 | ... | ... | ... | ... |
| 麻木 | ... | ... | ... | ... |

### 状态转换路径
- **常见路径**：...
- **理想路径**：...
- **危险路径**：...
- **恢复路径**：...

### 能量管理策略
- **已验证有效**：...
- **理论上知道但未执行**：...
- **无效/反效果**：...
- **待实验**：...
```

### 12.9 用户专属成长轨迹

**说明**：用户独特的成长模式和关键转折点。

```markdown
### 成长档案
| 阶段 | 时间 | 关键事件 | 模式建立 | 遗留影响 |
|------|------|---------|---------|---------|
| 早期 | ... | ... | ... | ... |
| 转折1 | ... | ... | ... | ... |
| 发展期 | ... | ... | ... | ... |
| 转折2 | ... | ... | ... | ... |
| 当前 | ... | ... | ... | ... |

### 重复模式
- **成功模式**：...
- **失败模式**：...
- **逃避模式**：...
- **成长模式**：...

### 关键洞察时刻
- **何时**：...
- **触发**：...
- **内容**：...
- **后续**：...
```

### 12.10 用户专属干预响应档案

**说明**：记录什么类型的干预对用户有效/无效。

```markdown
### 干预响应档案
| 干预类型 | 具体方式 | 用户反应 | 效果 | 备注 |
|---------|---------|---------|------|------|
| 直接追问 | ... | ... | ... | ... |
| 认知重构 | ... | ... | ... | ... |
| 情感反映 | ... | ... | ... | ... |
| 行为实验 | ... | ... | ... | ... |
| 系统分析 | ... | ... | ... | ... |
| 隐喻工作 | ... | ... | ... | ... |
| 身体关注 | ... | ... | ... | ... |
| 社交暴露 | ... | ... | ... | ... |

### 有效干预特征
- **共同特征**：...
- **时机特征**：...
- **方式特征**：...

### 无效/反效果干预
- **类型**：...
- **原因**：...
- **替代方案**：...
```

---

## 13. 待确认问题清单（动态更新）

**说明**：持续更新的待确认问题，根据对话动态添加和标记。

```markdown
### 待确认问题
1. [ ] 问题1：...（添加时间：...，来源：...，优先级：P0/P1/P2/P3）
2. [x] 问题2：...（已确认：...，确认时间：...）

### 问题优先级规则
- **P0**：影响当前决策，需立即确认
- **P1**：影响路径选择，需近期确认
- **P2**：完善画像，可逐步确认
- **P3**：背景信息，有机会时确认
```

---

## 14. 给后续Agent的备注（动态更新）

**说明**：根据新发现持续更新的交互指南。

### 与用户交互原则（v1.0）
```markdown
### 核心原则
1. ...
2. ...

### 新增原则（基于新发现）
- [日期] 发现：... → 新增原则：...

### 废除原则（基于验证）
- [日期] 验证：... → 原则X不适用，原因：...
```

### 关键触发点（动态扩展）
```markdown
| 触发信号 | 含义 | 建议响应 | 验证状态 |
|---------|------|---------|---------|
| ... | ... | ... | 待验证/已验证 |
```

### 有效策略参考（动态扩展）
```markdown
| 策略 | 适用情境 | 效果 | 验证状态 |
|------|---------|------|---------|
| ... | ... | ... | 实验中/已验证 |
```
EOF
    
    info "共享文件创建完成"
}

# 验证安装
# 注意：验证步骤包括：
# 1. 检查 Agent 是否注册成功
# 2. 检查 Agent-to-Agent 配置
# 3. 检查 workspace 目录
# 4. 检查共享文件
# 
# 常见问题排查：
# - 如果 Agent 未注册成功，检查 openclaw agents list
# - 如果 binding 未生效，检查 openclaw config get bindings
# - 如果 Agent 无法通信，检查 tools.agentToAgent.allow

verify_installation() {
    info "验证安装..."
    
    echo ""
    echo "=== 已注册 Agent ==="
    openclaw agents list
    
    echo ""
    echo "=== Agent-to-Agent 通信配置 ==="
    openclaw config get tools.agentToAgent.allow || true
    
    echo ""
    echo "=== Workspace 目录 ==="
    ls -la ~/.openclaw/workspace-* 2>/dev/null || true
    
    echo ""
    echo "=== 共享文件 ==="
    ls -la ~/.openclaw/workspace-truth-seeker/*.md 2>/dev/null || true
    
    info "验证完成"
}

# 主函数
# 注意：执行流程
# 1. 检查环境（OpenClaw + Gateway）
# 2. 询问配置（团队名称、用户昵称、平台、botToken）
# 3. 创建 workspaces（复制模板文件）
# 4. 注册 Agent（openclaw agents add）
# 5. 创建 Channel Accounts（配置 botToken）
# 6. 配置 Bindings（将 Agent 与 account 绑定）
# 7. 配置 Agent-to-Agent（设置允许列表）
# 8. 创建共享文件（TEAM_REGISTRY.md、user_profile.md）
# 9. 验证安装
# 10. 提示重启 Gateway

main() {
    echo "=== 内阁AI团队一键部署 ==="
    echo ""
    
    check_openclaw
    check_gateway
    ask_user_config
    render_templates
    create_workspaces
    register_agents
    create_channel_accounts_and_bindings
    configure_cron
    configure_agent_communication
    create_shared_files
    verify_installation
    
    echo ""
    echo "=== 部署完成 ==="
    echo ""
    echo "团队名称: $TEAM_NAME"
    echo "用户昵称: $USER_NAME"
    echo "绑定平台: $PLATFORM"
    echo ""
    echo "已部署 Agent:"
    echo "  - TruthSeeker (真相探寻者)"
    echo "  - UserAvatar (用户分身)"
    echo "  - EliteAdvisor (顶级顾问)"
    echo "  - ExternalConnector (外部对接)"
    echo ""
    echo "重要：必须重启 Gateway 才能生效！"
    echo "执行命令：openclaw gateway restart"
    echo ""
    echo "下一步:"
    echo "  1. 重启 Gateway: openclaw gateway restart"
    echo "  2. 与 TruthSeeker 对话，建立用户画像"
    echo "  3. 配置外部团队链接 (ExternalConnector)"
    echo "  4. EliteAdvisor 已配置每天 9:00 自动执行每日指导"
    echo "  5. UserAvatar 已配置每 12 小时自动执行自主行动"
    echo ""
    echo "定时任务说明:"
    echo "  - EliteAdvisor: 每天 9:00 检查所有 Agent 状态，向用户汇报"
    echo "  - UserAvatar: 每 12 小时搜集信息、优化项目、发现机会"
    echo ""
    echo "注意事项:"
    echo "  - 如果 Agent 无法接收消息，检查 bindings 配置"
    echo "  - 如果 Agent 无法通信，检查 tools.agentToAgent.allow"
    echo "  - 如果需要回滚，查看 openclaw.json.bak 备份文件"
    echo "  - 定时任务在 Gateway 重启后自动生效"
    echo ""
    echo "定义'好'的标准:"
    echo "  UserAvatar 会基于以下标准评估和优化:"
    echo "  - 是否更接近用户目标"
    echo "  - 是否更高效利用资源"
    echo "  - 是否更可持续"
    echo "  - 是否更符合用户价值观"
    echo ""
    
    # 清理临时目录
    rm -rf "$TEMP_DIR"
}

# 执行主函数
main
