#!/bin/bash
# TruthTeam 多Agent系统一键部署脚本
# 使用方法: bash install.sh [--dry-run] [--home <dir>]
#
# 参数:
#   --dry-run     干运行模式：打印所有命令但不实际执行（不污染本地openclaw）
#   --home <dir>  指定OpenClaw home目录（默认: ~/.openclaw）
#
# 重要说明：
# 1. 此脚本由智能体执行，不是由用户直接执行
# 2. 执行前需要确保 OpenClaw CLI 已安装且 Gateway 正在运行
# 3. 执行过程中会修改 openclaw.json，建议先备份
# 4. 执行完成后需要重启 Gateway 才能生效
# 5. 如果遇到问题，可以查看 openclaw.json.bak 备份文件

set -e

# ============================================
# 颜色定义和基础函数（必须在参数解析之前）
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

dry_run_info() {
    echo -e "${BLUE}[DRY-RUN]${NC} $1"
}

# ============================================
# 参数解析
# ============================================
DRY_RUN=false
OPENCLAW_HOME="${HOME}/.openclaw"
TEMP_HOME_CREATED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --home)
            OPENCLAW_HOME="$2"
            shift 2
            ;;
        *)
            warn "未知参数: $1"
            shift
            ;;
    esac
done

# 干运行模式：如果未指定 --home，创建临时目录
if [ "$DRY_RUN" = true ]; then
    if [ "$OPENCLAW_HOME" = "${HOME}/.openclaw" ]; then
        OPENCLAW_HOME=$(mktemp -d)
        TEMP_HOME_CREATED=true
        info "【干运行模式】使用临时目录: $OPENCLAW_HOME"
    else
        info "【干运行模式】使用指定目录: $OPENCLAW_HOME"
    fi
    info "所有 openclaw 命令仅打印不执行"
    info "文件操作在隔离目录中进行，不会污染本地 ~/.openclaw"
    echo ""
fi

# 错误处理
trap 'cleanup' EXIT

cleanup() {
    rm -rf "${TEMP_DIR:-}"
    if [ "$DRY_RUN" = true ] && [ "$TEMP_HOME_CREATED" = true ]; then
        info "【干运行】清理临时目录: $OPENCLAW_HOME"
        rm -rf "$OPENCLAW_HOME"
    fi
}

# ============================================
# 命令包装函数
# ============================================

# 运行普通命令（mkdir, cp, git等）
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "$*"
        # 在临时目录模式下实际执行（文件操作在隔离目录中，安全）
        # 这样 node 脚本等后续依赖可以正常验证
        if [ "$TEMP_HOME_CREATED" = true ]; then
            "$@"
        fi
    else
        "$@"
    fi
}

# 运行 openclaw 命令（不捕获输出）
run_openclaw() {
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "openclaw $*"
    else
        openclaw "$@"
    fi
}

# 运行 openclaw 命令并捕获输出
# 在干运行模式下返回空/模拟值，让脚本继续执行所有步骤
capture_openclaw() {
    if [ "$DRY_RUN" = true ]; then
        # 输出到 stderr，这样 $() 不会捕获它
        echo -e "${BLUE}[DRY-RUN]${NC} openclaw $*" >&2
        # 根据命令返回合理的模拟值，让脚本继续执行
        local cmd="$*"
        case "$cmd" in
            "agents list")
                echo ""
                ;;
            "config get bindings")
                echo '[]'
                ;;
            "config get tools.agentToAgent.allow")
                echo '[]'
                ;;
            *)
                echo ""
                ;;
        esac
    else
        openclaw "$@"
    fi
}

# 运行 node 命令
# 在干运行模式下仍然执行，因为操作的是临时目录中的文件
run_node() {
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "node $*"
    fi
    node "$@"
}

# 写文件（处理 heredoc）
write_file() {
    local file="$1"
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "cat > $file << 'EOF'"
        # 消耗 stdin 但不写入
        cat > /dev/null
    else
        cat > "$file"
    fi
}

# ============================================
# 检查函数
# ============================================

check_openclaw() {
    if [ "$DRY_RUN" = true ]; then
        if ! command -v openclaw &> /dev/null; then
            warn "【干运行】未检测到 openclaw CLI，继续验证脚本逻辑..."
        else
            info "OpenClaw 已安装"
        fi
    else
        if ! command -v openclaw &> /dev/null; then
            error "OpenClaw CLI 未安装，请先安装 OpenClaw"
        fi
        info "OpenClaw 已安装"
    fi
}

check_gateway() {
    if [ "$DRY_RUN" = true ]; then
        info "【干运行】跳过 Gateway 运行状态检查"
    else
        if ! openclaw gateway status &> /dev/null; then
            error "Gateway 未运行，请先启动 Gateway"
        fi
        info "Gateway 运行中"
    fi
}

# ============================================
# 配置收集
# ============================================

ask_user_config() {
    echo ""
    echo "=== TruthTeam 多Agent系统部署配置 ==="
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo "【干运行模式】使用默认配置进行验证..."
        TEAM_NAME="TruthTeam"
        USER_NAME="老板"
        PLATFORM="telegram"
        USER_PLATFORM_ID="123456789"
        TRUTH_SEEKER_TOKEN="dry-run-token-1"
        USER_AVATAR_TOKEN="dry-run-token-2"
        ELITE_ADVISOR_TOKEN="dry-run-token-3"
        EXTERNAL_CONNECTOR_TOKEN="dry-run-token-4"
        info "团队名称: $TEAM_NAME"
        info "用户昵称: $USER_NAME"
        info "绑定平台: $PLATFORM"
        echo ""
        return
    fi

    read -p "团队名称 (默认: TruthTeam): " TEAM_NAME
    TEAM_NAME=${TEAM_NAME:-TruthTeam}

    read -p "AI应该如何称呼你 (默认: 老板): " USER_NAME
    USER_NAME=${USER_NAME:-老板}

    echo ""
    echo "选择要绑定的平台:"
    echo "1. Telegram (推荐)"
    echo "2. Discord"
    echo "3. 其他 (需手动配置)"
    read -p "请选择 (1-3, 默认: 1): " PLATFORM_CHOICE
    PLATFORM_CHOICE=${PLATFORM_CHOICE:-1}

    case $PLATFORM_CHOICE in
        1) PLATFORM="telegram" ;;
        2) PLATFORM="discord" ;;
        3) PLATFORM="other" ;;
        *) PLATFORM="telegram" ;;
    esac
    info "选择平台: $PLATFORM"

    if [ "$PLATFORM" != "other" ]; then
        echo ""
        read -p "你的 $PLATFORM 用户ID (用于消息白名单): " USER_PLATFORM_ID
        while [ -z "$USER_PLATFORM_ID" ]; do
            warn "用户ID不能为空"
            read -p "你的 $PLATFORM 用户ID: " USER_PLATFORM_ID
        done
    fi

    if [ "$PLATFORM" != "other" ]; then
        echo ""
        echo "请为每个 Agent 提供 $PLATFORM botToken"
        read -p "TruthSeeker botToken: " TRUTH_SEEKER_TOKEN
        read -p "UserAvatar botToken: " USER_AVATAR_TOKEN
        read -p "EliteAdvisor botToken: " ELITE_ADVISOR_TOKEN
        read -p "ExternalConnector botToken: " EXTERNAL_CONNECTOR_TOKEN
    fi

    echo ""
    info "配置确认: 团队=$TEAM_NAME, 用户=$USER_NAME, 平台=$PLATFORM"
    read -p "确认部署? (y/N): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        info "部署已取消"
        exit 0
    fi
}

# ============================================
# 备份与模板
# ============================================

backup_openclaw_config() {
    local CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"
    if [ -f "$CONFIG_FILE" ]; then
        run_cmd cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
        info "openclaw.json 已备份到 $CONFIG_FILE.bak"
    else
        if [ "$DRY_RUN" = true ]; then
            dry_run_info "备份 $CONFIG_FILE（文件不存在，跳过）"
        else
            warn "未找到 $CONFIG_FILE，跳过备份"
        fi
    fi
}

render_templates() {
    info "渲染模板..."

    TEMP_DIR=$(mktemp -d)

    run_cmd cp -r "$SCRIPT_DIR/templates/"* "$TEMP_DIR/"

    SAFE_TEAM_NAME=$(printf '%s' "$TEAM_NAME" | sed 's/[&/\]/\\&/g')
    SAFE_USER_NAME=$(printf '%s' "$USER_NAME" | sed 's/[&/\]/\\&/g')
    SAFE_PLATFORM=$(printf '%s' "$PLATFORM" | sed 's/[&/\]/\\&/g')

    find "$TEMP_DIR" -type f -name "*.md" -exec sed -i \
        -e "s/{{TEAM_NAME}}/$SAFE_TEAM_NAME/g" \
        -e "s/{{USER_NAME}}/$SAFE_USER_NAME/g" \
        -e "s/{{PLATFORM}}/$SAFE_PLATFORM/g" \
        {} +

    info "模板渲染完成"
}

# ============================================
# Workspace 创建
# ============================================

create_workspaces() {
    info "创建 Agent workspaces..."

    local BASE="$OPENCLAW_HOME"

    run_cmd mkdir -p "$BASE/workspace-truth-seeker"
    run_cmd mkdir -p "$BASE/workspace-user-avatar"
    run_cmd mkdir -p "$BASE/workspace-elite-advisor"
    run_cmd mkdir -p "$BASE/workspace-external-connector"

    run_cmd cp "$TEMP_DIR/truth-seeker/SOUL.md" "$BASE/workspace-truth-seeker/SOUL.md"
    run_cmd cp "$TEMP_DIR/truth-seeker/AGENTS.md" "$BASE/workspace-truth-seeker/AGENTS.md"
    run_cmd cp "$TEMP_DIR/truth-seeker/IDENTITY.md" "$BASE/workspace-truth-seeker/IDENTITY.md"
    run_cmd cp "$TEMP_DIR/truth-seeker/TOOLS.md" "$BASE/workspace-truth-seeker/TOOLS.md"

    run_cmd cp "$TEMP_DIR/user-avatar/SOUL.md" "$BASE/workspace-user-avatar/SOUL.md"
    run_cmd cp "$TEMP_DIR/user-avatar/AGENTS.md" "$BASE/workspace-user-avatar/AGENTS.md"
    run_cmd cp "$TEMP_DIR/user-avatar/IDENTITY.md" "$BASE/workspace-user-avatar/IDENTITY.md"
    run_cmd cp "$TEMP_DIR/user-avatar/TOOLS.md" "$BASE/workspace-user-avatar/TOOLS.md"

    run_cmd cp "$TEMP_DIR/elite-advisor/SOUL.md" "$BASE/workspace-elite-advisor/SOUL.md"
    run_cmd cp "$TEMP_DIR/elite-advisor/AGENTS.md" "$BASE/workspace-elite-advisor/AGENTS.md"
    run_cmd cp "$TEMP_DIR/elite-advisor/IDENTITY.md" "$BASE/workspace-elite-advisor/IDENTITY.md"
    run_cmd cp "$TEMP_DIR/elite-advisor/TOOLS.md" "$BASE/workspace-elite-advisor/TOOLS.md"

    run_cmd cp "$TEMP_DIR/external-connector/SOUL.md" "$BASE/workspace-external-connector/SOUL.md"
    run_cmd cp "$TEMP_DIR/external-connector/AGENTS.md" "$BASE/workspace-external-connector/AGENTS.md"
    run_cmd cp "$TEMP_DIR/external-connector/IDENTITY.md" "$BASE/workspace-external-connector/IDENTITY.md"
    run_cmd cp "$TEMP_DIR/external-connector/TOOLS.md" "$BASE/workspace-external-connector/TOOLS.md"

    info "Workspaces 创建完成"
}

# ============================================
# 用户资料库
# ============================================

create_user_archive() {
    info "创建用户资料库（User Archive）..."

    local ARCHIVE_DIR="$OPENCLAW_HOME/workspace-truth-seeker/user-archive"

    run_cmd mkdir -p "$ARCHIVE_DIR"
    run_cmd cp -r "$TEMP_DIR/user-archive/"* "$ARCHIVE_DIR/"

    # Git 初始化
    if [ "$DRY_RUN" = true ]; then
        if [ ! -d "$ARCHIVE_DIR/.git" ]; then
            dry_run_info "cd $ARCHIVE_DIR && git init && git add . && git commit -m '[SYSTEM] Initialize user archive'"
        else
            dry_run_info "Git 仓库已存在，跳过初始化"
        fi
    else
        if [ ! -d "$ARCHIVE_DIR/.git" ]; then
            (cd "$ARCHIVE_DIR" && git init && git add . && git commit -m "[SYSTEM] Initialize user archive")
            info "Git 仓库已初始化"
        else
            info "Git 仓库已存在，跳过初始化"
        fi
    fi

    info "用户资料库创建完成: $ARCHIVE_DIR"
}

# ============================================
# Agent 注册
# ============================================

register_agents() {
    info "注册 Agent..."

    local EXISTING_AGENTS
    EXISTING_AGENTS=$(capture_openclaw agents list 2>/dev/null | grep -oE '^[a-z0-9-]+' || true)

    if echo "$EXISTING_AGENTS" | grep -q "^truth-seeker$"; then
        info "TruthSeeker 已注册，跳过"
    else
        info "注册 TruthSeeker..."
        run_openclaw agents add truth-seeker \
            --workspace "$OPENCLAW_HOME/workspace-truth-seeker" \
            --non-interactive
    fi

    if echo "$EXISTING_AGENTS" | grep -q "^user-avatar$"; then
        info "UserAvatar 已注册，跳过"
    else
        info "注册 UserAvatar..."
        run_openclaw agents add user-avatar \
            --workspace "$OPENCLAW_HOME/workspace-user-avatar" \
            --non-interactive
    fi

    if echo "$EXISTING_AGENTS" | grep -q "^elite-advisor$"; then
        info "EliteAdvisor 已注册，跳过"
    else
        info "注册 EliteAdvisor..."
        run_openclaw agents add elite-advisor \
            --workspace "$OPENCLAW_HOME/workspace-elite-advisor" \
            --non-interactive
    fi

    if echo "$EXISTING_AGENTS" | grep -q "^external-connector$"; then
        info "ExternalConnector 已注册，跳过"
    else
        info "注册 ExternalConnector..."
        run_openclaw agents add external-connector \
            --workspace "$OPENCLAW_HOME/workspace-external-connector" \
            --non-interactive
    fi

    info "Agent 注册完成"
}

# ============================================
# Channel Accounts & Bindings
# ============================================

create_channel_accounts_and_bindings() {
    info "创建 Channel Accounts 并配置 bindings..."

    if [ "$PLATFORM" == "other" ]; then
        warn "其他平台需要手动配置 channel 绑定"
        return
    fi

    run_openclaw config set "channels.$PLATFORM.accounts.truth-seeker.botToken" "$TRUTH_SEEKER_TOKEN"
    run_openclaw config set "channels.$PLATFORM.accounts.truth-seeker.dmPolicy" "allowlist"
    run_openclaw config set "channels.$PLATFORM.accounts.truth-seeker.allowFrom" "[$USER_PLATFORM_ID]" --strict-json

    run_openclaw config set "channels.$PLATFORM.accounts.user-avatar.botToken" "$USER_AVATAR_TOKEN"
    run_openclaw config set "channels.$PLATFORM.accounts.user-avatar.dmPolicy" "allowlist"
    run_openclaw config set "channels.$PLATFORM.accounts.user-avatar.allowFrom" "[$USER_PLATFORM_ID]" --strict-json

    run_openclaw config set "channels.$PLATFORM.accounts.elite-advisor.botToken" "$ELITE_ADVISOR_TOKEN"
    run_openclaw config set "channels.$PLATFORM.accounts.elite-advisor.dmPolicy" "allowlist"
    run_openclaw config set "channels.$PLATFORM.accounts.elite-advisor.allowFrom" "[$USER_PLATFORM_ID]" --strict-json

    run_openclaw config set "channels.$PLATFORM.accounts.external-connector.botToken" "$EXTERNAL_CONNECTOR_TOKEN"
    run_openclaw config set "channels.$PLATFORM.accounts.external-connector.dmPolicy" "allowlist"
    run_openclaw config set "channels.$PLATFORM.accounts.external-connector.allowFrom" "[$USER_PLATFORM_ID]" --strict-json

    info "配置 bindings..."

    local EXISTING_BINDINGS
    EXISTING_BINDINGS=$(capture_openclaw config get bindings 2>/dev/null || echo '[]')

    local NEW_BINDINGS
    NEW_BINDINGS='[
      {"agentId": "truth-seeker", "match": {"channel": "'"$PLATFORM"'", "accountId": "truth-seeker"}},
      {"agentId": "user-avatar", "match": {"channel": "'"$PLATFORM"'", "accountId": "user-avatar"}},
      {"agentId": "elite-advisor", "match": {"channel": "'"$PLATFORM"'", "accountId": "elite-advisor"}},
      {"agentId": "external-connector", "match": {"channel": "'"$PLATFORM"'", "accountId": "external-connector"}}
    ]'

    local MERGED_BINDINGS
    MERGED_BINDINGS=$(run_node -e "
        const existing = $EXISTING_BINDINGS;
        const newBindings = $NEW_BINDINGS;
        const existingIds = new Set(existing.map(b => b.agentId));
        const toAdd = newBindings.filter(b => !existingIds.has(b.agentId));
        const merged = [...existing, ...toAdd];
        console.log(JSON.stringify(merged, null, 2));
    ")

    run_openclaw config set bindings "$MERGED_BINDINGS" --strict-json

    info "Channel Accounts 和 bindings 创建完成"
}

# ============================================
# Cron 配置
# ============================================

configure_cron() {
    info "配置定时任务（cron）..."

    local CRON_DIR="$OPENCLAW_HOME/cron"
    local CRON_FILE="$CRON_DIR/jobs.json"

    run_cmd mkdir -p "$CRON_DIR"

    run_node -e "
        const fs = require('fs');
        const path = '$CRON_FILE';

        let existing = { version: 1, jobs: [] };
        try {
            const raw = fs.readFileSync(path, 'utf8');
            existing = JSON.parse(raw);
            if (!existing.jobs) existing.jobs = [];
        } catch (e) {
            // 文件不存在或格式错误
        }

        const newJobs = [
            {
                name: 'tt-truth-seeker-monitor',
                description: 'TruthSeeker 6h scan: read session indices, detect contradictions, update heatmap',
                agentId: 'truth-seeker',
                cron: '0 */6 * * *',
                message: '【被动监控】读取 99-meta/scan-state.md，扫描 agents/*/sessions/sessions.json 找新 session，读最后 20 行检测矛盾，更新 contradictions.md 和 state-board.md'
            },
            {
                name: 'tt-elite-advisor-round',
                description: 'EliteAdvisor 12h proactive supervision: read state-board, scan sessions, identify issues, outreach',
                agentId: 'elite-advisor',
                cron: '0 */12 * * *',
                message: '【定时巡视】1)读99-meta/state-board.md 2)扫描agents/*/sessions找最近12h用户活动 3)读取相关session详情 4)如发现问题，向用户推送建议 5)生成报告写入10-reports/elite-advisor/ 6)更新99-meta/elite-advisor-last-round.md'
            },
            {
                name: 'tt-user-avatar-action',
                description: 'UserAvatar 12h autonomous action',
                agentId: 'user-avatar',
                cron: '0 6,18 * * *',
                message: '【自主行动】读取99-meta/state-board.md和00-master-profile.md，执行预设目标相关行动，更新state-board.md'
            }
        ];

        const existingNames = new Set(existing.jobs.map(j => j.name));
        let added = 0;
        for (const job of newJobs) {
            if (existingNames.has(job.name)) {
                console.log('SKIP: ' + job.name + ' already exists');
                continue;
            }
            existing.jobs.push({
                id: require('crypto').randomUUID(),
                name: job.name,
                description: job.description,
                enabled: true,
                createdAtMs: Date.now(),
                schedule: { kind: 'cron', expr: job.cron },
                sessionTarget: 'isolated',
                wakeMode: 'now',
                payload: {
                    kind: 'agentTurn',
                    message: job.message,
                    lightContext: true
                },
                delivery: { mode: 'none' },
                state: {}
            });
            added++;
            console.log('ADDED: ' + job.name);
        }

        if (added > 0) {
            fs.writeFileSync(path, JSON.stringify(existing, null, 2) + '\n');
            console.log('Wrote ' + added + ' new cron jobs to ' + path);
        } else {
            console.log('No new cron jobs to add');
        }
    "

    if [ "$DRY_RUN" = true ]; then
        dry_run_info "验证 $CRON_FILE JSON 格式"
    else
        if ! node -e "JSON.parse(require('fs').readFileSync('$CRON_FILE', 'utf8'))" 2>/dev/null; then
            error "cron/jobs.json 格式验证失败！"
        fi
    fi

    info "定时任务配置完成"
    info "TruthSeeker：每 6 小时被动监控扫描"
    info "EliteAdvisor：每 12 小时定时巡视"
    info "UserAvatar：每 12 小时自主行动（6:00 和 18:00）"
}

# ============================================
# Agent 通信配置
# ============================================

configure_agent_communication() {
    info "配置 Agent-to-Agent 通信..."

    run_openclaw config set tools.agentToAgent.enabled true

    local EXISTING_ALLOW
    EXISTING_ALLOW=$(capture_openclaw config get tools.agentToAgent.allow 2>/dev/null || echo '[]')

    local MERGED_ALLOW
    MERGED_ALLOW=$(run_node -e "
        const existing = $EXISTING_ALLOW;
        const newAgents = ['truth-seeker', 'user-avatar', 'elite-advisor', 'external-connector'];
        const merged = [...new Set([...existing, ...newAgents])];
        console.log(JSON.stringify(merged));
    ")

    run_openclaw config set tools.agentToAgent.allow "$MERGED_ALLOW"
    run_openclaw config set tools.sessions.visibility "all"

    info "Agent-to-Agent 通信配置完成"
    info "跨 agent session 可见性已启用"
}

# ============================================
# 共享文件
# ============================================

create_shared_files() {
    info "创建共享文件..."

    write_file "$OPENCLAW_HOME/workspace-truth-seeker/TEAM_REGISTRY.md" << 'EOF'
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

# ============================================
# 安装验证
# ============================================

verify_installation() {
    info "验证安装..."

    echo ""
    echo "=== 已注册 Agent ==="
    run_openclaw agents list

    echo ""
    echo "=== Agent-to-Agent 通信配置 ==="
    run_openclaw config get tools.agentToAgent.allow || true

    echo ""
    echo "=== Session 可见性 ==="
    run_openclaw config get tools.sessions.visibility || true

    echo ""
    echo "=== Workspace 目录 ==="
    run_cmd ls -la "$OPENCLAW_HOME/workspace-"* 2>/dev/null || true

    echo ""
    echo "=== 用户资料库 ==="
    run_cmd ls -la "$OPENCLAW_HOME/workspace-truth-seeker/user-archive/" 2>/dev/null || true

    echo ""
    echo "=== 共享文件 ==="
    run_cmd ls -la "$OPENCLAW_HOME/workspace-truth-seeker/"*.md 2>/dev/null || true

    info "验证完成"
}

# ============================================
# 主函数
# ============================================

main() {
    echo "=== TruthTeam 多Agent系统一键部署 ==="
    if [ "$DRY_RUN" = true ]; then
        echo "【干运行模式】命令仅打印，不实际执行"
        echo ""
    fi
    echo ""

    check_openclaw
    check_gateway
    ask_user_config
    backup_openclaw_config
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
    echo "  $OPENCLAW_HOME/workspace-truth-seeker/user-archive/"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo "【干运行完成】所有命令已验证，未执行实际操作"
        if [ "$TEMP_HOME_CREATED" = true ]; then
            echo "临时目录: $OPENCLAW_HOME（将在退出时自动清理）"
        fi
        echo ""
        echo "要实际部署，请运行:"
        echo "  bash install.sh"
        echo ""
    else
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
    fi
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "脚本目录: $SCRIPT_DIR"

# 执行
main
