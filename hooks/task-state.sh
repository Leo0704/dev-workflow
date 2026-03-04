#!/bin/bash
# 任务状态管理工具
# 提供 任务状态查询、更新、持久化 功能

set -e

# 加载共享库
source "$(dirname "$0")/lib/common.sh"

# 项目路径
PROJECT_ROOT=$(get_project_root)
TASK_DIR="$PROJECT_ROOT/task"
ACTIVE_TASKS_FILE="$TASK_DIR/.active-tasks.json"
CURRENT_TASK_FILE="$TASK_DIR/.current-task"

# 获取任务状态文件路径
get_task_state_file() {
    local task_dir="$1"
    if [ -n "$task_dir" ] && [ -d "$task_dir" ]; then
        echo "$task_dir/.task-state.json"
    fi
}

# 初始化活动任务列表
init_active_tasks() {
    if [ ! -f "$ACTIVE_TASKS_FILE" ]; then
        mkdir -p "$TASK_DIR"
        local timestamp=$(get_timestamp)
        cat > "$ACTIVE_TASKS_FILE" << EOF
{
  "task_list_id": "auto-agent-main",
  "created_at": "$timestamp",
  "last_updated": "$timestamp",
  "checkpoint_interval_minutes": 30,
  "active_tasks": []
}
EOF
        log_success "Created active tasks file"
    fi
}

# 添加任务到活动列表
add_task_to_active() {
    local task_id="$1"
    require_jq || return 1
    init_active_tasks

    # 检查任务是否已存在
    local exists=$(jq -e --arg id "$task_id" '.active_tasks[] | select(.id == $id)' "$ACTIVE_TASKS_FILE" 2>/dev/null)
    if [ -n "$exists" ]; then
        log_warn "Task $task_id already in active list"
        return 0
    fi

    # 添加任务
    local timestamp=$(get_timestamp)
    json_update "$ACTIVE_TASKS_FILE" \
        '.active_tasks += [{"id": $id, "status": "in_progress", "started_at": $ts}] | .last_updated = $ts' \
        --arg id "$task_id" --arg ts "$timestamp"
    log_success "Added task $task_id to active list"
}

# 从活动列表移除任务
remove_task_from_active() {
    local task_id="$1"
    require_jq || return 1

    if [ ! -f "$ACTIVE_TASKS_FILE" ]; then
        return 0
    fi

    local timestamp=$(get_timestamp)
    json_update "$ACTIVE_TASKS_FILE" \
        '.active_tasks = [.active_tasks[] | select(.id != $id)] | .last_updated = $ts' \
        --arg id "$task_id" --arg ts "$timestamp"
    log_success "Removed task $task_id from active list"
}

# 更新任务状态
update_task_status() {
    local task_dir="$1"
    local status="$2"
    local state_file="$task_dir/.task-state.json"

    if [ ! -f "$state_file" ]; then
        log_error "Task state file not found: $state_file"
        return 1
    fi

    local timestamp=$(get_timestamp)
    json_update "$state_file" \
        '.status = $status | .last_updated = $ts' \
        --arg status "$status" --arg ts "$timestamp"
    log_success "Updated task status to: $status"
}

# 更新工作流步骤
update_workflow_step() {
    local task_dir="$1"
    local step="$2"
    local state_file="$task_dir/.task-state.json"
    local step_file="$task_dir/.workflow-step"

    # 更新 .workflow-step 文件
    echo "$step" > "$step_file"

    # 更新 .task-state.json
    if [ -f "$state_file" ]; then
        local step_names=("历史学习检查" "需求理解" "上下文调研" "影响分析" "实施计划" "代码开发" "代码审核" "测试验证" "学习记录")
        local step_name="${step_names[$step]:-未知}"
        local timestamp=$(get_timestamp)

        json_update "$state_file" \
            '.workflow_step = $step | .workflow_step_name = $name | .last_updated = $ts' \
            --argjson step "$step" --arg name "$step_name" --arg ts "$timestamp"
        log_success "Updated workflow step to: $step"
    fi
}

# 获取任务状态摘要
get_task_summary() {
    local task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    if [ -z "$task_dir" ]; then
        echo "无当前任务"
        return 0
    fi

    local state_file="$task_dir/.task-state.json"
    if [ ! -f "$state_file" ]; then
        echo "任务状态文件不存在"
        return 0
    fi

    require_jq || return 1

    local task_id=$(jq -r '.task_id // "unknown"' "$state_file")
    local name=$(jq -r '.name // "unnamed"' "$state_file")
    local status=$(jq -r '.status // "unknown"' "$state_file")
    local step=$(jq -r '.workflow_step // 0' "$state_file")
    local step_name=$(jq -r '.workflow_step_name // "未开始"' "$state_file")

    echo "任务: $task_id"
    echo "名称: $name"
    echo "状态: $status"
    echo "步骤: $step - $step_name"
}

# 记录决策
record_decision() {
    local task_dir="$1"
    local context="$2"
    local decision="$3"
    local reasoning="$4"

    local decisions_file="$task_dir/.memory/decisions.json"
    if [ ! -f "$decisions_file" ]; then
        mkdir -p "$(dirname "$decisions_file")"
        echo '{"task_id": "unknown", "decisions": []}' > "$decisions_file"
    fi

    require_jq || return 1

    local timestamp=$(get_timestamp)
    local decision_id="DEC-$(date +%Y%m%d%H%M%S)"

    json_update "$decisions_file" \
        '.decisions += [{id: $id, timestamp: $ts, context: $ctx, decision: $dec, reasoning: $rea, alternatives: []}]' \
        --arg id "$decision_id" --arg ts "$timestamp" --arg ctx "$context" --arg dec "$decision" --arg rea "$reasoning"
    log_success "Recorded decision: $decision_id"
}

# 记录错误
record_error() {
    local task_dir="$1"
    local tool="$2"
    local error_type="$3"
    local message="$4"

    local errors_file="$task_dir/.memory/errors.json"
    if [ ! -f "$errors_file" ]; then
        mkdir -p "$(dirname "$errors_file")"
        echo '{"task_id": "unknown", "errors": []}' > "$errors_file"
    fi

    require_jq || return 1

    local timestamp=$(get_timestamp)
    local error_id="ERR-$(date +%Y%m%d%H%M%S)"

    json_update "$errors_file" \
        '.errors += [{id: $id, timestamp: $ts, tool: $tool, error_type: $type, message: $msg, resolved: false}]' \
        --arg id "$error_id" --arg ts "$timestamp" --arg tool "$tool" --arg type "$error_type" --arg msg "$message"
    log_success "Recorded error: $error_id"
}

# 主命令入口
case "${1:-}" in
    "init")
        init_active_tasks
        ;;
    "add")
        add_task_to_active "${2:-}"
        ;;
    "remove")
        remove_task_from_active "${2:-}"
        ;;
    "status")
        update_task_status "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}"
        ;;
    "step")
        update_workflow_step "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}"
        ;;
    "summary")
        get_task_summary
        ;;
    "decision")
        record_decision "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}" "${3:-}" "${4:-}"
        ;;
    "error")
        record_error "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}" "${3:-}" "${4:-}"
        ;;
    "current")
        get_current_task_name "$PROJECT_ROOT"
        ;;
    "dir")
        get_current_task_dir "$PROJECT_ROOT"
        ;;
    *)
        echo "用法: $0 {init|add|remove|status|step|summary|decision|error|current|dir}"
        echo ""
        echo "命令说明:"
        echo "  init              - 初始化活动任务列表"
        echo "  add <task_id>     - 添加任务到活动列表"
        echo "  remove <task_id>  - 从活动列表移除任务"
        echo "  status <status>   - 更新当前任务状态"
        echo "  step <number>     - 更新工作流步骤"
        echo "  summary           - 显示任务状态摘要"
        echo "  decision          - 记录决策"
        echo "  error             - 记录错误"
        echo "  current           - 获取当前任务名"
        echo "  dir               - 获取当前任务目录"
        exit 1
        ;;
esac
