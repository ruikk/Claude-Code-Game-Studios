# settings.local.json 模板（Template）

创建 `.claude/settings.local.json`，用于个人覆盖配置（personal overrides），这些配置**不应**提交到版本控制。请将其添加到 `.gitignore`。

## settings.local.json 示例（Example settings.local.json）

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

## 权限模式（Permission Modes）

Claude Code 支持不同的权限模式。针对游戏开发（game dev）的推荐如下：

### 开发期间（默认）（During Development (Default)）
使用**normal mode**——Claude 在运行大多数命令前会先询问。对于生产代码（production code）这是最安全的方式。

### 原型制作期间（During Prototyping）
使用**auto-accept mode**并限制作用范围——可在一次性原型（throwaway prototype）代码上实现更快迭代。仅在 `prototypes/` 目录中工作时使用此模式。

### 代码评审期间（During Code Review）
使用**只读（read-only）**权限——Claude 可以读取和搜索，但不能修改文件。

## 本地自定义 Hooks（Customizing Hooks Locally）

你可以在 `settings.local.json` 中添加个人 hooks，以扩展（而非覆盖）项目 hooks。比如，在构建完成时添加通知：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo Session ended at $(date)'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```
