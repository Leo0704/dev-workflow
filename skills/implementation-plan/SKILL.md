---
name: implementation-plan
description: |
  实施计划技能 - 设计技术方案和实施步骤。

  触发场景：用户说"设计方案"、"实施计划"、"技术方案"、"实现计划"、
  "架构设计"、"开发计划"、"如何实现"、"制定方案"。

  当需要设计具体的技术实现方案、规划开发步骤、评估技术选型、
  制定实施计划时，使用此技能。
user-invokable: true
---

老板好！这是实施计划技能。

---

## 执行流程

### 步骤 1: 审阅前置报告

```bash
# 读取已有的分析报告
cat task/{当前任务}/requirement-report.md
cat task/{当前任务}/context-report.md
cat task/{当前任务}/impact-report.md
```

### 步骤 2: 设计技术方案

按层次设计：
1. **数据层** - 数据模型、数据库 schema
2. **业务层** - 业务逻辑、服务设计
3. **接口层** - API 设计、路由规划
4. **前端层** - 组件设计、状态管理（如适用）

### 步骤 3: 规划实施步骤

将方案拆解为可执行步骤：
- 每步都可独立测试
- 每步都有明确的完成标准
- 保留回滚路径

### 步骤 4: 生成报告

使用模板: `templates/plan-report.md`

```bash
# 读取模板
cat skills/implementation-plan/templates/plan-report.md

# 填充后保存到
task/{当前任务}/plan-report.md
```

### 步骤 5: 更新工作流状态

**完成实施计划后，自动更新工作流步骤**：

```bash
echo "4" > task/$(cat task/.current-task)/.workflow-step
```

### 步骤 6: 等待用户确认

**重要**: 实施计划必须经用户确认后才能进入代码开发阶段。

### 步骤 7: Git 分支创建（可选）

用户确认后，建议创建功能分支：

```bash
# 检查当前分支
git branch --show-current

# 如果在 main/master，创建 feature 分支
git checkout -b feature/{任务名}
```

---

## 设计原则

1. **最小改动** - 优先复用现有代码
2. **清洁架构** - 关注点分离、依赖倒置
3. **平衡** - 在最小改动和清洁架构之间权衡

---

## 输出文件

生成报告到: `task/{任务名}/plan-report.md`

包含：
- 方案概述
- 技术设计（数据层/业务层/接口层）
- 实施步骤
- 风险和注意事项

---

## 核心原则

- 渐进式：从简单方案开始
- 可验证：每步都可测试
- 可回滚：保留回滚路径
