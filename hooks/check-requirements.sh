#!/bin/bash
# 检查当前任务目录，显示需求文档列表

source "$(dirname "$0")/lib/common.sh"

init_task_context

if [ -n "$CURRENT_TASK_DIR" ] && [ -d "$CURRENT_TASK_DIR" ]; then
    FILE_COUNT=$(count_files "$CURRENT_TASK_DIR")
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "当前任务: $CURRENT_TASK_NAME"
        echo "需求文档 ($FILE_COUNT 个):"
        find "$CURRENT_TASK_DIR" -type f ! \( -name ".workflow-step" -o -name ".gitkeep" -o -name "*.json" -o -name "README.md" \) 2>/dev/null | while read -r f; do
            [ -n "$f" ] && echo "  - $(basename "$f")"
        done
        echo ""
        echo "老板，模糊点必须确认后再继续！"
    fi
fi
