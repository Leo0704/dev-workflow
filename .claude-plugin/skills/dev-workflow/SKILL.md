---
name: dev-workflow
description: |
  通用软件开发工作流 - 9步完整开发流程，支持多Agent并行协作。

  触发场景：用户说"开始开发"、"实现功能"、"开发工作流"、"完整开发流程"、
  "按流程开发"、"执行开发任务"，或需要系统性地完成一个开发任务。

  当用户需要从头到尾完成一个功能开发，包括需求分析、代码实现、测试验证等
  完整流程时，使用此技能。也适用于复杂的多步骤开发任务。
user-invokable: true
---

老板好！我是你的软件开发工作流编排助手。

---

## 工作流概览

| 步骤 | 名称 | 技能 | 说明 |
|------|------|------|------|
| 0 | 历史学习检查 | - | 检查 MEMORY.md 和 learnings/ |
| 1 | 需求理解 | requirement-analysis | 分析业务需求、可行性 |
| 2 | 上下文调研 | context-research | 探索相似功能、架构、数据流 |
| 3 | 影响分析 | impact-analysis | 评估依赖、风险、回滚方案 |
| 4 | 实施计划 | implementation-plan | 设计技术方案 |
| 5 | 代码开发 | code-development | 按计划实现代码 |
| 6 | 代码审核 | code-review | 检查 Bug、质量、规范 |
| 7 | 测试验证 | testing | 单元/集成/E2E 测试 |
| 8 | 学习记录 | learning-record | 提取和记录学习 |

---

## 执行流程

### 步骤 0: 历史学习检查

在开始任何任务前，先检查历史学习：

```bash
# 检查项目级记忆
cat MEMORY.md

# 检查学习记录
cat learnings/LEARNINGS.md

# 检查错误记录
cat learnings/ERRORS.md
```

**目的**: 避免重复犯错，复用已有经验。

### 步骤 1-3: 分析阶段（可并行）

这三个步骤相互独立，可以并行执行：

```
步骤 1: requirement-analysis
  - 读取需求文档
  - 拆解功能点
  - 识别模糊点
  - 输出: requirement-report.md

步骤 2: context-research
  - 搜索相似功能
  - 分析架构
  - 追踪数据流
  - 输出: context-report.md

步骤 3: impact-analysis
  - 扫描依赖
  - 评估风险
  - 规划回滚
  - 输出: impact-report.md
```

### 步骤 4: 实施计划

**依赖**: 步骤 1-3 的报告

```
1. 读取 requirement-report.md
2. 读取 context-report.md
3. 读取 impact-report.md
4. 设计技术方案
5. 输出: plan-report.md
6. ⚠️ 等待用户确认方案
```

### 步骤 5: 代码开发

**依赖**: 步骤 4 用户确认

```bash
# 更新工作流状态
echo "5" > task/$(cat task/.current-task)/.workflow-step

# 按计划实现代码
# 参考: skills/code-development/SKILL.md
```

### 步骤 6-7: 验证阶段（可并行）

这两个步骤可以并行执行：

```
步骤 6: code-review
  - 审核代码质量
  - 检查安全问题
  - 输出: review-report.md

步骤 7: testing
  - 执行测试
  - 输出: test-plan.md, test-cases.md, test-report.md
```

### 步骤 8: 学习记录

```bash
# 更新工作流状态
echo "8" > task/$(cat task/.current-task)/.workflow-step

# 记录学习
# 参考: skills/learning-record/SKILL.md
```

---

## 任务目录结构

```
task/
├── 2026-03-04-功能名称/
│   ├── prd.pdf                ← 需求文档
│   ├── requirement-report.md  ← 需求理解报告
│   ├── context-report.md      ← 调研报告
│   ├── impact-report.md       ← 影响分析报告
│   ├── plan-report.md         ← 实施计划报告
│   ├── review-report.md       ← 代码审核报告
│   ├── test-plan.md           ← 测试计划
│   ├── test-cases.md          ← 测试用例
│   ├── test-report.md         ← 测试报告
│   └── .workflow-step         ← 工作流状态
└── .current-task              ← 当前任务标识
```

---

## 工作边界

开始前必须明确：
- 可修改的项目/目录
- 只读参考的项目/目录
- 项目依赖关系

---

## 跳过工作流

如需快速修复，可以跳过工作流：

```bash
touch task/$(cat task/.current-task)/.skip-workflow
```

---

## 特殊流程

**需求变更：** 记录变更 → 评估影响 → 更新计划

**取消开发：** 检查修改状态 → 确认保留内容 → 回滚（如需）
