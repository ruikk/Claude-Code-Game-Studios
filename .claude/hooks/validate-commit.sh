#!/bin/bash
# Claude Code PreToolUse 钩子: 验证 git commit 命令
# 从标准输入接收 JSON，包含 tool_input.command
# 退出码 0 = 允许, 退出码 2 = 阻断 (stderr 显示给 Claude)
#
# 输入格式 (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git commit -m ..." } }

INPUT=$(cat)

# 解析命令 -- 优先使用 jq，退回使用 grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# 仅处理 git commit 命令
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+commit'; then
    exit 0
fi

# 获取已暂存的文件
STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
    exit 0
fi

WARNINGS=""

# 检查设计文档是否包含必需的章节
DESIGN_FILES=$(echo "$STAGED" | grep -E '^design/gdd/')
if [ -n "$DESIGN_FILES" ]; then
    while IFS= read -r file; do
        if [[ "$file" == *.md ]] && [ -f "$file" ]; then
            for section in "Overview" "Player Fantasy" "Detailed" "Formulas" "Edge Cases" "Dependencies" "Tuning Knobs" "Acceptance Criteria"; do
                if ! grep -qi "$section" "$file"; then
                    WARNINGS="$WARNINGS\n设计: $file 缺少必需的章节: $section"
                fi
            done
        fi
    done <<< "$DESIGN_FILES"
fi

# 验证 JSON 数据文件 -- 阻断无效 JSON
DATA_FILES=$(echo "$STAGED" | grep -E '^assets/data/.*\.json$')
if [ -n "$DATA_FILES" ]; then
    # 查找可用的 Python 命令
    PYTHON_CMD=""
    for cmd in python python3 py; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    done

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if [ -n "$PYTHON_CMD" ]; then
                if ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                    echo "已阻断: $file 不是有效的 JSON" >&2
                    exit 2
                fi
            else
                echo "警告: 无法验证 JSON (未找到 python): $file" >&2
            fi
        fi
    done <<< "$DATA_FILES"
fi

# 检查游戏代码中是否存在硬编码的游戏数值
# 使用 grep -E (POSIX 扩展) 而非 grep -P (Perl) 以保证跨平台兼容性
CODE_FILES=$(echo "$STAGED" | grep -E '^src/gameplay/')
if [ -n "$CODE_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '(damage|health|speed|rate|chance|cost|duration)[[:space:]]*[:=][[:space:]]*[0-9]+' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\n代码: $file 可能包含硬编码的游戏数值。请使用数据文件。"
            fi
        fi
    done <<< "$CODE_FILES"
fi

# 检查没有负责人的 TODO/FIXME -- 使用 grep -E 而非 grep -P
SRC_FILES=$(echo "$STAGED" | grep -E '^src/')
if [ -n "$SRC_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '(TODO|FIXME|HACK)[^(]' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\n规范: $file 中的 TODO/FIXME 没有负责人标签。请使用 TODO(name) 格式。"
            fi
        fi
    done <<< "$SRC_FILES"
fi

# 输出警告 (非阻断) 并允许提交
if [ -n "$WARNINGS" ]; then
    echo -e "=== 提交验证警告 ===$WARNINGS\n================================" >&2
fi

exit 0
