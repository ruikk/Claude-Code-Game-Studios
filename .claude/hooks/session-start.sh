#!/bin/bash
# Claude Code SessionStart 钩子: 在会话开始时加载项目上下文
# 输出 Claude 在会话开始时看到的上下文信息
#
# 输入格式 (SessionStart): No stdin input

echo "=== Claude Code Game Studios — 会话上下文 ==="

# 当前分支
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
    echo "分支: $BRANCH"
    echo ""
    echo "最近的提交:"
    git log --oneline -5 2>/dev/null | while read -r line; do
        echo "  $line"
    done
fi

# Current sprint (find most recent sprint file)
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SPRINT" ]; then
    echo ""
    echo "活跃迭代: $(basename "$LATEST_SPRINT" .md)"
fi

# Current milestone
LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MILESTONE" ]; then
    echo "活跃里程碑: $(basename "$LATEST_MILESTONE" .md)"
fi

# Open bug count
BUG_COUNT=0
for dir in tests/playtest production; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "BUG-*.md" 2>/dev/null | wc -l)
        BUG_COUNT=$((BUG_COUNT + count))
    fi
done
if [ "$BUG_COUNT" -gt 0 ]; then
    echo "未解决的 Bug: $BUG_COUNT"
fi

# Code health quick check
if [ -d "src" ]; then
    TODO_COUNT=$(grep -r "TODO" src/ 2>/dev/null | wc -l)
    FIXME_COUNT=$(grep -r "FIXME" src/ 2>/dev/null | wc -l)
    if [ "$TODO_COUNT" -gt 0 ] || [ "$FIXME_COUNT" -gt 0 ]; then
        echo ""
        echo "代码健康: ${TODO_COUNT} 个 TODO, ${FIXME_COUNT} 个 FIXME 在 src/ 中"
    fi
fi

# --- Active session state recovery ---
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "=== 检测到活跃会话状态 ==="
    echo "上一次会话留下了状态文件: $STATE_FILE"
    echo "请读取此文件以恢复上下文并从中断处继续。"
    echo ""
    echo "快速摘要: (last 20 lines):"
    tail -20 "$STATE_FILE" 2>/dev/null
    TOTAL_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null)
    if [ "$TOTAL_LINES" -gt 20 ]; then
        echo "  ... (共 $TOTAL_LINES 行 — 请读取完整文件以继续)"
    fi
    echo "=== 会话状态预览结束 ==="
fi

echo "==================================="
exit 0
