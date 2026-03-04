# 代码重复审核报告

**生成时间**: 2026-03-04
**审核范围**: hooks/, skills/, 配置文件

---

## 摘要

| 类别 | 重复点数 | 高优先级 | 建议处理 |
|------|----------|----------|----------|
| Hooks | 5 | 3 | 重构抽取公共函数 |
| Skills | 0 | 0 | 无需处理 |
| 配置文件 | 2 | 1 | 合并冗余内容 |

---

## 一、Hooks 目录重复分析

### 重复点 1: 项目路径和任务目录获取 (高优先级)

**出现次数**: 10 个文件

**重复代码**:
```bash
PROJECT_ROOT=$(get_project_root)
TASK_DIR="$PROJECT_ROOT/task"
CURRENT_TASK_FILE="$TASK_DIR/.current-task"
CURRENT_TASK_NAME=$(get_current_task_name)
CURRENT_TASK_DIR=$(get_current_task_dir)
```

**涉及文件**:
- hooks/check-requirements.sh:6-12
- hooks/check-file-boundary.sh:35-36
- hooks/check-bash-boundary.sh:18-19
- hooks/check-workflow-step.sh:17-21
- hooks/code-review.sh:17-22
- hooks/session-start.sh:7-11
- hooks/task-state.sh:11-14
- hooks/checkpoint.sh:11-13
- hooks/error-detector.sh:7
- hooks/learning-activator.sh:7

**重构建议**:
已在 `hooks/lib/common.sh` 中有部分函数，建议扩展：
```bash
# 在 common.sh 中添加
init_task_context() {
    local root="${1:-$(get_project_root)}"
    PROJECT_ROOT="$root"
    TASK_DIR="$root/task"
    CURRENT_TASK_FILE="$TASK_DIR/.current-task"
    CURRENT_TASK_NAME=$(get_current_task_name "$root")
    CURRENT_TASK_DIR=$(get_current_task_dir "$root")
}
```

---

### 重复点 2: jq 依赖检查 (中优先级)

**出现次数**: 7 个文件

**重复代码**:
```bash
has_jq || exit 0
# 或
if ! has_jq; then
    ...
fi
```

**涉及文件**:
- hooks/check-file-boundary.sh:9
- hooks/check-bash-boundary.sh:9
- hooks/check-workflow-step.sh:8
- hooks/code-review.sh:8
- hooks/error-detector.sh:8-9
- hooks/session-start.sh:18,39
- hooks/task-state.sh:45,66,etc

**重构建议**:
已经抽取到 `common.sh`，但可以考虑添加自动跳过模式：
```bash
# 在 common.sh 中添加
skip_if_no_jq() {
    has_jq || exit 0
}
```

---

### 重复点 3: 标准 JSON 输入读取 (中优先级)

**出现次数**: 5 个文件

**重复代码**:
```bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
# 或
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
```

**涉及文件**:
- hooks/check-requirements.sh:10-11
- hooks/check-file-boundary.sh:11-12
- hooks/check-bash-boundary.sh:11-12
- hooks/check-workflow-step.sh:10-11
- hooks/error-detector.sh:11-12

**重构建议**:
```bash
# 在 common.sh 中添加
read_tool_input() {
    local field="$1"
    local default="${2:-}"
    cat | jq -r ".tool_input.$field // $default"
}
```

---

### 重复点 4: 路径边界检查逻辑 (高优先级)

**出现次数**: 2 个文件 (但逻辑相似度高)

**重复逻辑**:
- `check-file-boundary.sh`: 检查文件写入路径
- `check-bash-boundary.sh`: 检查 Bash 命令中的路径

两个文件都有：
```bash
ALLOWED_PREFIXES=()
ALLOWED_PREFIXES+=("$PROJECT_ROOT")
ALLOWED_PREFIXES+=("$HOME/.claude")

# 从配置文件读取额外的允许路径
if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r path; do
        ...
    done < <(jq -r '.allowedPaths[]? // empty' "$CONFIG_FILE")
fi
```

**重构建议**:
```bash
# 在 common.sh 中添加
get_allowed_paths() {
    local root="${1:-$(get_project_root)}"
    local config_file="$root/.claude/config.json"

    echo "$root"
    echo "$HOME/.claude"

    if [ -f "$config_file" ] && has_jq; then
        jq -r '.allowedPaths[]? // empty' "$config_file" | while read -r path; do
            [[ "$path" != /* ]] && path="$root/$path"
            echo "$path"
        done
    fi
}

is_path_allowed() {
    local path="$1"
    local allowed
    while IFS= read -r allowed; do
        [[ "$path" == "$allowed"* ]] && return 0
    done < <(get_allowed_paths)
    return 1
}
```

---

### 重复点 5: 任务状态/步骤读取 (高优先级)

**出现次数**: 4 个文件

**重复逻辑**:
```bash
STEP_FILE="$TASK_DIR/$CURRENT_TASK_NAME/.workflow-step"
if [ -f "$STEP_FILE" ]; then
    CURRENT_STEP=$(cat "$STEP_FILE" 2>/dev/null | tr -d ' \n')
fi

# 或读取 .task-state.json
if [ -f "$state_file" ] && has_jq; then
    local status=$(jq -r '.status // "unknown"' "$state_file")
    local step=$(jq -r '.workflow_step // 0' "$state_file")
fi
```

**涉及文件**:
- hooks/check-workflow-step.sh:21,49-56
- hooks/code-review.sh:30-33
- hooks/session-start.sh:14-30
- hooks/task-state.sh:17-22,120-146
- hooks/checkpoint.sh:54-67

**重构建议**:
```bash
# 在 common.sh 中添加
get_workflow_step() {
    local task_dir="${1:-$(get_current_task_dir)}"
    local step_file="$task_dir/.workflow-step"

    if [ -f "$step_file" ]; then
        local step=$(cat "$step_file" 2>/dev/null | tr -d ' \n')
        [[ "$step" =~ ^[0-9]+$ ]] && echo "$step" && return
    fi
    echo "0"
}

get_task_status() {
    local task_dir="${1:-$(get_current_task_dir)}"
    local state_file="$task_dir/.task-state.json"

    if [ -f "$state_file" ] && has_jq; then
        jq -c '{status, workflow_step, workflow_step_name, last_updated}' "$state_file"
    fi
}
```

---

## 二、Skills 目录分析

**审核结果**: 无明显重复

当前 skills 目录结构：
```
skills/
├── dev-guide/SKILL.md
├── code-review/SKILL.md
└── dev-workflow/SKILL.md
```

3 个技能文件各司其职，内容互补，无重复。

---

## 三、配置文件重复分析

### 重复点 1: CLAUDE.md 与 MEMORY.md 内容重叠

**重复内容**:

| 内容 | CLAUDE.md | MEMORY.md |
|------|-----------|-----------|
| 提交规范 | ✓ "不添加 Co-Authored-By 标识" | ✓ "提交规范: 不添加 Co-Authored-By 标识" |
| 需求原则 | ✓ "需求不清晰不写代码" | ✓ "需求原则: 需求不清晰不写代码" |
| 工作流步骤 | ✓ 描述了工作流步骤 | ✓ "工作流: 步骤通过 .workflow-step 文件跟踪" |
| 钩子系统 | ✓ 详细描述 | - |
| 学习日志 | ✓ 详细描述 | ✓ 简要提及 |

**建议**:
- MEMORY.md 应该只保留**跨会话的关键约定**
- 详细规范保留在 CLAUDE.md
- MEMORY.md 简化为引用 CLAUDE.md

**重构后 MEMORY.md**:
```markdown
# Auto-Agent 项目记忆

> 详细规范见 CLAUDE.md

## 关键约定（跨会话）

- 提交时不添加 Co-Authored-By 标识
- 需求不清晰不写代码
- 工作流步骤通过 .workflow-step 文件跟踪

## 记忆层次

- `MEMORY.md`（本文件）: 关键约定
- `~/.claude/projects/.../memory/`: 用户级自动记忆
- `.learnings/`: 学习日志
```

---

### 重复点 2: dev-workflow/SKILL.md 与 CLAUDE.md 部分重叠

**重叠内容**:
- 工作流步骤描述
- 目录结构说明
- 学习日志系统说明

**建议**:
- dev-workflow/SKILL.md 是详细的工作流指南
- CLAUDE.md 应该只保留核心约定，引用 SKILL.md 获取详细步骤

---

## 四、重构建议汇总

### 高优先级（建议立即处理）

1. **扩展 common.sh 公共函数库**
   - 添加 `init_task_context()`
   - 添加 `read_tool_input()`
   - 添加 `get_workflow_step()`
   - 添加 `is_path_allowed()`

2. **合并路径边界检查逻辑**
   - check-file-boundary.sh 和 check-bash-boundary.sh 共用 `is_path_allowed()`

### 中优先级（建议后续处理）

3. **简化 MEMORY.md**
   - 只保留关键约定
   - 引用 CLAUDE.md 获取详细规范

### 低优先级（可选）

4. **统一任务状态读取**
   - 考虑完全迁移到 .task-state.json
   - 或保持 .workflow-step 作为简单状态

---

## 五、推荐重构步骤

```bash
# 步骤 1: 扩展 common.sh
# 添加上述推荐的公共函数

# 步骤 2: 重构 hooks
# 逐个更新 hooks 使用公共函数

# 步骤 3: 简化配置文件
# 精简 MEMORY.md

# 步骤 4: 测试
# 确保所有 hooks 正常工作
```

---

## 附录：当前 hooks/lib/common.sh 内容

```bash
# 已有的公共函数
- 颜色定义 (RED, GREEN, YELLOW, BLUE, NC)
- 日志函数 (log_info, log_success, log_warn, log_error)
- get_project_root()
- require_jq(), has_jq()
- get_current_task_name(), get_current_task_dir()
- json_update()
- count_files()
- get_timestamp()
```

建议扩展的函数见上述重构建议。
