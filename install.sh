#!/bin/bash
# Dev-Workflow 安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/Leo0704/dev-workflow/main/install.sh | bash

set -e

PLUGIN_NAME="dev-workflow"
REPO_URL="https://github.com/Leo0704/dev-workflow.git"
TEMP_DIR="/tmp/${PLUGIN_NAME}-install"
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

# 克隆仓库
echo "==> Downloading ${PLUGIN_NAME}..."
rm -rf "$TEMP_DIR"
git clone --depth 1 "$REPO_URL" "$TEMP_DIR"

# 安装插件
echo "==> Installing plugin..."
cp -r "$TEMP_DIR/.claude-plugin" "$PLUGIN_DIR"

# 清理
rm -rf "$TEMP_DIR"

echo ""
echo "==> Installation complete!"
echo ""
echo "Available skills:"
echo "  /dev-workflow          - 9步开发工作流"
echo "  /requirement-analysis  - 需求分析"
echo "  /context-research      - 上下文调研"
echo "  /impact-analysis       - 影响分析"
echo "  /implementation-plan   - 实施计划"
echo "  /code-development      - 代码开发"
echo "  /code-review           - 代码审核"
echo "  /testing               - 测试验证"
echo "  /learning-record       - 学习记录"
echo ""
echo "Start with: /dev-workflow"
