---
name: dev-workflow
description: |
  通用软件开发工作流 - 9步完整开发流程，支持 Subagent 并行协作。

  触发场景：用户说"开始开发"、"实现功能"、"开发工作流"、"完整开发流程"、
  "按流程开发"、"执行开发任务"，或需要系统性地完成一个开发任务。

  当用户需要从头到尾完成一个功能开发，包括需求分析、代码实现、测试验证等
  完整流程时，使用此技能。也适用于复杂的多步骤开发任务。
user-invokable: true
---

老板好！我是你的软件开发工作流编排助手。

---

## 任务分级

工作流支持三种任务级别，自动适配流程复杂度：

| 级别 | 触发条件 | 流程 | 跳过步骤 |
|------|----------|------|----------|
| **Quick** 🚀 | typo、注释、小修改 | 直接到步骤5 | 0-4 |
| **Standard** ⚡ | bug修复、单文件改动 | 需求分析→计划→开发 | 2-3 |
| **Full** 📋 | 新功能、模块开发 | 完整9步流程 | 无 |

**自动检测**：提交任务时会自动分析并设置级别
**手动切换**：修改 `task/{任务名}/.task-level` 文件

---

## 工作流概览

### 流程图

```
┌─────────────────────────────────────────────────────────────────┐
│  任务分级检查                                                    │
│  Quick → 跳到步骤5 | Standard → 跳到步骤4 | Full → 完整流程     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 0: 历史学习检查                                            │
│  检查插件学习库 data/learnings.md 和 data/errors.md             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 1-3: 分析阶段 (并行执行，Standard/Full)                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ 1.需求分析  │  │ 2.上下文调研│  │ 3.影响分析  │             │
│  │ (Group A)   │  │ (Group A)   │  │ (Group A)   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 4: 实施计划                                                │
│  综合分析报告 → 设计方案 → ⚠️ 等待用户确认                       │
│  → 建议 Git 分支创建                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 5: 代码开发                                                │
│  按计划实现代码                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 6-7: 验证阶段 (并行执行)                                   │
│  ┌─────────────┐  ┌─────────────┐                              │
│  │ 6.代码审核  │  │ 7.测试验证  │                              │
│  │ (Group B)   │  │ (Group B)   │                              │
│  └─────────────┘  └─────────────┘                              │
│         │                │                                      │
│         └───────┬────────┘                                      │
│                 ↓                                                │
│         ┌──────────────┐                                        │
│         │  发现问题？  │                                        │
│         └──────┬───────┘                                        │
│           是 ↙    ↘ 否                                          │
│    ┌──────────┐    ┌──────────┐                                 │
│    │ 回到步骤5│    │ 进入步骤8│                                 │
│    │ 修复代码 │    │ 学习记录 │                                 │
│    │    ↓     │    └──────────┘                                 │
│    │ 重新验证 │                                                 │
│    └──────────┘                                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  步骤 8: 学习记录                                                │
│  更新插件学习库 data/learnings.md 和 data/errors.md             │
│  → Git 提交建议                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 步骤说明

| 步骤 | 名称 | Agent | 并行组 | 自动流转 | 说明 |
|------|------|-------|--------|----------|------|
| 0 | 历史学习检查 | - | - | ✅ | 检查插件学习库 |
| 1 | 需求分析 | `requirement-analyst` | A | ✅ | 分析业务需求、可行性 |
| 2 | 上下文调研 | `context-researcher` | A | ✅ | 探索相似功能、架构、数据流 |
| 3 | 影响分析 | `impact-analyzer` | A | ✅ | 评估依赖、风险、回滚方案 |
| 4 | 实施计划 | - | - | ✅ | 设计技术方案，Git 分支建议 |
| 5 | 代码开发 | - | - | ✅ | 按计划实现代码 |
| 6 | 代码审核 | `code-reviewer` | B | ✅ | 检查 Bug、质量、规范 |
| 7 | 测试验证 | `tester` | B | ✅ | 单元/集成/E2E 测试 |
| 8 | 学习记录 | - | - | ✅ | 提取和记录学习，Git 提交建议 |

### 新增特性

| 特性 | 说明 |
|------|------|
| **任务分级** | 自动检测任务复杂度，适配流程 |
| **自动步骤流转** | 每个 skill 完成后自动更新 `.workflow-step` |
| **智能学习提取** | Stop 钩子自动生成学习点草稿 |
| **Git 集成** | 步骤4建议分支，步骤8建议提交 |

---

## 执行流程

### 步骤 0: 历史学习检查

在开始任何任务前，检查插件学习库：

```bash
# 检查插件学习数据
cat ~/.claude/plugins/dev-workflow/data/learnings.md
cat ~/.claude/plugins/dev-workflow/data/errors.md
```

**目的**: 复用插件积累的经验，避免重复犯错。

### 步骤 1-3: 分析阶段（并行执行）

这三个步骤相互独立，**必须使用 Agent 工具并行启动**：

```
并行启动三个 subagents:

1. requirement-analyst
   - 读取需求文档
   - 拆解功能点
   - 识别模糊点
   - 输出: requirement-report.md
   - 自动更新: .workflow-step → 1

2. context-researcher
   - 搜索相似功能
   - 分析架构
   - 追踪数据流
   - 输出: context-report.md
   - 自动更新: .workflow-step → 2

3. impact-analyzer
   - 扫描依赖
   - 评估风险
   - 规划回滚
   - 输出: impact-report.md
   - 自动更新: .workflow-step → 3
```

**并行调用方式**:
使用 Agent 工具在单个消息中同时启动三个 agents：

```
Agent 工具调用:
1. subagent_type: "dev-workflow:requirement-analyst"
   prompt: "分析 task/{任务名}/prd.pdf 的需求，输出到 requirement-report.md"

2. subagent_type: "dev-workflow:context-researcher"
   prompt: "调研项目中与 {功能关键词} 相关的实现，输出到 context-report.md"

3. subagent_type: "dev-workflow:impact-analyzer"
   prompt: "分析实现 {功能名} 的影响范围和风险，输出到 impact-report.md"
```

**降级方案（Agent 不可用时）**:

如果 Agent 工具不可用，按顺序串行执行：

```bash
# 步骤 1: 需求分析
/dev-workflow:requirement-analysis
# 手动执行需求分析，输出 requirement-report.md

# 步骤 2: 上下文调研
/dev-workflow:context-research
# 手动执行上下文调研，输出 context-report.md

# 步骤 3: 影响分析
/dev-workflow:impact-analysis
# 手动执行影响分析，输出 impact-report.md
```

**等待所有 agents 完成后**，进入步骤 4。

### 步骤 4: 实施计划

**依赖**: 步骤 1-3 的报告

```
1. 读取 requirement-report.md
2. 读取 context-report.md
3. 读取 impact-report.md
4. 设计技术方案
5. 输出: plan-report.md
6. 自动更新: .workflow-step → 4
7. ⚠️ 等待用户确认方案
8. Git 分支建议（如在 main/master）
```

### 步骤 5: 代码开发

**依赖**: 步骤 4 用户确认

```bash
# 自动更新工作流状态
echo "5" > task/$(cat task/.current-task)/.workflow-step

# 按计划实现代码
# 参考: skills/code-development/SKILL.md
```

### 步骤 6-7: 验证阶段（并行执行）

这两个步骤相互独立，**必须使用 Agent 工具并行启动**：

```
并行启动两个 subagents:

1. code-reviewer
   - 审核代码质量
   - 检查安全问题
   - 输出: review-report.md
   - 自动更新: .workflow-step → 6

2. tester
   - 设计测试用例
   - 执行测试
   - 输出: test-plan.md, test-cases.md, test-report.md
   - 自动更新: .workflow-step → 7
```

**⚠️ 验证失败处理（迭代循环）**:

等待所有 agents 完成后，检查结果：

| 场景 | 处理方式 |
|------|----------|
| 代码审核发现问题 | 回到步骤5修复 → 重新执行步骤6 |
| 测试失败 | 回到步骤5修复 → 重新执行步骤7 |
| 两者都有问题 | 回到步骤5修复 → 重新执行步骤6-7 |

**降级方案（Agent 不可用时）**:

```bash
# 步骤 6: 代码审核
/dev-workflow:code-review
# 手动执行代码审核，输出 review-report.md

# 步骤 7: 测试验证
/dev-workflow:testing
# 手动执行测试，输出 test-plan.md, test-cases.md, test-report.md
```

**所有验证通过后**，进入步骤 8。

### 步骤 8: 学习记录

**目的**: 更新插件学习库，积累跨项目经验。

```bash
# 自动更新工作流状态
echo "8" > task/$(cat task/.current-task)/.workflow-step
```

**学习数据存储位置**: `~/.claude/plugins/dev-workflow/data/`

| 文件 | 内容 | 更新方式 |
|------|------|----------|
| `learnings.md` | 最佳实践、有效模式 | 自动生成草稿 + 手动确认 |
| `errors.md` | 错误和解决方案 | 钩子自动记录 |

**手动更新学习库**:
```
/dev-workflow:learning-record
```

**Git 提交建议**: 如果有未提交的更改，提示使用 `/commit` 或 `/commit-push-pr`

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
│   ├── .workflow-step         ← 工作流状态
│   ├── .task-level            ← 任务级别 (quick/standard/full)
│   └── .skip-workflow         ← 跳过工作流标记（可选）
└── .current-task              ← 当前任务标识
```

---

## 工作边界

开始前必须明确：
- 可修改的项目/目录
- 只读参考的项目/目录
- 项目依赖关系

---

## 快速命令

### 切换任务级别

```bash
# Quick 模式（直接写代码）
echo "quick" > task/$(cat task/.current-task)/.task-level
echo "5" > task/$(cat task/.current-task)/.workflow-step

# Standard 模式（需求+计划+开发）
echo "standard" > task/$(cat task/.current-task)/.task-level
echo "1" > task/$(cat task/.current-task)/.workflow-step

# Full 模式（完整流程）
echo "full" > task/$(cat task/.current-task)/.task-level
echo "0" > task/$(cat task/.current-task)/.workflow-step
```

### 跳过工作流

```bash
touch task/$(cat task/.current-task)/.skip-workflow
```

---

## 特殊流程

### 需求变更

当需求在开发过程中发生变更：

```
1. 记录变更内容到 task/{任务名}/requirement-report.md
2. 评估变更影响（可能需要重新执行步骤 2-3）
3. 更新实施计划（步骤 4）
4. 获得用户确认
5. 继续开发流程
```

**如果变更较大**，建议重新启动工作流。

### 取消开发

```
1. 检查当前修改状态 (git status)
2. 确认需要保留的内容
3. 回滚不需要的修改（如需）
4. 清理任务目录
```
