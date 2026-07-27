# 活动 Hooks（Active Hooks）

Hooks 在 `.claude/settings.json` 中配置，并会自动触发：

| Hook | Event | Trigger | Action |
| ---- | ----- | ------- | ------ |
| `validate-commit.sh` | PreToolUse (Bash) | `git commit` commands | 校验设计文档章节、JSON 数据文件、硬编码数值、TODO 格式 |
| `validate-push.sh` | PreToolUse (Bash) | `git push` commands | 在推送到受保护分支（develop/main）时发出警告 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | Asset file changes | 检查 `assets/` 中文件的命名规范与 JSON 有效性 |
| `session-start.sh` | SessionStart | Session begins | 加载 sprint 上下文、里程碑、git 活动；检测并预览活动会话状态文件以便恢复 |
| `detect-gaps.sh` | SessionStart | Session begins | 检测新项目（建议使用 /start），以及在存在代码/原型时检测缺失文档，建议使用 /reverse-document 或 /project-stage-detect |
| `pre-compact.sh` | PreCompact | Context compression | 在压缩前将会话状态（active.md、已修改文件、WIP 设计文档）写入对话，确保在摘要化后仍可保留 |
| `post-compact.sh` | PostCompact | After compaction | 提醒 Claude 从 `active.md` 检查点恢复会话状态 |
| `notify.sh` | Notification | Notification event | 通过 PowerShell 显示 Windows toast 通知 |
| `session-stop.sh` | Stop | Session ends | 汇总完成成果并更新会话日志 |
| `log-agent.sh` | SubagentStart | Agent spawned | 审计追踪开始——记录带时间戳的子代理调用 |
| `log-agent-stop.sh` | SubagentStop | Agent stops | 审计追踪结束——完成子代理记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | Skill file changes | 在任意 `.claude/skills/` 文件被写入或编辑后，建议运行 `/skill-test` |

Hook 参考文档：`.claude/docs/hooks-reference/`
Hook 输入 schema 文档：`.claude/docs/hooks-reference/hook-input-schemas.md`
