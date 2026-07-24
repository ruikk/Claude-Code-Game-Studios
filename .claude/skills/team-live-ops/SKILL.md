---
name: team-live-ops
description: "协调 live-ops 团队规划上线后内容：组织 live-ops-designer、economy-designer、analytics-engineer、community-manager、writer 和 narrative-director，共同设计并规划赛季、活动或在线内容更新。"
argument-hint: "[season name or event description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
**参数检查：** 如果未提供赛季名称或活动描述，则输出：
> "用法：`/team-live-ops [season name or event description]` — 请提供要规划的赛季或在线活动的名称或描述。"
随后立即停止，不生成任何子代理，也不读取任何文件。

使用有效参数调用此技能时，通过结构化规划管线协调 live-ops 团队。

**决策点：** 每次阶段转换时，使用 `AskUserQuestion` 将子代理的提案作为
可选项呈现给用户。先在对话中写出代理的完整分析，再用简洁标签记录决策。
必须获得用户批准后才能进入下一阶段。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，则使用该模式。
2. 否则读取 `production/review-mode.txt`，并使用其中记录的模式。
3. 如果仍未确定，则默认使用 `lean`。

模式：
- `full` — 按说明生成所有总监和主管关卡
- `lean` — 跳过总监关卡，除非其类型为 PHASE-GATE（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有总监关卡，不使用任何代理关卡运行此技能

保存确定的模式，供所有后续阶段使用。

## 团队构成
- **live-ops-designer** — 赛季结构、活动节奏、留存机制、战斗通行证
- **economy-designer** — 在线经济平衡、商店轮换、货币定价、保底机制
- **analytics-engineer** — 成功指标、A/B 测试设计、事件追踪、仪表盘规格
- **community-manager** — 面向玩家的公告、活动描述、赛季信息
- **narrative-director** — 赛季叙事主题、故事线、世界事件框架
- **writer** — 活动描述、奖励物品名称、赛季风味文本、公告文案

## 如何委派

使用 Task 工具将每位团队成员生成为子代理：
- `subagent_type: live-ops-designer` — 赛季/活动结构和留存机制
- `subagent_type: economy-designer` — 在线经济平衡和奖励定价
- `subagent_type: analytics-engineer` — 成功指标、A/B 测试、活动埋点
- `subagent_type: community-manager` — 面向玩家的沟通和信息发布
- `subagent_type: narrative-director` — 赛季主题和叙事框架
- `subagent_type: writer` — 所有面向玩家的文本：活动描述、物品名称、文案

每个代理的提示词都必须提供完整上下文（游戏概念路径、现有赛季文档、伦理政策路径、当前经济状态）。管线允许时并行启动相互独立的代理（阶段 3 和阶段 4 可同时运行）。

## 管线

### 阶段 1：赛季/活动范围界定
委派给 **live-ops-designer**：
- 定义赛季或活动：类型（赛季、限时活动、挑战）、持续时间、主题方向
- 概述内容清单：新增内容（模式、物品、挑战、故事节点）
- 定义留存吸引点：赛季期间促使玩家每日/每周回归的因素
- 确定资源预算：需要制作多少新内容，以及可以复用多少内容
- 输出：包含范围、内容清单和留存机制概述的赛季简报

### 阶段 2：叙事主题
委派给 **narrative-director**：
- 阅读阶段 1 的赛季简报
- 设计赛季叙事主题：此活动如何与游戏世界相连？
- 定义玩家将在活动期间发现的核心故事悬念
- 确定本赛季可以推进哪些现有世界观线索
- 输出：叙事框架文档（主题、故事悬念、世界观联系）

### 阶段 3：经济设计（主题明确时可与阶段 2 并行）
委派给 **economy-designer**：
- 阅读赛季简报以及 `design/live-ops/economy-rules.md` 中的现有经济规则
- 设计奖励路径：免费档位进度、高级档位价值主张
- 规划赛季内经济：赛季货币、商店轮换、定价
- 为所有随机要素定义保底机制和厄运保护
- 验证高级奖励路径中不存在付费获胜物品
- 输出：包含奖励表、定价和货币流的经济设计文档

### 阶段 4：分析与成功指标（与阶段 3 并行）
委派给 **analytics-engineer**：
- 阅读赛季简报
- 定义成功指标：参与率目标、留存提升目标、战斗通行证完成率
- 设计赛季期间要运行的 A/B 测试（例如不同的奖励发放节奏）
- 指定本赛季内容所需的新遥测事件
- 输出：包含成功标准和埋点要求的分析计划

### 阶段 5：内容撰写（并行）
并行委派：
- **narrative-director**（如有需要）：撰写本赛季的游戏内叙事文本（过场动画脚本、NPC 对话、世界事件描述）
- **writer**：撰写所有面向玩家的文本，包括活动名称、奖励物品描述、挑战目标文本、赛季风味文本
- 两者都应阅读阶段 2 的叙事框架文档

### 阶段 6：玩家沟通计划
委派给 **community-manager**：
- 阅读赛季简报、经济设计和叙事框架
- 起草赛季上线公告（语气、核心亮点、各平台专用版本）
- 规划沟通节奏：上线前预告、上线日帖子、赛季中期提醒、最后一周的错失恐惧推动信息
- 为首日补丁说明起草已知问题章节占位内容
- 输出：包含各触点文案草稿的沟通日历

### 阶段 7：审查与签署
汇总所有阶段的输出，并提交整合后的赛季计划：
- 赛季简报（阶段 1）
- 叙事框架（阶段 2）
- 经济设计和奖励表（阶段 3）
- 分析计划和成功指标（阶段 4）
- 已撰写内容清单（阶段 5）
- 沟通日历（阶段 6）

向用户提交包含以下内容的摘要：
- **内容范围**：正在创建哪些内容
- **经济健康检查**：奖励路径是否公平且不存在掠夺性设计？
- **分析准备情况**：是否已定义成功标准并完成埋点？
- **伦理审查**：依据 `design/live-ops/ethics-policy.md` 检查阶段 3 的经济设计
  - 如果文件不存在：标记“ETHICS REVIEW SKIPPED: 未找到 `design/live-ops/ethics-policy.md`。经济设计未依据伦理政策进行审查。建议在开始制作前创建该文件。”在赛季设计输出文档中包含此标记，并在后续步骤中添加：创建 `design/live-ops/ethics-policy.md`。
  - 如果文件存在且发现违规：标记“ETHICS FLAG: 阶段 3 经济设计中的 [element] 违反了 [policy rule]。解决此问题前无法批准。”不得给出 COMPLETE 结论或写入输出文档。使用 `AskUserQuestion` 提供以下选项：修改经济设计 / 使用书面理由推翻 / 取消。如果用户选择修改：重新生成 economy-designer 以产出修正版设计，然后返回阶段 7 审查。如果用户选择取消：以 Verdict: BLOCKED 结束，并输出“由于伦理违规尚未解决，live ops 设计已取消。请解决标记的问题，然后重新运行 /team-live-ops。”
- **待决问题**：开始制作前仍需决定的事项

在委派给制作团队之前，请用户批准赛季计划。只有在用户批准且不存在未解决的伦理违规时，才能给出 COMPLETE 结论。如果仍有伦理违规未解决，则以 Verdict: **BLOCKED** 结束。

## 输出文档

所有文档均保存到 `design/live-ops/`：
- `seasons/S[N]_[name].md` — 赛季设计文档（来自阶段 1-3）
- `seasons/S[N]_[name]_analytics.md` — 分析计划（来自阶段 4）
- `seasons/S[N]_[name]_comms.md` — 沟通日历（来自阶段 6）

## 错误恢复协议

如果通过 Task 生成的任何代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即披露**：在继续执行依赖阶段前，向用户报告“[AgentName]: BLOCKED — [reason]”
2. **评估依赖关系**：检查后续阶段是否需要被阻塞代理的输出。如果需要，则在获得用户输入前不得越过该依赖点。
3. **提供选项**：通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止并优先解决阻塞问题
4. **始终生成部分报告**：输出所有已完成的内容。绝不能因为一个代理受阻而丢弃工作成果。

如果 BLOCKED 状态无法解决，则以 Verdict: **BLOCKED** 结束，而不是 COMPLETE。

## 文件写入协议

所有文件写入（赛季设计文档、分析计划、沟通日历）都委派给通过 Task 生成的
子代理。每个子代理都执行“可以写入 [path] 吗？”协议。此协调器不直接写入文件。

## 输出

摘要需涵盖：赛季主题和范围、经济设计亮点、成功指标、内容清单、沟通计划，以及开始制作前需要用户决定的所有待决事项。

Verdict: **COMPLETE** — 赛季计划已生成并移交制作。

## 后续步骤

- 对赛季设计文档运行 `/design-review`，验证其一致性。
- 运行 `/sprint-plan`，安排本赛季的内容制作工作。
- 赛季内容准备好部署时，运行 `/team-release`。
