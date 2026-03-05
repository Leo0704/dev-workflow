# Dev-Workflow 项目规范

本文档包含项目的关键约定和规范，供 AI 助手参考。

## 项目概述

这是一个 Claude Code 开发工作流增强插件，提供结构化的9步开发流程。

## 核心功能

### 1. 开发工作流 (dev-workflow)
- 9步开发流程：历史学习检查 → 需求理解 → 上下文调研 → 影响分析 → 实施计划 → 代码开发 → 代码审核 → 测试验证 → 学习记录
- 强制需求确认机制：需求不清晰不写代码

### 2. 任务分级 (v2.1 新增)
- **Quick** 🚀：typo、注释、小修改 → 直接写代码
- **Standard** ⚡：bug修复、单文件改动 → 需求分析+计划+开发
- **Full** 📋：新功能、模块开发 → 完整9步流程
- 自动检测任务复杂度并适配流程

### 3. 强制步骤更新

每个 skill **必须在开始时**更新 `.workflow-step`，确保钩子能正确检查流程状态。

### 4. 自我学习系统
- 学习数据存储在插件目录 `~/.claude/plugins/dev-workflow/data/`
- `data/learnings.md` - 最佳实践和经验（自动生成草稿）
- `data/errors.md` - 错误和解决方案（钩子自动记录）

### 4. Git 集成 (v2.1 新增)
- 步骤4确认后：建议创建 feature 分支
- 步骤8完成后：提示 `/commit` 或 `/commit-push-pr`

## 文件分布

| 位置 | 内容 | 说明 |
|------|------|------|
| 用户项目 `task/` | 需求文档、分析报告、工作流状态 | 跟随项目，可版本控制 |
| 插件目录 `data/` | 学习数据 | 跨项目复用 |

## 目录结构

```
~/.claude/plugins/dev-workflow/
├── .claude-plugin/
│   └── plugin.json          # 插件清单
├── skills/                   # 技能目录
│   ├── dev-workflow/         # 主工作流
│   ├── requirement-analysis/
│   ├── context-research/
│   ├── impact-analysis/
│   ├── implementation-plan/
│   ├── code-development/
│   ├── code-review/
│   ├── testing/
│   └── learning-record/
├── hooks/                    # 钩子
│   ├── hooks.json
│   ├── task-classifier.sh    # 任务分级（新增）
│   ├── git-integration.sh    # Git 集成（新增）
│   └── *.sh
├── agents/                   # 子代理
├── data/                     # 学习数据（安装时创建）
│   ├── learnings.md
│   └── errors.md
├── CLAUDE.md                 # 本文件（项目规范）
└── README.md
```

## 钩子系统

| 钩子 | 触发时机 | 作用 |
|------|----------|------|
| SessionStart | 会话开始 | 显示当前任务 |
| UserPromptSubmit | 用户提交提示 | **任务分级** + 需求检查 |
| PreToolUse | 工具使用前 | 检查文件边界和工作流步骤 |
| Stop | 会话结束 | **Git 建议** + **智能学习提取** |
| PostToolUse(Bash) | Bash命令后 | 错误检测，自动记录到插件数据 |

## 开发规范

### 工作边界
- 只修改允许修改的项目/目录
- 参考其他项目代码时只读取不修改

### 代码风格
- Shell 脚本使用 bash shebang
- 保持钩子脚本精简，避免性能影响

### 提交规范
- 不添加 Co-Authored-By 标识

## 常用命令

```bash
# 查看插件学习数据
cat ~/.claude/plugins/dev-workflow/data/learnings.md
cat ~/.claude/plugins/dev-workflow/data/errors.md

# 手动记录学习
/dev-workflow:learning-record

# 切换任务级别
echo "quick" > task/$(cat task/.current-task)/.task-level
echo "standard" > task/$(cat task/.current-task)/.task-level
echo "full" > task/$(cat task/.current-task)/.task-level
```

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 2.1.1 | 2026-03-05 | 修复步骤流转问题：skill 必须在开始时更新 `.workflow-step` |
| 2.1.0 | 2026-03-05 | 任务分级、自动步骤流转、智能学习提取、Git 集成 |
| 2.0.0 | - | 重构为插件结构 |
| 1.0.0 | - | 初始版本 |
