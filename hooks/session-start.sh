#!/bin/bash
# 会话开始时注入上下文
# 功能：显示当前任务、加载任务状态、显示检查点信息

source "$(dirname "$0")/lib/common.sh"

init_task_context

# 显示当前任务信息
show_current_task() {
    if [ -z "$CURRENT_TASK_DIR" ] || [ -z "$CURRENT_TASK_NAME" ]; then
        return 1
    fi

    local file_count=$(count_files "$CURRENT_TASK_DIR")

    echo "## 当前任务: $CURRENT_TASK_NAME"
    echo ""

    # 显示工作流步骤
    local current_step=$(get_workflow_step "$CURRENT_TASK_DIR")
    if [ "$current_step" -gt 0 ]; then
        local step_names=("历史学习检查" "需求理解" "上下文调研" "影响分析" "实施计划" "代码开发" "代码审核" "测试验证" "学习记录")
        local step_name="${step_names[$current_step]:-进行中}"
        echo "工作流步骤: $current_step / 8 - $step_name"
        echo ""
    fi

    # 显示需求文档
    if [ "$file_count" -gt 0 ]; then
        echo "需求文档 ($file_count 个):"
        find "$CURRENT_TASK_DIR" -type f ! \( -name ".workflow-step" -o -name ".gitkeep" -o -name "*.json" -o -name "README.md" \) 2>/dev/null | while read -r f; do
            [ -n "$f" ] && echo "  - $(basename "$f")"
        done
        echo ""
    fi

    return 0
}

# 显示可用任务列表
show_available_tasks() {
    local tasks=""

    # 从 requirements/ 目录获取
    if [ -d "$PROJECT_ROOT/requirements" ]; then
        tasks=$(find "$PROJECT_ROOT/requirements" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null)
    fi

    # 从 task/ 目录获取
    if [ -d "$TASK_DIR" ]; then
        local task_tasks=$(find "$TASK_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null)
        if [ -n "$tasks" ] && [ -n "$task_tasks" ]; then
            tasks="$tasks"$'\n'"$task_tasks"
        elif [ -n "$task_tasks" ]; then
            tasks="$task_tasks"
        fi
    fi

    if [ -n "$tasks" ]; then
        echo "## 可用任务"
        echo ""
        echo "$tasks" | sort -u | while read -r task; do
            [ -n "$task" ] && echo "  - $task"
        done
        echo ""
        echo "切换任务命令："
        echo '```bash'
        echo "echo \"任务名\" > task/.current-task"
        echo '```'
        return 0
    fi

    return 1
}

# 主逻辑
if show_current_task; then
    echo "---"
    echo ""
    echo "请使用 \`/dev-workflow\` 继续开发工作流。"
    echo ""
    echo "**需求理解不清晰，坚决不写代码！**"
else
    if show_available_tasks; then
        echo ""
        echo "或将需求文档放入 requirements/ 目录后切换。"
    else
        echo "老板好！请创建需求目录开始开发。"
        echo ""
        echo '```bash'
        echo "mkdir -p task/\$(date +%Y-%m-%d)-功能名称"
        echo "echo \"\$(date +%Y-%m-%d)-功能名称\" > task/.current-task"
        echo '```'
    fi
    echo ""
    echo "**需求理解不清晰，坚决不写代码！**"
fi
