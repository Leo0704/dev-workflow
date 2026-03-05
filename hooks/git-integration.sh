#!/bin/bash
# Git 工作流集成钩子
# 自动管理 Git 分支和提交

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.event // ""' 2>/dev/null)
STEP=$(echo "$INPUT" | jq -r '.step // 0' 2>/dev/null)

init_task_context

# 检查是否在 Git 仓库中
is_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

# 获取当前分支
get_current_branch() {
    git branch --show-current 2>/dev/null
}

# 检查是否有未提交的更改
has_changes() {
    ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null
}

# 获取修改的文件列表
get_changed_files() {
    git diff --name-only 2>/dev/null
    git diff --cached --name-only 2>/dev/null
}

# 检查是否在 main/master 分支
is_main_branch() {
    local branch=$(get_current_branch)
    [[ "$branch" == "main" || "$branch" == "master" ]]
}

# 生成分支名
generate_branch_name() {
    local task_name="$1"
    local task_type="$2"
    local safe_name=$(echo "$task_name" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    echo "${task_type}/${safe_name}"
}

is_git_repo || exit 0

# 步骤 4 确认后：创建 feature 分支
if [ "$EVENT" == "step4_confirmed" ] && [ -n "$CURRENT_TASK_NAME" ]; then
    if is_main_branch; then
        BRANCH_NAME=$(generate_branch_name "$CURRENT_TASK_NAME" "feature")

        cat << EOF

---
**Git 分支建议** 🌿

当前在主分支，建议创建功能分支：

\`\`\`bash
git checkout -b $BRANCH_NAME
\`\`\`

分支命名规范：feature/{任务名}
EOF
    fi
fi

# 步骤 8 完成后：提示提交
if [ "$EVENT" == "step8_complete" ] && [ -n "$CURRENT_TASK_NAME" ]; then
    if has_changes; then
        CHANGED_FILES=$(get_changed_files | head -10)
        CHANGED_COUNT=$(get_changed_files | wc -l | tr -d ' ')

        cat << EOF

---
**Git 提交建议** 📝

检测到 $CHANGED_COUNT 个文件已修改：

\`\`\`
$CHANGED_FILES
\`\`\`

建议提交命令：

\`\`\`bash
git add .
git commit -m "feat: $CURRENT_TASK_NAME

- 实现详情见 task/$CURRENT_TASK_NAME/plan-report.md
- 测试报告见 task/$CURRENT_TASK_NAME/test-report.md"
\`\`\`

或使用 /commit 技能自动生成提交信息。
EOF
    fi
fi

exit 0
