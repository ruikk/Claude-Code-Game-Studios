#!/bin/bash
# Claude Code Stop 钩子: Claude 完成时记录会话摘要
# 记录本次工作内容用于审计追踪和迭代跟踪

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"

mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

# Log recent git activity from this session (check up to 8 hours for long sessions)
RECENT_COMMITS=$(git log --oneline --since="8 hours ago" 2>/dev/null)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null)

# --- 会话关闭时归档当前会话状态（请勿删除） ---
# active.md 在正常退出后会保留，以支持多会话恢复功能。
# 仅允许手动删除 active.md，或存在明确替代文件时方可移除。
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    {
        echo "## 已归档的会话状态: $TIMESTAMP"
        cat "$STATE_FILE"
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
fi

if [ -n "$RECENT_COMMITS" ] || [ -n "$MODIFIED_FILES" ]; then
    {
        echo "## 会话结束: $TIMESTAMP"
        if [ -n "$RECENT_COMMITS" ]; then
            echo "### 提交"
            echo "$RECENT_COMMITS"
        fi
        if [ -n "$MODIFIED_FILES" ]; then
            echo "### 未提交的变更"
            echo "$MODIFIED_FILES"
        fi
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
fi

exit 0
