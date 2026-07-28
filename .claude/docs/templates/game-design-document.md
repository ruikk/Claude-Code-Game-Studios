# [机制/系统名称]

> **状态**: 草稿 | 评审中 | 已批准 | 已实现
> **作者**: [Agent 或人员]
> **最后更新**: [日期]
> **最后验证**: [日期 — 此文档上次与当前设计核对并确认准确的时间]
> **实现支柱（Implements Pillar）**: [该机制支撑的游戏支柱]

## 摘要（Summary）

[2–3 句话：这个系统是什么、它为玩家带来什么、以及它为什么存在于这款游戏中。为分层上下文加载而写——当技能扫描 20 份游戏设计文档时，会用本节判断是否继续阅读。避免术语堆砌。]

> **快速参考（Quick reference）** — 层级: `[Foundation | Core | Feature | Presentation]` · 优先级: `[MVP | Vertical Slice | Alpha | Full Vision]` · 关键依赖: `[System names or "None"]`

## 概述（Overview）

[用一段话向完全不了解项目的人解释该机制。它是什么？玩家会做什么？它为什么存在？]

## 玩家幻想（Player Fantasy）

[玩家在参与此机制时应该“感受到”什么？它服务的情绪体验或力量幻想是什么？本节将指导下方所有细节决策。]

## 详细规则（Detailed Rules）

### 核心规则（Core Rules）

[精确、无歧义的规则。程序员应能在不追问的情况下实现本节。顺序流程使用编号规则，属性使用项目符号。]

### 状态与转换（States and Transitions）

[若此系统存在状态（如武器状态、状态效果、阶段），请记录每一个状态，以及状态间每一种有效转换。]

| State | Entry Condition | Exit Condition | Behavior |
|-------|----------------|----------------|----------|

### 与其他系统的交互（Interactions with Other Systems）

[该系统如何与战斗、背包、成长、UI 交互？
对每项交互，请明确接口：哪些数据流入、哪些流出，以及各方职责归属。]

## 公式（Formulas）

[该系统使用的全部数学公式。对每个公式：]

### [公式名称 Formula Name]

```text
result = base_value * (1 + modifier_sum) * scaling_factor
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_value | float | 1-100 | data file | The base amount before modifiers |
| modifier_sum | float | -0.9 to 5.0 | calculated | Sum of all active modifiers |
| scaling_factor | float | 0.5-2.0 | data file | Level-based scaling |

**预期输出范围（Expected output range）**: [min] to [max]
**边界情况（Edge case）**: 当 modifier_sum < -0.9 时，将其钳制为 -0.9，以防结果为负。

## 边界情况（Edge Cases）

[明确记录在非常规情境下会发生什么。每个边界情况都应有清晰处理结果。]

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| [What if X is zero?] | [This happens] | [Because of this reason] |
| [What if both effects trigger?] | [Priority rule] | [Design reasoning] |

## 依赖项（Dependencies）

[列出该机制依赖的所有系统，以及依赖该机制的系统。]

| System | Direction | Nature of Dependency |
|--------|-----------|---------------------|
| [Combat] | This depends on Combat | Needs damage calculation results |
| [Inventory] | Inventory depends on this | Provides item effect data |

## 调优旋钮（Tuning knobs）

[所有应可调整以便平衡的数值。包括当前值、安全范围，以及在极端值下的影响。]

| Parameter | Current Value | Safe Range | Effect of Increase | Effect of Decrease |
|-----------|--------------|------------|-------------------|-------------------|

## 视觉/音频需求（Visual/Audio Requirements）

[该机制需要哪些视觉与音频反馈？]

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|----------------|---------------|----------|

## 手感（Game Feel）

> **为何本节与 Visual/Audio Requirements 分离**：Visual/Audio Requirements 记录“发生什么反馈事件”
> （即事件到资产的表格映射）；Game Feel 记录“机制操作起来的感觉如何”——包括响应性、重量感、吸附感以及交互的动觉品质。
> 这些是对时序、帧数据与控制体感的设计目标。手感必须在设计阶段明确，因为它会驱动动画预算、输入处理架构与 hitbox 时序。
> 实现后再补手感目标代价很高，且常需要底层返工。

### 手感参考（Feel Reference）

[指定一个能体现目标手感的具体游戏、机制或时刻。要精确——引用“具体机制”，而非仅游戏名。解释你借鉴的品质。可选：加入反向参考（不应像什么）。]

> 示例："应该感觉像 黑暗之魂 的武器挥动——沉重、有力、预示明确，但击中时很爽。不像早期 光环 的近战那样漂浮。"

### 输入响应性（Input Responsiveness）

[按动作定义从玩家输入到可见/可听响应的最大可接受延迟。]

| Action | Max Input-to-Response Latency (ms) | Frame Budget (at 60fps) | Notes |
|--------|-----------------------------------|------------------------|-------|
| [Primary action] | [e.g., 50ms] | [e.g., 3 frames] | |
| [Secondary action] | | | |

### 动画手感目标（Animation Feel Targets）

[本机制中每个动画的帧数据目标。Startup = 动作生效前的起手/蓄力；
Active = 动作“生效中”的帧（hitbox 生效、技能触发等）；
Recovery = 动作结算后的硬直/脆弱帧。]

| Animation | Startup Frames | Active Frames | Recovery Frames | Feel Goal | Notes |
|-----------|---------------|--------------|----------------|-----------|-------|
| [e.g., Light attack] | | | | [e.g., Snappy, low commitment] | |
| [e.g., Heavy attack] | | | | [e.g., Weighty, high commitment] | |

### 冲击时刻（Impact Moments）

[定义机制中的“标点时刻”——反馈强度峰值，让动作显得有分量。每个高风险高收益事件至少应有一条记录。]

| Impact Type | Duration (ms) | Effect Description | Configurable? |
|-------------|--------------|-------------------|---------------|
| Hit-stop (freeze frames) | [e.g., 80ms] | [Freeze both objects on contact] | Yes |
| Screen shake | [e.g., 150ms] | [Directional, decaying] | Yes |
| Camera impact | | | |
| Controller rumble | | | |
| Time-scale slowdown | | | |

### 重量与响应画像（Weight and Responsiveness Profile）

[用简短文字描述整体手感目标。回答以下问题：]

- **重量感（Weight）**: 更偏厚重且审慎，还是轻快且反应灵敏？
- **玩家控制感（Player control）**: 玩家在每个时刻的可控感有多高？
  （高控制 = 可在动作中途修正；低控制 = 承诺度高、基于惯性）
- **吸附/利落感（Snap quality）**: 更偏清脆二元，还是平滑模拟？
- **加速模型（Acceleration model）**: 移动/动作是瞬时起步（街机感），还是从零爬升（拟真感）？减速同理。
- **失败质感（Failure texture）**: 玩家失误时，机制给人的感受是公平还是惩罚？玩家能否读懂“为什么失败”？

### 手感验收标准（Feel Acceptance Criteria）

[无需测量仪器、由 playtest（玩家测试）人员即可验证的具体标准。
这些是主观目标，但要写得足够精确，以获得一致判断。]

- [ ] [e.g., "Combat feels impactful — playtesters comment on weight unprompted"]
- [ ] [e.g., "No reviewer uses the words 'floaty', 'slippery', or 'unresponsive'"]
- [ ] [e.g., "Input latency is imperceptible at target 60fps framerate"]
- [ ] [e.g., "Hit-stop reads as satisfying, not as lag or stutter"]

## UI 需求（UI Requirements）

[哪些信息需要在何时展示给玩家？]

| Information | Display Location | Update Frequency | Condition |
|-------------|-----------------|-----------------|-----------|

## 交叉引用（Cross-References）

[声明对其他游戏设计文档中“具体机制、数值或规则”的所有显式依赖。
该表会被 `/review-all-gdds` Phase 2c 进行机器校验——它用可验证声明替代隐式文字引用。若你在本文任意位置引用了其他系统行为，必须在此出现。]

| This Document References | Target GDD | Specific Element Referenced | Nature |
|--------------------------|-----------|----------------------------|--------|
| [e.g., "combo multiplier feeds score"] | `design/gdd/score.md` | `combo_multiplier` output value | Data dependency |
| [e.g., "death triggers respawn"] | `design/gdd/respawn.md` | Death state transition | State trigger |
| [e.g., "stamina gates dodge"] | `design/gdd/stamina.md` | Stamina depletion rule | Rule dependency |

> **关于 “Nature” 的说明**：使用以下之一 — `Data dependency`（我们消费其输出）、
> `State trigger`（其状态变化触发我们的行为）、`Rule dependency`（我们的规则假设其规则也成立）、`Ownership handoff`（我们将某个值的所有权移交给它们）。

## 验收标准（Acceptance Criteria）

[可测试标准，用于确认该机制按设计正常工作。]

- [ ] [Criterion 1: specific, measurable, testable]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
- [ ] Performance: System update completes within [X]ms
- [ ] No hardcoded values in implementation

## 未决问题（Open Questions）

[尚未决策的事项。每个问题都应有负责人和截止日期。]

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
