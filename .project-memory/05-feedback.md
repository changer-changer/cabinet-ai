# Lessons Learned

## 2026-05-10 — 不要猜测 OpenClaw 机制

**教训**：用户明确说"不要去瞎想或者猜想"。所有设计决策必须基于真实 OpenClaw 文件读取，不能靠推测。

**实际做法**：
1. 读 `~/.openclaw/cron/jobs.json` 真实格式 → 才知道 cron 是 JSON 不是 CLI
2. 读 OpenClaw 源码 `workspace-Caf7L7oC.js` → 才知道 8 个 bootstrap 文件的加载顺序和限制
3. 读 `docs/concepts/soul.md` → 才知道 SOUL.md 的正确定位是"人格"不是"操作规程"

**反模式**：先设计再验证。应该**先调研再设计**。

---

## 2026-05-10 — SOUL.md 不要塞操作规程

**教训**：一开始把 state-board 更新规范、被动监控流程、矛盾热力图维护都写进了 SOUL.md。后来发现这些是"怎么工作"应该在 AGENTS.md。

**原因**：没有弄清楚 OpenClaw bootstrap 文件的职责分工。

**正确做法**：
- SOUL.md = "我是谁"（人格、语气、思维框架）
- AGENTS.md = "我怎么工作"（操作规程、状态维护、通信命令）

---

## 2026-05-10 — TEAM_REGISTRY.md 不会自动加载

**教训**：创建了 TEAM_REGISTRY.md 作为团队注册表，但它不是 OpenClaw 标准 bootstrap 文件，不会被自动注入 system prompt。

**正确做法**：团队注册表放在 AGENTS.md 里（精简为表格格式）。

---

## 2026-05-09 — allowFrom 必须用 --strict-json

**教训**：`openclaw config set "key" "[$USER_PLATFORM_ID]"` 会存为字符串 `'[8434568597]'` 而非 JSON 数组 `[8434568597]`。

**正确做法**：加 `--strict-json` 标志。

---

## 2026-05-10 — openclaw agent 没有 --session 参数

**教训**：AGENTS.md 和 TOOLS.md 中的 A2A 命令写了 `--session isolated`，但 `openclaw agent` 没有这个参数。实际参数是 `--session-id <uuid>`。

**验证方法**：`openclaw agent --help` 查看真实参数列表。

**正确做法**：A2A 命令直接用 `openclaw agent --agent <id> --message "..."`，不需要 session 参数。

---

## 2026-05-10 — openclaw cron add 是真实 CLI

**教训**：一开始以为没有 `openclaw cron add` CLI，所以直接写 JSON。实际上 CLI 存在且参数清晰。

**验证方法**：`openclaw cron add --help` 查看参数。

**正确做法**：用 `openclaw cron add --name ... --agent ... --cron ... --message ... --session isolated --light-context --wake now`。

---

## 2026-05-10 — openclaw agents list 输出格式

**教训**：`openclaw agents list` 输出格式是 `- agent-id`（带 `- ` 前缀），不是纯 agent-id。grep 模式需要匹配实际格式。

**正确做法**：`grep -oE '^- [a-z0-9-]+' | sed 's/^- //'`
