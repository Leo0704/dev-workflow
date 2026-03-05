# Dev-Workflow

Claude Code 开发工作流增强插件，提供结构化的9步开发流程。

## 安装

### 方式一：一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/Leo0704/dev-workflow/main/install.sh | bash
```

### 方式二：手动安装

```bash
# 克隆到插件目录
git clone https://github.com/Leo0704/dev-workflow.git ~/.claude/plugins/dev-workflow
```

### 验证安装

```bash
# 在 Claude Code 中执行
/dev-workflow:dev-workflow
```

## 新增特性 (v2.1)

### 任务分级

工作流自动检测任务复杂度，适配流程：

| 级别 | 触发条件 | 流程 |
|------|----------|------|
| **Quick** 🚀 | typo、注释、小修改 | 直接到步骤5 |
| **Standard** ⚡ | bug修复、单文件改动 | 需求分析→计划→开发 |
| **Full** 📋 | 新功能、模块开发 | 完整9步流程 |

### 自动步骤流转

每个 skill 完成后自动更新 `.workflow-step`，无需手动维护。

### 智能学习提取

会话结束时自动分析并生成学习点草稿，执行 `/dev-workflow:learning-record` 确认。

### Git 集成

- 步骤4确认后：建议创建 feature 分支
- 步骤8完成后：提示使用 `/commit` 或 `/commit-push-pr`

## 插件结构

```
dev-workflow/
├── .claude-plugin/
│   └── plugin.json       # 插件清单
├── skills/                # 技能目录
│   ├── dev-workflow/      # 主工作流
│   ├── requirement-analysis/
│   ├── context-research/
│   ├── impact-analysis/
│   ├── implementation-plan/
│   ├── code-development/
│   ├── code-review/
│   ├── testing/
│   └── learning-record/
├── hooks/                 # 钩子
│   ├── hooks.json
│   ├── task-classifier.sh    # 任务分级（新增）
│   ├── git-integration.sh    # Git 集成（新增）
│   ├── learning-activator.sh # 智能学习（增强）
│   └── *.sh
├── data/                  # 学习数据（安装时创建）
│   ├── learnings.md
│   └── errors.md
├── CLAUDE.md              # 项目规范
└── README.md
```

## 可用技能

所有技能都以 `/dev-workflow:` 为前缀：

| 技能 | 命令 | 说明 |
|------|------|------|
| 主工作流 | `/dev-workflow:dev-workflow` | 完整9步开发流程 |
| 需求分析 | `/dev-workflow:requirement-analysis` | 分析业务需求 |
| 上下文调研 | `/dev-workflow:context-research` | 探索相关代码 |
| 影响分析 | `/dev-workflow:impact-analysis` | 评估风险影响 |
| 实施计划 | `/dev-workflow:implementation-plan` | 设计技术方案 |
| 代码开发 | `/dev-workflow:code-development` | 编写代码 |
| 代码审核 | `/dev-workflow:code-review` | 审核代码质量 |
| 测试验证 | `/dev-workflow:testing` | 执行测试 |
| 学习记录 | `/dev-workflow:learning-record` | 确认学习点 |

## 开发工作流

9 步开发流程：

| 步骤 | 名称 | 说明 | 自动流转 |
|------|------|------|----------|
| 0 | 历史学习检查 | 检查相关历史学习 | ✅ |
| 1 | 需求理解 | 读取需求文档，确认模糊点 | ✅ |
| 2 | 上下文调研 | 调研相关代码和文档 | ✅ |
| 3 | 影响分析 | 评估改动范围和风险 | ✅ |
| 4 | 实施计划 | 拆分任务，制定计划 | ✅ |
| 5 | 代码开发 | 编写代码 | ✅ |
| 6 | 代码审核 | 审核代码质量 | ✅ |
| 7 | 测试验证 | 编写测试，执行验证 | ✅ |
| 8 | 学习记录 | 记录有价值的学习 | ✅ |

**核心原则：需求理解不清晰，坚决不写代码！**

## 钩子系统

| 钩子 | 触发时机 | 作用 |
|------|----------|------|
| SessionStart | 会话开始 | 显示当前任务和状态 |
| UserPromptSubmit | 用户提交提示 | 任务分级 + 需求提醒 |
| PreToolUse(Edit/Write) | 文件编辑前 | 检查工作流步骤 |
| PreToolUse(Bash) | 命令执行前 | 检查命令边界 |
| PostToolUse(Bash) | Bash命令后 | 错误检测，自动记录 |
| Stop | 会话结束 | Git 建议 + 学习提取 |

## 自我学习系统

插件会自动积累学习数据，存储在插件目录：

| 文件 | 内容 | 更新方式 |
|------|------|----------|
| `data/learnings.md` | 最佳实践和经验 | 自动草稿 + 手动确认 |
| `data/errors.md` | 错误和解决方案 | 钩子自动记录 |

管理学习数据：`/dev-workflow:learning-record`

## 文件分布

| 位置 | 内容 | 说明 |
|------|------|------|
| 用户项目 `task/` | 需求文档、分析报告、工作流状态 | 跟随项目，可版本控制 |
| 插件目录 `data/` | 学习数据 | 跨项目复用 |

```
用户项目/                       插件目录/
├── src/                       ├── skills/
├── package.json               ├── hooks/
└── task/                      ├── agents/
    ├── 2026-03-05-登录/       └── data/
    │   ├── prd.pdf                  ├── learnings.md
    │   ├── requirement-report.md    └── errors.md
    │   ├── .workflow-step
    │   └── .task-level        ← 新增：任务级别
    └── .current-task
```

## 快速命令

### 切换任务级别

```bash
# Quick 模式（直接写代码）
echo "quick" > task/$(cat task/.current-task)/.task-level
echo "5" > task/$(cat task/.current-task)/.workflow-step

# Standard 模式（需求+计划+开发）
echo "standard" > task/$(cat task/.current-task)/.task-level

# Full 模式（完整流程）
echo "full" > task/$(cat task/.current-task)/.task-level
```

### 跳过工作流

```bash
touch task/$(cat task/.current-task)/.skip-workflow
```

## 依赖

- Claude Code CLI
- jq（JSON 处理）
- bash
