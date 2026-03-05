#!/bin/bash
# 工作流步骤检查（增强版）
# 支持任务分级，根据级别调整步骤要求

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

init_task_context

# 没有当前任务 → 不强制
[ -z "$CURRENT_TASK_DIR" ] && exit 0

# 检查是否跳过工作流
[ -f "$CURRENT_TASK_DIR/.skip-workflow" ] && exit 0

# 检查任务目录是否有需求文档
FILE_COUNT=$(count_files "$CURRENT_TASK_DIR" "-name .workflow-step -o -name .gitkeep -o -name .skip-workflow -o -name .task-level -o -name .skip-*")
[ "$FILE_COUNT" -eq 0 ] && exit 0

# 检查是否是代码文件
is_code_file "$FILE_PATH" || exit 0

# 排除：允许写入工作流状态文件本身
[[ "$FILE_PATH" == *".workflow-step"* ]] && exit 0
[[ "$FILE_PATH" == *".skip-workflow"* ]] && exit 0
[[ "$FILE_PATH" == *".task-level"* ]] && exit 0

# 读取当前步骤和任务级别
CURRENT_STEP=$(get_workflow_step "$CURRENT_TASK_DIR")
TASK_LEVEL="full"
[ -f "$CURRENT_TASK_DIR/.task-level" ] && TASK_LEVEL=$(cat "$CURRENT_TASK_DIR/.task-level" | tr -d ' \n')

# 根据任务级别确定允许写代码的步骤
REQUIRED_STEP=5
case "$TASK_LEVEL" in
    "quick")
        REQUIRED_STEP=0  # Quick Fix: 不限制
        ;;
    "standard")
        REQUIRED_STEP=4  # Standard: 步骤4后可写
        ;;
    "full")
        REQUIRED_STEP=5  # Full: 步骤5后可写
        ;;
esac

# 检查是否满足要求
if [ "$CURRENT_STEP" -lt "$REQUIRED_STEP" ]; then
    # 根据任务级别生成不同的提示
    case "$TASK_LEVEL" in
        "quick")
            # Quick Fix 不应该到这里，但如果到了就放行
            exit 0
            ;;
        "standard")
            echo "" >&2
            echo "┌─────────────────────────────────────────────────────────┐" >&2
            echo "│  ⚠️  工作流检查 [Standard 模式]" >&2
            echo "├─────────────────────────────────────────────────────────┤" >&2
            echo "│  当前步骤: ${CURRENT_STEP}/8" >&2
            echo "│  Standard 模式需要完成到步骤 4 才能修改代码" >&2
            echo "│" >&2
            if [ "$CURRENT_STEP" -eq 0 ]; then
                echo "│  💡 建议: 先完成需求分析 (步骤 1)" >&2
            elif [ "$CURRENT_STEP" -lt 4 ]; then
                echo "│  💡 建议: 先完成实施计划 (步骤 4)" >&2
            fi
            echo "│" >&2
            echo "│  切换模式:" >&2
            echo "│  echo 'quick' > task/\$(cat task/.current-task)/.task-level" >&2
            echo "│  echo '0' > task/\$(cat task/.current-task)/.workflow-step" >&2
            echo "└─────────────────────────────────────────────────────────┘" >&2
            echo "" >&2
            exit 2
            ;;
        "full")
            echo "" >&2
            echo "┌─────────────────────────────────────────────────────────┐" >&2
            echo "│  ⚠️  工作流检查 [Full 模式]" >&2
            echo "├─────────────────────────────────────────────────────────┤" >&2
            echo "│  当前步骤: ${CURRENT_STEP}/8" >&2
            echo "│  Full 模式需要完成到步骤 5 才能修改代码" >&2
            echo "│" >&2
            if [ "$CURRENT_STEP" -eq 0 ]; then
                echo "│  💡 建议使用 /dev-workflow 开始工作流" >&2
            else
                STEP_NAMES=("历史学习检查" "需求理解" "上下文调研" "影响分析" "实施计划" "代码开发" "代码审核" "测试验证" "学习记录")
                STEP_NAME="${STEP_NAMES[$CURRENT_STEP]:-进行中}"
                echo "│  💡 请先完成步骤 $((CURRENT_STEP + 1)): ${STEP_NAME}" >&2
            fi
            echo "│" >&2
            echo "│  切换模式:" >&2
            echo "│  echo 'standard' > task/\$(cat task/.current-task)/.task-level" >&2
            echo "│  echo 'quick' > task/\$(cat task/.current-task)/.task-level" >&2
            echo "│" >&2
            echo "│  跳过工作流:" >&2
            echo "│  touch task/\$(cat task/.current-task)/.skip-workflow" >&2
            echo "└─────────────────────────────────────────────────────────┘" >&2
            echo "" >&2
            exit 2
            ;;
    esac
fi

exit 0
