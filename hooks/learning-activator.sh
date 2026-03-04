#!/bin/bash
# 学习提醒钩子
# 在任务完成后提醒记录学习

source "$(dirname "$0")/lib/common.sh"

init_task_context

LEARNINGS_DIR="$PROJECT_ROOT/learnings"

# 检查学习日志目录是否存在
[ ! -d "$LEARNINGS_DIR" ] && exit 0

# 统计待处理的学习条目
PENDING_COUNT=$(grep -h "Status\*\*: pending" "$LEARNINGS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$PENDING_COUNT" -gt 0 ] 2>/dev/null; then
    cat << EOF

---
**学习日志提醒**

待处理条目: ${PENDING_COUNT} 个

完成任务后，考虑是否需要记录学习：
- 发现非显而易见的解决方案？
- 遇到意外行为需要绕过？
- 学到项目特定模式？
- 错误需要调试才能解决？

如需记录，请编辑 learnings/ 下的对应文件。
EOF
fi
