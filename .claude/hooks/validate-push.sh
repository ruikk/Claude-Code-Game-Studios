#!/bin/bash
# Claude Code PreToolUse 钩子: 验证 git push 命令
# 在推送到受保护分支时发出警告
# 退出码 0 = 允许, 退出码 2 = 阻断
#
# 输入格式 (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git push origin main" } }

INPUT=$(cat)

# 解析命令 -- 优先使用 jq，退回使用 grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# 仅处理 git push 命令
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+push'; then
    exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
MATCHED_BRANCH=""

# 检查是否正在推送到受保护分支
for branch in develop main master; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        MATCHED_BRANCH="$branch"
        break
    fi
    # 同时检查是否明确推送到受保护分支 (安全引用分支名)
    if echo "$COMMAND" | grep -qE "[[:space:]]${branch}([[:space:]]|$)"; then
        MATCHED_BRANCH="$branch"
        break
    fi
done

if [ -n "$MATCHED_BRANCH" ]; then
    echo "检测到向受保护分支 '$MATCHED_BRANCH' 推送。" >&2
    echo "提醒: 确保构建通过，单元测试通过，且不存在 S1/S2 级 Bug。" >&2
    # 允许推送但发出警告 -- 取消下方注释以改为阻断模式:
    # echo "已阻断: 推送到 $CURRENT_BRANCH 前请先运行测试" >&2
    # exit 2
fi

exit 0
