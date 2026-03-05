#!/bin/bash
# 错误检测钩子
# 检测命令执行失败并自动记录到插件数据目录

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // ""' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

[ -z "$OUTPUT" ] && exit 0

# 错误模式
ERROR_PATTERNS="error:|Error:|ERROR:|failed|FAILED|command not found|No such file|Permission denied|fatal:|Exception|Traceback|npm ERR!|ModuleNotFoundError|SyntaxError|TypeError|exit code|non-zero"

# 检查是否包含错误
contains_error=false
matched_pattern=""
for pattern in $ERROR_PATTERNS; do
    if [[ "$OUTPUT" == *"$pattern"* ]]; then
        contains_error=true
        matched_pattern="$pattern"
        break
    fi
done

if [ "$contains_error" = true ]; then
    # 提取错误摘要（前3行非空内容）
    ERROR_SUMMARY=$(echo "$OUTPUT" | grep -v '^$' | head -3 | tr '\n' ' ' | cut -c1-200)

    # 记录到插件数据目录
    ERRORS_FILE="$(dirname "$0")/../data/errors.md"
    if [ -f "$ERRORS_FILE" ]; then
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
        cat >> "$ERRORS_FILE" << EOF

## [$TIMESTAMP]
**命令**: \`${TOOL_INPUT:0:100}\`
**错误**: ${matched_pattern}
**摘要**: ${ERROR_SUMMARY}
**状态**: 待解决

EOF
    fi

    cat << EOF

---
**错误已记录**

检测到错误并自动记录到插件学习库。
解决后请执行: /dev-workflow:learning-record
EOF
fi
