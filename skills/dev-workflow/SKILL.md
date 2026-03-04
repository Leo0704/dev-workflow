---
name: dev-workflow
description: 通用软件开发工作流 - 编排各子技能完成完整开发流程
user-invokable: true
---

老板好！我是你的软件开发工作流编排助手。

当收到开发需求时，我会按顺序调用各子技能完成完整的开发流程。

---

## 工作流步骤

| 步骤 | 名称 | 技能 | 说明 |
|------|------|------|------|
| 0 | 历史学习检查 | - | 读取 MEMORY.md、.claude/learnings/ |
| 1 | 需求理解 | requirement-analysis | 智能搜索、需求拆解 |
| 2 | 上下文调研 | context-research | 代码追踪、相关代码调研 |
| 3 | 影响分析 | impact-analysis | 文件变更、风险评估 |
| 4 | 实施计划 | implementation-plan | 架构方案选择、任务拆分 |
| 5 | 代码开发 | code-development | 按计划实现、自检 |
| 6 | 代码审核 | code-review | 3 视角并行审核 |
| 7 | 测试验证 | testing | 测试计划、用例、报告 |
| 8 | 学习记录 | learning-record | 记录学习、错误、最佳实践 |

---

## 任务目录结构

```
task/
├── 2024-01-15-功能名称/    ← 任务目录（按日期+功能命名）
│   ├── prd.pdf             ← 需求文档
│   ├── test-plan.md        ← 测试计划
│   ├── test-cases.md       ← 测试用例
│   ├── test-report.md      ← 测试报告
│   └── .workflow-step      ← 工作流状态
└── .current-task           ← 当前任务标识
```

**创建新任务：**
```bash
mkdir -p task/$(date +%Y-%m-%d)-功能名称
echo "$(date +%Y-%m-%d)-功能名称" > task/.current-task
```

---

## 状态跟踪

每进入新步骤：
```bash
echo "N" > task/$(cat task/.current-task)/.workflow-step
```

工作流完成后删除：
```bash
rm task/$(cat task/.current-task)/.workflow-step
```

---

## 工作边界

开始前必须明确：
- 可修改的项目/目录
- 只读参考的项目/目录
- 项目依赖关系

---

## 输出格式

```
## [步骤 0] 历史学习检查
检查相关历史学习...

## [步骤 1] 需求理解
调用 requirement-analysis 技能...

## [步骤 2] 上下文调研
调用 context-research 技能...

## [步骤 3] 影响分析
调用 impact-analysis 技能...

## [步骤 4] 实施计划
调用 implementation-plan 技能...

## [步骤 5] 代码开发
调用 code-development 技能...

## [步骤 6] 代码审核
调用 code-review 技能...

## [步骤 7] 测试验证
调用 testing 技能...

## [步骤 8] 学习记录
调用 learning-record 技能...
```

---

## 特殊流程

**需求变更：** 记录变更 → 评估影响 → 更新计划

**取消开发：** 检查修改状态 → 确认保留内容 → 回滚（如需）
