#!/bin/bash
# 学习激活钩子（增强版）
# 在会话结束时：检查待处理错误 + 智能提取学习点

source "$(dirname "$0")/lib/common.sh"

DATA_DIR="$(dirname "$0")/../data"
ERRORS_FILE="$DATA_DIR/errors.md"
LEARNINGS_FILE="$DATA_DIR/learnings.md"

# 检查数据目录是否存在
[ ! -d "$DATA_DIR" ] && exit 0

init_task_context

# === 1. 统计待解决的错误 ===
PENDING_ERRORS=0
if [ -f "$ERRORS_FILE" ]; then
    PENDING_ERRORS=$(grep -c "状态.*:.*待解决" "$ERRORS_FILE" 2>/dev/null || echo "0")
fi

# === 2. 分析本次会话，提取学习点 ===
analyze_session() {
    local learnings=""

    if [ -z "$CURRENT_TASK_DIR" ] || [ ! -d "$CURRENT_TASK_DIR" ]; then
        return
    fi

    # 检查生成的报告文件
    local reports=("requirement-report.md" "context-report.md" "impact-report.md" "plan-report.md" "review-report.md" "test-report.md")
    local report_count=0
    for report in "${reports[@]}"; do
        [ -f "$CURRENT_TASK_DIR/$report" ] && report_count=$((report_count + 1))
    done

    # 检查工作流完成度
    local current_step=$(get_workflow_step "$CURRENT_TASK_DIR")

    # 根据完成的步骤提取学习点
    if [ "$report_count" -ge 3 ]; then
        learnings="${learnings}完成了完整的分析流程（$report_count 份报告）\n"
    fi

    if [ "$current_step" -ge 6 ]; then
        learnings="${learnings}代码开发完成，已进入验证阶段\n"
    fi

    if [ -f "$CURRENT_TASK_DIR/review-report.md" ]; then
        # 检查是否有严重问题被修复
        if grep -q "🔴\|Critical\|严重" "$CURRENT_TASK_DIR/review-report.md" 2>/dev/null; then
            learnings="${learnings}代码审核发现并修复了严重问题\n"
        fi
    fi

    if [ -f "$CURRENT_TASK_DIR/test-report.md" ]; then
        # 检查测试结果
        if grep -q "通过\|passed\|✓" "$CURRENT_TASK_DIR/test-report.md" 2>/dev/null; then
            learnings="${learnings}测试验证通过\n"
        fi
    fi

    echo -e "$learnings"
}

# === 3. 生成学习点草稿 ===
generate_learning_draft() {
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    local task_name="${CURRENT_TASK_NAME:-未知任务}"
    local session_summary=$(analyze_session)

    if [ -n "$session_summary" ] && [ -f "$LEARNINGS_FILE" ]; then
        # 追加到学习文件末尾（待确认区）
        cat >> "$LEARNINGS_FILE" << EOF

---
## [$timestamp] 待确认学习点

**任务**: $task_name

**会话摘要**:
$session_summary

**状态**: 待确认

> 请执行 /dev-workflow:learning-record 确认或编辑此学习点
EOF
    fi
}

# === 4. 输出提醒 ===
output=""

# 错误提醒
if [ "$PENDING_ERRORS" -gt 0 ] 2>/dev/null; then
    output="${output}
---
**学习提醒** 📚

待解决的错误: ${PENDING_ERRORS} 个"
fi

# 学习点提取提醒
if [ -n "$CURRENT_TASK_DIR" ] && [ -d "$CURRENT_TASK_DIR" ]; then
    current_step=$(get_workflow_step "$CURRENT_TASK_DIR")
    if [ "$current_step" -ge 5 ]; then
        # 自动生成学习草稿
        generate_learning_draft

        output="${output}

已完成学习点草稿生成，建议执行:
/dev-workflow:learning-record

这将帮助你：
- 确认和编辑本次会话的学习点
- 更新错误的解决方案
- 精简学习数据"
    fi
fi

# Git 提交提醒
if [ -n "$CURRENT_TASK_DIR" ] && [ "$current_step" -ge 8 ]; then
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            output="${output}

**Git 提交提醒** 📝

有未提交的更改，建议：
/commit - 自动生成提交信息
/commit-push-pr - 提交并创建 PR"
        fi
    fi
fi

[ -n "$output" ] && echo "$output"

exit 0
