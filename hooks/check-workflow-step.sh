#!/bin/bash
# 工作流步骤检查
# 有需求文档时，必须走完前4步才能写代码

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

init_task_context

# 没有当前任务 → 不强制
[ -z "$CURRENT_TASK_DIR" ] && exit 0

# 检查任务目录是否有需求文档
FILE_COUNT=$(count_files "$CURRENT_TASK_DIR" "-name .workflow-step -o -name .gitkeep")
[ "$FILE_COUNT" -eq 0 ] && exit 0

# 检查是否是代码文件
is_code_file "$FILE_PATH" || exit 0

# 排除：允许写入工作流状态文件本身
[[ "$FILE_PATH" == *".workflow-step"* ]] && exit 0

# 读取当前步骤
CURRENT_STEP=$(get_workflow_step "$CURRENT_TASK_DIR")

# 步骤 >= 5 才能写代码
if [ "$CURRENT_STEP" -lt 5 ]; then
    echo "⛔ 工作流拦截: 当前在步骤 ${CURRENT_STEP}，必须完成到步骤 5（代码开发）才能修改代码文件" >&2
    echo "" >&2
    if [ "$CURRENT_STEP" -eq 0 ]; then
        echo "还没开始工作流。请先使用 /dev-workflow 执行需求理解。" >&2
    else
        echo "请先完成步骤 $((CURRENT_STEP + 1)) 再继续。" >&2
    fi
    echo "如需跳过工作流，请先清空需求文档目录。" >&2
    exit 2
fi

exit 0
