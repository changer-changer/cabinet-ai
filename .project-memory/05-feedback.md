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
