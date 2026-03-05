---
name: requirement-analysis
description: |
  需求分析技能 - 深度理解、拆解和分析业务需求。

  触发场景：用户说"分析需求"、"理解需求"、"拆解需求"、"需求文档"、"PRD分析"、
  "帮我看看这个需求"、"业务分析"、"可行性分析"、"需求澄清"，或提供了需求文档/PDF。

  当用户提供了一份需求文档、PRD、功能描述，或需要深入理解业务需求、
  拆解功能点、评估技术可行性时，使用此技能。
user-invokable: true
---

老板好！这是需求分析技能。

---

## 执行流程

### ⚠️ 步骤 0: 立即更新工作流状态（必须）

**在开始任何操作前，必须先更新工作流步骤！**

```bash
echo "1" > task/$(cat task/.current-task)/.workflow-step
```

这确保钩子知道当前正在执行步骤 1。

### 步骤 1: 读取需求文档

```bash
# 检查任务目录中的需求文档
ls task/{当前任务}/
# 常见文档: prd.pdf, requirements.md, 需求文档.*
```

### 步骤 2: 搜索相关知识

使用 Grep、WebSearch 或 MCP 工具搜索：
- 业务领域知识
- 技术方案参考
- 开源项目参考

### 步骤 3: 分析和拆解

按以下维度分析：
1. **业务价值** - 解决什么问题、目标用户、成功指标
2. **需求拆解** - 功能点、优先级(P0/P1/P2)、依赖关系
3. **技术可行性** - 技术方案、风险评估
4. **工作边界** - 可修改/只读/禁止的范围
5. **模糊点** - 需要用户确认的问题

### 步骤 4: 生成报告

使用模板: `templates/requirement-report.md`

```bash
# 读取模板
cat skills/requirement-analysis/templates/requirement-report.md

# 填充后保存到
task/{当前任务}/requirement-report.md
```

### 步骤 5: 确认模糊点

**重要**: 如果有模糊点，使用 AskUserQuestion 工具向用户确认后再继续。

---

## 输出文件

生成报告到: `task/{任务名}/requirement-report.md`

---

## 核心原则

> **需求理解不清楚，坚决不写代码**
> **用户没确认模糊点，坚决不进入下一步**
