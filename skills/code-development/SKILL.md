---
name: code-development
description: |
  代码开发技能 - 按计划实现代码。

  触发场景：用户说"开始写代码"、"实现代码"、"编写代码"、"开发功能"、
  "写实现"、"代码实现"、"开始开发"。

  当需求分析、上下文调研、实施计划都已完成，需要动手写代码实现功能时，
  使用此技能。
user-invokable: true
---

老板好！这是代码开发技能。

---

## 执行流程

### ⚠️ 步骤 0: 立即更新工作流状态（必须）

**在开始任何操作前，必须先更新工作流步骤！**

```bash
echo "5" > task/$(cat task/.current-task)/.workflow-step
```

这确保钩子知道当前正在执行步骤 5。

### 步骤 1: 前置检查

```bash
# 确认实施计划已存在
cat task/{当前任务}/plan-report.md

# 确认工作边界
# 只修改 plan-report.md 中指定的文件
```

### 步骤 2: 按层次实现

按以下顺序实现代码：

1. **数据层** - 数据模型、数据库 schema
2. **业务层** - 业务逻辑、外部服务调用
3. **接口层** - API Handler、路由注册
4. **前端/界面**（如适用）

### 步骤 4: 使用检查清单

使用模板: `templates/implementation-checklist.md`

```bash
# 读取检查清单
cat skills/code-development/templates/implementation-checklist.md
```

### 步骤 5: 自检

实现完成后，对照检查清单进行自检：
- [ ] 代码能正常编译/构建
- [ ] 无编译警告
- [ ] 符合项目代码风格
- [ ] 错误处理完整
- [ ] 无安全问题

---

## 实现流程

1. **数据层** - 数据模型、数据库 schema
2. **业务层** - 业务逻辑、外部服务调用
3. **接口层** - API Handler、路由注册
4. **前端/界面**（如适用）

---

## 输出文件

使用模板: `templates/implementation-checklist.md`

---

## 核心原则

- 参考现有代码风格
- 优先复用而非新建
- 边界检查：只修改允许的文件
- 简洁性：避免过度设计
