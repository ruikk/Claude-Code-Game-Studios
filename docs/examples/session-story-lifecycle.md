# 会话示例：完整故事生命周期 — /story-readiness → Implement → /story-done

**背景：** 独立开发者，处于制作阶段的迭代中期。移动系统 GDD 和架构已经完成。`/create-stories` 已生成移动系统核心实现故事。

**初始状态：**
- `design/gdd/movement-system.md` — 已完成，包含全部 8 个章节
- `docs/architecture/movement-adr-001.md` — Status: Accepted
- `production/sprints/sprint-03.md` — 在待办列表中列出 STORY-MOV-001
- `production/stories/STORY-MOV-001.md` — 已存在但尚未验证
- 尚无实现代码

**会话时长：** 约 50 分钟
**轮数：** 13
**结果：** 故事已验证就绪、完成实现，并通过 `/story-done` 验证完成

---

## 阶段 1：故事就绪检查

### 第 1 轮：用户运行就绪检查

**用户：**
> /story-readiness production/stories/STORY-MOV-001.md

### 第 2 轮：代理验证故事

**代理（通过 /story-readiness）：**
> 正在读取 `production/stories/STORY-MOV-001.md`……
>
> **STORY-MOV-001：实现带地形修正的 CharacterBody2D 移动**
>
> 正在运行 4 项验证：
>
> **1. 设计完整性**
> - 已引用 GDD：`design/gdd/movement-system.md` ✅
> - GDD 章节覆盖：详细规则 ✅、公式 ✅、边界情况 ✅
> - 已嵌入 TR-ID：TR-MOV-001 至 TR-MOV-008 ✅
>
> **2. 架构完整性**
> - 已引用 ADR：`docs/architecture/movement-adr-001.md` ✅
> - ADR 状态：**Accepted** ✅ *（如果为 Proposed，则会是 BLOCKED）*
> - 故事中的控制清单版本：`2026-03-10`——当前清单为 `2026-03-10` ✅
>
> **3. 范围清晰度**
> - 验收标准：9 项，全部可度量 ✅
> - 已列出范围外项目：游泳、攀爬 ✅
> - 发现歧义：**1**
>   - ⚠️ 故事说“翻滚方向遵循最后一次输入方向”，但 GDD 说“沿移动方向翻滚”——玩家停止后立即翻滚时两者冲突。请在接手前澄清。
>
> **4. 完成定义**
> - 所需测试：公式函数的单元测试 ✅
> - 集成信号：`on_stamina_event` 必须正确触发 ✅
>
> ---
> **结论：NEEDS WORK**
>
> 必须在实现开始前解决一项歧义。现在解决它后，我就可以将故事标记为就绪，可以吗？

### 第 3 轮：用户解决歧义

**用户：**
> 翻滚使用最后一次移动方向。如果玩家站立不动，则改用当前朝向。

### 第 4 轮：代理更新故事

**代理：**
> 正在更新故事的详细规则章节：
>
> > 翻滚方向：最后一次移动方向。如果翻滚输入发生时速度为零，则使用当前朝向。
>
> 可以将这段内容写入 `production/stories/STORY-MOV-001.md`，并将 Status 设置为 `ready-for-dev` 吗？

**用户：**
> 是

**代理写入更新。故事状态：`ready-for-dev`。**

> **结论：READY**
> 故事已准备好实现。准备构建时即可接手。

---

## 阶段 2：实现

### 第 5 轮：用户开始实现

**用户：**
> 让我们实现 STORY-MOV-001。我准备开始编码了。

### 第 6 轮：代理读取故事和 ADR

**代理（gameplay-programmer）：**
> 正在读取 `production/stories/STORY-MOV-001.md`、`design/gdd/movement-system.md` 和 `docs/architecture/movement-adr-001.md`……
>
> **架构（来自 ADR-001）：**
> - `MovementComponent.gd`——附加到玩家场景，而不是单例
> - 通过 `TerrainLayer.get_modifier(tile_position)` 辅助函数查找地形修正
> - 通过信号发送耐力事件（而不是直接调用 StaminaSystem）
>
> **我提议的文件结构：**
> ```
> src/gameplay/movement/
>   movement_component.gd       # CharacterBody2D logic, state machine
>   terrain_modifier_table.gd   # Const table: terrain_type -> {speed_mod, drain_mod}
> tests/unit/
>   test_movement_formulas.gd   # Unit tests for speed/drain calculations
> ```
>
> 可以按这个结构继续吗？

**用户：**
> 是

### 第 7 轮：代理实现并展示关键代码

**代理：**
> 正在实现 `movement_component.gd`。写入文件前，下面是供你审查的关键摘录：
>
> ```gdscript
> class_name MovementComponent
> extends Node
>
> signal stamina_event(type: String, amount: float)
>
> @export var base_walk_speed: float = 120.0
> @export var run_multiplier: float = 1.7
> @export var stamina_drain_walk: float = 2.0
> @export var stamina_drain_run: float = 6.0
> @export var stamina_cost_roll: float = 15.0
>
> var _is_carrying_heavy: bool = false
>
> func _physics_process(delta: float) -> void:
>     var terrain_mod := _get_terrain_modifier()
>     var effective_speed := _calculate_speed(terrain_mod)
>     # ...
> ```
>
> 所有值均为 `@export`，没有硬编码。你希望采用这个方向吗？

**用户：**
> 看起来不错。写入吧。

### 第 8-9 轮：代理写入文件并运行测试

**代理写入：**
- `src/gameplay/movement/movement_component.gd`
- `src/gameplay/movement/terrain_modifier_table.gd`
- `tests/unit/test_movement_formulas.gd`

**代理：**
> 文件已写入。正在运行可用的 lint 检查……
>
> 没有错误。已创建测试文件，包含 6 个单元测试，覆盖：
> - 行走速度公式（3 种地形）
> - 奔跑速度公式
> - 耐力消耗计算
> - 翻滚耐力消耗（包含速度为零和不为零的边界情况）
>
> 需要手动测试：无敌帧、斜坡阻挡、地形集成（需要运行场景）。

---

## 阶段 3：故事完成

### 第 10 轮：用户手动测试并运行 /story-done

**用户：**
> 我已经在场景中测试过了，一切正常。/story-done production/stories/STORY-MOV-001.md

### 第 11 轮：代理运行完成审查

**代理（通过 /story-done）：**
> 正在读取故事、GDD 和 ADR……
>
> **阶段 1：已定位故事** ✅ `production/stories/STORY-MOV-001.md`
>
> **阶段 2：验收标准验证**
>
> | # | 标准 | 验证方式 | 状态 |
> |---|-----------|--------------|--------|
> | 1 | 普通地面上的行走速度正确 | 自动：公式单元测试通过 | ✅ AUTO |
> | 2 | 奔跑速度正确 | 自动：公式单元测试通过 | ✅ AUTO |
> | 3 | 耐力为 0 时取消奔跑 | 手动：用户确认 | ✅ MANUAL |
> | 4 | 翻滚无敌帧正常工作 | 手动：用户确认 | ✅ MANUAL |
> | 5 | 地形修正正确应用 | 手动：用户确认 | ✅ MANUAL |
> | 6 | 携带重物时禁用奔跑 | 自动：尚不可测试（库存未集成） | ⏳ DEFERRED |
> | 7 | 耐力信号正确触发 | 自动：等待集成测试 | ⏳ DEFERRED |
> | 8 | 没有硬编码值 | 自动：搜索魔法数字 → 找到 0 个 | ✅ AUTO |
> | 9 | 超过 45° 的斜坡阻止移动 | 手动：用户确认 | ✅ MANUAL |
>
> **阶段 3：GDD/ADR 偏差**
>
> 正在根据 TR-ID 扫描实现……
>
> - TR-MOV-001 至 TR-MOV-007：✅ 已按规格实现
> - TR-MOV-008（携带重物信号）：⚠️ ADVISORY——延期至库存集成故事。不是偏差，只是当前无法验证。
>
> **阶段 4：清单过时检查**
>
> 故事控制清单版本 `2026-03-10` 与当前清单 `2026-03-10` 匹配。✅
>
> **阶段 5：代码审查提示**
>
> 建议在标记完成前运行 `/code-review src/gameplay/movement/`。不构成阻塞。
>
> ---
> **完成报告：COMPLETE WITH NOTES**
>
> 故事已完成。有两条标准延期至库存集成——记录为延期，而不是阻塞。
>
> 可以将故事状态更新为 `Status: Complete`、添加完成备注，并更新 `production/sprint-status.yaml` 吗？

**用户：**
> 是

### 第 12 轮：代理关闭故事

**代理写入：**
- 故事 `Status: Complete` + 完成备注（记录延期标准）
- `production/sprint-status.yaml`——将 STORY-MOV-001 设置为 `done`

**代理：**
> STORY-MOV-001 已关闭。
>
> **已记录延期标准**（将在库存集成故事中自动显示）：
> - 携带重物时禁用奔跑（需要库存信号）
> - 耐力信号集成测试（需要耐力系统）
>
> **迭代中的下一个就绪故事：**
> - STORY-MOV-002：耐力系统——这是逻辑上的下一个故事（下游依赖现已解除阻塞）
> - STORY-HUD-001：移动 HUD 指示器——同样已解除阻塞
>
> 对你接下来选择的故事运行 `/story-readiness`。

---

## 这个示例展示的内容

- **就绪门禁发现真实问题**：如果没有 `/story-readiness`，翻滚方向歧义会导致实现后期才做决定
- **ADR 状态是硬门禁**：如果 `movement-adr-001.md` 是 `Proposed` 而不是 `Accepted`，故事会处于 `BLOCKED`，实现不会开始
- **延期标准**：并非每条验收标准都能在故事关闭时验证——`/story-done` 跟踪延期项目，而不是阻止完成
- **TR-ID 引用**：故事存储 `TR-MOV-001` 等 ID，而不是引用 GDD 原文——避免 GDD 后续润色措辞时产生错误偏差标记
- **sprint-status.yaml**：迭代状态的唯一事实来源，由 `/story-done` 更新并由 `/sprint-status` 读取
- **清单版本检查**：确保故事的实现指南没有偏离当前架构决策
