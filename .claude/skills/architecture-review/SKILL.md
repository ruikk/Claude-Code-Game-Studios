---
name: architecture-review
description: "根据所有 GDD 验证项目架构的完整性与一致性。构建可追溯性矩阵，将每项 GDD 技术需求映射到 ADR，识别覆盖缺口，检测 ADR 间冲突，验证所有决策中的引擎兼容性是否一致，并给出 PASS/CONCERNS/FAIL 结论。相当于架构领域的 /design-review。"
argument-hint: "[focus: full | coverage | consistency | engine | single-gdd path/to/gdd.md]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
agent: technical-director
model: opus
---

# 架构审查

架构审查用于验证完整的架构决策集合是否覆盖所有游戏设计需求、内部是否一致，
以及是否正确面向项目锁定的引擎版本。它是 Technical Setup 与 Pre-Production
之间的质量门禁。

**参数模式：**
- **无参数 / `full`**：完整审查，即所有阶段
- **`coverage`**：仅检查可追溯性，即哪些 GDD 需求没有 ADR
- **`consistency`**：仅检测 ADR 间冲突
- **`engine`**：仅审计引擎兼容性
- **`single-gdd [path]`**：审查某个指定 GDD 的架构覆盖情况
- **`rtm`**：需求可追溯性矩阵（Requirements Traceability Matrix），在标准矩阵基础上
  增加故事文件路径和测试文件路径；输出完整的
  GDD 需求 → ADR → Story → Test 链到
  `docs/architecture/requirements-traceability.md`。在已有故事和测试的 Production
  阶段使用。

---

## 阶段 1：加载所有内容

### 阶段 1a — L0：摘要扫描（快速、低 token 消耗）

读取任何完整文档之前，使用 Grep 从所有 GDD 和 ADR 中提取 `## Summary` 章节：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 4
Grep pattern="## Summary" glob="docs/architecture/adr-*.md" output_mode="content" -A 3
```

对于 `single-gdd [path]` 模式：使用目标 GDD 的摘要识别哪些 ADR 引用了同一系统
（在 ADR 中 Grep 系统名称），然后只完整读取这些 ADR。完全跳过与其无关的 GDD。

对于 `engine` 模式：只完整读取 ADR，引擎检查不需要 GDD。

对于 `coverage` 或 `full` 模式：继续完整读取以下所有内容。

### 阶段 1b — L1/L2：加载完整文档

根据当前模式读取所有适用输入：

### 设计文档
- `design/gdd/` 中所有范围内的 GDD，每个文件都必须完整读取
- `design/gdd/systems-index.md`，权威系统清单

### 架构文档
- `docs/architecture/` 中所有范围内的 ADR，每个文件都必须完整读取
- `docs/architecture/architecture.md`（如果存在）

### 引擎参考资料
- `docs/engine-reference/[engine]/VERSION.md`
- `docs/engine-reference/[engine]/breaking-changes.md`
- `docs/engine-reference/[engine]/deprecated-apis.md`
- `docs/engine-reference/[engine]/modules/` 中的所有文件

### 项目标准
- `.claude/docs/technical-preferences.md`

报告数量："已加载 [N] 个 GDD、[M] 个 ADR，引擎：[名称 + 版本]。"

如果 `docs/consistency-failures.md` 存在，**还要读取该文件**。提取 Domain 与审查中
系统相匹配的条目（Architecture、Engine 或正在覆盖的任意 GDD domain）。在阶段 4
冲突检测输出顶部，以“已知易冲突领域”注释呈现反复出现的模式。

---

## 阶段 2：从每个 GDD 中提取技术需求

### 预加载 TR 注册表

提取任何需求之前，如果 `docs/architecture/tr-registry.yaml` 存在，先读取它。
按 `id` 和规范化后的 `requirement` 文本（小写、去除首尾空白）索引现有条目。
这可防止不同审查轮次之间的 ID 重新编号。

对于提取出的每项需求，匹配规则如下：
1. 与同一系统的现有注册表条目**完全匹配/近似匹配** → 原样复用该条目的 TR-ID。
   仅当 GDD 措辞发生变化（意图相同、表述更清晰）时，才更新注册表中的
   `requirement` 文本，并添加 `revised: [date]` 字段。
2. **无匹配** → 分配新 ID：该系统下一个可用的 `TR-[system]-NNN`，从现有最大
   序号 + 1 开始。
3. **存在歧义**（部分匹配、意图不清）→ 询问用户：
   > “'[new requirement text]' 与
   > `TR-[system]-NNN: [existing text]` 指的是同一项需求，还是一项新需求？”
   用户回答：“同一项需求”（复用 ID）或“新需求”（分配新 ID）。

对于注册表中 `status: deprecated` 的任何需求，跳过它。
该需求已被有意从 GDD 中移除。

读取每个 GDD，并提取所有**技术需求**，即架构为保证系统正常工作而必须提供的内容。
技术需求是指任何隐含了具体架构决策的陈述。

要提取的类别：

| 类别 | 示例 |
|----------|---------|
| **数据结构** | “每个实体都具有生命值、最大生命值和状态效果” → 需要组件/数据模式 |
| **性能约束** | “碰撞检测必须在 200 个实体下以 60fps 运行” → 物理预算 ADR |
| **引擎能力** | “角色动画使用反向运动学” → IK 系统 ADR |
| **跨系统通信** | “伤害系统同时通知 UI 和音频” → 事件/信号架构 ADR |
| **状态持久化** | “玩家进度在不同会话间保留” → 存档系统 ADR |
| **线程/时序** | “AI 决策在主线程之外执行” → 并发 ADR |
| **平台要求** | “支持键盘、手柄和触控” → 输入系统 ADR |

为每个 GDD 生成结构化列表：

```
GDD: [filename]
系统: [system name]
技术需求:
  TR-[GDD]-001: [requirement text] → 领域: [Physics/Rendering/etc]
  TR-[GDD]-002: [requirement text] → 领域: [...]
```

这将成为**需求基线**，即架构必须覆盖内容的完整集合。

---

## 阶段 3：构建可追溯性矩阵

针对阶段 2 提取的每项技术需求搜索 ADR：

1. 读取每个 ADR 的“GDD Requirements Addressed”章节
2. 检查它是否明确引用该需求或其 GDD
3. 检查 ADR 的决策文本是否隐式覆盖该需求
4. 标记覆盖状态：

| 状态 | 含义 |
|--------|---------|
| ✅ **已覆盖** | 某个 ADR 明确处理了此需求 |
| ⚠️ **部分覆盖** | 某个 ADR 部分覆盖此需求，或覆盖情况存在歧义 |
| ❌ **缺口** | 没有 ADR 处理此需求 |

构建完整矩阵：

```
## 可追溯性矩阵

| 需求 ID | GDD | 系统 | 需求 | ADR 覆盖 | 状态 |
|---------------|-----|--------|-------------|--------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox 检测 < 1 帧 | ADR-0003 | ✅ |
| TR-combat-002 | combat.md | Combat | 连击窗口时序 | — | ❌ GAP |
| TR-inventory-001 | inventory.md | Inventory | 持久化物品存储 | ADR-0005 | ✅ |
```

统计总数：X 项已覆盖、Y 项部分覆盖、Z 项存在缺口。

---

## 阶段 3b：故事与测试关联（仅 RTM 模式）

*除非参数为 `rtm`，或参数为 `full` 且已有故事，否则跳过此阶段。*

本阶段扩展阶段 3 的矩阵，加入实现每项需求的故事以及验证它的测试，从而生成完整的
需求可追溯性矩阵（RTM）。

### 步骤 3b-1 — 加载故事

Glob `production/epics/**/*.md`（排除 EPIC.md 索引文件）。对于每个故事文件：
- 从故事的 Context 章节提取 `TR-ID`
- 提取故事文件路径、标题和 Status
- 提取 `## Test Evidence` 章节，即声明的测试文件路径

### 步骤 3b-2 — 加载测试文件

Glob `tests/unit/**/*_test.*` 和 `tests/integration/**/*_test.*`。
构建索引：系统 → [测试文件路径]。

对于步骤 3b-1 中的每个测试文件路径，通过 Glob 确认文件是否确实存在。
如果声明的路径不存在，标记为 MISSING。

### 步骤 3b-3 — 构建扩展 RTM

对于阶段 3 矩阵中的每个 TR-ID，添加：
- **Story**：引用此 TR-ID 的故事文件路径（可能有多个）
- **Test File**：故事 Test Evidence 章节中声明的测试文件路径
- **Test Status**：COVERED（测试文件存在）/ MISSING（已声明路径但未找到）/
  NONE（未声明测试路径，故事类型可能为 Visual/Feel/UI）/
  NO STORY（需求尚无故事，即 pre-production 缺口）

扩展矩阵格式：

```
## 需求可追溯性矩阵（RTM）

| TR-ID | GDD | 需求 | ADR | Story | Test File | Test Status |
|-------|-----|-------------|-----|-------|-----------|-------------|
| TR-combat-001 | combat.md | Hitbox < 1 帧 | ADR-0003 | story-001-hitbox.md | tests/unit/combat/hitbox_test.gd | COVERED |
| TR-combat-002 | combat.md | 连击窗口 | — | story-002-combo.md | — | NONE (Visual/Feel) |
| TR-inventory-001 | inventory.md | 持久化存储 | ADR-0005 | — | — | NO STORY |
```

RTM 覆盖摘要：
- COVERED：[N]，具有 ADR + story + passing test 的需求
- MISSING test：[N]，故事存在但未找到测试文件
- NO STORY：[N]，具有 ADR 但尚无故事的需求
- NO ADR：[N]，缺少架构覆盖的需求（来自阶段 3 的缺口）
- 完整链路完成（COVERED）：[N/total]（[%]）

---

## 阶段 4：检测 ADR 间冲突

将每个 ADR 与所有其他 ADR 比较，以检测矛盾。以下情况视为冲突：

- **数据所有权冲突**：两个 ADR 都声称独占同一份数据
- **集成契约冲突**：ADR-A 假设系统 X 具有接口 Y，但 ADR-B 为系统 X 定义了不同接口
- **性能预算冲突**：ADR-A 为物理分配 N ms，ADR-B 为 AI 分配 N ms，两者合计超过总帧预算
- **依赖循环**：ADR-A 规定系统 X 在 Y 之前初始化；ADR-B 规定 Y 在 X 之前初始化
- **架构模式冲突**：ADR-A 对某子系统使用事件驱动通信；ADR-B 对同一子系统使用直接函数调用
- **状态管理冲突**：两个 ADR 都定义了对同一游戏状态的权威性
  （例如 Combat ADR 和 Character ADR 都声称拥有生命值）

对于发现的每个冲突：

```
## 冲突：[ADR-NNNN] vs [ADR-MMMM]
类型：[数据所有权 / 集成 / 性能 / 依赖 / 模式 / 状态]
ADR-NNNN 声明：[...]
ADR-MMMM 声明：[...]
影响：[如果两者都按现有描述实现，会发生什么问题]
解决方案选项：
  1. [选项 A]
  2. [选项 B]
```

### ADR 依赖顺序

完成冲突检测后，分析所有 ADR 的依赖图：

1. 从每个 ADR 的“ADR Dependencies”章节中**收集所有 `Depends On` 字段**
2. **拓扑排序**：确定正确的实现顺序；无依赖的 ADR 最先（Foundation），依赖它们的 ADR 随后，依此类推
3. **标记未解决的依赖**：如果 ADR-A 的“Depends On”字段引用了仍为 `Proposed` 或不存在的 ADR，则标记：
   ```
   ⚠️  ADR-0005 依赖 ADR-0002，但 ADR-0002 仍为 Proposed。
       在 ADR-0002 变为 Accepted 之前，无法安全实现 ADR-0005。
   ```
4. **循环检测**：如果 ADR-A 依赖 ADR-B，而 ADR-B 又直接或间接依赖 ADR-A，将其标记为 `DEPENDENCY CYCLE`：
   ```
   🔴 DEPENDENCY CYCLE: ADR-0003 → ADR-0006 → ADR-0003
      必须先打破此循环，才能实现其中任何一个 ADR。
   ```
5. **输出建议的实现顺序**：
   ```
   ### 建议的 ADR 实现顺序（拓扑排序）
   Foundation（无依赖）：
     1. ADR-0001: [title]
     2. ADR-0003: [title]
   依赖 Foundation：
     3. ADR-0002: [title]（需要 ADR-0001）
     4. ADR-0005: [title]（需要 ADR-0003）
   Feature 层：
     5. ADR-0004: [title]（需要 ADR-0002、ADR-0005）
   ```

---

## 阶段 5：交叉检查引擎兼容性

跨所有 ADR 检查引擎一致性：

### 版本一致性
- 所有提及引擎版本的 ADR 是否使用同一版本？
- 如果任何 ADR 是针对较旧引擎版本编写的，将其标记为可能已过时

### Post-Cutoff API 一致性
- 收集所有 ADR 中的“Post-Cutoff APIs Used”字段
- 对每项 API 使用相关模块参考文档进行验证
- 检查是否有两个 ADR 对同一 post-cutoff API 作出相互矛盾的假设

### 已弃用 API 检查
- 在所有 ADR 中 Grep `deprecated-apis.md` 列出的 API 名称
- 标记引用了已弃用 API 的任何 ADR

### 缺少引擎兼容性章节
- 列出所有完全缺少 Engine Compatibility 章节的 ADR
- 这些是盲区，其引擎假设未知

输出格式：
```
### 引擎审计结果
引擎：[名称 + 版本]
具有 Engine Compatibility 章节的 ADR：X / 共 Y 个

已弃用 API 引用：
  - ADR-0002：使用 [deprecated API]，自 [version] 起弃用

过时版本引用：
  - ADR-0001：针对 [older version] 编写，当前项目版本为 [version]

Post-Cutoff API 冲突：
  - ADR-0004 和 ADR-0007 都使用 [API]，但假设不兼容
```

---

### 咨询引擎专家

完成上述引擎审计后，通过 Task 启动**主要引擎专家**，获取领域专家的第二意见：
- 读取 `.claude/docs/technical-preferences.md` 的 `引擎专家` 章节，获取主要专家
- 如果未配置引擎，跳过此咨询
- 使用以下内容启动 `subagent_type: [primary specialist]`：所有包含引擎专属决策或
  `Post-Cutoff APIs Used` 字段的 ADR、引擎参考文档以及阶段 5 审计发现。要求专家：
  1. 确认或质疑每项审计发现；专家可能了解参考文档未记录的引擎细节
  2. 识别审计可能遗漏的 ADR 引擎专属反模式（例如使用错误的 Godot 节点类型、Unity 组件耦合、Unreal 子系统误用）
  3. 标记对引擎行为所作假设与实际锁定版本不同的 ADR

将额外发现纳入阶段 5 输出的 `### 引擎专家发现`。这些发现会影响最终结论；
专家识别的问题与审计识别的问题权重相同。

---

## 阶段 5b：设计修订标记（Architecture → GDD 反馈）

对于阶段 5 中的每项**高风险引擎发现**，检查是否有 GDD 作出了与已验证引擎实际行为
相矛盾的假设。

要检查的具体情况：

1. **Post-cutoff API 行为不同于训练数据中的假设**：如果 ADR 记录了与默认 LLM 假设
   不同且已经验证的 API 行为，检查引用相关系统的所有 GDD。查找围绕旧有（假设）行为
   编写的设计规则。

2. **ADR 中已知的引擎限制**：如果 ADR 记录了已知引擎限制
   （例如“Jolt 忽略 HingeJoint3D damp”“D3D12 现在是默认 backend”），检查围绕受影响
   功能设计机制的 GDD。

3. **已弃用 API 冲突**：如果阶段 5 标记了 ADR 中使用的已弃用 API，检查是否有 GDD
   包含假设该已弃用 API 行为的机制。

对于发现的每个冲突，将其记录到 GDD 修订标记表中：

```
### GDD 修订标记（Architecture → Design 反馈）
以下 GDD 假设与已验证的引擎行为或已接受 ADR 冲突。
该 GDD 应在其系统进入实现之前完成修订。

| GDD | 假设 | 实际情况（来自 ADR/engine-reference） | 操作 |
|-----|-----------|--------------------------------------|--------|
| combat.md | “使用 HingeJoint3D damp 实现武器后坐力” | Jolt 忽略 damp，见 ADR-0003 | 修订 GDD |
```

如果没有发现修订标记，写入：“无 GDD 修订标记，所有 GDD 假设均与已验证的引擎行为一致。”

询问之前，内联显示建议变更；并排展示每个被标记 GDD 当前的 systems-index 行与建议更新后的行，
使用户可以准确看到将发生什么变化。

然后使用 `AskUserQuestion`：
- “发现 [N] 个 GDD 修订标记。可以更新系统索引吗？”
  - [A] 是，立即将全部 [N] 项更新应用到系统索引
  - [B] 先显示完整 diff，然后再次询问
  - [C] 否，暂时保持系统索引不变

如果选择 [A]：应用更新。Status 字段必须恰好为 `Needs Revision`，不得添加括号说明
（其他技能会匹配这个精确字符串，括号会导致匹配失败）。
如果选择 [B]：显示建议的完整 systems-index 章节，然后使用 `AskUserQuestion` 再次询问。

---

## 阶段 6：架构文档覆盖情况

如果 `docs/architecture/architecture.md` 存在，根据 GDD 验证它：

- `systems-index.md` 中的每个系统是否都出现在架构层中？
- 数据流章节是否覆盖 GDD 中定义的所有跨系统通信？
- API 边界是否支持 GDD 中的所有集成需求？
- 架构文档中是否存在没有对应 GDD 的系统（孤立架构）？

---

## 阶段 7：输出审查报告

```
## 架构审查报告
日期：[date]
引擎：[name + version]
已审查 GDD：[N]
已审查 ADR：[M]

---

### 可追溯性摘要
需求总数：[N]
✅ 已覆盖：[X]
⚠️ 部分覆盖：[Y]
❌ 缺口：[Z]

### 覆盖缺口（不存在 ADR）
对于每个缺口：
  ❌ TR-[id]: [GDD] → [system] → [requirement]
     建议的 ADR：“/architecture-decision [suggested title]”
     领域：[Physics/Rendering/etc]
     引擎风险：[LOW/MEDIUM/HIGH]

### ADR 间冲突
[列出阶段 4 的所有冲突]

### ADR 依赖顺序
[阶段 4 依赖排序章节中按拓扑排序的实现顺序]
[未解决的依赖和循环（如有）]

### GDD 修订标记
[与已验证引擎行为冲突的 GDD 假设，来自阶段 5b]
[或：“无，所有 GDD 假设均与已验证的引擎行为一致”]

### 引擎兼容性问题
[列出阶段 5 的所有引擎问题]

### 架构文档覆盖情况
[列出阶段 6 中缺失的系统和孤立架构]

---

### 结论：[PASS / CONCERNS / FAIL]

PASS：所有需求均已覆盖、无冲突、引擎一致
CONCERNS：存在一些缺口或部分覆盖，但没有阻塞性冲突
FAIL：存在关键缺口（Foundation/Core 层需求未覆盖），
      或检测到阻塞性的 ADR 间冲突

### 阻塞问题（必须解决后才能 PASS）
[列出必须解决的项目，仅用于 FAIL 结论]

### 必需的 ADR
[按优先级列出要创建的 ADR，最基础的优先]
```

---

## 阶段 8：写入并更新可追溯性索引

使用 `AskUserQuestion` 请求写入批准：
- “审查完成。要写入哪些内容？”
  - [A] 写入全部三个文件（审查报告 + 可追溯性索引 + TR 注册表）
  - [B] 仅写入审查报告，即 `docs/architecture/architecture-review-[date].md`
  - [C] 暂不写入任何内容，我需要先审阅发现

### RTM 输出（仅 rtm 模式）

对于 `rtm` 模式，使用 `AskUserQuestion`：
- “可以写入完整的需求可追溯性矩阵吗？”
  - [A] 是，写入 `docs/architecture/requirements-traceability.md`
  - [B] 暂不写入，先显示完整 RTM 数据，然后再次询问

RTM 文件格式：

```markdown
# 需求可追溯性矩阵（RTM）

> 最后更新：[date]
> 模式：/architecture-review rtm
> 覆盖率：[N]% 完整链路已完成（GDD → ADR → Story → Test）

## 如何阅读此矩阵

| 列 | 含义 |
|--------|---------|
| TR-ID | 来自 tr-registry.yaml 的稳定需求 ID |
| GDD | 源设计文档 |
| ADR | 约束实现的架构决策 |
| Story | 实现此需求的故事文件 |
| Test File | 自动化测试文件路径 |
| Test Status | COVERED / MISSING / NONE / NO STORY |

## 完整可追溯性矩阵

| TR-ID | GDD | 需求 | ADR | Story | Test File | 状态 |
|-------|-----|-------------|-----|-------|-----------|--------|
[阶段 3b 的完整矩阵行]

## 覆盖摘要

| 状态 | 数量 | % |
|--------|-------|---|
| COVERED，完整链路已完成 | [N] | [%] |
| MISSING test，故事存在但无测试 | [N] | [%] |
| NO STORY，ADR 存在但尚未实现 | [N] | [%] |
| NO ADR，架构缺口 | [N] | [%] |
| **需求总数** | **[N]** | **100%** |

## 未覆盖需求（优先修复清单）

完整链路中断的需求，按层级确定优先级：

### Foundation 层缺口
[列出每个缺口及建议操作]

### Core 层缺口
[列表]

### Feature / Presentation 层缺口
[列表，优先级较低]

## 历史记录

| 日期 | 完整链路 % | 备注 |
|------|-------------|-------|
| [date] | [%] | 初始 RTM |
```

### 更新 TR 注册表

还要询问：“可以使用本次审查的新需求 ID 更新 `docs/architecture/tr-registry.yaml` 吗？”

如果同意：
- **追加**本次审查之前注册表中不存在的所有新 TR-ID
- 对 GDD 措辞发生变化的条目，**更新** `requirement` 文本和 `revised` 日期（ID 保持不变）
- 对 GDD 需求已不存在的注册表条目标记 `status: deprecated`（标记前向用户确认）
- **绝不**重新编号或删除现有条目
- 更新顶部的 `last_updated` 和 `version` 字段

这可确保未来所有故事文件都能引用稳定的 TR-ID，并在后续每次架构审查中保持不变。

### 更新反思日志

写入审查报告后，将阶段 4 中发现的所有 🔴 CONFLICT 条目追加到
`docs/consistency-failures.md`（如果该文件存在）：

```markdown
### [YYYY-MM-DD] — /architecture-review — 🔴 CONFLICT
**领域**：Architecture / [specific domain，例如 State Ownership、Performance]
**涉及文档**：[ADR-NNNN] vs [ADR-MMMM]
**发生情况**：[具体冲突，即每个 ADR 分别声称什么]
**解决方式**：[已经或应当如何解决]
**模式**：[面向此领域未来 ADR 作者的通用经验]
```

仅追加 CONFLICT 条目，不记录 GAP 条目（架构完成前缺少 ADR 属于预期情况）。
如果文件不存在，不要创建；仅在文件已存在时追加。

### 更新会话状态

写入所有已批准的文件后，静默追加到 `production/session-state/active.md`：

    ## 会话摘录 — /architecture-review [date]
    - 结论：[PASS / CONCERNS / FAIL]
    - 需求：共 [N] 项，[X] 项已覆盖、[Y] 项部分覆盖、[Z] 项存在缺口
    - 已注册的新 TR-ID：[N，或“无”]
    - GDD 修订标记：[以逗号分隔的 GDD 名称，或“无”]
    - 主要 ADR 缺口：[报告中前 3 个缺口标题，或“无”]
    - 报告：docs/architecture/architecture-review-[date].md

如果 `active.md` 不存在，使用此块作为初始内容创建该文件。
在对话中确认：“会话状态已更新。”

可追溯性索引格式：

```markdown
# 架构可追溯性索引
最后更新：[date]
引擎：[name + version]

## 覆盖摘要
- 需求总数：[N]
- 已覆盖：[X]（[%]）
- 部分覆盖：[Y]
- 缺口：[Z]

## 完整矩阵
[阶段 3 的完整可追溯性矩阵]

## 已知缺口
[所有 ❌ 项及建议的 ADR]

## 已取代的需求
[其 GDD 在 ADR 编写后发生变化的需求]
```

---

## 阶段 9：交接

完成审查并写入已批准的文件后，呈现：

1. **立即执行的操作**：列出最应创建的 3 个 ADR（高影响缺口优先，Foundation 层先于 Feature 层）
2. **门禁前检查清单**：通过 Glob 检查以下项目是否存在，并将每项标记为 ✅ 或 ❌：
   - `tests/unit/` 和 `tests/integration/` 目录；如果为 ❌，运行 `/test-setup`
   - `.github/workflows/tests.yml`；如果为 ❌，运行 `/test-setup`
   - `design/accessibility-requirements.md`；如果为 ❌，运行 `/ux-design`
   - `design/ux/interaction-patterns.md`；如果为 ❌，运行 `/ux-design`
   将 ❌ 项作为 gate-check 前的必需步骤呈现。如果任何项目为 ❌，不要提供 `/gate-check`
   选项，而应改为提供要运行的缺失技能。
3. **重新运行触发条件**：“每写入一个新 ADR 后，重新运行 `/architecture-review`，
   以验证覆盖率是否提升”

然后根据门禁前检查清单的状态，以 `AskUserQuestion` 结束：
- 如果仍有 ADR 缺口，或任何门禁前项目为 ❌：
  - “架构审查完成。接下来要做什么？”
    - [A] 编写缺失的 ADR，在新会话中运行 `/architecture-decision [system]`
    - [B] 运行 `/test-setup`，这是 gate-check 前的必需步骤（仅在测试基础设施为 ❌ 时显示）
    - [C] 运行 `/ux-design`，这是 gate-check 前的必需步骤（仅在 UX/accessibility 文件为 ❌ 时显示）
    - [D] 本次会话到此为止
- 如果所有门禁前检查项均为 ✅，且没有阻塞性的 ADR 缺口：
  - “架构审查完成。所有门禁前项目均已确认。接下来要做什么？”
    - [A] 运行 `/gate-check pre-production`
    - [B] 编写缺失的 ADR，在新会话中运行 `/architecture-decision [system]`
    - [C] 本次会话到此为止

---

## 错误恢复协议

如果任何已启动的 agent 返回 BLOCKED、报错或未能完成：

1. **立即呈现**：继续之前报告“[AgentName]: BLOCKED — [reason]”
2. **评估依赖**：如果后续阶段需要被阻塞 agent 的输出，未经用户输入，不得越过该阶段继续
3. 通过 AskUserQuestion **提供选项**，包含三个选择：
   - 跳过此 agent，并在最终报告中注明缺口
   - 以更窄范围重试（更少的 GDD、聚焦单个系统）
   - 在此停止，先解决阻塞因素
4. **始终生成部分报告**，输出已经完成的所有内容，避免工作丢失

---

## 协作协议

1. **静默读取**，不要叙述读取的每个文件
2. **显示矩阵**，请求任何内容之前先呈现完整的可追溯性矩阵，让用户了解当前状态
3. **不要猜测**，如果需求存在歧义，询问：“[X] 是技术需求还是设计偏好？”
4. **批准前先提供草稿**，请求批准之前，始终在对话中内联显示将要写入的内容
   （报告、更新后的 ADR 章节、systems-index 行）。绝不请求写入用户尚未看到的内容。
5. **写入批准必须使用 `AskUserQuestion`**，纯文本“可以吗？”并不充分。
   使用带有 [A]/[B]/[C] 标签选项的结构化工具，让用户在“立即写入”“先显示完整草稿”
   和“暂不写入”之间选择。多文件变更集必须列出每个文件及其变更，然后使用分组选项
   一次询问，不要对每个文件分别提出纯文本问题。
6. **非阻塞性**，结论仅供参考；即使发现 CONCERNS 甚至 FAIL，是否继续仍由用户决定
