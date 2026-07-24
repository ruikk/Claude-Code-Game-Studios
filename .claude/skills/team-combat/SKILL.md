---
name: team-combat
description: "编排战斗团队：协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer 和 qa-tester，端到端地设计、实现并验证战斗功能。"
argument-hint: "[combat feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
**参数检查：** 如果未提供战斗功能描述，则输出：
> "用法：`/team-combat [combat feature description]` - 请描述要设计和实现的战斗功能（例如 `近战招架系统`、`远程武器散布`）。"
然后立即停止，不生成任何子代理，也不读取任何文件。

使用有效参数调用此技能时，通过结构化管线编排战斗团队。

**决策点：** 每次阶段转换时，使用 `AskUserQuestion` 将子代理的提案作为可选项呈现给用户。
先在对话中写出代理的完整分析，再用简洁的标签记录决定。
必须获得用户批准后才能进入下一阶段。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，则使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中指定的模式。
3. 如果仍未指定，则默认为 `lean`。

模式：
- `full` - 按说明生成所有总监和主管关卡
- `lean` - 跳过总监关卡，除非其类型为 PHASE-GATE（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` - 完全跳过所有总监关卡，不经过任何代理关卡运行此技能

保存最终确定的模式，供后续所有阶段使用。

## 团队构成
- **game-designer** - 设计机制，定义公式和边界情况
- **gameplay-programmer** - 实现核心玩法代码
- **ai-programmer** - 实现该功能所需的 NPC/敌人 AI 行为
- **technical-artist** - 制作 VFX、着色器效果和视觉反馈
- **sound-designer** - 定义音频事件、打击音效和战斗环境音频
- **engine specialist**（主要）- 验证架构和实现模式是否符合引擎惯用方式（从 `.claude/docs/technical-preferences.md` 的 Engine Specialists 章节读取）
- **qa-tester** - 编写测试用例并验证实现

## 如何委派

使用 Task 工具将每位团队成员生成为子代理：
- `subagent_type: game-designer` - 设计机制，定义公式和边界情况
- `subagent_type: gameplay-programmer` - 实现核心玩法代码
- `subagent_type: ai-programmer` - 实现 NPC/敌人 AI 行为
- `subagent_type: technical-artist` - 制作 VFX、着色器效果和视觉反馈
- `subagent_type: sound-designer` - 定义音频事件、打击音效和环境音频
- `subagent_type: [primary engine specialist]` - 验证架构和实现是否符合引擎惯用方式
- `subagent_type: qa-tester` - 编写测试用例并验证实现

始终在每个代理的提示词中提供完整上下文（设计文档路径、相关代码文件和约束）。在管线允许时并行启动相互独立的代理（例如，阶段 3 的代理可以同时运行）。

## 管线

### 阶段 1：设计
委派给 **game-designer**：
- 在 `design/gdd/` 中创建或更新设计文档，内容包括：机制概述、玩家幻想、详细规则、含变量定义的公式、边界情况、依赖项、带安全范围的调优参数以及验收标准
- 输出：完整的设计文档

### 阶段 2：架构
委派给 **gameplay-programmer**（如果涉及 AI，则同时委派给 **ai-programmer**）：
- 审查设计文档
- 设计代码架构：类结构、接口和数据流
- 确定与现有系统的集成点
- 输出：包含文件列表和接口定义的架构草案

然后生成 **primary engine specialist** 来验证拟议架构：
- 类/节点/组件结构是否符合已锁定引擎的惯用方式？（例如 Godot 节点层级、Unity MonoBehaviour 与 DOTS 的取舍、Unreal Actor/Component 设计）
- 是否有应替代自定义实现的引擎原生系统？
- 拟使用的 API 是否已在锁定的引擎版本中弃用或发生变更？
- 输出：引擎架构说明；在阶段 3 开始前将其纳入架构

使用 `AskUserQuestion`：
- 提示："架构草案已完成。是否批准继续并行实现？"
- 选项：
  - `[A] 继续 - 生成实现代理（gameplay-programmer、ai-programmer、technical-artist、sound-designer）`
  - `[B] 先修改架构 - 我会说明需要更改的内容`
  - `[C] 在此停止 - 我稍后继续`

仅当用户选择 [A] 时才生成实现代理。

### 阶段 3：实现（尽可能并行）
并行委派：
- **gameplay-programmer**：实现核心战斗机制代码
- **ai-programmer**：实现 AI 行为（如果该功能涉及 NPC 反应）
- **technical-artist**：制作 VFX 和着色器效果
- **sound-designer**：定义音频事件列表和混音说明

### 阶段 4：集成
- 连接玩法代码、AI、VFX 和音频
- 确保所有调优参数均已公开并由数据驱动
- 验证该功能能否与现有战斗系统协同工作

### 阶段 5：验证
委派给 **qa-tester**：
- 根据验收标准编写测试用例
- 测试设计文档中记录的所有边界情况
- 验证性能影响是否在预算范围内
- 为发现的所有问题提交缺陷报告

### 阶段 6：签核
- 汇总所有团队成员的结果
- 报告功能状态：COMPLETE / NEEDS WORK / BLOCKED
- 列出所有未解决的问题及其负责人

## 错误恢复协议

如果通过 Task 生成的任何代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即报告**：在继续执行依赖阶段前，向用户报告 "[AgentName]: BLOCKED - [reason]"
2. **评估依赖关系**：检查后续阶段是否需要被阻塞代理的输出。如果需要，在没有用户输入的情况下不得越过该依赖点继续执行。
3. **提供选项**：通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止，先解决阻塞问题
4. **始终生成部分报告**：输出所有已完成的内容。绝不能因为某个代理受阻而丢弃工作成果。

常见阻塞原因：
- 缺少输入文件（找不到故事、缺少 GDD）→ 转到用于创建该文件的技能
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事中的指令冲突 → 明确报告冲突，不要猜测

## 文件写入协议

所有文件写入（设计文档、实现文件、测试用例）都委派给通过 Task 生成的子代理。
每个子代理都执行“可以写入 [path] 吗？”协议。此编排器不直接写入文件。

## 输出

生成一份摘要报告，涵盖：设计完成状态、每位团队成员的实现状态、测试结果以及所有未解决的问题。

结论：**COMPLETE** - 战斗功能已完成设计、实现和验证。
结论：**BLOCKED** - 一个或多个阶段无法完成；已生成部分报告并列出未解决事项。

## 后续步骤

- 在关闭故事前，对已实现的战斗代码运行 `/code-review`。
- 运行 `/balance-check`，验证战斗公式和调优值。
- 如果需要打磨 VFX、音频或性能，则运行 `/team-polish`。
