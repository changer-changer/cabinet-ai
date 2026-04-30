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
# EliteAdvisor：每日指导 + 每日更新状况
# - 每天检查所有 Agent 的状态
# - 每天向用户汇报团队状况
# - 每天提供指导建议
# 
# UserAvatar：每12小时自主行动
# - 每12小时搜集信息、发现机会
# - 检查正在进行的项目
# - 优化项目执行
# - 定义"好"的标准并优化
# 
# 注意：cron 使用 sessionTarget: "main" 时，会在主会话中植入消息
# 使用 sessionTarget: "isolated" 时，会在独立会话中执行

configure_cron() {
    info "配置定时任务（cron）..."
    
    # EliteAdvisor：每日指导（每天一次）
    info "配置 EliteAdvisor 每日指导..."
    openclaw config set cron.jobs '[
      {
        "name": "elite-advisor-daily-check",
        "schedule": "0 9 * * *",
        "agentId": "elite-advisor",
        "sessionTarget": "main",
        "message": "执行每日检查：1.读取所有Agent的今日对话和记忆 2.评估团队整体状态 3.发现问题并提供指导建议 4.向用户汇报今日状况和建议"
      },
      {
        "name": "user-avatar-12h-action",
        "schedule": "0 */12 * * *",
        "agentId": "user-avatar",
        "sessionTarget": "isolated",
        "message": "执行12小时自主行动：1.搜集用户目标领域的最新信息 2.检查正在进行的项目状态 3.评估项目执行质量（定义好的标准：是否更接近目标、是否更高效、是否更可持续） 4.发现优化机会 5.生成行动建议"
      }
    ]' --strict-json
    
    info "定时任务配置完成"
    info "EliteAdvisor：每天 9:00 执行每日指导"
    info "UserAvatar：每12小时执行自主行动"
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
    
    # 创建空的 user_profile.md 在 TruthSeeker workspace
    touch "$HOME/.openclaw/workspace-truth-seeker/user_profile.md"
    
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
