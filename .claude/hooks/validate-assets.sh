#!/bin/bash
# Claude Code PostToolUse 钩子: Write/Edit 后验证资产文件
# 检查 assets/ 目录中文件的命名规范
#
# 退出行为：
#   exit 0 = 成功或仅有建议性警告（非阻塞）
#   exit 1 = 阻塞性错误（会中断构建的问题：无效的 JSON、缺少必填字段）
#
# 输入格式（用于 Write/Edit 的 PostToolUse）:
# { "tool_name": "Write", "tool_input": { "file_path": "assets/data/foo.json", "content": "..." } }

INPUT=$(cat)

# Parse file path -- use jq if available, fall back to grep
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Normalize path separators (Windows backslash to forward slash)
FILE_PATH=$(echo "$FILE_PATH" | sed 's|\\|/|g')

# Only check files in assets/
if ! echo "$FILE_PATH" | grep -qE '(^|/)assets/'; then
    exit 0
fi

FILENAME=$(basename "$FILE_PATH")
WARNINGS=""   # Style/convention issues -- exit 0 with advisory message
ERRORS=""     # Build-breaking issues -- exit 1 to block the operation

# ADVISORY: Check naming convention (lowercase with underscores only)
# Naming issues are style violations -- warn but do not block
# Uses grep -E (POSIX) not grep -P (Perl) for Windows Git Bash compatibility
if echo "$FILENAME" | grep -qE '[A-Z[:space:]-]'; then
    WARNINGS="$WARNINGS\n  命名: $FILE_PATH 必须为小写加下划线 (当前: $FILENAME)"
fi

# BLOCKING: Check JSON validity for data files
# Invalid JSON will break runtime loading -- this is a build-breaking error
if echo "$FILE_PATH" | grep -qE '(^|/)assets/data/.*\.json$'; then
    if [ -f "$FILE_PATH" ]; then
        # Find a working Python command
        PYTHON_CMD=""
        for cmd in python python3 py; do
            if command -v "$cmd" >/dev/null 2>&1; then
                PYTHON_CMD="$cmd"
                break
            fi
        done

        if [ -n "$PYTHON_CMD" ]; then
            if ! "$PYTHON_CMD" -m json.tool "$FILE_PATH" > /dev/null 2>&1; then
                ERRORS="$ERRORS\n  格式: $FILE_PATH 不是有效的 JSON — 继续执行前先修复语法错误。"
            fi
        fi
    fi
fi

# Report warnings (advisory -- non-blocking)
if [ -n "$WARNINGS" ]; then
    echo -e "=== 资产验证: 警告 ===$WARNINGS\n==================================\n(警告仅作提示，请在最终提交前完成修复。)" >&2
fi

# Report errors and block if any build-breaking issues found
if [ -n "$ERRORS" ]; then
    echo -e "=== 资产验证: 错误 (阻塞) ===$ERRORS\n===========================================\n出现错误必须修复后方可继续执行。" >&2
    exit 1
fi

exit 0
