#!/bin/bash
# Claude Code PreCompact 钩子: 在上下文压缩之前转储会话状态
# 该输出会在上下文压缩前展示在对话中，确保关键状态信息能够在摘要整理过程中得以保留。

echo "=== 压缩前的会话状态 ==="
echo "时间戳: $(date)"

# --- Active session state file ---
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "## 活跃会话状态 (来自 $STATE_FILE)"
    STATE_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
    if [ "$STATE_LINES" -gt 100 ] 2>/dev/null; then
        head -n 100 "$STATE_FILE"
        echo "... (已截断 — 共 $STATE_LINES 行，显示前 100 行)"
    else
        cat "$STATE_FILE"
    fi
else
    echo ""
    echo "## 未找到活跃会话状态文件"
    echo "建议维护 production/session-state/active.md 以便更好地恢复。"
fi

# --- Files modified this session (unstaged + staged + untracked) ---
echo ""
echo "## 已修改的文件 (git 工作树)"

CHANGED=$(git diff --name-only 2>/dev/null)
STAGED=$(git diff --staged --name-only 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

if [ -n "$CHANGED" ]; then
    echo "未暂存的变更:"
    echo "$CHANGED" | while read -r f; do echo "  - $f"; done
fi
if [ -n "$STAGED" ]; then
    echo "已暂存的变更:"
    echo "$STAGED" | while read -r f; do echo "  - $f"; done
fi
if [ -n "$UNTRACKED" ]; then
    echo "新未跟踪的文件:"
    echo "$UNTRACKED" | while read -r f; do echo "  - $f"; done
fi
if [ -z "$CHANGED" ] && [ -z "$STAGED" ] && [ -z "$UNTRACKED" ]; then
    echo "  (没有未提交的变更)"
fi

# --- Work-in-progress design docs ---
echo ""
echo "## 设计文档 — 进行中的工作"

WIP_FOUND=false
for f in design/gdd/*.md; do
    [ -f "$f" ] || continue
    INCOMPLETE=$(grep -n -E "TODO|WIP|PLACEHOLDER|\[TO BE|\[TBD\]" "$f" 2>/dev/null)
    if [ -n "$INCOMPLETE" ]; then
        WIP_FOUND=true
        echo "  $f:"
        echo "$INCOMPLETE" | while read -r line; do echo "    $line"; done
    fi
done

if [ "$WIP_FOUND" = false ]; then
    echo "  (在设计文档中未发现进行中标记)"
fi

# --- Log compaction event ---
SESSION_LOG_DIR="production/session-logs"
mkdir -p "$SESSION_LOG_DIR" 2>/dev/null
echo "上下文压缩发生于 $(date)。" \
    >> "$SESSION_LOG_DIR/compaction-log.txt" 2>/dev/null

echo ""
echo "## 恢复说明"
echo "压缩后，请读取 $STATE_FILE 以恢复完整的工作上下文。"
echo "然后读取上面列出的正在积极处理的文件。"
echo "=== 会话状态结束 ==="

exit 0
