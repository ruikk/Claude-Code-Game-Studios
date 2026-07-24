---
name: team-audio
description: "编排音频团队：由 audio-director、sound-designer、technical-artist 和 gameplay-programmer 完成从方向制定到实现的完整音频流程。"
argument-hint: "[feature or area to design audio for] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---

如果未提供参数，输出用法说明并退出，不生成任何代理：
> 用法：`/team-audio [feature or area]` — 指定要进行音频设计的功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）。此处不要使用 `AskUserQuestion`；直接输出说明。

使用参数调用此技能时，通过结构化流程编排音频团队。

**决策点：** 每次转换步骤时，使用 `AskUserQuestion` 将子代理的提案作为可选项
呈现给用户。在对话中写出代理的完整分析，然后用简洁标签记录决定。
必须获得用户批准才能进入下一步。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，使用该模式。
2. 否则读取 `production/review-mode.txt` — 使用其中写明的模式。
3. 否则默认为 `lean`。

模式：
- `full` — 按说明生成所有总监和负责人关卡
- `lean` — 跳过总监关卡，除非其类型为 PHASE-GATE（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有总监关卡的生成；运行技能时不使用任何代理关卡

保存确定的模式，供后续所有阶段使用。

1. **读取参数**，获取目标功能或区域（例如 `combat`、
   `main menu`、`forest biome`、`boss encounter`）。

2. **收集上下文**：
   - 读取 `design/gdd/` 中与该功能相关的设计文档
   - 如果存在，读取 `design/gdd/sound-bible.md` 中的声音圣经
   - 读取 `assets/audio/` 中现有的音频资产清单
   - 读取该区域已有的声音设计文档

## 如何委派

使用 Task 工具将每位团队成员生成为子代理：
- `subagent_type: audio-director` — 声音标识、情感基调、音频调色板
- `subagent_type: sound-designer` — SFX 规格、音频事件、混音组
- `subagent_type: technical-artist` — 音频中间件、总线结构、内存预算
- `subagent_type: [primary engine specialist]` — 验证该引擎的音频集成模式
- `subagent_type: gameplay-programmer` — 音频管理器、玩法触发器、自适应音乐

始终在每个代理的提示词中提供完整上下文（功能描述、现有音频资产、设计文档引用）。

3. 按顺序**编排音频团队**：

### 步骤 1：音频方向（audio-director）
生成 `audio-director` 代理以：
- 定义此功能或区域的声音标识
- 指定情感基调和音频调色板
- 确定音乐方向（自适应分层、分轨、过渡）
- 定义音频优先级和混音目标
- 制定所有自适应音频规则（战斗强度、探索、紧张度）

### 步骤 2：声音设计与音频无障碍（并行）
生成 `sound-designer` 代理以：
- 为每个音频事件创建详细的 SFX 规格
- 定义声音类别（环境、UI、玩法、音乐、对话）
- 指定每种声音的参数（音量范围、音高变化、衰减）
- 规划包含触发条件的音频事件清单
- 定义混音组和闪避规则

并行生成 `accessibility-specialist` 代理以：
- 识别哪些音频事件承载关键玩法信息（受到伤害、附近有敌人、目标完成），并需要为听障玩家提供视觉替代方案
- 指定字幕要求：哪些音频事件需要字幕、文本格式和屏幕显示时长
- 检查是否不存在仅通过音频传达的玩法状态（所有状态都必须有视觉备用方案）
- 审查音频事件清单，找出可能给听觉敏感玩家带来问题的事件（高频警报、突然的巨响）
- 输出：集成到音频事件规格中的音频无障碍要求清单

### 步骤 3：技术实现（并行）
生成 `technical-artist` 代理以：
- 设计音频中间件集成（Wwise/FMOD/native）
- 定义音频总线结构和路由
- 指定各平台音频资产的内存预算
- 规划流式加载与预加载资产策略
- 设计所有音频响应式视觉效果

并行生成**主要引擎专家**（来自 `.claude/docs/technical-preferences.md` 的 Engine Specialists）以验证集成方案：
- 建议的音频中间件集成是否符合该引擎的惯用方式？（例如 Godot 内置的 AudioStreamPlayer 与 FMOD、Unity 的 Audio Mixer 与 Wwise、Unreal 的 MetaSounds 与 FMOD）
- 是否有应采用的引擎特定音频节点或组件模式？
- 固定引擎版本中是否存在会影响集成计划的已知音频系统变更？
- 输出：与 technical-artist 计划合并的引擎音频集成说明

如果未配置引擎，跳过生成专家。

### 步骤 4：代码集成（gameplay-programmer）
生成 `gameplay-programmer` 代理以：
- 实现音频管理器系统或审查现有系统
- 将音频事件连接到玩法触发器
- 实现自适应音乐系统（如有指定）
- 设置音频遮挡和混响区域
- 为音频事件触发器编写单元测试

4. 汇总所有团队输出，**编制音频设计文档**。

5. **保存到** `design/audio/audio-[feature].md`。

   注意：如果 `design/audio/` 不存在，编写文档的子代理应创建它（写入文件时会自动创建该目录）。

6. **输出摘要**，其中包括：音频事件数量、预计资产数量、
   实现任务，以及团队成员之间的所有待解决问题。

结论：**COMPLETE** — 音频设计文档已生成，团队流程已完成。

如果流程因依赖项未解决而停止（例如关键无障碍缺口或缺失的 GDD 未由用户解决）：

结论：**BLOCKED** — [reason]

## 文件写入协议

所有文件写入（音频设计文档、SFX 规格、实现文件）均委派给通过 Task 生成的
子代理。每个子代理都执行“可以写入 [path] 吗？”协议。
此编排器不直接写入文件。

## 后续步骤

- 在开始实现之前，与 audio-director 一起审查音频设计文档。
- 设计获批后，使用 `/dev-story` 实现音频管理器和事件系统。
- 创建音频资产后，运行 `/asset-audit` 以验证命名和格式合规性。

## 错误恢复协议

如果通过 Task 生成的任何代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即报告**：在继续执行依赖阶段前，向用户报告“[AgentName]: BLOCKED — [reason]”
2. **评估依赖关系**：检查后续阶段是否需要被阻塞代理的输出。如果需要，未经用户输入，不得越过该依赖点继续执行。
3. 通过 AskUserQuestion **提供选项**：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止并先解决阻塞项
4. **始终生成部分报告** — 输出所有已完成的内容。绝不因一个代理受阻而丢弃工作。

常见阻塞项：
- 输入文件缺失（找不到故事、缺少 GDD）→ 转到创建该文件的技能
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事的指令冲突 → 报告冲突，不要猜测
