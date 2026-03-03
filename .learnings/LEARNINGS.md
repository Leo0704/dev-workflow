# Learnings

学习、纠正和最佳实践记录。在重要任务前回顾。

**分类**: correction | insight | knowledge_gap | best_practice
**领域**: frontend | backend | infra | tests | docs | config
**状态**: pending | in_progress | resolved | wont_fix | promoted

## 状态定义

| 状态 | 含义 |
|--------|---------|
| `pending` | 待处理 |
| `in_progress` | 处理中 |
| `resolved` | 已解决 |
| `wont_fix` | 不修复（原因见 Resolution） |
| `promoted` | 已提升到 CLAUDE.md 或 MEMORY.md |

---

## 记录格式

```markdown
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
一句话描述学到了什么

### Details
完整上下文：发生了什么、哪里错了、什么是正确的

### Suggested Action
具体的修复或改进建议

### Metadata
- Source: conversation | error | user_feedback
- Related Files: path/to/file.ext
- Tags: tag1, tag2
- See Also: LRN-20250110-001 (关联条目)
```

---
