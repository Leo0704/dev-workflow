#!/bin/bash
# hooks/lib/common.sh - 共享函数库
# 所有 hooks 脚本共用的基础功能

# === 颜色定义 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === 日志函数 ===
log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# === 项目路径 ===
# 获取插件根目录（优先使用环境变量）
get_plugin_root() {
    if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
        echo "$CLAUDE_PLUGIN_ROOT"
    else
        # 从 lib 目录向上两级
        echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    fi
}

# 获取项目根目录（工作目录）
get_project_root() {
    echo "${PWD}"
}

# === 工具检查 ===
# 检查 jq 是否可用，不可用则返回错误
require_jq() {
    if ! command -v jq &>/dev/null; then
        log_error "jq is required but not installed"
        return 1
    fi
}

# 静默检查 jq（用于条件判断）
has_jq() {
    command -v jq &>/dev/null
}

# === 任务操作 ===
# 获取当前任务名
get_current_task_name() {
    local root="${1:-$(get_project_root)}"
    local task_file="$root/task/.current-task"
    if [ -f "$task_file" ]; then
        cat "$task_file" 2>/dev/null | tr -d ' \n'
    fi
}

# 获取当前任务目录（优先 requirements/，其次 task/）
get_current_task_dir() {
    local root="${1:-$(get_project_root)}"
    local name=$(get_current_task_name "$root")
    if [ -n "$name" ]; then
        if [ -d "$root/requirements/$name" ]; then
            echo "$root/requirements/$name"
            return
        fi
        if [ -d "$root/task/$name" ]; then
            echo "$root/task/$name"
            return
        fi
    fi
}

# === JSON 操作 ===
# 安全更新 JSON 文件
# 用法: json_update <file> <jq_expr> [jq_args...]
json_update() {
    local file="$1"
    local expr="$2"
    shift 2

    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi

    local tmp_file=$(mktemp)
    if jq "$@" "$expr" "$file" > "$tmp_file"; then
        mv "$tmp_file" "$file"
    else
        rm -f "$tmp_file"
        log_error "jq update failed"
        return 1
    fi
}

# === 文件计数 ===
# 计算目录中的文件数（排除特定文件）
count_files() {
    local dir="$1"
    local exclude_patterns="${2:--name ".workflow-step" -o -name ".gitkeep" -o -name "*.json" -o -name "README.md"}"

    if [ ! -d "$dir" ]; then
        echo 0
        return
    fi

    local files=$(find "$dir" -type f ! \( $exclude_patterns \) 2>/dev/null)
    if [ -n "$files" ]; then
        echo "$files" | grep -c .
    else
        echo 0
    fi
}

# === 时间戳 ===
# 获取 ISO 8601 时间戳
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# === 任务上下文初始化 ===
# 初始化任务相关变量（需在调用后使用）
# 设置: PROJECT_ROOT, TASK_DIR, CURRENT_TASK_FILE, CURRENT_TASK_NAME, CURRENT_TASK_DIR
init_task_context() {
    local root="${1:-$(get_project_root)}"
    PROJECT_ROOT="$root"
    TASK_DIR="$root/task"
    CURRENT_TASK_FILE="$TASK_DIR/.current-task"
    CURRENT_TASK_NAME=$(get_current_task_name "$root")
    CURRENT_TASK_DIR=$(get_current_task_dir "$root")
}

# === 工具输入读取 ===
# 从 stdin 读取工具输入并解析字段
# 用法: read_tool_input <field> [default]
# 示例: FILE_PATH=$(read_tool_input file_path)
read_tool_input() {
    local field="$1"
    local default="${2:-}"
    if has_jq; then
        cat | jq -r ".tool_input.$field // $default" 2>/dev/null
    else
        echo "$default"
    fi
}

# === 工作流步骤 ===
# 获取当前任务的工作流步骤（0-8）
get_workflow_step() {
    local task_dir="${1:-$(get_current_task_dir)}"
    if [ -z "$task_dir" ]; then
        echo "0"
        return
    fi

    local step_file="$task_dir/.workflow-step"
    if [ -f "$step_file" ]; then
        local step=$(cat "$step_file" 2>/dev/null | tr -d ' \n')
        if [[ "$step" =~ ^[0-9]+$ ]]; then
            echo "$step"
            return
        fi
    fi
    echo "0"
}

# 设置工作流步骤
set_workflow_step() {
    local task_dir="${1:-$(get_current_task_dir)}"
    local step="$2"
    if [ -n "$task_dir" ] && [ -n "$step" ]; then
        echo "$step" > "$task_dir/.workflow-step"
    fi
}

# === 路径边界检查 ===
# 获取允许修改的路径列表
get_allowed_paths() {
    local root="${1:-$(get_project_root)}"
    local config_file="$root/.claude/config.json"

    # 默认允许的路径
    echo "$root"
    echo "$HOME/.claude"

    # 从配置文件读取额外路径
    if [ -f "$config_file" ] && has_jq; then
        jq -r '.allowedPaths[]? // empty' "$config_file" 2>/dev/null | while read -r path; do
            if [ -n "$path" ]; then
                # 处理相对路径
                [[ "$path" != /* ]] && path="$root/$path"
                echo "$path"
            fi
        done
    fi
}

# 检查路径是否在允许范围内
is_path_allowed() {
    local path="$1"
    local root="${2:-$(get_project_root)}"

    # 规范化路径
    if [ -e "$path" ]; then
        path="$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")"
    fi

    local allowed
    while IFS= read -r allowed; do
        [ -z "$allowed" ] && continue
        if [[ "$path" == "$allowed"* ]]; then
            return 0
        fi
    done < <(get_allowed_paths "$root")

    return 1
}

# 获取禁止的文件模式
get_forbidden_patterns() {
    local root="${1:-$(get_project_root)}"
    local config_file="$root/.claude/config.json"

    # 默认禁止模式
    echo ".env"
    echo ".env.local"
    echo ".env.*"
    echo "*.pem"
    echo "*.key"
    echo "*.p12"
    echo "credentials.json"
    echo "secrets.yaml"
    echo "secrets.json"

    # 从配置文件读取额外模式
    if [ -f "$config_file" ] && has_jq; then
        jq -r '.forbiddenPatterns[]? // empty' "$config_file" 2>/dev/null
    fi
}

# 检查是否是敏感文件
is_sensitive_file() {
    local path="$1"
    local basename=$(basename "$path")
    local root="${2:-$(get_project_root)}"

    local pattern
    while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        case "$basename" in
            $pattern) return 0 ;;
        esac
    done < <(get_forbidden_patterns "$root")

    return 1
}

# === 代码文件检测 ===
# 检查是否是代码文件
is_code_file() {
    local path="$1"
    local basename=$(basename "$path")

    case "$basename" in
        *.go|*.vue|*.ts|*.js|*.jsx|*.tsx|*.py|*.java|*.rs|*.c|*.cpp|*.h|*.php|*.rb|*.swift|*.kt)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# === 初始化导出 ===
# 导出所有公共函数
export -f log_info log_success log_warn log_error
export -f get_project_root require_jq has_jq
export -f get_current_task_name get_current_task_dir
export -f json_update count_files get_timestamp
export -f init_task_context read_tool_input
export -f get_workflow_step set_workflow_step
export -f get_allowed_paths is_path_allowed
export -f get_forbidden_patterns is_sensitive_file
export -f is_code_file
