# Hook 输入/输出 Schema（模式）

本文档说明了每种 Claude Code hook 在各事件类型下通过 stdin 接收的 JSON 负载。

## PreToolUse

在工具执行前触发。可**允许**（exit 0）或**阻止**（exit 2）。

### PreToolUse: Bash

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git commit -m 'feat: add player health system'",
    "description": "Commit changes with message",
    "timeout": 120000
  }
}
```

### PreToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "content": "extends Node\n..."
  }
}
```

### PreToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "old_string": "var health = 100",
    "new_string": "var health: int = 100"
  }
}
```

### PreToolUse: Read

```json
{
  "tool_name": "Read",
  "tool_input": {
    "file_path": "src/gameplay/health.gd"
  }
}
```

## PostToolUse

在工具完成后触发。**不能阻止**（用于阻止的 exit code 会被忽略）。stderr 消息会以警告形式显示。

### PostToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "content": "{\"goblin\": {\"health\": 50}}"
  },
  "tool_output": "File written successfully"
}
```

### PostToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "old_string": "\"health\": 50",
    "new_string": "\"health\": 75"
  },
  "tool_output": "File edited successfully"
}
```

## SubagentStart

当通过 Task 工具启动子代理时触发。

```json
{
  "agent_name": "game-designer",
  "model": "sonnet",
  "description": "Design the combat healing mechanic"
}
```

## SessionStart

在 Claude Code 会话开始时触发。**无 stdin 输入**——hook 仅执行，其 stdout 会作为上下文展示给 Claude。

## PreCompact

在上下文窗口压缩前触发。**无 stdin 输入**——hook 会在压缩发生前运行以保存状态。

## Stop

在 Claude Code 会话结束时触发。**无 stdin 输入**——hook 会运行清理与日志记录逻辑。

## Exit Code 参考

| Exit Code | 含义 | 适用事件 |
|-----------|---------|-------------------|
| 0 | 允许 / 成功 | 所有事件 |
| 2 | 阻止（stderr 会显示给 Claude） | 仅 PreToolUse |
| Other | 视为错误，但工具继续执行 | 所有事件 |

## Notes（说明）

- Hooks 通过 **stdin**（pipe）接收 JSON。使用 `INPUT=$(cat)` 捕获输入。
- 如可用，使用 `jq` 解析；否则回退到 `grep` 以保证跨平台兼容性。
- 在 Windows 上，`grep -P`（Perl regex）通常不可用。请改用 `grep -E`（POSIX extended）。
- 在 Windows 上，路径分隔符可能是 `\`。比较路径时可用 `sed 's|\\|/|g'` 进行规范化。
