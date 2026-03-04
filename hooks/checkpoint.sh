#!/bin/bash
# 检查点管理工具
# 提供 创建、恢复、列出、清理 检查点功能

set -e

# 加载共享库
source "$(dirname "$0")/lib/common.sh"

# 项目路径
PROJECT_ROOT=$(get_project_root)
TASK_DIR="$PROJECT_ROOT/task"
CURRENT_TASK_FILE="$TASK_DIR/.current-task"

# 默认配置
CHECKPOINT_INTERVAL_MINUTES=${CHECKPOINT_INTERVAL_MINUTES:-30}
MAX_CHECKPOINT_AGE_DAYS=${MAX_CHECKPOINT_AGE_DAYS:-30}

# 获取检查点目录
get_checkpoint_dir() {
    local task_dir="$1"
    if [ -n "$task_dir" ]; then
        echo "$task_dir/checkpoints"
    fi
}

# 生成检查点 ID
generate_checkpoint_id() {
    echo "CP-$(date +%Y%m%d-%H%M%S)"
}

# 创建检查点
create_checkpoint() {
    local task_dir="$1"
    local description="${2:-自动检查点}"

    if [ -z "$task_dir" ]; then
        task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    fi

    if [ -z "$task_dir" ]; then
        log_error "No current task"
        return 1
    fi

    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")
    mkdir -p "$checkpoint_dir"

    local checkpoint_id=$(generate_checkpoint_id)
    local checkpoint_file="$checkpoint_dir/${checkpoint_id}.json"
    local timestamp=$(get_timestamp)

    # 收集检查点数据
    local state_file="$task_dir/.task-state.json"
    local workflow_step=0
    local task_status="unknown"

    if [ -f "$state_file" ] && has_jq; then
        workflow_step=$(jq -r '.workflow_step // 0' "$state_file")
        task_status=$(jq -r '.status // "unknown"' "$state_file")
    fi

    # 读取工作流步骤文件
    local step_file="$task_dir/.workflow-step"
    if [ -f "$step_file" ]; then
        workflow_step=$(cat "$step_file" 2>/dev/null | tr -d ' \n')
    fi

    # 创建检查点 JSON
    cat > "$checkpoint_file" << EOF
{
  "checkpoint_id": "$checkpoint_id",
  "task_id": "$(basename "$task_dir")",
  "timestamp": "$timestamp",
  "description": "$description",
  "workflow_step": $workflow_step,
  "task_status": "$task_status",
  "files_snapshot": []
}
EOF

    # 记录当前修改的文件（如果有 git）
    if command -v git &>/dev/null && [ -d "$PROJECT_ROOT/.git" ]; then
        local modified_files=$(git -C "$PROJECT_ROOT" diff --name-only 2>/dev/null | head -20)
        if [ -n "$modified_files" ] && has_jq; then
            local files_json=$(echo "$modified_files" | jq -R -s 'split("\n") | map(select(length > 0))')
            json_update "$checkpoint_file" '.files_snapshot = $files' --argjson files "$files_json"
        fi
    fi

    # 更新任务状态中的检查点列表
    if [ -f "$state_file" ] && has_jq; then
        json_update "$state_file" \
            '.checkpoints += [{"id": $cp, "timestamp": $ts}]' \
            --arg cp "$checkpoint_id" --arg ts "$timestamp"
    fi

    log_success "Created checkpoint: $checkpoint_id"
    echo "  描述: $description"
    echo "  步骤: $workflow_step"
    echo "  文件: $checkpoint_file"

    return 0
}

# 列出检查点
list_checkpoints() {
    local task_dir="$1"

    if [ -z "$task_dir" ]; then
        task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    fi

    if [ -z "$task_dir" ]; then
        echo "无当前任务"
        return 0
    fi

    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")

    if [ ! -d "$checkpoint_dir" ]; then
        echo "无检查点"
        return 0
    fi

    local checkpoints=$(find "$checkpoint_dir" -name "*.json" -type f 2>/dev/null | sort -r)
    local count=$(echo "$checkpoints" | grep -c . 2>/dev/null || echo 0)

    if [ "$count" -eq 0 ] || [ -z "$checkpoints" ]; then
        echo "无检查点"
        return 0
    fi

    echo "检查点列表 (共 $count 个):"
    echo ""

    require_jq || return 1
    echo "$checkpoints" | while read -r cp_file; do
        if [ -n "$cp_file" ] && [ -f "$cp_file" ]; then
            local id=$(jq -r '.checkpoint_id // "unknown"' "$cp_file" 2>/dev/null)
            local ts=$(jq -r '.timestamp // "unknown"' "$cp_file" 2>/dev/null)
            local desc=$(jq -r '.description // "无描述"' "$cp_file" 2>/dev/null)
            local step=$(jq -r '.workflow_step // 0' "$cp_file" 2>/dev/null)
            echo "  [$id] 步骤 $step - $desc"
            echo "        时间: $ts"
            echo ""
        fi
    done
}

# 恢复检查点
restore_checkpoint() {
    local task_dir="$1"
    local checkpoint_id="$2"

    if [ -z "$task_dir" ]; then
        task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    fi

    if [ -z "$task_dir" ]; then
        log_error "No current task"
        return 1
    fi

    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")

    if [ -z "$checkpoint_id" ]; then
        # 获取最新的检查点
        checkpoint_id=$(find "$checkpoint_dir" -name "*.json" -type f 2>/dev/null | sort -r | head -1)
        if [ -z "$checkpoint_id" ]; then
            log_error "No checkpoints found"
            return 1
        fi
        checkpoint_id=$(basename "$checkpoint_id" .json)
    fi

    local checkpoint_file="$checkpoint_dir/${checkpoint_id}.json"

    if [ ! -f "$checkpoint_file" ]; then
        log_error "Checkpoint not found: $checkpoint_id"
        return 1
    fi

    require_jq || return 1

    local step=$(jq -r '.workflow_step // 0' "$checkpoint_file")
    local status=$(jq -r '.task_status // "unknown"' "$checkpoint_file")

    # 恢复工作流步骤
    echo "$step" > "$task_dir/.workflow-step"

    # 更新任务状态
    local state_file="$task_dir/.task-state.json"
    if [ -f "$state_file" ]; then
        local timestamp=$(get_timestamp)
        json_update "$state_file" \
            '.workflow_step = $step | .status = $status | .last_updated = $ts' \
            --argjson step "$step" --arg status "$status" --arg ts "$timestamp"
    fi

    log_success "Restored checkpoint: $checkpoint_id"
    echo "  步骤: $step"
    echo "  状态: $status"

    return 0
}

# 清理旧检查点
cleanup_checkpoints() {
    local task_dir="$1"
    local max_age_days="${2:-$MAX_CHECKPOINT_AGE_DAYS}"

    if [ -z "$task_dir" ]; then
        task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    fi

    if [ -z "$task_dir" ]; then
        return 0
    fi

    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")

    if [ ! -d "$checkpoint_dir" ]; then
        return 0
    fi

    local count=0
    find "$checkpoint_dir" -name "*.json" -type f -mtime +$max_age_days 2>/dev/null | while read -r cp_file; do
        rm "$cp_file"
        count=$((count + 1))
    done

    if [ "$count" -gt 0 ]; then
        log_success "Cleaned up $count old checkpoints (older than $max_age_days days)"
    fi
}

# 检查是否需要创建自动检查点
check_auto_checkpoint() {
    local task_dir=$(get_current_task_dir "$PROJECT_ROOT")

    if [ -z "$task_dir" ]; then
        return 0
    fi

    local state_file="$task_dir/.task-state.json"
    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")
    local last_checkpoint_file="$checkpoint_dir/.last-auto-checkpoint"

    # 获取上次检查点时间
    local last_checkpoint_time=0
    if [ -f "$last_checkpoint_file" ]; then
        last_checkpoint_time=$(cat "$last_checkpoint_file" 2>/dev/null)
    fi

    # 检查间隔
    local current_time=$(date +%s)
    local interval_seconds=$((CHECKPOINT_INTERVAL_MINUTES * 60))
    local elapsed=$((current_time - last_checkpoint_time))

    if [ "$elapsed" -ge "$interval_seconds" ]; then
        create_checkpoint "$task_dir" "定时自动检查点"
        mkdir -p "$checkpoint_dir"
        echo "$current_time" > "$last_checkpoint_file"
    fi
}

# 显示检查点详情
show_checkpoint() {
    local task_dir="$1"
    local checkpoint_id="$2"

    if [ -z "$task_dir" ]; then
        task_dir=$(get_current_task_dir "$PROJECT_ROOT")
    fi

    local checkpoint_dir=$(get_checkpoint_dir "$task_dir")
    local checkpoint_file="$checkpoint_dir/${checkpoint_id}.json"

    if [ ! -f "$checkpoint_file" ]; then
        log_error "Checkpoint not found: $checkpoint_id"
        return 1
    fi

    require_jq || return 1
    cat "$checkpoint_file" | jq .
}

# 主命令入口
case "${1:-}" in
    "create")
        create_checkpoint "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-自动检查点}"
        ;;
    "list"|"ls")
        list_checkpoints "$(get_current_task_dir "$PROJECT_ROOT")"
        ;;
    "restore")
        restore_checkpoint "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}"
        ;;
    "cleanup")
        cleanup_checkpoints "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}"
        ;;
    "auto")
        check_auto_checkpoint
        ;;
    "show")
        show_checkpoint "$(get_current_task_dir "$PROJECT_ROOT")" "${2:-}"
        ;;
    *)
        echo "用法: $0 {create|list|restore|cleanup|auto|show}"
        echo ""
        echo "命令说明:"
        echo "  create [描述]     - 创建检查点"
        echo "  list              - 列出所有检查点"
        echo "  restore [id]      - 恢复检查点（默认最新）"
        echo "  cleanup [天数]    - 清理旧检查点（默认 30 天）"
        echo "  auto              - 检查并创建自动检查点"
        echo "  show <id>         - 显示检查点详情"
        echo ""
        echo "环境变量:"
        echo "  CHECKPOINT_INTERVAL_MINUTES - 自动检查点间隔（默认 30 分钟）"
        echo "  MAX_CHECKPOINT_AGE_DAYS     - 检查点保留天数（默认 30 天）"
        exit 1
        ;;
esac
