#!/bin/bash
# 代码审核脚本
# 在代码修改后触发审核提醒，自动检测项目类型并执行对应的检查
# 同时检查是否有未完成的任务，提示继续工作流

source "$(dirname "$0")/lib/common.sh"

has_jq || exit 0

INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

init_task_context
cd "$PROJECT_ROOT" 2>/dev/null || exit 0

# === 任务续接检查 ===
check_pending_tasks() {
    # 检查是否有当前任务
    if [ -n "$CURRENT_TASK_NAME" ] && [ -d "$CURRENT_TASK_DIR" ]; then
        local current_step=$(get_workflow_step "$CURRENT_TASK_DIR")
        if [ "$current_step" -gt 0 ]; then
            if [ "$current_step" -lt 7 ]; then
                echo ""
                echo "---"
                echo ""
                echo "## 📋 任务续接提醒"
                echo ""
                echo "**当前任务:** $CURRENT_TASK_NAME"
                echo "**当前步骤:** $current_step / 7"
                echo ""
                echo "工作流尚未完成，请使用 \`/dev-workflow\` 继续。"
                echo ""
                return 0
            else
                echo ""
                echo "---"
                echo ""
                echo "## ✅ 任务完成"
                echo ""
                echo "**当前任务:** $CURRENT_TASK_NAME"
                echo "**状态:** 工作流已完成（步骤 7/7）"
                echo ""
                echo "建议清理："
                echo '```bash'
                echo "rm task/$CURRENT_TASK_NAME/.workflow-step"
                echo '```'
                echo ""
                return 0
            fi
        fi
    fi

    # 检查是否有其他待处理任务
    if [ -d "$TASK_DIR" ]; then
        local pending_tasks=$(find "$TASK_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -5)
        if [ -n "$pending_tasks" ]; then
            echo ""
            echo "---"
            echo ""
            echo "## 📋 可用任务"
            echo ""
            echo "$pending_tasks" | while read -r task_dir; do
                [ -n "$task_dir" ] && echo "  - $(basename "$task_dir")"
            done
            echo ""
            echo "使用以下命令切换任务："
            echo '```bash'
            echo "echo \"任务名\" > task/.current-task"
            echo '```'
            echo ""
        fi
    fi
}

# 检查是否有未提交的修改
CHANGES=$(git status --porcelain 2>/dev/null)
[ -z "$CHANGES" ] && exit 0

CHANGE_COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')

# 检测项目类型
detect_project_type() {
    if [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "package.json" ]; then
        echo "node"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project_type)

# 根据项目类型执行检查
BUILD_STATUS="未检查"
LINT_STATUS="未检查"
BUILD_ERROR=""
LINT_ERROR=""

case "$PROJECT_TYPE" in
    go)
        HAS_GO_CHANGES=$(echo "$CHANGES" | grep '\.go$' | head -1)
        if [ -n "$HAS_GO_CHANGES" ]; then
            BUILD_OUTPUT=$(go build ./... 2>&1)
            [ $? -eq 0 ] && BUILD_STATUS="通过" || { BUILD_STATUS="失败"; BUILD_ERROR=$(echo "$BUILD_OUTPUT" | head -5); }

            VET_OUTPUT=$(go vet ./... 2>&1)
            [ $? -eq 0 ] && LINT_STATUS="通过" || { LINT_STATUS="失败"; LINT_ERROR=$(echo "$VET_OUTPUT" | head -5); }

            FMT_OUTPUT=$(gofmt -l . 2>&1)
            [ -z "$FMT_OUTPUT" ] && FMT_STATUS="通过" || { gofmt -w . 2>/dev/null; FMT_STATUS="已自动格式化"; }
        fi
        ;;
    node)
        HAS_JS_CHANGES=$(echo "$CHANGES" | grep -E '\.(js|ts|jsx|tsx|vue)$' | head -1)
        if [ -n "$HAS_JS_CHANGES" ]; then
            [ -f "pnpm-lock.yaml" ] && PKG_MANAGER="pnpm" || { [ -f "yarn.lock" ] && PKG_MANAGER="yarn" || PKG_MANAGER="npm"; }

            if [ -f "package.json" ] && grep -q '"build"' package.json; then
                BUILD_OUTPUT=$($PKG_MANAGER run build 2>&1)
                [ $? -eq 0 ] && BUILD_STATUS="通过" || { BUILD_STATUS="失败"; BUILD_ERROR=$(echo "$BUILD_OUTPUT" | head -5); }
            fi

            if [ -f "package.json" ] && grep -q '"lint"' package.json; then
                LINT_OUTPUT=$($PKG_MANAGER run lint 2>&1)
                [ $? -eq 0 ] && LINT_STATUS="通过" || { LINT_STATUS="失败"; LINT_ERROR=$(echo "$LINT_OUTPUT" | head -5); }
            fi
        fi
        ;;
    python)
        HAS_PY_CHANGES=$(echo "$CHANGES" | grep '\.py$' | head -1)
        if [ -n "$HAS_PY_CHANGES" ]; then
            if command -v python &> /dev/null; then
                BUILD_OUTPUT=$(python -m py_compile . 2>&1)
                [ $? -eq 0 ] && BUILD_STATUS="通过" || { BUILD_STATUS="失败"; BUILD_ERROR=$(echo "$BUILD_OUTPUT" | head -5); }
            fi
        fi
        ;;
esac

# 构建输出
cat << EOF
---

**老板，检测到 ${CHANGE_COUNT} 个文件被修改，请确认：**

- [ ] 边界检查: 只修改了允许修改的项目
- [ ] 代码风格: 符合项目规范
- [ ] 安全性: 无注入等风险
- [ ] 错误处理: 完善

**项目类型:** ${PROJECT_TYPE}
EOF

[ "$BUILD_STATUS" != "未检查" ] || [ "$LINT_STATUS" != "未检查" ] && {
    echo ""
    echo "**编译/检查结果:**"
    [ "$BUILD_STATUS" != "未检查" ] && echo "- build: $BUILD_STATUS"
    [ "$LINT_STATUS" != "未检查" ] && echo "- lint: $LINT_STATUS"
}

[ -n "$BUILD_ERROR" ] && {
    echo ""
    echo "**编译错误详情:**"
    echo '```'
    echo "$BUILD_ERROR"
    echo '```'
}

[ -n "$LINT_ERROR" ] && {
    echo ""
    echo "**检查错误详情:**"
    echo '```'
    echo "$LINT_ERROR"
    echo '```'
}

echo ""
echo "**需要详细审核请使用 /code-review 技能**"

# 检查待续接的任务
check_pending_tasks

exit 0
