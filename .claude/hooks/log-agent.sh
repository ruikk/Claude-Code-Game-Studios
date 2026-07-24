#!/bin/bash
# Claude Code SubagentStart 钩子: 记录代理(Agent)调用以生成审计追踪
# 跟踪哪些代理(Agent)正在被使用以及何时使用
#
# 输入格式 (SubagentStart) — per Claude Code hooks reference:
# { "session_id": "...", "agent_id": "agent-abc123", "agent_type": "Explore", ... }
#
# 智能体类型存放于 agent_type，并非 agent_name。每次调用时读取 .agent_name 都会返回空值，
# 因此程序会一直使用兜底值 “unknown”，审计追踪日志无法记录任何有效信息。

INPUT=$(cat)

# 解析代理(Agent)名称 -- 优先使用 jq，退回使用 grep
if command -v jq >/dev/null 2>&1; then
    AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_type // "unknown"' 2>/dev/null)
else
    AGENT_NAME=$(echo "$INPUT" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"agent_type"[[:space:]]*:[[:space:]]*"//;s/"$//')
    [ -z "$AGENT_NAME" ] && AGENT_NAME="unknown"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"

mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

echo "$TIMESTAMP | 代理(Agent)调用: $AGENT_NAME" >> "$SESSION_LOG_DIR/agent-audit.log" 2>/dev/null

exit 0
