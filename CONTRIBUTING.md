# 为 Claude Code Game Studios 做贡献

CCGS 是一个使用 Claude Code 进行独立游戏开发的协作框架。
我们欢迎修复缺陷、添加填补实际空缺的新技能、改进代理以及修复钩子。不符合框架发展方向的
PR 将被关闭，且不会提供冗长说明。

## 什么是优质的 PR

- **缺陷修复**：修复确实存在的问题
- **新技能**：解决尚未覆盖的工作流空缺
- **改进**：改进现有代理、技能或钩子
- **文档更正**：修正错误信息、失效引用或过时步骤

以 PR 形式提交的功能请求将被关闭。请改为创建议题。

**本仓库不是什么：**
CCGS 是帮助你制作游戏的系统，而不是存放你使用它制作的游戏的地方。GDDs、ADRs、PRDs、
游戏概念、关卡设计、叙事文档或 CCGS 为你自己的项目生成的任何其他产物都不会合并到这里；
请将它们保存在你自己的仓库中。

## 不可妥协的技术规则

如果忽略以下规则，你的 PR 将被拒绝。

**技能文件**
- 技能必须位于 `.claude/skills/<name>/SKILL.md`，且必须使用子目录格式。Claude Code 会静默
  忽略扁平放置的 `.md` 文件。
- SKILL.md 必须包含 YAML 前置元数据：`name`、`description`、
  `argument-hint`、`allowed-tools` 和 `model`
- 模型层级：只读状态检查使用 `haiku`，多文档综合和阶段门审核使用 `opus`，其他情况使用 `sonnet`

**钩子**
- 使用 `grep -E`，绝不使用 `grep -P`（Perl 正则表达式在 Windows Git Bash 上无法正常工作）
- 必须为未安装 `jq` 或 `python` 的系统提供后备方案
- 钩子会在每次会话启动时运行；不适用时必须快速、正常地退出（`exit 0`）

**代理**
- 新代理必须包含**协作协议（Collaboration Protocol）**章节，说明代理如何提问并将决定权交给用户
- 未经用户明确授权，代理不得修改其文档所述职责范围之外的文件

**参考文档**
- 如果你的 PR 添加或更改了技能、代理或钩子，请更新对应的参考文档（agent-roster、
  skills-reference、hooks-reference 或 rules-reference）。添加内容却未更新索引的 PR 将被退回。

## 协作原则

CCGS 不是自主系统。每个工作流都遵循：
**提问 → 选项 → 决定 → 草稿 → 审批 → 写入**

技能和代理必须先询问再行动。没有用户的明确确认，不得向文件写入任何内容。如果你的贡献让
代理单方面作出决定或写入文件，该贡献将不会被合并。

## 测试你的更改

请在 Claude Code 会话中运行更改，并确认其端到端正常工作。对于技能，请调用该技能并验证输出
是否符合技能声明的功能。对于钩子，请触发相关事件，确认钩子正确执行并正常退出。

请在 PR 描述中加入简短说明，写明测试内容及输出结果。

## 提交格式

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat: add /retrospective skill for end-of-sprint reviews
fix: correct grep -P usage in session-start hook
docs: update skills-reference with new /qa-plan entry
```

类型：`feat`、`fix`、`docs`、`chore`、`refactor`、`test`

## PR 流程

- 你的 PR 将通过 CODEOWNERS 自动分配给维护者
- 审查会在维护者有时间时进行；这是一个由个人维护的项目
- 如果你的 PR 保持开放数周仍未收到反馈，可以留言适当提醒
- 已合并贡献的作者会在发行说明中获得署名

## 平台兼容性

CCGS 必须能在 Windows (Git Bash)、macOS 和 Linux 上运行。如果你的钩子或脚本使用任何
特定于平台的内容，它将被拒绝。如有疑问，请在 Windows 上测试。
