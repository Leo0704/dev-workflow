#!/bin/bash
# 错误检测钩子
# 检测命令执行失败并提醒记录

if ! command -v jq &> /dev/null; then
    exit 0
fi

INPUT=$(cat)
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // ""' 2>/dev/null)

if [ -z "$OUTPUT" ]; then
    exit 0
fi

# 错误模式
ERROR_PATTERNS="error:|Error:|ERROR:|failed|FAILED|command not found|No such file|Permission denied|fatal:|Exception|Traceback|npm ERR!|ModuleNotFoundError|SyntaxError|TypeError|exit code|non-zero"

# 检查是否包含错误
contains_error=false
for pattern in $ERROR_PATTERNS; do
    if [[ "$OUTPUT" == *"$pattern"* ]]; then
        contains_error=true
        break
    fi
done

if [ "$contains_error" = true ]; then
    cat << EOF

---
**错误检测**

检测到命令错误。如符合以下条件，建议记录到 .learnings/ERRORS.md：
- 错误非预期或不明显
- 需要调查才能解决
- 可能在类似场景中再次发生
- 解决方案对未来会话有帮助

记录格式: [ERR-YYYYMMDD-XXX]
EOF
fi
