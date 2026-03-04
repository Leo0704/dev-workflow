# Auto-Agent

基于 Claude Code 的开发工作流增强系统，提供结构化的开发流程和自我改进能力。

## 快速开始

### 1. 创建需求目录

```bash
mkdir -p requirements/$(date +%Y-%m-%d)-功能名称
```

### 2. 放入需求文档

将 PRD、设计图等文档放入刚创建的目录：

```
requirements/
└── 2026-03-03-功能名称/
    ├── prd.pdf
    └── 设计图.png
```

### 3. 切换到该任务

```bash
echo "$(date +%Y-%m-%d)-功能名称" > task/.current-task
```

### 4. 启动工作流

在 Claude Code 中输入 `/dev-workflow` 启动开发工作流。

## 目录结构

```
auto-agent/
├── requirements/           # 需求文档目录
│   ├── YYYY-MM-DD-功能名/  # 按日期+功能命名
│   │   ├── prd.pdf        # 需求文档
│   │   └── 设计图.png      # 设计稿
│   └── README.md          # 目录说明
├── task/                   # 运行时状态（自动生成）
│   ├── .active-tasks.json # 活动任务列表
│   ├── .current-task      # 当前任务标识
│   └── YYYY-MM-DD-功能名/ # 任务状态目录
│       ├── .task-state.json      # 任务状态
│       ├── .workflow-step        # 工作流步骤
│       ├── .memory/              # 任务记忆
│       │   ├── decisions.json    # 决策记录
│       │   ├── findings.json     # 发现记录
│       │   └── errors.json       # 错误记录
│       └── checkpoints/          # 检查点
│           └── CP-*.json         # 检查点数据
├── hooks/                  # 钩子脚本
│   ├── session-start.sh    # 会话启动
│   ├── check-requirements.sh
│   ├── check-workflow-step.sh
│   ├── task-state.sh       # 任务状态管理
│   └── checkpoint.sh       # 检查点管理
├── skills/                 # 技能文件
│   ├── dev-workflow/       # 开发工作流（主编排）
│   ├── requirement-analysis/
│   ├── context-research/
│   ├── impact-analysis/
│   ├── implementation-plan/
│   ├── code-development/
│   ├── code-review/
│   ├── testing/
│   └── learning-record/
├── .claude/learnings/             # 学习日志
│   ├── LEARNINGS.md        # 学习记录
│   ├── ERRORS.md           # 错误记录
│   └── FEATURE_REQUESTS.md # 功能请求
├── .claude/                # Claude Code 配置
│   ├── hooks -> ../hooks   # 钩子链接
│   └── settings.local.json
├── settings.json           # 钩子注册
├── CLAUDE.md               # 项目规范
├── MEMORY.md               # 跨会话记忆
└── README.md               # 本文件
```

## 开发工作流

8 步开发流程：

| 步骤 | 名称 | 说明 |
|------|------|------|
| 0 | 历史学习检查 | 检查相关历史学习 |
| 1 | 需求理解 | 读取需求文档，确认模糊点 |
| 2 | 上下文调研 | 调研相关代码和文档 |
| 3 | 影响分析 | 评估改动范围和风险 |
| 4 | 实施计划 | 拆分任务，制定计划 |
| 5 | 代码开发 | 编写代码 |
| 6 | 代码审核 | 审核代码质量 |
| 7 | 测试验证 | 编写测试，执行验证 |
| 8 | 学习记录 | 记录有价值的学习 |

**核心原则：需求理解不清晰，坚决不写代码！**

## 常用命令

```bash
# 创建新任务
mkdir -p requirements/$(date +%Y-%m-%d)-功能名称
echo "$(date +%Y-%m-%d)-功能名称" > task/.current-task

# 查看任务状态
bash hooks/task-state.sh summary

# 创建检查点
bash hooks/checkpoint.sh create "描述"

# 列出检查点
bash hooks/checkpoint.sh list

# 恢复检查点
bash hooks/checkpoint.sh restore CP-xxx

# 记录学习
echo "## [LRN-$(date +%Y%m%d)-001] category" >> .claude/learnings/LEARNINGS.md
```

## 钩子系统

| 钩子 | 触发时机 | 作用 |
|------|----------|------|
| SessionStart | 会话开始 | 显示当前任务和状态 |
| UserPromptSubmit | 用户提交提示 | 显示需求文档提醒 |
| PreToolUse(Edit/Write) | 文件编辑前 | 检查工作流步骤 |
| PreToolUse(Bash) | 命令执行前 | 检查命令边界 |
| Stop | 会话结束 | 代码审核 |

## 学习系统

- `MEMORY.md` - 跨会话持久化记忆
- `.claude/learnings/LEARNINGS.md` - 学习和最佳实践
- `.claude/learnings/ERRORS.md` - 错误和解决方案

## 配置

复制到新项目：

```bash
# 复制核心文件
cp -r hooks/ /path/to/new-project/
cp -r skills/ /path/to/new-project/
cp settings.json /path/to/new-project/
cp CLAUDE.md /path/to/new-project/

# 创建目录
mkdir -p /path/to/new-project/{requirements,task,.claude/learnings,.claude}
ln -s ../hooks /path/to/new-project/.claude/hooks
```

## 依赖

- Claude Code CLI
- jq（JSON 处理）
- bash
