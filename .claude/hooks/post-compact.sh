#!/usr/bin/env bash
# post-compact.sh — fires after conversation compaction
# 提示 Claude 从基于文件的检查点恢复会话状态。

ACTIVE="production/session-state/active.md"

echo "=== 压缩完成，上下文已恢复 ==="

if [ -f "$ACTIVE" ]; then
  SIZE=$(wc -l < "$ACTIVE" 2>/dev/null || echo "?")
  echo "会话状态文件已存在: $ACTIVE ($SIZE 行)"
  echo "重要：立即读取该文件以恢复工作上下文。"
  echo "文件包含：当前任务、已作出的决策、正在编辑的文件、待解决问题。"
else
  echo "未在 $ACTIVE 路径找到会话状态文件"
  echo "如果正在执行任务，请检查 production/session-logs/ 目录查看上一次会话审计记录。"
fi

echo "========================================="
