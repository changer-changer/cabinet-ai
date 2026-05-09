#!/bin/bash
# TruthTeam 多Agent系统一键部署脚本
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
check_openclaw() {
    if ! command -v openclaw &> /dev/null; then
        error "OpenClaw CLI 未安装，请先安装 OpenClaw"
    fi
    info "OpenClaw 已安装"
}

# 检查 Gateway 是否运行
check_gateway() {
    if ! openclaw gateway status &> /dev/null; then
        error "Gateway 未运行，请先启动 Gateway"
    fi
    info "Gateway 运行中"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "脚本目录: $SCRIPT_DIR"

# 询问用户配置
ask_user_config() {
    echo ""
    echo "=== TruthTeam 多Agent系统部署配置 ==="
    echo ""

    # 询问团队名称
    read -p "团队名称 (默认: TruthTeam): " TEAM_NAME
    TEAM_NAME=${TEAM_NAME:-TruthTeam}

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
create_workspaces() {
    info "创建 Agent workspaces..."

    WORKSPACE_BASE="$HOME/.openclaw"

    # 创建目录
    mkdir -p "$WORKSPACE_BASE/workspace-truth-seeker"
    mkdir -p "$WORKSPACE_BASE/workspace-user-avatar"
    mkdir -p "$WORKSPACE_BASE/workspace-elite-advisor"
    mkdir -p "$WORKSPACE_BASE/workspace-external-connector"

    # 复制 Agent 定义文件（SOUL.md, AGENTS.md, IDENTITY.md, TOOLS.md）
    cp "$TEMP_DIR/truth-seeker/SOUL.md" "$WORKSPACE_BASE/workspace-truth-seeker/SOUL.md"
    cp "$TEMP_DIR/truth-seeker/AGENTS.md" "$WORKSPACE_BASE/workspace-truth-seeker/AGENTS.md"
    cp "$TEMP_DIR/truth-seeker/IDENTITY.md" "$WORKSPACE_BASE/workspace-truth-seeker/IDENTITY.md"
    cp "$TEMP_DIR/truth-seeker/TOOLS.md" "$WORKSPACE_BASE/workspace-truth-seeker/TOOLS.md"

    cp "$TEMP_DIR/user-avatar/SOUL.md" "$WORKSPACE_BASE/workspace-user-avatar/SOUL.md"
    cp "$TEMP_DIR/user-avatar/AGENTS.md" "$WORKSPACE_BASE/workspace-user-avatar/AGENTS.md"
    cp "$TEMP_DIR/user-avatar/IDENTITY.md" "$WORKSPACE_BASE/workspace-user-avatar/IDENTITY.md"
    cp "$TEMP_DIR/user-avatar/TOOLS.md" "$WORKSPACE_BASE/workspace-user-avatar/TOOLS.md"

    cp "$TEMP_DIR/elite-advisor/SOUL.md" "$WORKSPACE_BASE/workspace-elite-advisor/SOUL.md"
    cp "$TEMP_DIR/elite-advisor/AGENTS.md" "$WORKSPACE_BASE/workspace-elite-advisor/AGENTS.md"
    cp "$TEMP_DIR/elite-advisor/IDENTITY.md" "$WORKSPACE_BASE/workspace-elite-advisor/IDENTITY.md"
    cp "$TEMP_DIR/elite-advisor/TOOLS.md" "$WORKSPACE_BASE/workspace-elite-advisor/TOOLS.md"

    cp "$TEMP_DIR/external-connector/SOUL.md" "$WORKSPACE_BASE/workspace-external-connector/SOUL.md"
    cp "$TEMP_DIR/external-connector/AGENTS.md" "$WORKSPACE_BASE/workspace-external-connector/AGENTS.md"
    cp "$TEMP_DIR/external-connector/IDENTITY.md" "$WORKSPACE_BASE/workspace-external-connector/IDENTITY.md"
    cp "$TEMP_DIR/external-connector/TOOLS.md" "$WORKSPACE_BASE/workspace-external-connector/TOOLS.md"

    info "Workspaces 创建完成"
}

# 创建用户资料库（User Archive）
create_user_archive() {
    info "创建用户资料库（User Archive）..."

    ARCHIVE_DIR="$HOME/.openclaw/workspace-truth-seeker/user-archive"

    # 复制模板文件和目录结构
    cp -r "$TEMP_DIR/user-archive/"* "$ARCHIVE_DIR/"

    # 初始化 git
    if [ ! -d "$ARCHIVE_DIR/.git" ]; then
        cd "$ARCHIVE_DIR"
        git init
        git add .
        git commit -m "[SYSTEM] Initialize user archive"
        info "Git 仓库已初始化"
    else
        info "Git 仓库已存在，跳过初始化"
    fi

    info "用户资料库创建完成: $ARCHIVE_DIR"
}

# 注册 Agent（幂等）
register_agents() {
    info "注册 Agent..."

    # 获取已注册的 agent 列表
    EXISTING_AGENTS=$(openclaw agents list 2>/dev/null | grep -oE '^[a-z0-9-]+' || true)

    # 注册 TruthSeeker
    if echo "$EXISTING_AGENTS" | grep -q "^truth-seeker$"; then
        info "TruthSeeker 已注册，跳过"
    else
        info "注册 TruthSeeker..."
        openclaw agents add truth-seeker \
            --workspace "$HOME/.openclaw/workspace-truth-seeker" \
            --non-interactive
    fi

    # 注册 UserAvatar
    if echo "$EXISTING_AGENTS" | grep -q "^user-avatar$"; then
        info "UserAvatar 已注册，跳过"
    else
        info "注册 UserAvatar..."
        openclaw agents add user-avatar \
            --workspace "$HOME/.openclaw/workspace-user-avatar" \
            --non-interactive
    fi

    # 注册 EliteAdvisor
    if echo "$EXISTING_AGENTS" | grep -q "^elite-advisor$"; then
        info "EliteAdvisor 已注册，跳过"
    else
        info "注册 EliteAdvisor..."
        openclaw agents add elite-advisor \
            --workspace "$HOME/.openclaw/workspace-elite-advisor" \
            --non-interactive
    fi

    # 注册 ExternalConnector
    if echo "$EXISTING_AGENTS" | grep -q "^external-connector$"; then
        info "ExternalConnector 已注册，跳过"
    else
        info "注册 ExternalConnector..."
        openclaw agents add external-connector \
            --workspace "$HOME/.openclaw/workspace-external-connector" \
            --non-interactive
    fi

    info "Agent 注册完成"
}

# 创建 Channel Accounts 并配置 bindings（幂等）
create_channel_accounts_and_bindings() {
    info "创建 Channel Accounts 并配置 bindings..."

    if [ "$PLATFORM" == "other" ]; then
        warn "其他平台需要手动配置 channel 绑定"
        return
    fi

    # 创建 Channel Accounts
    info "创建 TruthSeeker account..."
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.botToken" "$TRUTH_SEEKER_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.truth-seeker.allowFrom" '[8434568597]'

    info "创建 UserAvatar account..."
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.botToken" "$USER_AVATAR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.user-avatar.allowFrom" '[8434568597]'

    info "创建 EliteAdvisor account..."
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.botToken" "$ELITE_ADVISOR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.elite-advisor.allowFrom" '[8434568597]'

    info "创建 ExternalConnector account..."
    openclaw config set "channels.$PLATFORM.accounts.external-connector.botToken" "$EXTERNAL_CONNECTOR_TOKEN"
    openclaw config set "channels.$PLATFORM.accounts.external-connector.dmPolicy" "allowlist"
    openclaw config set "channels.$PLATFORM.accounts.external-connector.allowFrom" '[8434568597]'

    # 配置 bindings（幂等：读取现有，追加缺失）
    info "配置 bindings..."

    # 获取现有 bindings
    EXISTING_BINDINGS=$(openclaw config get bindings 2>/dev/null || echo '[]')

    # 定义需要添加的 bindings
    NEW_BINDINGS='[
      {"agentId": "truth-seeker", "match": {"channel": "'$PLATFORM'", "accountId": "truth-seeker"}},
      {"agentId": "user-avatar", "match": {"channel": "'$PLATFORM'", "accountId": "user-avatar"}},
      {"agentId": "elite-advisor", "match": {"channel": "'$PLATFORM'", "accountId": "elite-advisor"}},
      {"agentId": "external-connector", "match": {"channel": "'$PLATFORM'", "accountId": "external-connector"}}
    ]'

    # 使用 node 合并 bindings（避免依赖 jq）
    MERGED_BINDINGS=$(node -e "
        const existing = $EXISTING_BINDINGS;
        const newBindings = $NEW_BINDINGS;
        const existingIds = new Set(existing.map(b => b.agentId));
        const toAdd = newBindings.filter(b => !existingIds.has(b.agentId));
        const merged = [...existing, ...toAdd];
        console.log(JSON.stringify(merged, null, 2));
    ")

    openclaw config set bindings "$MERGED_BINDINGS" --strict-json

    info "Channel Accounts 和 bindings 创建完成"
}

# 配置定时任务（cron）——使用 openclaw cron add（幂等）
configure_cron() {
    info "配置定时任务（cron）..."

    # 获取现有 cron jobs
    EXISTING_CRONS=""
    if [ -f "$HOME/.openclaw/cron/jobs.json" ]; then
        EXISTING_CRONS=$(cat "$HOME/.openclaw/cron/jobs.json" 2>/dev/null || echo "[]")
    else
        EXISTING_CRONS="[]"
    fi

    # TruthSeeker：每6小时被动监控扫描
    if echo "$EXISTING_CRONS" | grep -q '"tt-truth-seeker-monitor"' 2>/dev/null; then
        info "TruthSeeker cron 已存在，跳过"
    else
        info "配置 TruthSeeker 被动监控..."
        openclaw cron add --name "tt-truth-seeker-monitor" \
            --agent truth-seeker --cron "0 */6 * * *" --session isolated \
            --message "【被动监控扫描】读取99-meta/scan-state.md，扫描所有agent session和memory，检测矛盾点，写入10-reports/contradictions.md，更新scan-state" \
            --description "TruthSeeker passive monitoring scan"
    fi

    # EliteAdvisor：每12小时定时指导
    if echo "$EXISTING_CRONS" | grep -q '"tt-elite-advisor-check"' 2>/dev/null; then
        info "EliteAdvisor cron 已存在，跳过"
    else
        info "配置 EliteAdvisor 定时指导..."
        openclaw cron add --name "tt-elite-advisor-check" \
            --agent elite-advisor --cron "0 */12 * * *" --session isolated \
            --message "【定时指导】读取用户资料库，检查所有agent记录，评估目标偏离风险，生成导师报告写入10-reports/elite-advisor/" \
            --description "EliteAdvisor mentoring check"
    fi

    # UserAvatar：每12小时自主行动（与 EliteAdvisor 错开6小时）
    if echo "$EXISTING_CRONS" | grep -q '"tt-user-avatar-action"' 2>/dev/null; then
        info "UserAvatar cron 已存在，跳过"
    else
        info "配置 UserAvatar 自主行动..."
        openclaw cron add --name "tt-user-avatar-action" \
            --agent user-avatar --cron "0 6,18 * * *" --session isolated \
            --message "【自主行动】读取用户资料库，搜集目标领域信息，检查项目进展，生成行动建议，如需执行则触发external-connector" \
            --description "UserAvatar autonomous action"
    fi

    info "定时任务配置完成"
    info "TruthSeeker：每6小时被动监控扫描"
    info "EliteAdvisor：每12小时定时指导"
    info "UserAvatar：每12小时自主行动（6:00 和 18:00）"
}

# 配置 Agent-to-Agent 通信
configure_agent_communication() {
    info "配置 Agent-to-Agent 通信..."

    # 启用 agent-to-agent
    openclaw config set tools.agentToAgent.enabled true

    # 获取现有 allow 列表
    EXISTING_ALLOW=$(openclaw config get tools.agentToAgent.allow 2>/dev/null || echo '[]')

    # 合并 allow 列表
    MERGED_ALLOW=$(node -e "
        const existing = $EXISTING_ALLOW;
        const newAgents = ['truth-seeker', 'user-avatar', 'elite-advisor', 'external-connector'];
        const merged = [...new Set([...existing, ...newAgents])];
        console.log(JSON.stringify(merged));
    ")

    openclaw config set tools.agentToAgent.allow "$MERGED_ALLOW"

    # 启用跨 agent session 可见性（TruthSeeker 被动监控需要）
    openclaw config set tools.sessions.visibility "all"

    info "Agent-to-Agent 通信配置完成"
    info "跨 agent session 可见性已启用（tools.sessions.visibility: all）"
}

# 创建共享文件（更新版：引用 user-archive）
create_shared_files() {
    info "创建共享文件..."

    # 创建 TEAM_REGISTRY.md 在 TruthSeeker workspace
    cat > "$HOME/.openclaw/workspace-truth-seeker/TEAM_REGISTRY.md" << 'EOF'
# TEAM_REGISTRY.md — 团队注册表

## Agent 注册表

### TruthSeeker
- **ID**: truth-seeker
- **能力**: 用户对话、真相追问、画像生成、被动监控
- **Workspace**: ~/.openclaw/workspace-truth-seeker
- **状态**: 活跃
- **核心产出**: user-archive/01-profile/

### UserAvatar
- **ID**: user-avatar
- **能力**: 自主决策、目标制定、任务布置
- **Workspace**: ~/.openclaw/workspace-user-avatar
- **状态**: 活跃
- **依赖**: user-archive/00-master-profile.md, user-archive/01-profile/

### EliteAdvisor
- **ID**: elite-advisor
- **能力**: 主动监督、思维注入、质量把关
- **Workspace**: ~/.openclaw/workspace-elite-advisor
- **状态**: 活跃
- **监督范围**: TruthSeeker, UserAvatar, ExternalConnector
- **读取**: user-archive/ 所有文件

### ExternalConnector
- **ID**: external-connector
- **能力**: 任务执行、信息中枢、外部对接
- **Workspace**: ~/.openclaw/workspace-external-connector
- **状态**: 活跃
- **掌握信息**: 团队全信息、工具全清单、外部全联系
- **读取**: user-archive/00-master-profile.md, user-archive/02-projects/

## 工具注册表

| 工具名 | 类型 | 能力 | 状态 |
|-------|------|------|------|
| (待配置) | | | |

## 外部联系注册表

| 外部团队 | 联系人 | 协议 | 用途 |
|---------|--------|------|------|
| (待配置) | | | |
EOF

    info "共享文件创建完成"
}

# 验证安装
verify_installation() {
    info "验证安装..."

    echo ""
    echo "=== 已注册 Agent ==="
    openclaw agents list

    echo ""
    echo "=== Agent-to-Agent 通信配置 ==="
    openclaw config get tools.agentToAgent.allow || true

    echo ""
    echo "=== Session 可见性 ==="
    openclaw config get tools.sessions.visibility || true

    echo ""
    echo "=== Workspace 目录 ==="
    ls -la ~/.openclaw/workspace-* 2>/dev/null || true

    echo ""
    echo "=== 用户资料库 ==="
    ls -la ~/.openclaw/workspace-truth-seeker/user-archive/ 2>/dev/null || true

    echo ""
    echo "=== 共享文件 ==="
    ls -la ~/.openclaw/workspace-truth-seeker/*.md 2>/dev/null || true

    info "验证完成"
}

# 主函数
main() {
    echo "=== TruthTeam 多Agent系统一键部署 ==="
    echo ""

    check_openclaw
    check_gateway
    ask_user_config
    render_templates
    create_workspaces
    create_user_archive
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
    echo "  - TruthSeeker (真相探寻者) — 被动监控 + 真相挖掘"
    echo "  - UserAvatar (用户分身) — 自主决策 + 任务布置"
    echo "  - EliteAdvisor (顶级顾问) — 主动监督 + 定时辅导"
    echo "  - ExternalConnector (外部对接) — 任务执行 + 外部链接"
    echo ""
    echo "用户资料库位置:"
    echo "  ~/.openclaw/workspace-truth-seeker/user-archive/"
    echo ""
    echo "重要：必须重启 Gateway 才能生效！"
    echo "执行命令：openclaw gateway restart"
    echo ""
    echo "下一步:"
    echo "  1. 重启 Gateway: openclaw gateway restart"
    echo "  2. 与 TruthSeeker 对话，建立用户画像"
    echo "  3. 配置外部团队链接 (ExternalConnector)"
    echo ""
    echo "定时任务说明:"
    echo "  - TruthSeeker: 每 6 小时扫描所有 session，检测矛盾点"
    echo "  - EliteAdvisor: 每 12 小时检查所有 Agent，生成导师报告"
    echo "  - UserAvatar: 每 12 小时自主行动（6:00 和 18:00）"
    echo ""
    echo "Agent 通信方式:"
    echo "  1. 共享文件系统: user-archive/ 目录读写"
    echo "  2. Bash 触发: openclaw agent --agent <id> --message ..."
    echo "  3. Cron 定时: 自动执行后台任务"
    echo ""
    echo "注意事项:"
    echo "  - 如果 Agent 无法接收消息，检查 bindings 配置"
    echo "  - 如果 Agent 无法通信，检查 tools.agentToAgent.allow"
    echo "  - 如果需要回滚，查看 openclaw.json.bak 备份文件"
    echo "  - 定时任务在 Gateway 重启后自动生效"
    echo ""

    # 清理临时目录
    rm -rf "$TEMP_DIR"
}

# 执行主函数
main
