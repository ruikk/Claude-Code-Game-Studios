# Interaction Pattern Library: [Game Title]

> **Status**: Draft | Stable | Under Revision
> **Author**: [ux-designer]
> **Last Updated**: [Date]
> **Version**: [1.0]
> **Engine**: [Godot 4.6 / Unity 6 / Unreal Engine 5]
> **UI Framework**: [Godot Control nodes / Unity UI Toolkit / Unreal UMG]
> **Related Documents**:
> - `docs/art-bible.md` — 视觉标准（颜色、排版、图标体系）
> - `docs/accessibility-requirements.md` — 各功能的无障碍承诺
> - `docs/ux/ux-spec-[screen].md` — 引用本模式库的单屏 UX 规格

> **Why this document exists**：每个 UI 屏幕规格都应能直接写“uses Button (Primary) pattern”，
> 而不是重复定义悬停状态、按压动画、焦点行为、键盘处理与屏幕阅读器播报。
> 本库是可复用交互行为的唯一事实来源（single source of truth）。
> 当屏幕规格引用某个模式名时，程序员应在这里查完整定义。行为变更也应在这里统一更新，并自动影响所有使用处。
>
> 这是一个持续演进文档。新屏幕设计时应同步新增模式——在设计新交互前先检查本库。
> 若需要新模式，请在编写第一个使用它的屏幕规格之前（或至少同时）先补充到本库，或先向 ux-designer 提案。
>
> **Status definitions**:
> - **Draft**：交互已定义，但尚未实现或验证
> - **Stable**：已实现、已测试，并且至少在一个已发布屏幕中验证通过
> - **Deprecated**：正在淘汰——现有使用会逐步迁移，新屏幕禁止使用

---

## How to Use This Library / 如何使用本库

**If you are designing a screen**：在发明新交互前，先浏览下方 Pattern Catalog Index。
若已有标准模式适配，请在屏幕规格中按名称引用（例如：“The confirm button uses Button (Primary) pattern”）。若现有模式不适配，请先提议新模式——在引入它的屏幕规格之前或同时，将其写入本库。

**If you are implementing a screen**：当屏幕规格写着“use [PatternName] pattern”时，请到本文件查阅完整规格。
implementation notes 提供引擎实现指引。Accessibility 部分列出的要求是不可协商项。

**If you are reviewing a screen spec**：请核对所有可交互元素都引用了本库中的模式，或提供了完整交互规格。
“standard button”或“the usual way”不构成有效引用。

**If you are updating a pattern**：修改 Stable 模式会影响所有使用该模式的屏幕。
修改前请先审计全部用例（在屏幕规格中搜索模式名）、评估影响、获得 ux-designer 批准，并在实现改动之前或同时更新本文档。

---

## Pattern Catalog Index / 模式目录索引

> 每新增一个模式，都要在此表新增一行。
> “Used In”列是使用审计轨迹——有新屏幕采用该模式时请同步更新。

| Pattern Name | Category | Description | Used In (Screens) | Status |
|-------------|----------|-------------|------------------|--------|
| Button (Primary) | Input | 主行动按钮（CTA）。视觉权重最高。每屏一个。 | [Main Menu, Pause Menu, Settings] | Draft |
| Button (Secondary) | Input | 次级动作或取消。视觉权重低于 Primary。 | [All modal dialogs, settings screens] | Draft |
| Button (Destructive) | Input | 不可逆动作。执行前必须二次确认。 | [Delete Save, Reset Settings] | Draft |
| Toggle | Input | 二元开/关状态选择。 | [Accessibility settings, audio settings] | Draft |
| Slider | Input | 连续值选择。 | [Volume controls, brightness, text size] | Draft |
| Dropdown / Select | Input | 从离散选项列表中选择。 | [Resolution, language, key binding] | Draft |
| List Item | Layout / Input | 纵向可滚动列表中的可选行。 | [Achievements, quest log, settings list] | Draft |
| Grid Item | Layout / Input | 二维网格中的可选单元。 | [Inventory, ability select, item shop] | Draft |
| Modal Dialog | Feedback / Layout | 需要玩家明确决策的阻塞式覆盖层。 | [Confirmation dialogs, error prompts] | Draft |
| Confirmation Dialog | Feedback / Layout | 专用于破坏性操作确认的模态框。 | [Delete Save, Leave Match, Reset] | Draft |
| Toast / Notification | Feedback | 屏幕角落的非阻塞临时消息。 | [Achievement unlock, autosave notification] | Draft |
| Tooltip | Feedback | 悬停或聚焦时的上下文信息。 | [Inventory items, ability descriptions, settings] | Draft |
| Progress Bar | Feedback / Layout | 线性进度指示器。 | [Loading screen, XP bar, quest progress] | Draft |
| Input Field | Input | 文本输入控件。 | [Player name, search, key binding entry] | Draft |
| Tab Bar | Navigation | 单屏内分栏导航。 | [Character sheet, settings, crafting] | Draft |
| Scroll Container | Layout | 带可见滚动指示的可滚动内容区。 | [Inventory, lore entries, credits] | Draft |
| Inventory Slot | Game-Specific | 背包网格物品槽（空、已填充、已装备、已锁定）。 | [Inventory screen, equipment screen] | Draft |
| Ability / Skill Icon | Game-Specific | 带冷却、充能、锁定态的技能按钮。 | [HUD ability bar, skill tree] | Draft |
| Health / Resource Bar | Game-Specific | 带阈值状态与受击闪烁的数值条。 | [HUD] | Draft |
| Minimap | Game-Specific | 含玩家标记与兴趣点的小地图。 | [HUD] | Draft |
| Quest / Objective Tracker | Game-Specific | 带距离与完成状态的当前目标显示。 | [HUD] | Draft |
| Dialogue Box | Game-Specific | 含说话者标识的 NPC 对话 UI。 | [All dialogue sequences] | Draft |
| Context Action Prompt | Game-Specific | 交互物体附近的“Press X to [action]”提示。 | [World interaction] | Draft |
| Damage Number | Game-Specific | 浮动战斗反馈数字。 | [Combat HUD] | Draft |
| Status Effect Icon | Game-Specific | 带持续时间的增益/减益图标。 | [HUD status bar, enemy health display] | Draft |
| Notification Banner | Game-Specific | 成就、升级、获得物品等横幅通知。 | [Global overlay] | Draft |
| Screen Push | Navigation | 带方向感动画的前进导航。 | [All menu navigation] | Draft |
| Screen Pop (Back) | Navigation | 反向动画的返回导航。 | [All menu navigation] | Draft |
| Screen Replace | Navigation | 不叠加历史栈的屏幕替换。 | [Main Menu to Loading Screen] | Draft |
| Modal Open / Close | Navigation | 使背景变暗的覆盖层开关。 | [All modal dialogs] | Draft |
| Tab Switch | Navigation | 同屏标签内容切换。 | [All tabbed screens] | Draft |
| Focus Management | Navigation | 屏幕开/关/切换时的焦点规则。 | [All screens] | Draft |
| Escape / Cancel | Navigation | 跨平台、跨输入方式的一致返回行为。 | [All screens] | Draft |
| Loading State | Feedback | 屏幕与组件的加载中表现方式。 | [All loading states] | Draft |
| Empty State | Feedback | 空列表/空网格的展示方式。 | [Empty inventory, no quests, no saves] | Draft |
| Error State | Feedback | 错误信息的传达方式。 | [Save failed, network error, invalid input] | Draft |
| Success Confirmation | Feedback | 成功完成动作的确认方式。 | [Settings saved, item crafted, quest turned in] | Draft |
| Optimistic UI | Feedback | 系统确认前先展示“假定成功”。 | [If online features are present] | Draft |

---

## Standard Control Patterns / 标准控件模式

---

#### Button (Primary)

**Category**: Input
**Status**: Draft
**When to Use**：屏幕中最重要的单一动作。“Start Game”“Confirm”“Accept”“Buy”。
同一时刻最多只应有一个 Primary 按钮可见。它回答的是“玩家在这里最可能想做什么？”
**When NOT to Use**：备选/次级动作；需要二次确认的破坏性动作；以及任何非本屏主目标动作。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 全不透明填充，主色取自 art-bible。标签居中。 | — | — | — | — |
| Hovered (mouse) | 亮度 +15%，轻微缩放 1.03x，光标变 pointer | 鼠标移入 | 从 Default 过渡 | 80ms ease-out | [UI hover sound — see Sound Standards] |
| Focused (keyboard/gamepad) | 显示焦点环（2px，偏移 3px，高对比色）。亮度同 Hovered。 | Tab / D-pad 导航 | 从 Default 过渡 | 80ms ease-out | [UI focus sound — same as hover] |
| Pressed | 缩放 0.97x，亮度 -10% | Click / Enter / A (Xbox) / Cross (PS) | 动作在抬起时触发，而非按下时；按下时仅做缩放反馈 | 按下 60ms ease-in；释放 80ms ease-out | [UI confirm sound] |
| Disabled | 40% 透明度，无 pointer，无 hover | — | 无响应 | — | — |
| Loading (post-press) | 标签替换为 spinner；按钮保持 pressed 缩放并进入 disabled | — | 防止重复提交 | 异步操作期间 | — |

**Accessibility**:
- 键盘：Tab 聚焦，Enter 或 Space 激活。必须可从屏幕任一交互元素通过 Tab 序列到达。
- 手柄：D-pad 或左摇杆移动焦点到按钮；A (Xbox) / Cross (PS) 激活。屏幕打开时默认焦点必须落在 Primary 按钮上。
- 屏幕阅读器：按钮需暴露与可见标签一致的可访问名称。Role: "button"。禁用时 State: "dimmed"。激活播报：“[Label] button — [result of action, if known].”
- 色盲：Primary 与 Secondary 不得仅靠颜色区分。Primary 除颜色外还应有更高视觉权重（如填充 vs 描边、或更大尺寸）。
- 最小触控目标：44x44pt（iOS HIG）/ 48x48dp（Android）。即便 PC，只要可能支持触控也应满足。

**Implementation Notes**:
[Godot: Extend `Button` control. Override `_draw()` for custom states rather than
modifying themes mid-state. Use `focus_mode = FOCUS_ALL` to ensure keyboard
focusability. Set `mouse_default_cursor_shape = CURSOR_POINTING_HAND`. For the
scale animation, use a Tween on the `scale` property of the button's parent
Control — scaling the Button itself can clip children.]

---

#### Button (Secondary)

**Category**: Input
**Status**: Draft
**When to Use**：备选或取消动作，如“Back”“Cancel”“Skip”“Maybe Later”。视觉权重应低于 Primary，作为退让选项而非竞争焦点。
**When NOT to Use**：破坏性动作（用 Button (Destructive)）；屏幕最重要动作（用 Button (Primary)）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 描边样式（仅边框、透明填充），次级配色。尺寸或权重略低于 Primary。 | — | — | — | — |
| Hovered | 背景出现 15% 透明填充；边框提亮；缩放 1.02x。 | 鼠标移入 | 从 Default 过渡 | 80ms ease-out | [UI hover sound — softer variant than Primary] |
| Focused | 焦点环，与 Primary 相同规格。 | Tab / D-pad | 从 Default 过渡 | 80ms ease-out | [UI focus sound] |
| Pressed | 缩放 0.97x，填充透明度升至 30% | Click / Enter / B (Xbox) / Circle (PS)（在聚焦态） | 动作在抬起时触发 | 60ms ease-in | [UI cancel/back sound] |
| Disabled | 40% 透明度 | — | 无响应 | — | — |

**Accessibility**：与 Button (Primary) 要求一致。可访问名称必须与可见标签一致。
在同时存在 Primary/Secondary 的对话框中，Secondary 通常还应映射平台“取消”输入（B / Circle / Escape）以及直接聚焦激活。

**Implementation Notes**: [Same as Button (Primary). Where a Primary and Secondary
appear together, ensure Secondary is always positioned consistently — right/bottom
of Primary on horizontal layouts, or below Primary on vertical layouts. Consistency
across screens is more important than per-screen aesthetic preference.]

---

#### Button (Destructive)

**Category**: Input
**Status**: Draft
**When to Use**：任何不可逆且会导致玩家数据或关键进度损失的动作：“Delete Save File”“Reset All Settings”“Leave Match”“Discard Changes”。
视觉表现应在按下前就传达风险。
**When NOT to Use**：可撤销动作，或虽有后果但可恢复的动作。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 描边或填充破坏性颜色（通常低饱和红；需在 accessibility-requirements 中验证色盲兼容）。标签可带警告图标。 | — | — | — | — |
| Hovered / Focused | 行为同 Button (Primary) 的 hover/focus，但采用破坏性配色 | — | — | 80ms | [UI hover sound] |
| Pressed (first press) | **不直接执行动作**。而是打开 Confirmation Dialog pattern（见下文）。按钮本体短促 pulse。 | Click / Enter | 触发 Confirmation Dialog | 100ms pulse | [UI warning sound — distinct from standard confirm] |
| — | 实际执行由 Confirmation Dialog 处理 | — | — | — | — |
| Disabled | 40% 透明度 | — | 无响应 | — | — |

> **Critical rule**：Button (Destructive) **永不直接执行**动作。
> 它必须总是触发 Confirmation Dialog，没有例外。误触玩家必须始终有一次“反悔机会”。
> 破坏性动作跳过确认，会产生最明显的负面社区情绪之一。参见任何游戏论坛中的“误删存档”投诉。

**Accessibility**：屏幕阅读器需播报破坏性语义：“[Label] button — this action cannot be undone.”
除可访问名称外，若支持 `description` 属性，应补充该警告文案。

**Implementation Notes**: [Destructive button triggers a separate Confirmation Dialog scene. Pass the action callback to the dialog — the button itself does not hold the execution logic. This separation prevents accidental execution if the confirmation dialog has a bug.]

---

#### Toggle

**Category**: Input
**Status**: Draft
**When to Use**：二元开关设置，且两种状态都合理、并且当前状态需一眼可见。
“Subtitles: On/Off”“Aim Assist: On/Off”“Notifications: On/Off”。
**When NOT to Use**：超过两个选项（用 Dropdown）；一次性动作而非持久状态（用 Button）；
切换后果复杂到需要说明（应旁置描述字段）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Off / Default | 轨道：低饱和填充。滑块：最左。标签：“Off”或状态标签。 | — | — | — | — |
| Hovered | 轨道提亮 10%；光标 pointer。 | 鼠标移入 | 过渡 | 60ms | [UI hover sound] |
| Focused | 焦点环包裹整个 toggle（轨道+滑块）。 | Tab / D-pad | — | 60ms | [UI focus sound] |
| Pressed / Activated | 滑块滑至右侧；轨道填充切换为激活色；标签变为“On”或激活态标签；状态持久化。 | Click / Enter / A / Cross | 切换状态；触发 onChange；持久化值。 | 滑动 150ms ease-in-out | [Toggle ON sound] |
| Pressed / Deactivated | 滑块回左；轨道恢复低饱和。 | 同上 | 切换状态 | 150ms ease-in-out | [Toggle OFF sound — subtly different from ON] |
| Disabled | 40% 透明度。不可交互。当前状态仍可见。 | — | 无响应 | — | — |

**Accessibility**:
- 键盘/手柄：Space 或 Enter 切换。避免要求方向键（左/右）才能切换——部分用户无法预期该行为。
- 屏幕阅读器：Role: "switch"。State: "on"/"off"。可访问名称不应包含状态（状态会单独播报）。正确：“Subtitles” + state “on”；错误：“Subtitles On”。
- 标签文本（不只是滑块位置）必须随状态更新，照顾无法稳定判断左右位置的玩家。

**Implementation Notes**: [Godot: Use a custom Control or a CheckButton. The
built-in CheckButton provides accessibility role but uses a checkbox-style visual;
a custom slide-toggle animation may be needed for the target art style. Ensure
the slide animation is skipped when motion reduction mode is active — in that
case, snap to final state instantly.]

---

#### Slider

**Category**: Input
**Status**: Draft
**When to Use**：从连续范围中选择数值，允许近似、且范围与相对位置本身有意义。音量（0–100%）、亮度、文本大小。
**When NOT to Use**：精确输入（用 Input Field）；短离散列表选择（用 Dropdown）；二元状态（用 Toggle）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 轨道（全宽）、填充（滑块左侧，表示当前值）、滑块手柄、当前值标签（轨道右侧或滑块上方）。 | — | — | — | — |
| Hovered | 滑块略放大（1.2x），轨道提亮。 | 鼠标移入 | — | 60ms | — |
| Focused | 滑块焦点环，轨道提亮。 | Tab / D-pad | — | 60ms | [UI focus sound] |
| Dragging (mouse) | 滑块随光标移动；填充实时更新；数值标签实时更新。 | Click + drag on thumb | 连续更新值；持续触发 onChange。 | 实时 | [Slider adjust sound — subtle, loops while dragging] |
| Keyboard / D-pad adjust | 每次移动一档（范围 5%，或 1 个离散单位）。 | 聚焦时 Left/Right arrows 或 Left/Right D-pad | 按步进改值；每步触发 onChange。 | 即时 | [Slider step sound — one click per step] |
| Keyboard fast adjust | 大步进（范围 25%）。 | 聚焦时 Page Up / Page Down | 大步进改值 | 即时 | [Same step sound] |
| Released | 数值锁定，onChange 发出最终值。 | Mouse release | — | — | — |
| Disabled | 40% 透明度。不可交互。数值可见。 | — | 无响应 | — | — |

**Accessibility**:
- 键盘：Left/Right 小步进；Page Up/Page Down 大步进；Home/End 跳到最小/最大。
- 屏幕阅读器：Role: "slider"。可访问名称为标签（如 “Music Volume”）。每次变化播报当前值：“Music Volume, 80 percent.” 首次聚焦播报最小/最大值。
- 所有 slider 必须显示数值，不能只靠填充位置表达。

**Implementation Notes**: [Godot `HSlider`: set `step` to appropriate increment.
Override keyboard input to add Page Up/Down support via `_input()`. Bind the
`value_changed` signal to update the displayed numeric label. When motion reduction
mode is enabled, ensure value label updates are the sole feedback — do not suppress
them. Rumble feedback on gamepad slider adjustment is a nice enhancement for
accessibility.]

---

#### Dropdown / Select

**Category**: Input
**Status**: Draft
**When to Use**：从 3-15 个离散选项中选一个，静止态只需展示当前值。分辨率、语言、窗口模式、输入预设。
**When NOT to Use**：二选一（用 Toggle）；超过约 15 项（用完整 List 或可滚动 Select）；需要强比较多个选项（应直接可见，如横向选择器或列表）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Closed / Default | 标签（左）、当前值（右）、下拉箭头（最右）。 | — | — | — | — |
| Hovered | 行背景 10% 透明填充 | 鼠标移入 | — | 60ms | — |
| Focused (closed) | 整行焦点环。 | Tab / D-pad | — | 60ms | [UI focus sound] |
| Opening | 下拉列表出现在下方（靠屏底则改上方）；列表项可见；已选项高亮；焦点移动到列表中已选项。 | Click / Enter / A / Cross | 打开列表 | 100ms ease-out (expand) | [UI expand sound] |
| List item hovered/focused | 列表项高亮 | Mouse / D-pad | — | 60ms | [UI hover sound] |
| List item selected | 列表关闭；闭合态展示新值；触发 onChange。 | Click / Enter / A / Cross on item | 选值并关闭 | 80ms ease-in (collapse) | [UI confirm sound] |
| Dismissed without selecting | 列表关闭；值不变。 | Escape / B / Circle / click outside | 收起 | 80ms | [UI cancel sound] |
| Disabled | 40% 透明度。不可交互。 | — | — | — | — |

**Accessibility**:
- 键盘：展开时 Up/Down 选择项；Enter 选中；Escape 收起；输入首字母跳至首个匹配项。
- 屏幕阅读器：Role: "combobox"。可访问名称是字段标签。需播报 expanded/collapsed。聚焦时播报当前值。每项播报值与位置：“English, 1 of 12.”
- 下拉列表不得遮挡触发控件或当前项（小屏常见失败点）。

**Implementation Notes**: [Godot: Custom implementation using a `Button` (the
closed state) and a `PopupMenu` or a `VBoxContainer` revealed by animation. Native
`OptionButton` provides accessibility but limited visual customization. Ensure
the popup positions itself above the control if it would be clipped by the screen
bottom. Close the popup on `_input` detecting click outside its rect.]

---

#### List Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**：纵向可滚动列表中的单个可选行。成就、任务日志、设置分类、存档槽等。列表是容器，本模式是其中一行。
**When NOT to Use**：二维布局（用 Grid Item）；非可选内容行（移除 hover/focus/pressed 状态）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 全宽行；图标（可选，左）；主标签；副标签/元信息（右或主标签下）；右箭头（如可深入）。 | — | — | — | — |
| Hovered | 行背景高亮 12% 透明度。 | 鼠标移入 | — | 60ms | — |
| Focused | 行焦点环，或行背景 20% 高亮（与平台规范一致）。 | D-pad / Tab | — | 60ms | [UI focus sound] |
| Selected (persistent) | 行背景 25% 高亮；可有选中标识（左边框/勾选）。需与 focused 区分——可选中但未聚焦。 | — | 渲染态 | — | — |
| Pressed / Activated | 短暂亮闪后导航或执行动作 | Click / Enter / A / Cross | 导航或动作 | 80ms flash | [UI confirm sound] |
| Disabled | 40% 透明度。不可交互。 | — | — | — | — |

**Accessibility**:
- 键盘/手柄：Up/Down 或 D-pad 在列表项间移动。到达底部应停止而非循环（除非明确设计循环）。
- 屏幕阅读器：Role: "listitem"，父级 Role: "list"。可访问名称为主标签；副标签可选入 description。播报位置：“Quest Log, 3 of 12.”
- 最小行高：44pt / 48dp（触控）；手柄主平台建议 56px，更舒适。

**Implementation Notes**: [Godot: Use a `VBoxContainer` inside a `ScrollContainer`.
Each row is a custom `Control` or `PanelContainer` with a `_gui_input` override.
For keyboard navigation inside the scroll container, implement custom focus
traversal — Godot's default Tab navigation does not scroll the container to keep
focused items in view. Use `ensure_control_visible()` on the scroll container.]

---

#### Grid Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**：二维网格中的可选单元。背包槽、技能选择、合成素材选择、角色头像选择等。网格是容器，本模式是单元。
**When NOT to Use**：单列内容（用 List Item）；不可选展示单元（移除交互态）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Empty | 空槽视觉（轻边框/虚线边框），区别于 disabled。 | — | — | — | — |
| Populated | 物品图标填满单元；叠加数量（右下，若适用）；品质指示（边框色或覆盖图标）。 | — | — | — | — |
| Hovered | 亮度 +15%；400ms 后显示 tooltip。 | 鼠标移入 | — | 60ms | — |
| Focused | 焦点环（2px，偏移 2px）；亮度同 hovered；tooltip 400ms 显示（手柄可即时）。 | D-pad 导航 | — | 60ms | [UI focus sound] |
| Selected (persistent) | 明确边框（更粗、对比色）；可显示勾选。 | Click / Enter / A / Cross | 选中；可与其他单元 focused 并存。 | 即时 | [UI select sound] |
| Pressed | 0.95x 短缩放后执行动作 | Double-click / Enter / A / Cross | 动作（装备/使用/检视，视上下文定义） | 80ms | [UI confirm sound] |
| Locked | 已填充内容上叠加锁图标；无 hover/focus | — | 不可交互 | — | — |
| Drag source | 单元变暗（50%），光标出现拖拽预览。 | Click + drag (mouse only) | 开始拖拽 | 即时 | [UI grab sound] |
| Drop target (valid) | 单元提亮，显示可接收颜色提示 | 拖拽物悬停 | — | 60ms | — |
| Drop target (invalid) | 红色着色或抖动动画 | 拖拽物悬停无效槽 | — | 60ms | [UI error sound] |

**Accessibility**:
- 键盘/手柄：D-pad 或方向键导航格子。网格需对屏幕阅读器暴露维度，播报行列位置。
- 屏幕阅读器：Role: "gridcell"，父级 "grid"。可访问名称：物品名（空格为 "empty slot"）。状态：选中时 "selected"，锁定时 "dimmed"。位置：“row 2, column 3.”
- Tooltip 必须可通过键盘触发，不能只在 hover 时出现。

**Implementation Notes**: [Godot: `GridContainer` with fixed column count. Each
cell is a custom `Control`. Implement custom D-pad navigation by overriding
`_gui_input` and calculating the cell to the left/right/above/below based on
index and column count. `GridContainer` does not provide this natively.]

---

#### Modal Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**：必须先处理才能继续的决策或确认。该对话框是阻塞式：背景变暗且不可交互。“Are you sure?”、“Your progress will be saved.”、错误状态等。
**When NOT to Use**：非阻塞通知（用 Toast / Notification）；可稍后再看的信息（放入持久帮助系统）；允许玩家继续在后台操作的对话框。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Opening | 背景遮罩从 0 到 60% 透明；面板从 0.9 缩放到 1.0；从中心进入（非边缘滑入）。 | 代码触发 | 焦点移至对话框首个可交互元素（或 Primary 按钮） | 200ms ease-out | [UI modal open sound] |
| Active | 背景不可交互；输入焦点完全在对话框内；玩家不能操作背景。 | 键盘/手柄仅在对话框内导航 | — | — | — |
| Dismissing (confirmed) | 面板放大到 1.1 后淡出；遮罩淡出至 0%。 | Primary 按钮 | 执行动作，焦点回到触发元素 | 180ms | [UI confirm sound] |
| Dismissing (cancelled) | 面板缩到 0.9 后淡出；遮罩淡出至 0%。 | Secondary / Escape / B / Circle | 不执行动作，焦点回到触发元素 | 150ms | [UI cancel sound] |
| Cannot dismiss | 若为阻塞错误，不提供取消路径，只提供解决选项。 | — | — | — | — |

> **Focus trap rule**：模态框打开时，Tab 与 D-pad 导航必须只在模态框内循环。
> 焦点不得移出到背景内容。
> 这是无障碍要求（WCAG 2.1 SC 2.1.2）与 UX 完整性要求。
> 模态框关闭后，焦点必须回到触发该模态框的元素，而不是页面顶部。

**Accessibility**:
- 屏幕阅读器：容器 role 为 "dialog"。可访问名称为对话框标题（必需——即使视觉隐藏也要有标题）。打开时播报标题与首个可聚焦元素；焦点陷阱生效。
- 键盘：Escape 始终映射取消/关闭；Enter 始终映射确认/主动作。
- 减少动态：缩放动画改为瞬时出现/消失；保留 100ms 更快遮罩淡入淡出。

**Implementation Notes**: [Godot: Implement as a `CanvasLayer` with a high layer
value (100+) to ensure it renders above all game content. The background overlay
is a full-screen `ColorRect` at 60% black opacity. Use `grab_focus()` on the
dialog's primary button after the open animation completes. Override `_input()` to
implement the focus trap — intercept Tab navigation and reroute to the dialog's
focusable elements.]

---

#### Confirmation Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**：专用于确认破坏性动作。必须由 Button (Destructive) 触发。始终仅两个选项：确认（标签必须是具体动作，不是“OK”）和取消。
**When NOT to Use**：非破坏性确认；无需决策的错误/通知；超过两个动作的对话框。

> **Label rule**：确认按钮必须用具体动作文案，不可用泛化 “OK” 或 “Yes”。
> 应写“Delete Save File”，而非“OK”；写“Leave Match”，而非“Yes”。
> 这可降低快速阅读困难玩家的误操作。该模式源自 Apple HIG，并由长期可用性研究验证。

**Structure**:
- Title：简短且描述动作。“Delete save file?”，而非“Are you sure?”
- Body：一句话说明后果。“This cannot be undone.”
- Confirm button：Button (Primary)——标签为具体动作，如 “Delete Save File.”
- Cancel button：Button (Secondary)——“Cancel.”
- Default focus：Cancel（更安全默认，降低误触破坏性动作风险）。

**Accessibility**：继承 Modal Dialog 全部无障碍要求。另加：屏幕阅读器播报 “Alert dialog, [title]” 以提示破坏性语境。默认焦点在 Cancel 是**要求**，不是偏好。

**Implementation Notes**: [Confirmation Dialog is a specific instance of Modal
Dialog — implement it as a subclass or as a parameterized scene. The default
focus on Cancel is critical: set `grab_focus()` on the Cancel button, not the
Confirm button, after open animation completes.]

---

#### Toast / Notification

**Category**: Feedback
**Status**: Draft
**When to Use**：简短、非阻塞、无需决策的信息。“Game saved.”“Achievement unlocked.”“Your inventory is full.” 玩家可继续操作；通知自动消失。
**When NOT to Use**：需要决策的信息（用 Modal Dialog）；需要玩家采取动作的错误；玩家绝不能错过的关键信息。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Entering | 从屏幕边缘滑入（通常右下，避开主操作区）；透明度 0→100%。 | 代码触发 | — | 200ms ease-out | [Sound matching notification type — see Sound Standards] |
| Displayed | 全不透明。可选：图标（左）、标题、正文（可选）、关闭按钮 X（可选）。 | 指针悬停暂停自动关闭计时 | 暂停 auto-dismiss | — | — |
| Auto-dismiss | 透明度 100→0 并滑出 | 计时结束（单行默认 5 秒；双行 8 秒） | 出队移除 | 200ms ease-in | — |
| Manual dismiss | 立即淡出并滑出 | 点击/触控 X 或触屏滑动 | 移除 | 150ms | [UI cancel sound, quiet] |
| Queue overflow | 新通知将最旧通知提前顶出 | 旧通知显示中收到新通知 | FIFO 队列，同时最多 3 条 | — | — |

**Accessibility**:
- 屏幕阅读器：Toast 必须无需聚焦即可朗读。HTML 通常用 `role="status"` 或 `role="alert"`；游戏 UI 依赖引擎无障碍通知系统。请在 engine-reference 文档核实支持情况。
- 减少动态：滑入改为仅淡入淡出。
- Toast 不得作为唯一信息渠道来承载“需要玩家行动”的信息。若需行动，必须同时给出持久 UI 元素。
- 自动消失下限 5 秒。认知处理速度不同玩家可能需要更久，建议提供延长到 10 或 15 秒的设置。

**Implementation Notes**: [Godot: Manage a queue of `PanelContainer` scenes in a
`VBoxContainer` anchored to a screen corner. Each toast is instantiated, added to
the container, then auto-removed after a timer. The container should be on a high
`CanvasLayer` (50+) but below modal dialogs (100+). Animate using a `Tween` on
`modulate.a` and `position.x`. When motion reduction is active, skip the position
animation.]

---

#### Tooltip

**Category**: Feedback
**Status**: Draft
**When to Use**：补充可见标签的上下文信息。背包物品描述、角色面板属性解释、无障碍设置说明等。玩家应能访问这些信息，或在不看它的情况下继续。
**When NOT to Use**：玩家**必须**阅读才能完成操作的信息——这类内容应放在标签或正文，不应藏在 tooltip。触屏平台无 hover 时 tooltip 不可发现；纯触控平台请改为信息按钮并打开说明模态框。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Hidden | — | — | — | — | — |
| Hover trigger | — | 鼠标进入元素 | 启动 400ms 延时计时 | — | — |
| Gamepad/keyboard trigger | — | 元素获得焦点 | 启动 300ms 延时（更短，因为导航是主动行为） | — | — |
| Appearing | 提示面板淡入并从 0.95 缩放到 1.0；定位在元素附近（优先上方，靠边自动修正）。 | 计时结束 | 显示 tooltip | 120ms ease-out | — |
| Displayed | 提示可见；标题（可选）；正文；最大宽度 300px；可多行。 | — | — | — | — |
| Hiding | 提示淡出 | 鼠标离开 / 焦点移走 | 隐藏 tooltip | 80ms ease-in | — |

**Accessibility**:
- 屏幕阅读器：tooltip 内容必须无需 hover 也可访问。父元素可访问名称应包含最关键 tooltip 信息；完整文本可放 `description`。元素聚焦时应读出 tooltip 内容。
- 300-400ms 延时是必需的，可避免误触发；即时 tooltip 在手柄导航中会干扰操作。
- tooltip 文本对比度必须满足正文标准（至少 4.5:1）。

**Implementation Notes**: [Godot: Attach a custom `TooltipControl` scene as a
child of the trigger element. Show/hide with a `Timer` node. Position the tooltip
using a `CanvasLayer` to ensure it appears above all other UI. For screen edges,
detect if the tooltip rect extends beyond `get_viewport_rect()` and flip the
position to the opposite side.]

---

#### Progress Bar

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**：朝明确终点推进的线性进度。加载进度、XP 到下一等级、可计数任务进度（“3 of 10 enemies defeated”）、下载进度。
**When NOT to Use**：环形/径向进度（另建 Radial Progress 模式）；频繁上下波动值（用 Health/Resource Bar）；无明确终点的值。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 轨道（全宽背景色）+ 填充（左→右，数值色）+ 数值标签（百分比或 N/M，可在内外）。 | — | — | — | — |
| Value increasing | 填充宽度动画到新值 | 值变化 | 平滑补间 | 300ms ease-out | [Context-dependent — XP gain has a sound; loading has none] |
| Value at maximum | 填充满格；可选完成动画（pulse/glow）。 | 值到 100% | 触发完成事件 | 200ms | [Completion sound if appropriate] |
| Value at zero | 填充隐藏（0 宽）；轨道仍可见。 | — | — | — | — |
| Indeterminate (unknown duration) | 循环动画（填充段左→右重复），用于未知时长加载。 | — | — | 无限循环 | — |

**Accessibility**:
- 屏幕阅读器：Role: "progressbar"。可访问名称要说明“在进展什么”（如 “Experience Points”“Loading”）。播报当前值 + 百分比 + 最大值：“Experience Points, 450 of 1000, 45 percent.” 在显著变化时更新，不要每像素播报。
- 不能只靠填充颜色表达值，必须有数字。
- 不确定进度条应播报“Loading, in progress”，无需播报变化（值未知）。
- 减少动态：不确定态循环动画改静态“loading”指示；平滑填充改即时跳变。

**Implementation Notes**: [Godot: `ProgressBar` built-in with custom theming.
For indeterminate mode, `ProgressBar` does not have a native indeterminate state
in Godot 4.x — implement using a looping `Tween` on a fill element's position.
Ensure the Tween is paused when motion reduction mode is active and a static
indicator is shown instead.]

---

#### Input Field

**Category**: Input
**Status**: Draft
**When to Use**：文本输入。新存档玩家名、列表搜索、按键重映射（特例：显示按键输入而非文本）、精确数字输入。
**When NOT to Use**：已知选项选择（用 Dropdown/List）。主机平台应尽量减少文本输入——虚拟键盘摩擦高。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 输入框边框、占位文本（标签风格、低饱和）、空输入区。 | — | — | — | — |
| Hovered | 边框略提亮 | 鼠标移入 | — | 60ms | — |
| Focused | 边框全亮；光标闪烁（530ms on/530ms off）；占位文本隐藏。 | Tab / click | 主机/移动端打开虚拟键盘 | 即时 | [UI focus sound] |
| Typing | 字符出现，光标前进。 | 键盘输入 | 更新字段值 | 即时 | [Subtle keystroke sound, optional] |
| Value present | 显示已输入值，占位隐藏；非空时显示清空按钮（X，右侧）。 | — | — | — | — |
| Character limit reached | 拒绝继续输入；可选短抖动并改变上限提示色。 | 达到上限后继续输入 | 拒绝字符 | 200ms shake | [UI error sound, subtle] |
| Clear | 字段清空，光标回位，清空按钮消失。 | Click X / gamepad clear input | 清空值 | 即时 | [UI cancel sound, subtle] |
| Validation error | 边框错误色（红，需色盲安全）；字段下方显示错误消息。 | submit 或 blur 时 | 显示错误 | 即时 | [UI error sound] |
| Validated / correct | 边框成功色（绿，需色盲安全）；可选成功图标。 | 校验通过 | — | 即时 | — |
| Disabled | 40% 透明度，不可交互，值仍可见。 | — | — | — | — |

**Accessibility**:
- 键盘：支持标准编辑快捷键（Home, End, Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+Z）。
- 屏幕阅读器：Role: "textbox"。可访问名称应为字段标签（不是 placeholder）。播报当前值；达到字符上限立即播报；校验错误出现时立即播报。
- placeholder 不能作为唯一标签。必须有可见标签（上方或旁侧），否则输入后占位消失会给认知/记忆困难玩家造成困扰。

**Implementation Notes**: [Godot `LineEdit`: set `placeholder_text` for the hint
but always include a visible `Label` node as the field's accessible name. Bind
`text_changed` signal for real-time validation. Bind `text_submitted` for form
submission on Enter. On console, `LineEdit.call("_popup_keyboard")` or use the OS
virtual keyboard API — verify against engine-reference/godot/ for Godot 4.6
console keyboard API specifics.]

---

#### Tab Bar

**Category**: Navigation
**Status**: Draft
**When to Use**：把单屏内容分为多个互斥分区，一次只显示一个。角色面板（Stats / Equipment / Skills）、设置页（Gameplay / Graphics / Audio / Accessibility）。超过 5-6 个 tab 时该模式会崩坏，应考虑侧栏导航。
**When NOT to Use**：超过 6 个 tab；需要同时可见的内容（用布局模式）；不同屏幕间导航（用 Screen Push）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default (inactive tab) | 标签文本，无激活标识。 | — | — | — | — |
| Active tab | 标签 + 激活指示（下划线/填充/高对比背景）；内容区显示该 tab 内容。 | — | — | — | — |
| Hovered (inactive) | tab 背景轻微填充 | 鼠标移入 | — | 60ms | — |
| Focused (keyboard/gamepad) | 标签焦点环。 | Tab（tab 区内）或 D-pad 左右 | — | 60ms | [UI focus sound] |
| Activated | 激活指示过渡到该 tab；内容区过渡（淡入或滑动）。 | Click / Enter / A / Cross | 切换 tab 并更新内容 | 150ms ease | [UI tab switch sound] |
| Gamepad shoulder button | — | L1/R1 (PS) 或 LB/RB (Xbox) | 上/下一个 tab（平台标准） | 150ms | [UI tab switch sound] |

**Accessibility**:
- 键盘：tab 栏内箭头键左右切换；Tab 键把焦点移入下方内容区。遵循 ARIA tab panel 模式。
- 屏幕阅读器：单个 tab role "tab"；容器 role "tablist"；内容区 role "tabpanel"。激活态 "selected"。可访问名称为 tab 标签；tabpanel 由对应 tab 命名。
- 激活 tab 必须有非颜色差异（如下划线、填充样式、字重变化）。

**Implementation Notes**: [Godot: `TabContainer` built-in. For custom visual
styling, implement manually with a `HBoxContainer` of tab buttons and a
`MarginContainer` for content. The shoulder button shortcut (LB/RB) must be
implemented in the screen's `_input()` override — it is not built into Godot's
tab system. Check platform conventions: Xbox uses LB/RB; PlayStation uses L1/R1;
both are the same physical button, so a single binding works.]

---

#### Scroll Container

**Category**: Layout
**Status**: Draft
**When to Use**：内容超出可视容器时。背包列表、世界观文本、制作名单、长设置列表。滚动指示器用于提示“还有内容”。
**When NOT to Use**：可分页场景（密集列表下分页可能更清晰）；无限滚动（必须提供 loading state 与 end state）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Content fits | 不显示滚动条（或按美术要求固定显示满高滚动条）。 | — | — | — | — |
| Scrollable | 显示滚动条（右侧）；滑块尺寸反映可视区/内容比例。 | — | — | — | — |
| Scrolling (mouse) | 内容滚动；滑块同比移动。 | Mouse wheel | 每 tick 滚动 3 行（可配置，跟随 OS） | 平滑 | — |
| Scrollbar drag | 内容滚动，滑块跟随指针。 | Click + drag thumb | 按比例滚动 | 实时 | — |
| Keyboard scroll | 内容按单项高度滚动。 | 容器聚焦且无子项聚焦时 Up/Down | 单位滚动 | 即时 | — |
| Gamepad scroll | 保持聚焦项在可视区内。 | D-pad 导航到视区外项 | 自动滚动以显露聚焦项 | 平滑 150ms | — |
| Scroll top / bottom | 到边界停止；滑块到端点。 | 触达内容边界 | 停止 | — | — |
| Focus follows scroll | 子元素获焦点时，容器确保其完全可见。 | 任意子元素获焦 | 滚动显露该元素 | 200ms ease | — |

**Accessibility**:
- 键盘/手柄：不应要求用户直接操作滚动条；在内部列表项间导航应自动滚动保持可见。
- 屏幕阅读器：容器应播报 “scrollable” 与滚动位置（如 “showing items 5 through 15 of 30”）。需引擎无障碍支持，需在 engine-reference/godot/ 验证。
- 渐隐边缘可作为辅助视觉线索，但不能是唯一“还有内容”的提示；必须有滚动条。

**Implementation Notes**: [Godot `ScrollContainer`: call `ensure_control_visible()`
on the focused child whenever `gui_focus_changed` fires inside the container.
Bind this via a recursive `connect` on the container's `gui_focus_changed` signal.
For smooth scroll animation, use a `Tween` on `scroll_vertical` rather than
setting it directly.]

---

## Game-Specific UI Patterns / 游戏特定 UI 模式

---

#### Inventory Slot

**Category**: Game-Specific
**Status**: Draft
**When to Use**：背包网格中的所有物品容器：空槽、已填充槽、已装备槽、锁定槽。槽是框架，图标是内容。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Empty | 轻量槽边框，无内容。与 disabled 不同。空槽仍可交互（可接收物品）。 | 不要让空槽完全不可见——否则玩家会丢失网格感知 |
| Populated | 物品图标占槽 80%。堆叠数右下（若适用）。品质边框（色盲安全：图标+颜色）。装备标识右上（若已装备）。 | |
| Focused | 焦点环；300ms 后出现 tooltip。 | |
| Selected | 更粗或高对比边框。用于多选场景。 | |
| Drag source | 槽位变暗，拖拽幽灵跟随指针。 | 拖拽细节见 Grid Item |
| Locked | 锁图标覆盖。不可交互。可在锁后 50% 透明显示物品。 | 用于锁定配装槽、DLC 内容等 |
| Highlighted | 动态边框发光（pulse）。用于任务相关或新获得物品。 | 减少动态时以静态徽记替代 pulse |
| Cooldown overlay | 从 12 点位顺时针递减的径向遮罩。 | 仅当槽位表示有冷却的主动物品时适用 |

**Accessibility**：堆叠数与品质级别必须有文本或图标替代，不能仅颜色编码。tooltip 是主要无障碍承载，必须可键盘和屏幕阅读器访问。锁定槽应播报 “locked”。

**Implementation Notes**: [Godot: Custom `Control` node. Quality border implemented as a `StyleBoxFlat` swapped based on rarity — avoid using `modulate` color for quality, as it affects the icon color. Drag and drop implemented via `get_drag_data()` and `can_drop_data()` / `drop_data()` override methods.]

---

#### Ability / Skill Icon

**Category**: Game-Specific
**Status**: Draft
**When to Use**：HUD 技能栏按钮、技能树节点，以及任何需要表达技能可用状态的场景。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Available | 图标全不透明；下方显示按键绑定。 | |
| On cooldown | 从 12 点位顺时针递减径向遮罩；剩余 >2 秒时中央显示数字。 | |
| Charges remaining | 图标下方充能指示（如 3 个实心点=3 层）。屏幕阅读器需有数字替代。 | |
| Out of resource | 图标去饱和至 ~20%；边框与按键标签变暗。需与冷却态区分（资源不足而非时间冷却）。 | |
| Locked / not unlocked | 仅显示剪影（不显示完整美术）；锁徽记；tooltip 可显示解锁条件。 | |
| Active / channeling | 边框 pulse；径向填充显示引导剩余时长。 | |
| Just activated | 短暂缩放 0.9x 后弹回 1.0x（过冲到 1.05x）。 | 例：Guild Wars 2 与 Path of Exile 都使用“按下-回弹”反馈以确认释放。需尊重减少动态设置。 |

**Accessibility**：所有冷却/充能信息必须有数字值（屏幕阅读器无法解析径向遮罩）。冷却数字即为满足项。技能名与描述需通过 tooltip 暴露给屏幕阅读器。

**Implementation Notes**: [Godot: Custom `TextureButton` subclass with overlay
`Control` nodes for cooldown radial and charge pips. The cooldown radial uses a
custom shader on a `ColorRect` rotating a mask — or implement with a
`ProgressBar` styled as circular if engine supports it. Verify against
engine-reference/godot/ for Godot 4.6 shader support for this pattern.]

---

#### Health / Resource Bar

**Category**: Game-Specific
**Status**: Draft
**When to Use**：HUD 中任何持续变化且关键的玩家资源值：生命、法力、耐力、护盾、燃料。

**States and behaviors**:

| Event | Visual | Audio | Duration |
|-------|--------|-------|---------|
| Value decrease (damage) | 填充收缩；短促受击闪（白/红）；幽灵条停留旧值并在 0.5s 内回落到新值（“受击指示”）。 | [Damage taken sound — varies by amount] | 立即下降，幽灵条 500ms 回落 |
| Value increase (heal) | 填充增长；短促治疗闪（绿；需有图标/光效作为非颜色备援）。 | [Heal sound] | 300ms ease-in |
| Below 25% threshold | 填充切换警戒态；边框 pulse（减少动态时用静态徽记）；可选心跳音（若音频是唯一信号，必须配视觉）。 | [Low health sound — loops until above threshold] | 持续 |
| At zero | 条为空；可选短抖动；触发死亡/耗尽事件。 | [Death/depletion sound] | 200ms shake |
| Maximum | 满值并短暂 glow。 | — | 200ms |
| Overflow (shield) | 在自然填充之外显示独立护盾段。 | [Shield gain sound] | 200ms |

**Accessibility**：当前值必须可作为数字访问（tooltip 或常驻显示或两者）。颜色阈值态必须有非颜色备援（图标、闪烁或音视觉警示）。25% 警戒必须有独立于颜色变化的视觉信号。

**Implementation Notes**: [Godot: Two overlapping `ProgressBar` nodes for ghost
bar effect — back bar holds previous value (drains via Tween), front bar holds
current value (updates instantly). Threshold states trigger `StyleBoxFlat` swaps
on the front bar. Ghost bar Tween duration is tunable as a designer parameter.]

---

#### Dialogue Box

**Category**: Game-Specific
**Status**: Draft
**When to Use**：NPC 对话、语音叙事、角色承载式教程文本。所有有“说话者”的对话。

**Structure**：说话者头像或名字标签（框体顶部或左侧）、对话正文、继续/推进提示（右下）。可选：跳过全部、配音指示、字幕指示。

**States and behaviors**:

| State | Visual | Input | Response | Duration |
|-------|--------|-------|----------|---------|
| Line entering | 逐字机效果显示文本；若无障碍选项启用，也可全量淡入。 | — | — | 速度可在无障碍设置中调节 |
| Revealing | 文本动画中；继续提示隐藏或低频 pulse。 | [Any advance input] | 立即跳到本行结尾（显示整行并停止逐字机） | 即时 |
| Line complete | 整行显示完成；继续提示可见并有动画。 | — | — | — |
| Advancing to next line | 继续提示隐藏；文本淡出或擦除；新行开始。 | [Any advance input] — Enter / A / Cross / Space / mouse click | 前进 | 100ms transition |
| Choices appearing | 选项按钮出现在对话下方；继续提示隐藏；导航焦点移到首个选项。 | D-pad / keyboard 选择，Enter / A / Cross 确认 | 选择分支 | 150ms enter animation |
| Closing | 对话框淡出 | 推进最终行后 | 控制权返还玩家 | 200ms |
| Skipping all (if supported) | 简短确认：“Skip dialogue?” | 专用跳过按钮 | 跳至对话后状态 | — |

**Accessibility**：所有语音对话默认开启字幕。逐字机速度是用户设置（见 accessibility-requirements.md）。对话框不得自动推进——节奏由玩家控制。说话者姓名始终显示。所有选项按钮必须可键盘/手柄导航。选项对屏幕阅读器可访问并播报位置。

**Implementation Notes**: [Godot: `RichTextLabel` with `bbcode_enabled` for
formatting. Typewriter effect via `visible_characters` property animated by a
`Timer`. Bind the advance input to a function that either skips typewriter
(sets `visible_characters = -1`) or advances the dialogue state. Speaker name
displayed in a separate `Label` above or beside the box. Dialogue data loaded from
JSON or a dedicated dialogue format (e.g., Dialogic, Yarn Spinner for Godot).]

---

#### Context Action Prompt

**Category**: Game-Specific
**Status**: Draft
**When to Use**：显示在可交互物体附近，提示玩家可执行动作。“Press [A] to open chest.” “Hold [E] to pick up.” 进入交互区域时出现，离开时消失。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Appearing | 淡入并从物体锚点上浮 8px。 | 减少动态时仅淡入，不上浮 |
| Idle | 平台正确按键图标 + 动作标签；输入方式切换时图标同步更新。 | 必须显示平台正确图标，不可硬编码“Press A” |
| Holding (for hold inputs) | 按键图标上的径向填充显示长按进度；标签改为进行时（“Opening...”）。 | |
| Cannot interact (blocked) | 图标变暗；若可知原因则显示原因（“Too heavy”“Need key”）。 | 可选——仅当原因对玩家有意义时展示 |
| Disappearing | 淡出。 | 离开交互区域触发 |

**Accessibility**：按键图标必须配文本标签，不能只靠图标（部分玩家使用自定义标签或自适应控制器）。提示位置必须避免覆盖角色生命值或关键 HUD 信息。

**Implementation Notes**: [Godot: Attach as a `Node3D` child (or `Node2D` child in 2D) of the interactable object. Use a `BillboardMesh` or a `SubViewport` with a UI scene for 3D games — this keeps the prompt facing the camera without code. Update the button icon texture based on `Input.get_joy_name()` or keyboard detection via `InputEventKey` vs `InputEventJoypadButton`. Hold progress implemented as an `AnimationPlayer` or `Tween` on a radial mask shader.]

---

#### Damage Number

**Category**: Game-Specific
**Status**: Draft
**When to Use**：战斗单位上方浮动反馈数字：普通伤害、暴击、治疗、未命中。

**Variants**:

| Variant | Visual | Notes |
|---------|--------|-------|
| Normal damage | 白色、常规字重、中等字号。 | |
| Critical hit | 放大（1.5x）、粗体、橙/黄（需色盲安全）；出现时短暂冲击缩放（1.3x → 1.0x）。 | 例：Path of Exile 与 Diablo IV 都用“尺度爆发”让暴击可通过尺寸而非颜色立刻识别。 |
| Healing | 绿色（需色盲安全：加 `+` 前缀与向上轨迹作为非颜色备援）。 | |
| Miss / Evade | “MISS” 灰色斜体，小号浮动。 | |
| Status damage (DoT) | 更小字号，颜色与状态效果一致。 | |

**Behavior**：数字从命中点上浮 1.0 秒；最后 0.4 秒透明度从 100% 退至 0%；连续高速命中数字应水平错位以避免重叠。屏幕同时显示伤害数字上限：[按游戏定义，通常每角色 8-12 个]。

**Accessibility**：伤害数字是补充反馈，绝不能是理解战斗状态的唯一渠道。生命条是权威来源。需提供“完全关闭伤害数字”选项（部分玩家会被其视觉负担压垮）。关闭后游戏仍需完全可玩。

**Implementation Notes**: [Godot: Pool of `Label3D` (3D games) or `Label` (2D games)
instances recycled via an object pool. Each instance is given a random small
horizontal offset on spawn (±20px) to reduce overlap. Float animation via
`Tween` on `position.y` and `modulate.a`. Critical hit scale-pop via Tween
with `EASE_OUT` on scale followed by linear settle.]

---

## Navigation Patterns / 导航模式

---

#### Screen Push / Pop / Replace

**Category**: Navigation
**Status**: Draft

这三种模式定义屏幕如何进入/退出导航栈。

| Pattern | Trigger | Animation | Stack Behavior | Focus Behavior |
|---------|---------|-----------|---------------|----------------|
| Push | 向更深层导航（打开子菜单/详情） | 新屏从右滑入；旧屏左移并变暗 | 旧屏保留在栈中 | 焦点移到新屏首个可交互元素 |
| Pop (Back) | Back / Escape / B / Circle | 当前屏右滑退出；上一屏从左滑入并恢复亮度 | 当前屏从栈移除 | 焦点返回触发 Push 的元素 |
| Replace | 跳转同级屏（非父子）或加载屏 | 当前淡出，新屏淡入，无方向偏置 | 当前移除，新屏加入 | 焦点移到新屏首个可交互元素 |

**Animation durations**：Push/Pop: 250ms ease-in-out；Replace: 200ms fade out + 200ms fade in。
**Motion reduction**：所有滑动改淡入淡出；时长降至 100ms。

**Implementation Notes**: [Godot: Implement as a `ScreenManager` singleton managing
a stack of `Control` scenes. `push(screen_scene)` instantiates and animates in.
`pop()` animates out and frees. `replace(screen_scene)` calls pop then push without
the intermediate stack state. Use `CanvasLayer` per screen to isolate input handling.
Store the "return focus" element reference before pushing so it can be restored on pop.]

---

#### Focus Management

**Category**: Navigation
**Status**: Draft

> 焦点管理是游戏 UI 中最常见的键盘/手柄无障碍失败点。
> 以下规则必须一致实现。玩家绝不能进入“看不出焦点在哪里”或“Tab/D-pad 没反应”的状态。

| Rule | Description |
|------|-------------|
| Screen open | 焦点放在最合理的可交互元素：通常是 Primary 按钮、首个列表项，或该屏上次访问时的最后焦点。不得落在非交互元素。 |
| Screen close / pop | 焦点返回触发导航的元素（打开屏幕的按钮、被选中的列表项）。若该元素不存在，转到最近的前序可交互元素。 |
| Modal open | 焦点困在模态框内。见 Modal Dialog 模式。 |
| Modal close | 焦点返回触发模态框的元素。 |
| Element disabled | 若当前焦点元素变为 disabled，焦点移至 tab 顺序中的下一个可交互元素。 |
| Element destroyed | 若当前焦点元素从场景移除，焦点移至 tab 顺序中最近的前序元素。 |
| Screen without interactive elements | 焦点管理 no-op；但必须保证 back/cancel 输入仍生效。 |
| Tab key (keyboard) | 按文档顺序（左→右，上→下）前进；Shift+Tab 后退。 |
| D-pad (gamepad) | 按空间方向移动焦点。手柄优先空间导航而非死板 tab 顺序。不得跨不相关区域环绕（如 Tab 栏与内容区应是独立导航区）。 |
| Focus is always visible | 使用键盘/手柄聚焦时，焦点环或等效指示**必须始终可见**。绝不可隐藏焦点指示。 |

---

#### Escape / Cancel

**Category**: Navigation
**Status**: Draft

> “返回”是所有菜单系统中使用频率最高的输入。
> 它必须在所有屏幕严格一致，无例外。

| Platform | Input | Behavior |
|----------|-------|---------|
| PC (keyboard) | Escape | 关闭最上层模态 / 返回导航栈上一屏 / 若在根屏（主菜单）则打开“quit?”确认 |
| PC (gamepad) | B (Xbox layout) / Circle (PS layout) | 同 Escape |
| Xbox | B button | 同 Escape |
| PlayStation | Circle button | 同 Escape |
| Nintendo Switch | B button | 同 Escape（注：Nintendo 部分第一方游戏使用 B 作为确认——本项目需在发版前确认平台规范并记录决策） |

**Rules**：该输入绝不能被重载成“返回/取消”以外行为。若某屏无返回路径（如暂停界面必须做选择），Escape 应无效或提示“必须先选择”，不能擅自跳走。每个屏幕都必须在其 UX 规格中显式定义 Escape 行为。

---

## Feedback and Loading Patterns / 反馈与加载模式

---

#### Loading State

**Category**: Feedback
**Status**: Draft

| Scope | Pattern | Notes |
|-------|---------|-------|
| Full screen (initial load) | 全屏加载页：游戏美术 + 进度条（可确定时优先 determinate）+ 提示文本（可选）。 | 不要使用纯黑空屏。应给玩家可读/可看的内容。 |
| Full screen (level transition) | 先淡黑，再加载页，再从黑淡入新场景。 | 淡出可减少旧场景突然消失的违和。 |
| Component / inline | spinner 或 skeleton placeholder 替换加载中组件；加载完成后不应导致布局跳动。 | 对布局密集内容，skeleton 优于 spinner，可避免布局抖动。 |
| Background / async | 操作未超 2 秒时不显示；超过 2 秒再显示小 spinner 或 toast。 | <2 秒操作不要显示 loading 指示，闪一下比等待更打断。 |

**Accessibility**：加载态需播报 “[Context] loading, please wait.”；完成后播报 “[Context] loaded.”。全屏加载页本身也需可被屏幕阅读器导航，提示文本与 UI 元素都应暴露。

---

#### Empty State

**Category**: Feedback
**Status**: Draft

> 空状态是游戏 UI 中最常被忽视的部分。
> 它决定玩家感受是“这里将来会放我的东西”，还是“这里怎么是空的？坏了吗？”
> 每个空列表/空网格都必须有设计化空状态。空状态不是错误，它是起点。

| Location | Empty State Content | Notes |
|----------|--------------------|----|
| Inventory (no items) | 图标（轻量、大、居中）+ 文案：“Your inventory is empty.” + 次文案：“Items you find on your journey will appear here.” | 不要写“No items found”——“found”暗示搜索失败 |
| Quest Log (no active quests) | 图标 + 文案：“No active quests.” + 次文案：“Talk to characters marked with [quest marker icon] to start a quest.” | 给玩家明确下一步 |
| Achievements (none earned) | 图标 + 文案：“No achievements yet.” + 引导示例：“Try [Action] to earn your first achievement.” | 用游戏化激励，而非仅描述为空 |
| Search results (no matches) | 图标 + 文案：“No results for '[search term]'.” + 次文案：“Try a different search or [browse all].” | 回显搜索词，并给替代动作 |

**Rule**：每个空状态必须至少包含图标、主文案，以及“次文案或动作按钮”。空白容器且无解释永不可接受。

---

#### Error State

**Category**: Feedback
**Status**: Draft

| Error Type | Pattern | Tone |
|-----------|---------|------|
| Input validation (form field) | 字段下方内联错误文案；文案左侧错误图标；字段红边（需图标备援保证色盲安全）。 | 中性且具体——“Username must be 3-20 characters.”，不要“Invalid input.” |
| Operation failed (save error, network error) | 非关键失败用 toast；关键失败（如存档无法写入）用 Modal Dialog。 | 冷静且可操作——“Save failed. Check storage space.”，不要“FATAL ERROR.” |
| System error (crash, data corruption) | 全屏错误页 + 错误码 + 恢复选项（“Restart Game”“Load last save”）+ 支持联系方式。 | 安抚式语气：承认问题、给玩家可控选项，永远不要责怪玩家。 |
| Soft error (action cannot be performed) | toast 或内联提示。 | 解释原因——“Not enough gold”，不要“Action unavailable.” |

**Principle**：错误信息永远不是“玩家的错”。它应告诉玩家“发生了什么、下一步做什么”。移除所有“invalid”泛词，替换为具体说明。

---

## Animation Standards / 动画标准

> 本库所有模式均使用下列统一时序。
> 当模式写“150ms ease-out”时，缓动定义以此处为准。
> 统一时序可让 UI 像一个系统，而不是零散拼接。

| Animation Type | Duration (ms) | Easing Function | Notes |
|---------------|--------------|----------------|-------|
| Button hover / focus enter | 80 | ease-out | 快速利落，不拖沓 |
| Button hover / focus exit | 60 | ease-in | 退出略快于进入 |
| Button press scale down | 60 | ease-in | 立即反馈 |
| Button press scale up (release) | 80 | ease-out | 略带弹性感 |
| Screen push (enter) | 250 | ease-in-out | 从右侧滑入 |
| Screen pop (exit) | 250 | ease-in-out | 向右滑出 |
| Modal open | 200 | ease-out | 从中心展开 |
| Modal close | 150 | ease-in | 收起快于展开 |
| Toast enter | 200 | ease-out | 从屏缘滑入 |
| Toast exit | 200 | ease-in | |
| Tab switch | 150 | ease-in-out | 内容交叉淡入或滑动 |
| Tooltip appear | 120 | ease-out | 前置 300-400ms 延时 |
| Tooltip disappear | 80 | ease-in | |
| Progress bar fill | 300 | ease-out | 值变化平滑动画 |
| Value flash (damage, gain) | 100ms on + 100ms off | linear | 短促吸睛 |
| Dialogue text reveal (per character) | 30ms per character | linear | 可在无障碍设置中调节 |
| HUD damage flash | 80 | linear | 白或红叠层，立即响应 |

**Motion reduction overrides**：启用减少动态模式（见 accessibility-requirements.md）后，所有滑动/缩放动画改为淡入淡出。淡入淡出时长减半。循环动画（不确定加载 spinner、脉冲指示）改为静态等效表现。

---

## Sound Standards / 声音标准

> 每个交互事件都应有声音反馈。
> 声音是主要反馈通道，不是装饰。
> 本表定义的是“事件类别”，具体音频资产见 `docs/sound-bible.md`。
> 该表将交互事件映射到声音类别，确保 sound designer 与 UI programmer 使用同一术语体系。

| Interaction Event | Sound Category | Notes |
|------------------|---------------|-------|
| Button hover / focus | UI Hover | 细微、短促（<80ms），快速导航时不疲劳。Hades 使用高频轻点击，快速导航时可自然融入背景。 |
| Button (Primary) confirm | UI Confirm — Primary | 比 secondary confirm 略更突出，体现“确认前进”。 |
| Button (Secondary) cancel / back | UI Cancel | 音高略向下，表达“返回”。Mass Effect 的返回声是清晰且可辨识的 swoosh。 |
| Button (Destructive) — opening confirmation | UI Warning | 与常规 confirm 明显区分，短促吸睛。 |
| Confirmation dialog — confirm destructive | UI Confirm — Destructive | 更“落地”、更终结，表示动作已执行。 |
| Toggle ON | UI Toggle On | 短促、有弹性、略明亮。Celeste 的无障碍开关有令人满足的 click-on。 |
| Toggle OFF | UI Toggle Off | 同一 click 家族，稍平缓。 |
| Slider adjust | UI Slider | 拖动时细微连续声；D-pad 每步单击。绝不应让人疲劳。 |
| Dropdown open | UI Expand | 短促且有“展开方向感”。 |
| Dropdown close / select | UI Select | 确认语义。 |
| Tab switch | UI Tab | 水平位移感；需与纵向导航声音区分。 |
| Modal open | UI Modal Open | 比常规导航更突出，用于引导注意。 |
| Modal close (cancel) | UI Modal Close | 表达“返回上一语境”。 |
| Toast — informational | UI Notification | 背景级、低侵入。 |
| Toast — achievement | UI Achievement | 有庆祝感但不过长。玩家应感到奖励，而非被打断。 |
| Toast — warning | UI Warning — Toast | 与 error 区分；是提醒，不是惊吓。 |
| Error state | UI Error | 友好但明确，不要刺耳蜂鸣。Dark Souls 的失败提示是低沉闷击，表达“不可行”但不攻击玩家。 |
| Success confirmation | UI Success | 干净、满足。 |
| Ability activate | Gameplay — Ability Activate | 偏“世界内”质感，区别纯 UI 声；属于 game feel（游戏手感）而非菜单手感。 |
| Damage received | Gameplay — Damage | 详见 sound-bible.md。 |
| Item pickup | Gameplay — Item Acquire | 短促、奖励感。 |
| Level up / rank up | Gameplay — Progression | 庆祝感强，突出程度与事件重要性匹配。 |
| Dialogue advance | UI Dialogue | 细微；若开启逐字机，应与其节奏一致。 |

---

## Open Questions / 待解决问题

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [Does the engine's accessibility node system support screen reader announcements for toast notifications without requiring focus? Verify against engine-reference/godot/ for Godot 4.6.] | [ux-designer] | [Before first menu implementation] | [Unresolved] |
| [What is the platform-correct confirm/cancel button mapping for Nintendo Switch release? Nintendo first-party convention differs from Xbox/PlayStation.] | [producer] | [Before platform certification submission] | [Unresolved] |
| [Should damage numbers be pooled as Label3D nodes or rendered in a SubViewport? Verify performance budget in coordination with technical-director.] | [lead-programmer, ux-designer] | [Before combat HUD implementation] | [Unresolved] |
| [What is the maximum number of simultaneous toast notifications before the queue becomes visually overwhelming? Needs playtesting.] | [ux-designer] | [First playtesting session] | [Unresolved] |
| [Add question] | [Owner] | [Deadline] | [Resolution] |
