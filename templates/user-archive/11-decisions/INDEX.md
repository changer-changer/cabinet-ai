# 11-decisions/ Index
# Purpose: Decision Time Machine — track major decisions with context and outcomes

## Decisions
| ID | Date | Decision | Confidence | Outcome |
|----|------|----------|------------|---------|
| (pending first decision) | | | | |

## Decision Template

When UserAvatar makes a major decision, create a file `YYYY-MM-DD-{short-name}.md`:

```markdown
---
decision_id: DEC-YYYY-MMDD-NNN
context_hash: {short hash}
confidence: {0-1}
---

## 决策背景
{为什么需要做这个决策}

## 考虑的选项
| 选项 | 预期价值 | 风险 | 适配度 |
|------|---------|------|--------|
| A | ... | ... | X% |
| B | ... | ... | X% |

## 推理过程
1. ...

## 最终选择
{选择了什么，为什么}

## 结果（事后填写）
{实际结果如何，与预期对比}
```

## Recent Decisions (last 5)
1. [SYSTEM] Archive initialized
