#!/bin/bash
# 检查文件修改边界
# 读取项目配置，只允许修改配置中指定的目录

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

init_task_context

# 规范化路径
if [ -e "$FILE_PATH" ]; then
    NORMALIZED_PATH="$(cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd)/$(basename "$FILE_PATH")"
else
    dir=$(dirname "$FILE_PATH")
    base=$(basename "$FILE_PATH")
    if [ -d "$dir" ]; then
        NORMALIZED_PATH="$(cd "$dir" 2>/dev/null && pwd)/$base"
    else
        NORMALIZED_PATH="$FILE_PATH"
    fi
fi

# 使用公共函数检查
if is_path_allowed "$NORMALIZED_PATH" "$PROJECT_ROOT"; then
    if is_sensitive_file "$NORMALIZED_PATH" "$PROJECT_ROOT"; then
        echo "禁止修改敏感文件: $FILE_PATH" >&2
        echo "敏感配置文件（.env, *.pem, *.key 等）禁止修改。" >&2
        exit 2
    fi
    exit 0
else
    echo "禁止修改: $FILE_PATH" >&2
    echo "该文件不在允许修改的范围内。" >&2
    echo "如需修改此文件，请在 .claude/config.json 中配置 allowedPaths。" >&2
    exit 2
fi
