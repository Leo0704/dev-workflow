#!/bin/bash
# Dev-Workflow 安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/Leo0704/dev-workflow/main/install.sh | bash

set -e

PLUGIN_NAME="dev-workflow"
REPO_URL="https://github.com/Leo0704/dev-workflow.git"
PLUGIN_DIR="$HOME/.claude/plugins/${PLUGIN_NAME}"

echo "==> Installing ${PLUGIN_NAME}..."

# 检查依赖
command -v git >/dev/null 2>&1 || { echo "Error: git is required"; exit 1; }

# 创建插件目录
mkdir -p "$HOME/.claude/plugins"

# 如果已存在，先备份
if [ -d "$PLUGIN_DIR" ]; then
    echo "==> Backing up existing installation..."
    mv "$PLUGIN_DIR" "${PLUGIN_DIR}.backup.$(date +%s)"
fi

# 直接克隆到插件目录
echo "==> Downloading ${PLUGIN_NAME}..."
git clone --depth 1 "$REPO_URL" "$PLUGIN_DIR"

# 创建学习数据目录
mkdir -p "$PLUGIN_DIR/data"

# 初始化学习文件（如果不存在）
[ ! -f "$PLUGIN_DIR/data/learnings.md" ] && cat > "$PLUGIN_DIR/data/learnings.md" << 'EOF'
# 插件学习记录

> 此文件存储用户使用插件积累的经验，自动维护。

## 最佳实践

## 常见问题

EOF

[ ! -f "$PLUGIN_DIR/data/errors.md" ] && cat > "$PLUGIN_DIR/data/errors.md" << 'EOF'
# 错误记录

> 此文件存储遇到的错误和解决方案，自动维护。

EOF

echo ""
echo "==> Installation complete!"
echo ""
echo "Available skills:"
echo "  /dev-workflow:dev-workflow          - 9步开发工作流"
echo "  /dev-workflow:requirement-analysis  - 需求分析"
echo "  /dev-workflow:context-research      - 上下文调研"
echo "  /dev-workflow:impact-analysis       - 影响分析"
echo "  /dev-workflow:implementation-plan   - 实施计划"
echo "  /dev-workflow:code-development      - 代码开发"
echo "  /dev-workflow:code-review           - 代码审核"
echo "  /dev-workflow:testing               - 测试验证"
echo "  /dev-workflow:learning-record       - 确认学习点"
echo ""
echo "新特性 (v2.1):"
echo "  - 任务分级: Quick/Standard/Full 自动适配流程"
echo "  - 自动步骤流转: 无需手动更新 .workflow-step"
echo "  - 智能学习提取: 会话结束自动生成学习草稿"
echo "  - Git 集成: 分支建议 + 提交提醒"
echo ""
echo "Start with: /dev-workflow:dev-workflow"
