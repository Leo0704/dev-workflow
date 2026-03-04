---
name: learning-record
description: |
  学习记录技能 - 提取和记录开发过程中的学习。

  触发场景：用户说"记录学习"、"保存经验"、"学习总结"、"记录经验"、
  "写学习日志"、"保存到learnings"、"记住这个"、"下次避免"。

  当开发任务完成或发现重要的经验教训、错误模式、最佳实践时，
  使用此技能将学习记录到 MEMORY.md 或 learnings/ 目录。
user-invokable: true
---

老板好！这是学习记录技能。

---

## 执行流程

### 步骤 1: 回顾开发过程

回顾本次开发过程中的：
- 遇到的错误和解决方案
- 有效的做法和模式
- 用户指出的问题
- 意外发现

### 步骤 2: 提取学习点

按以下类型分类：

1. **错误模式** - 遇到的错误及解决方案
2. **最佳实践** - 有效的做法和推荐模式
3. **用户纠正** - 用户指出的问题和正确理解
4. **意外发现** - 非显而易见的解决方案

### 步骤 3: 选择存储位置

| 条件 | 存储位置 |
|------|----------|
| 跨项目通用约定 | MEMORY.md |
| 项目特定经验 | learnings/LEARNINGS.md |
| 错误和解决方案 | learnings/ERRORS.md |

### 步骤 4: 记录学习

使用模板: `templates/learning-entry.md`

```bash
# 读取模板
cat skills/learning-record/templates/learning-entry.md

# 根据类型追加到对应文件
echo "内容" >> learnings/LEARNINGS.md
```

### 步骤 5: 更新工作流状态

```bash
echo "8" > task/$(cat task/.current-task)/.workflow-step
```

---

## 学习类型

1. **错误模式** - 遇到的错误及解决方案
2. **最佳实践** - 有效的做法和推荐模式
3. **用户纠正** - 用户指出的问题和正确理解
4. **意外发现** - 非显而易见的解决方案

---

## 存储位置

| 条件 | 存储位置 |
|------|----------|
| 跨项目通用 | MEMORY.md |
| 项目特定 | learnings/LEARNINGS.md |
| 错误记录 | learnings/ERRORS.md |

---

## 输出模板

使用模板: `templates/learning-entry.md`

---

## 核心原则

- 及时性：发现即记录
- 具体性：包含具体场景和代码
- 可操作性：提供明确建议
