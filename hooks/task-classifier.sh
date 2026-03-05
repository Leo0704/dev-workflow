#!/bin/bash
# 任务分级钩子
# 分析任务复杂度，自动设置任务级别

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

[ -z "$USER_PROMPT" ] && exit 0

init_task_context

# 没有当前任务时不分级
[ -z "$CURRENT_TASK_DIR" ] && exit 0

# 已有分级文件则跳过
[ -f "$CURRENT_TASK_DIR/.task-level" ] && exit 0

# 任务分级关键词
QUICK_FIX_KEYWORDS="typo|错别字|注释|文档|readme|license|格式化|format|lint fix|小修改|微调|改个|修改一下"
STANDARD_KEYWORDS="修复|fix|bug|单个|简单|添加字段|修改配置|调整|优化|重构单个"
COMPLEX_KEYWORDS="新功能|feature|模块|系统|架构|集成|迁移|重构|完整|开发|实现"

# 判断任务级别
classify_task() {
    local prompt="$1"
    local prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

    # Quick Fix: 极小改动
    if [[ "$prompt_lower" =~ $QUICK_FIX_KEYWORDS ]]; then
        echo "quick"
        return
    fi

    # Complex: 新功能/大改动
    if [[ "$prompt_lower" =~ $COMPLEX_KEYWORDS ]]; then
        echo "full"
        return
    fi

    # Standard: 中等改动
    if [[ "$prompt_lower" =~ $STANDARD_KEYWORDS ]]; then
        echo "standard"
        return
    fi

    # 默认完整流程
    echo "full"
}

# 设置任务级别
TASK_LEVEL=$(classify_task "$USER_PROMPT")
echo "$TASK_LEVEL" > "$CURRENT_TASK_DIR/.task-level"

# 根据级别设置跳过的步骤
case "$TASK_LEVEL" in
    "quick")
        # Quick Fix: 跳过所有分析步骤，直接到步骤5
        echo "5" > "$CURRENT_TASK_DIR/.workflow-step"
        touch "$CURRENT_TASK_DIR/.skip-analysis"
        cat << EOF

---
**任务级别检测: Quick Fix** 🚀

检测到快速修复任务，已自动：
- 跳过步骤 0-4（历史学习、需求分析、上下文调研、影响分析、实施计划）
- 直接进入步骤 5（代码开发）

如需完整流程，删除 task/.task-level 后重新开始。
EOF
        ;;
    "standard")
        # Standard: 跳过上下文调研和影响分析
        touch "$CURRENT_TASK_DIR/.skip-context"
        touch "$CURRENT_TASK_DIR/.skip-impact"
        cat << EOF

---
**任务级别检测: Standard** ⚡

检测到标准任务，已自动：
- 保留步骤 1（需求分析）
- 跳过步骤 2-3（上下文调研、影响分析）
- 需要步骤 4（实施计划确认）

如需完整流程，删除 task/.task-level 后重新开始。
EOF
        ;;
    "full")
        # Full: 完整流程，不跳过任何步骤
        cat << EOF

---
**任务级别检测: Full** 📋

将执行完整 9 步开发流程。

如需快速模式，可执行：
\`\`\`bash
echo "quick" > task/\$(cat task/.current-task)/.task-level
echo "5" > task/\$(cat task/.current-task)/.workflow-step
\`\`\`
EOF
        ;;
esac

exit 0
