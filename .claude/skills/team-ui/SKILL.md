---
name: team-ui
description: "编排 UI 团队完成完整的 UX 流程：从 UX 规格编写，到视觉设计、实现、审查和润色。与 /ux-design、/ux-review 及工作室 UX 模板集成。"
argument-hint: "[UI feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
调用此技能时，通过结构化流程编排 UI 团队。

**决策点：** 每次阶段转换时，使用 `AskUserQuestion` 将子代理的提案作为可选项呈现给用户。先在对话中写出代理的完整分析，再用简洁的标签记录决定。必须获得用户批准，才能进入下一阶段。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，则使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中记录的模式。
3. 否则默认为 `lean`。

模式：
- `full` — 按说明启用所有总监和主管关卡
- `lean` — 跳过总监关卡，除非它们属于 PHASE-GATE 类型（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有总监关卡代理；运行技能时不启用任何代理关卡

保存确定的模式，供后续所有阶段使用。

**总监关卡跳过规则**：在启用 creative-director、art-director 或任何其他 Tier 1/2 总监进行审查前（PHASE-GATE 触发条件除外），应用已确定的模式：若为 solo 模式则跳过；若为 lean 模式且当前不是 PHASE-GATE，则跳过。

## 团队构成
- **ux-designer** — 用户流程、线框图、无障碍、输入处理
- **ui-programmer** — UI 框架、界面、控件、数据绑定、实现
- **art-director** — 视觉风格、布局润色、与美术圣经保持一致
- **engine UI specialist** — 根据引擎特定最佳实践验证 UI 实现模式（从 `.claude/docs/technical-preferences.md` 的 Engine Specialists → UI Specialist 读取）
- **accessibility-specialist** — 在阶段 4 审核无障碍合规性

**此流程使用的模板：**
- `ux-spec.md` — 标准界面/流程 UX 规格
- `hud-design.md` — HUD 专用 UX 规格
- `interaction-pattern-library.md` — 可复用的交互模式
- `accessibility-requirements.md` — 已确定的无障碍等级和要求

## 如何委派

使用 Task 工具将每位团队成员作为子代理启动：
- `subagent_type: ux-designer` — 用户流程、线框图、无障碍、输入处理
- `subagent_type: ui-programmer` — UI 框架、界面、控件、数据绑定
- `subagent_type: art-director` — 视觉风格、布局润色、与美术圣经保持一致
- `subagent_type: [UI engine specialist]` — 验证引擎特定的 UI 模式（例如 unity-ui-specialist、ue-umg-specialist、godot-specialist）
- `subagent_type: accessibility-specialist` — 无障碍合规性审核

始终在每个代理的提示词中提供完整上下文（功能需求、现有 UI 模式、目标平台）。在流程允许时并行启动相互独立的代理（例如，阶段 4 的审查代理可以同时运行）。

## 流程

### 阶段 1a：收集上下文

开始任何设计之前，读取并综合：
- `design/gdd/game-concept.md` — 目标平台和预期受众
- `design/player-journey.md` — 玩家到达此界面时的状态和情境
- 与此功能相关的所有 GDD UI Requirements 章节
- `design/ux/interaction-patterns.md` — 要复用的现有模式（不要重新发明）
- `design/accessibility-requirements.md` — 已确定的无障碍等级（例如 Basic、Enhanced、Full）

**如果 `design/ux/interaction-patterns.md` 不存在**，立即指出此缺口：
> "interaction-patterns.md 不存在 — 没有可复用的现有模式。"

然后使用 `AskUserQuestion` 提供以下选项：
- (a) 先运行 `/ux-design patterns` 建立模式库，然后继续
- (b) 在没有模式库的情况下继续 — ui-programmer 会将创建的所有模式视为新模式，并在完成时逐一添加到新建的 `design/ux/interaction-patterns.md`

不要仅根据功能名称或 GDD 发明或假定模式。如果用户选择 (b)，在阶段 3 中明确指示 ui-programmer 将所有模式视为新模式，并在实现完成时将它们记录到 `design/ux/interaction-patterns.md`。在最终摘要报告中注明模式库状态（created / absent / updated）。

为 ux-designer 将上下文汇总成简报：玩家正在做什么、需要什么、有哪些约束，以及哪些现有模式与之相关。

### 阶段 1b：编写 UX 规格

调用 `/ux-design [feature name]` 技能，或直接委派给 ux-designer，按照 `ux-spec.md` 模板生成 `design/ux/[feature-name].md`。

如果设计 HUD，请使用 `hud-design.md` 模板，而不是 `ux-spec.md`。

> **特殊情况说明：**
> - 专门设计 HUD 时，使用 `argument: hud` 调用 `/ux-design`（例如 `/ux-design hud`）。
> - 对于交互模式库，在项目开始时运行一次 `/ux-design patterns`，之后的阶段每当引入新模式时都要更新它。

输出：所有必填规格章节均已填写的 `design/ux/[feature-name].md`。

### 阶段 1c：UX 审查

规格完成后，调用 `/ux-review design/ux/[feature-name].md`。

**关卡**：结论为 APPROVED 前，不得进入阶段 2。如果结论为 NEEDS REVISION，ux-designer 必须处理指出的问题并重新运行审查。用户可以明确接受 NEEDS REVISION 的风险并继续，但这必须是有意识的决定 — 在询问是否继续之前，先通过 `AskUserQuestion` 呈现具体问题。

### 阶段 2：视觉设计

委派给 **art-director**：
- 审查完整的 UX 规格（流程、线框图、交互模式、无障碍说明），而不只是线框图图片
- 应用美术圣经中的视觉处理：颜色、字体、间距、动画风格
- 检查视觉设计是否保持无障碍合规：验证颜色对比度，并确认颜色绝不是状态的唯一指示方式（必须通过形状、文字或图标加以强化）
- 明确美术管线所需的全部资产要求：指定尺寸的图标、背景纹理、字体、装饰元素，并给出精确的尺寸和格式要求
- 确保与现有已实现 UI 界面保持一致
- 输出：包含风格说明和资产清单的视觉设计规格

### 阶段 3：实现

开始实现前，启动 **engine UI specialist**（来自 `.claude/docs/technical-preferences.md` 的 Engine Specialists → UI Specialist），让其审查 UX 规格和视觉设计规格，并提供引擎特定的实现指导：
- 此界面应使用哪个引擎 UI 框架？（例如 Unity 中的 UI Toolkit 与 UGUI、Godot 中的 Control 节点与 CanvasLayer、Unreal 中的 UMG 与 CommonUI）
- 建议的布局或交互模式是否存在引擎特定的注意事项？
- 推荐使用怎样的引擎控件/节点结构？
- 输出：在 ui-programmer 开始前交付给他们的引擎 UI 实现说明

如果尚未配置引擎，则跳过此步骤。

委派给 **ui-programmer**：
- 按照 UX 规格和视觉设计规格实现 UI
- **使用 `design/ux/interaction-patterns.md` 中的模式** — 不要重新发明已有明确规格的模式。如果某个模式基本适用但需要修改，请记录偏差并标记为需要 ux-designer 审查。
- **UI 绝不拥有或修改游戏状态** — 只负责显示；为所有玩家操作发出事件
- 所有文本都通过本地化系统提供 — 不得硬编码面向玩家的字符串
- 同时支持两种输入方式（键盘/鼠标和游戏手柄）
- 按照 `design/accessibility-requirements.md` 中已确定的等级实现无障碍功能
- 建立与游戏状态的数据绑定
- **如果实现过程中创建了任何新的交互模式**（即模式库中尚不存在的内容），则在将实现标记为完成前，将其添加到 `design/ux/interaction-patterns.md`
- 输出：已实现的 UI 功能

### 阶段 4：审查（并行）

并行委派：
- **ux-designer**：验证实现是否符合线框图和交互规格。测试纯键盘和纯游戏手柄导航。检查无障碍功能是否正常工作。
- **art-director**：验证视觉效果是否与美术圣经一致。在支持的最低和最高分辨率下进行检查。
- **accessibility-specialist**：根据 `design/accessibility-requirements.md` 中记录的已确定无障碍等级验证合规性。将所有违规项标记为阻塞项。

三个审查分支都必须提交报告，才能进入阶段 5。

### 阶段 5：润色

- 处理所有审查反馈
- 验证动画可以跳过，并遵循玩家的减少动态效果偏好
- 确认 UI 音效通过音频事件系统触发（不得直接调用音频）
- 在所有支持的分辨率和宽高比下测试
- **验证 `design/ux/interaction-patterns.md` 为最新状态** — 如果此功能的实现过程中引入了任何新模式，确认它们已添加到模式库
- **确认所有 HUD 元素遵守视觉预算**，该预算在 `design/ux/hud.md` 中定义（元素数量、屏幕区域分配、最大不透明度值）

## 快速参考 — 各技能的使用时机

- `/ux-design` — 从零开始为界面、流程或 HUD 编写新的 UX 规格
- `/ux-review` — 在实现前验证已完成的 UX 规格
- `/team-ui [feature]` — 从概念到润色的完整流程（内部调用 `/ux-design` 和 `/ux-review`）
- `/quick-design` — 不需要全新完整 UX 规格的小型 UI 变更

## 错误恢复协议

如果任何已启动的代理（通过 Task）返回 BLOCKED、发生错误或无法完成：

1. **立即报告**：在继续依赖阶段前，向用户报告 "[AgentName]: BLOCKED — [reason]"
2. **评估依赖项**：检查后续阶段是否需要被阻塞代理的输出。如果需要，在没有用户输入的情况下，不得越过该依赖点继续。
3. **通过 AskUserQuestion 提供选项**：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止，先解决阻塞项
4. **始终生成部分报告** — 输出所有已完成的内容。绝不能因为一个代理被阻塞而丢弃工作。

常见阻塞项：
- 缺少输入文件（找不到故事、缺少 GDD）→ 转到创建该文件的技能
- ADR 状态为 Proposed → 不得实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事的指令冲突 → 明确指出冲突，不要猜测

## 文件写入协议

所有文件写入（UX 规格、交互模式库更新、实现文件）均委派给子代理和子技能（`/ux-design`、`ui-programmer`）。每个子代理和子技能都会执行“可以写入 [path] 吗？”协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：UX 规格状态、UX 审查结论、视觉设计状态、实现状态、无障碍合规性、输入方式支持情况、交互模式库更新状态，以及所有未解决问题。

结论：**COMPLETE** — UI 功能已通过完整流程交付（UX 规格 → 视觉设计 → 实现 → 审查 → 润色）。
结论：**BLOCKED** — 流程已停止；停止前明确报告阻塞项及其所在阶段。

## 后续步骤

- 如果最终规格尚未获批，对其运行 `/ux-review`。
- 在关闭故事前，对 UI 实现运行 `/code-review`。
- 如果需要进行视觉或音频润色，运行 `/team-polish`。
