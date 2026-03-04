---
name: learning-record
description: 记录开发过程中的学习、错误和最佳实践到 .claude/learnings/ 目录
user-invokable: true
---

老板好！我是学习记录助手。

当开发任务完成后，我会帮你整理并记录有价值的学习内容。

---

## 学习记录触发时机

以下情况值得记录学习：

- 发现非显而易见的解决方案
- 遇到意外错误并解决
- 用户纠正了你的理解
- 发现项目特定的最佳实践
- 找到更好的实现方法

---

## 学习记录类型

### 1. 学习记录 (LEARNINGS.md)

记录到 `.claude/learnings/LEARNINGS.md`：

```markdown
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high
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
```

### 2. 错误记录 (ERRORS.md)

记录到 `.claude/learnings/ERRORS.md`：

```markdown
## [ERR-YYYYMMDD-XXX] command_name

**Logged**: ISO-8601 timestamp
**Priority**: high
**Status**: pending
**Area**: backend

### Summary
简要描述什么失败了

### Error
```
实际错误信息
```

### Context
- 尝试的命令
- 环境详情

### Suggested Fix
可能的解决方案
```

---

## 学习提升

当学习具有广泛适用性时，提升到持久化文件：

| 学习类型 | 提升目标 |
|----------|----------|
| 项目约定 | CLAUDE.md |
| 工作流规则 | AGENTS.md |
| 行为准则 | 记忆系统 |

提升后更新学习状态：
```markdown
**Status**: promoted
**Promoted**: CLAUDE.md
```

---

## 执行流程

```
1. 检查是否有值得记录的内容
   - 是否有非显而易见的解决方案？
   - 是否有用户纠正？
   - 是否遇到并解决了问题？

2. 确定记录类型
   - 学习记录 -> LEARNINGS.md
   - 错误记录 -> ERRORS.md

3. 生成唯一 ID
   - 学习: LRN-YYYYMMDD-XXX
   - 错误: ERR-YYYYMMDD-XXX

4. 追加到对应文件

5. 报告记录内容
```

---

## 输出格式

记录完成后，用简洁格式报告：

```
## 学习记录完成

### 已记录
| ID | 类型 | 优先级 | 摘要 |
|----|------|--------|------|
| LRN-20260304-001 | 学习 | medium | xxx |

### 建议提升
| ID | 提升目标 | 理由 |
|----|----------|------|
| LRN-20260304-001 | MEMORY.md | 项目通用约定 |
```
