# 导演门禁 — 共享审查模式

本文档为所有工作流阶段中的所有总监和负责人审查定义标准门禁提示词。技能引用本文档中的门禁 ID，而不是在行内嵌入完整提示词——从而在提示词需要更新时消除漂移。

**范围**: 所有 7 个制作阶段（概念 → 发布）、所有 3 位一级总监，以及所有关键二级负责人。任何技能、团队编排器或工作流都可以调用这些门禁。

---

## 如何使用本文档

在任何技能中，用一个引用替换行内的总监提示词：

```
通过 Task 启动 `creative-director`，使用来自
`.claude/docs/director-gates.md` 的门禁 **CD-PILLARS**。
```

传递该门禁的 **传递的上下文** 字段下列出的上下文，然后按照
下方的 **裁决处理** 规则处理裁决。

---

## 审查模式

审查强度控制总监门禁是否运行。它可以全局设置
（跨会话持久），也可以在每次技能运行时覆盖。

**全局配置**: `production/review-mode.txt` — 一个单词：`full`、`lean` 或 `solo`。
在 `/start` 时设置一次。随时直接编辑该文件即可更改。

**按次覆盖**: 任何使用门禁的技能都接受 `--review [full|lean|solo]` 作为
参数。该参数仅覆盖该次运行的全局配置。

示例：
```
/brainstorm 太空恐怖           → 使用全局模式
/brainstorm 太空恐怖 --review full   → 本次运行强制使用 full 模式
/architecture-decision --review solo     → 本次运行跳过所有门禁
```

| 模式 | 运行内容 | 适合 |
|------|-----------|------|
| `full` | 所有门禁启用 — 当前行为 | 新项目、团队、学习工作流 |
| `lean` | 仅运行 PHASE-GATEs（`/gate-check`）— 跳过所有按技能的门禁 | 信任自己设计工作的有经验开发者 |
| `solo` | 不在任何地方运行总监门禁 | 游戏创作马拉松、原型、追求速度的资深独立开发者 |

**检查模式 — 在每次门禁生成前应用：**

```
在生成门禁 [GATE-ID] 之前：
1. 如果技能以 --review [mode] 调用，则使用该模式
2. 否则读取 production/review-mode.txt
3. 否则默认使用 full

应用解析后的模式：
- solo → 跳过所有门禁。注意："[GATE-ID] 已跳过 — 单人模式"
- lean → 除非这是一个 PHASE-GATE（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE），否则跳过
         注意："[GATE-ID] 已跳过 — 精简模式"
- full → 正常生成
```

---

## 调用模式（复制到任何技能中）

**强制要求：在每次生成关卡前解决审查模式。** 切勿在未检查的情况下生成关卡。解决的模式在每次技能运行时只确定一次：
1. 如果技能是用 `--review [mode]` 调用的，则使用该模式
2. 否则读取 `production/review-mode.txt`
3. 否则默认使用 `lean`

应用已解决的模式：
- `solo` → **跳过所有关卡**。输出中记录：`[GATE-ID] skipped — Solo mode`
- `lean` → **除非这是 PHASE-GATE，否则跳过**（CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE）。注意：`[GATE-ID] skipped — Lean mode`
- `full` → 正常生成

```
# 应用模式检查，然后：
通过任务生成 `[agent-name]`：
- 关卡: [GATE-ID]（见 .claude/docs/director-gates.md）
- 上下文: [该关卡下列出的字段]
- 等待裁定后再继续。
```

并行启动（在等待任何结果之前先发出所有 Task 调用）：

```
同时通过 Task 启动全部 [N] 个代理——在等待任何结果之前先发出所有 Task 调用。收集所有裁决后再继续。
```

---

## 标准裁决格式

所有门禁都会返回以下三种裁决之一。技能必须处理全部三种：

| 裁决 | 含义 | 默认操作 |
|---------|---------|----------------|
| **APPROVE / READY** | 没有问题。继续。 | 继续工作流 |
| **CONCERNS [list]** | 存在问题，但不阻塞。 | 通过 `AskUserQuestion` 向用户呈现 — 选项：`修订标记项` / `接受并继续` / `进一步讨论` |
| **REJECT / NOT READY [blockers]** | 存在阻塞问题。不要继续。 | 向用户呈现阻塞项。在解决之前，不要写入文件或推进阶段。 |

**升级规则**：当多个总监并行启动时，应用最严格的裁决——一个 NOT READY 会覆盖所有 READY 裁决。

---

## 记录门禁结果

门禁解析完成后，将裁决记录到相关文档的状态标题中：

```markdown
> **[Director] 审查 ([GATE-ID])**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]
```

对于阶段门禁，请视情况记录在 `docs/architecture/architecture.md` 或
`production/session-state/active.md` 中。

---

## 一级 — 创意总监门禁

代理：`creative-director` | 模型层级：Opus | 领域：愿景、支柱、玩家体验

---

### CD-PILLARS — 支柱压力测试

**触发条件**: 在游戏支柱和反支柱定义完成后（brainstorm 第 4 阶段，
或任何支柱被修订时）

**传递的上下文**:
- 完整的支柱集合，包含名称、定义和设计测试
- 反支柱列表
- 核心幻想陈述
- 独特钩子（“像 X，而且还有 Y”）

**提示词**:
> "审查这些游戏支柱。它们是否可证伪——某个真实的设计决策是否真的会让这一支柱失败？它们彼此之间是否形成了有意义的张力？
> 它们是否让这款游戏区别于最接近的同类作品？它们在实践中是否有助于解决设计分歧，还是过于模糊而没有用？
> 请针对每个支柱给出具体反馈，并给出整体裁决：APPROVE（强）、CONCERNS [list]（需要打磨），或 REJECT（薄弱——支柱没有分量）。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-GDD-ALIGN — GDD 支柱对齐检查

**触发条件**: 在系统 GDD 编写完成后（design-system、quick-design，或任何
产出 GDD 的工作流）

**传递的上下文**:
- GDD 文件路径
- 游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`）
- 本游戏的 MDA 美学目标
- 系统中声明的玩家幻想部分

**提示词**:
> "审查这份系统 GDD 是否与所述支柱对齐。每个部分是否都在服务这些支柱？
> 是否存在与某个支柱相矛盾或削弱它的机制或规则？玩家幻想部分是否与游戏的核心幻想一致？
> 请返回 APPROVE、CONCERNS [specific sections with issues]，
> 或 REJECT [pillar violations that must be redesigned before this system is implementable]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-SYSTEMS — 系统分解愿景检查

**触发条件**: 在 `/map-systems` 写入系统索引之后——在 GDD 编写开始之前
验证完整系统集合

**传递的上下文**:
- 系统索引路径（如果索引尚未写入，则使用依赖图摘要）
- 游戏支柱和核心幻想（来自 `design/gdd/game-concept.md`）
- 优先级层级分配（MVP / Vertical Slice / Alpha / Full Vision）
- 依赖图中标识出的任何高风险或瓶颈系统

**提示词**:
> "审查这份系统分解相对于游戏设计支柱的情况。完整的 MVP 层系统集合是否共同实现了核心幻想？
> 是否存在某些系统的机制并不服务任何已声明的支柱——这表明它们可能属于范围蔓延？
> 是否存在对支柱至关重要但没有分配任何系统来承载的玩家体验？
> 核心循环是否缺少任何所需系统？
> 请返回 APPROVE（系统服务于愿景）、CONCERNS [specific gaps or misalignments with their pillar implications]，
> 或 REJECT [fundamental gaps — the decomposition misses critical design intent and must be revised before GDD authoring begins]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-NARRATIVE — 叙事一致性检查

**触发条件**: 在叙事 GDD、设定文档、对话规格或世界构建文档完成后
（team-narrative、用于故事系统的 design-system、writer 交付物）

**传递的上下文**:
- 文档文件路径
- 游戏支柱
- 叙事方向简报或语气指南（如果存在于 `design/narrative/`）
- 新文档引用到的任何现有设定

**提示词**:
> "审查这份叙事内容是否与游戏的支柱和既定世界规则一致。语气是否与游戏既有的声音一致？
> 是否与现有设定或世界构建存在矛盾？内容是否服务于玩家体验支柱？
> 请返回 APPROVE、CONCERNS [specific inconsistencies]，或 REJECT [contradictions that break world coherence]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-PLAYTEST — 玩家体验验证

**触发条件**: 在生成 playtest 报告后（`/playtest-report`），或在任何
产生玩家反馈的会话之后

**传递的上下文**:
- Playtest 报告文件路径
- 游戏支柱和核心幻想陈述
- 正在测试的具体假设

**提示词**:
> "审查这份 playtest 报告相对于游戏的设计支柱和核心幻想。玩家体验是否与预期幻想一致？
> 是否存在代表支柱漂移的系统性问题——那些单独看起来没问题、但会破坏预期体验的机制？
> 请返回 APPROVE（核心幻想正在落地）、CONCERNS [预期体验与实际体验之间的差距]，
> 或 REJECT [core fantasy is not present — redesign needed before further playtesting]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-PHASE-GATE — 阶段转换时的创意就绪度

**触发条件**: 始终在 `/gate-check` 时——与 TD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**传递的上下文**:
- 目标阶段名称
- 当前存在的所有工件列表（文件路径）
- 游戏支柱和核心幻想

**提示词**:
> "从创意方向角度审查当前项目在 [target phase] 阶段的门禁就绪度。游戏支柱是否在所有设计工件中得到忠实体现？
> 当前状态是否保留了核心幻想？GDD 或架构中的任何设计决策是否损害了预期的玩家体验？
> 请返回 READY、CONCERNS [list]，或 NOT READY [blockers]。"

**裁决**: READY / CONCERNS / NOT READY

---

## 一级 — 技术总监门禁

代理：`technical-director` | 模型层级：Opus | 领域：架构、引擎风险、性能

---

### TD-SYSTEM-BOUNDARY — 系统边界架构审查

**触发条件**: 在 `/map-systems` 第 3 阶段的依赖映射达成一致之后、
但在 GDD 编写开始之前——在团队开始基于它编写 GDD 之前验证系统结构
在架构上是否健全

**传递的上下文**:
- 系统索引路径（如果索引尚未写入，则使用依赖图摘要）
- 层级分配（Foundation / Core / Feature / Presentation / Polish）
- 完整的依赖图（每个系统依赖什么）
- 标记出的任何瓶颈系统（被许多系统依赖）
- 发现的任何循环依赖及其建议解决方案

**提示词**:
> "在 GDD 编写开始之前，从架构角度审查这份系统分解。系统边界是否清晰——每个系统是否拥有明确独立的职责，且重叠最少？
> 是否存在 God Object 风险（某个系统做得过多）？依赖顺序是否会造成实现排期问题？
> 拟定的边界中是否存在隐式共享状态问题，导致实现后形成紧耦合？ 是否有任何 Foundation 层系统实际上依赖 Feature 层系统（依赖倒置）？
> 请返回 APPROVE（边界在架构上合理——可以进入 GDD 编写）、CONCERNS [需要在 GDD 中处理的具体边界问题]，
> 或 REJECT [基础边界问题——系统结构会引发架构问题，必须在任何 GDD 编写之前重构]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-FEASIBILITY — 技术可行性评估

**触发条件**: 在范围/可行性阶段识别出最大的技术风险之后
（brainstorm 第 6 阶段、quick-design，或任何带有技术未知项的早期概念）

**传递的上下文**:
- 概念的核心循环描述
- 平台目标
- 引擎选择（或“未定”）
- 已识别的技术风险列表

**提示词**:
> "审查这些技术风险，针对一个使用 [engine or 'undecided engine']、面向 [platform] 的 [genre] 游戏。
> 标出任何可能让当前描述的概念失效的 HIGH risk 项目，任何引擎特定且应影响引擎选择的风险，以及单人开发者经常低估的风险。
> 请返回 VIABLE（风险可控）、CONCERNS [list with mitigation suggestions]，或 HIGH RISK [blockers that require concept or scope revision]。"

**裁决**: VIABLE / CONCERNS / HIGH RISK

---

### TD-ARCHITECTURE — 架构签核

**触发条件**: 在主架构文档完成草稿后（`/create-architecture`
第 7 阶段），以及在任何重大架构修订之后

**传递的上下文**:
- 架构文档路径（`docs/architecture/architecture.md`）
- 技术需求基线（TR-ID 及其数量）
- 带有状态的 ADR 列表
- 引擎知识缺口清单

**提示词**:
> "审查这份主架构文档的技术健全性。
> 检查：(1) 基线中的每一项技术需求是否都由某个架构决策覆盖？
> (2) 所有 HIGH risk 引擎领域是否都被明确处理或标记为未决问题？
> (3) API 边界是否清晰、最小且可实施？
> (4) Foundation 层 ADR 缺口是否在实施开始前已解决？请返回 APPROVE、CONCERNS [list]，
> 或 REJECT [blockers that must be resolved before coding starts]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-ADR — 架构决策审查

**触发条件**: 在单独的 ADR 完成后（`/architecture-decision`），在其
被标记为 Accepted 之前

**传递的上下文**:
- ADR 文件路径
- 该领域的引擎版本与知识缺口风险级别
- 相关 ADR（如果有）

**提示词**:
> "审查这份 Architecture Decision Record。它是否有清晰的问题陈述和理由？被否决的替代方案是否确实经过考虑？
> Consequences 部分是否诚实地承认了权衡？是否标注了引擎版本？是否标出了知识截止之后的 API 风险？
> 是否链接到了它所覆盖的 GDD 需求？请返回 APPROVE、CONCERNS [specific gaps]，
> 或 REJECT [the decision is underspecified or makes unsound technical assumptions]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-ENGINE-RISK — 引擎版本风险审查

**触发条件**: 在做出涉及知识截止之后引擎 API 的架构决策时，
或在最终确定任何特定引擎的实现方式之前

**传递的上下文**:
- 正在使用的具体 API 或功能
- 引擎版本与 LLM 知识截止点（来自 `docs/engine-reference/[engine]/VERSION.md`）
- `breaking-changes` 或 `deprecated-apis` 文档中的相关摘录

**提示词**:
> "根据版本参考审查这项引擎 API 使用。该 API 是否存在于 [engine version] 中？
> 自 LLM 知识截止点以来，它的签名、行为或命名空间是否发生变化？是否有已知弃用项或知识截止后的替代方案？
> 请返回 APPROVE（按描述使用是安全的）、CONCERNS [verify before implementing]，
> 或 REJECT [API has changed — provide corrected approach]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-PHASE-GATE — 阶段转换时的技术就绪度

**触发条件**: 始终在 `/gate-check` 时——与 CD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**传递的上下文**:
- 目标阶段名称
- 架构文档路径（如果存在）
- 引擎参考路径
- ADR 列表

**提示词**:
> "从技术方向角度审查当前项目在 [target phase] 阶段的门禁就绪度。架构在这一阶段是否健全？所有高风险引擎领域是否都已处理？
> 性能预算是否现实且已文档化？Foundation 层决策是否已经充分到可以开始实施？
> 请返回 READY、CONCERNS [list]，或 NOT READY [blockers]。"

**裁决**: READY / CONCERNS / NOT READY

---

## 一级 — 制作人门禁

代理：`producer` | 模型层级：Opus | 领域：范围、时间线、依赖、制作风险

---

### PR-SCOPE — 范围和时间线验证

**触发条件**: 在定义范围层级之后（brainstorm 第 6 阶段、quick-design，
或任何产出 MVP 定义和时间估算的工作流）

**传递的上下文**:
- 完整的愿景范围描述
- MVP 定义
- 时间线估算
- 团队规模（solo / small team / etc.）
- 范围层级（如果时间耗尽时会交付什么）

**提示词**:
> "审查这份范围估算。对于所述团队规模而言，所述时间线内能否实现 MVP？
> 范围层级是否按风险正确排序——如果在该层级停止工作，每一层是否都能交付可发布产品？
> 在时间压力下最可能的砍点是什么，它是优雅降级还是破碎产品？
> 请返回 REALISTIC（范围与能力相符）、OPTIMISTIC [specific adjustments recommended]，
> 或 UNREALISTIC [blockers — timeline or MVP must be revised]。"

**裁决**: REALISTIC / OPTIMISTIC / UNREALISTIC

---

### PR-SPRINT — 迭代可行性审查

**触发条件**: 在最终确定迭代计划之前（`/sprint-plan`），以及在
任何迭代中途的范围变更之后

**传递的上下文**:
- 拟议的迭代故事列表（标题、估算、依赖）
- 团队容量（可用小时数）
- 当前迭代待办债务（如果有）
- 里程碑约束

**提示词**:
> "审查这份迭代计划的可行性。故事负载对于可用容量来说是否现实？故事是否按依赖正确排序？
> 故事之间是否存在隐藏依赖，可能在迭代中途卡住团队？是否有任何故事由于技术复杂度而被低估？
> 请返回 REALISTIC（计划可实现）、CONCERNS [specific risks]，
> 或 UNREALISTIC [sprint must be descoped — identify which stories to defer]。"

**裁决**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-MILESTONE — 里程碑风险评估

**触发条件**: 在里程碑评审（`/milestone-review`）、中途回顾，
或提出会影响里程碑的范围变更时

**传递的上下文**:
- 里程碑定义和目标日期
- 当前完成百分比
- 被阻塞故事数量
- 冲刺速度数据（如果有）

**提示词**:
> "审查这份里程碑状态。基于当前速度和被阻塞故事数量，这个里程碑能否按目标日期达成？
> 现在到里程碑之间的前三大制作风险是什么？哪些范围项应被砍掉以保护里程碑日期，哪些又是不可妥协的？
> 请返回 ON TRACK、AT RISK [specific mitigations]，
> 或 OFF TRACK [date must slip or scope must cut — provide both options]。"

**裁决**: ON TRACK / AT RISK / OFF TRACK

---

### PR-EPIC — Epic 结构可行性审查

**触发条件**: 在 `/create-epics` 产出 Epic 之后、拆分故事之前——在调用
`/create-stories` 之前验证 Epic 结构是否可制作

**传递的上下文**:
- Epic 定义文件路径（刚创建的所有 Epic）
- Epic 索引路径（`production/epics/index.md`）
- 里程碑时间线和目标日期
- 团队容量（solo / small team / size）
- 正在进行 Epic 划分的层级（Foundation / Core / Feature / etc.）

**提示词**:
> "在开始拆分故事之前，审查这份 Epic 结构的制作可行性。Epic 边界是否范围适当——每个 Epic 是否都能现实地在里程碑截止日前完成？
> Epic 是否按系统依赖正确排序——是否有任何 Epic 需要另一个 Epic 的输出后才能开始？
> 是否有任何 Epic 过小（应该合并）或过大（应该拆分为 2-3 个聚焦 Epic）？
> Foundation 层 Epic 的范围是否足以让 Core 层 Epic 在 Foundation 完成后的下一个迭代开始时启动？
> 请返回 REALISTIC（Epic 结构可制作）、CONCERNS [specific structural adjustments before stories are written]，
> 或 UNREALISTIC [epics must be split, merged, or reordered — story breakdown cannot begin until resolved]。"

**裁决**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-PHASE-GATE — 阶段转换时的制作就绪度

**触发条件**: 始终在 `/gate-check` 时——与 CD-PHASE-GATE 和 TD-PHASE-GATE 并行启动

**传递的上下文**:
- 目标阶段名称
- 当前存在的迭代和里程碑工件
- 团队规模和容量
- 当前被阻塞故事数量

**提示词**:
> "从制作视角审查当前项目在 [target phase] 阶段的门禁就绪度。所述时间线和团队规模下，范围是否现实？
> 依赖是否已正确排序，以便团队能够按顺序真正执行？是否存在可能在前两个迭代内破坏该阶段的里程碑或迭代风险？
> 请返回 READY、CONCERNS [list]，或 NOT READY [blockers]。"

**裁决**: READY / CONCERNS / NOT READY

---

## 一级 — 艺术总监门禁

代理: `art-director` | 模型层级: Sonnet | 领域: 视觉识别、艺术指南、视觉制作准备

---

### AD-CONCEPT-VISUAL — 视觉识别锚点

**触发条件**：在游戏支柱确定后（头脑风暴第四阶段），与 CD-PILLARS 并行进行

**传递的上下文**：
- 游戏概念（电梯推介、核心幻想、独特亮点）
- 完整的支柱集合，包括名称、定义和设计测试
- 目标平台（如果已知）
- 用户提到的任何参考游戏或视觉参考

**提示词**:
> "基于这些游戏支柱和核心概念，提出2-3个不同的视觉识别方向。对于每个方向，请提供：
> (1)一个能指导所有视觉决策的一行视觉规则(例如：‘一切都必须运动’，‘美在衰败中’)，(2)情绪和氛围目标，
> (3)形状语言(强调尖锐/圆润/有机/几何)，(4)色彩理念(调色方向，在这个世界里颜色意味着什么)。
> 请具体说明——避免泛泛而谈。其中一个方向应直接服务于主要设计支柱。
> 为每个方向命名。推荐最能服务于所述支柱的方向，并解释原因。"

**裁决**：CONCEPTS（多个有效选项—用户选择） / STRONG（一个方向明显占优） / CONCERNS（支柱尚未提供足够的方向来区分视觉识别）

---

### AD-ART-BIBLE — 美术圣经签核

**触发条件**：美术圣经完成草稿（`/art-bible`）后、资产制作开始前

**传递的上下文**：
- 美术圣经路径（`design/art/art-bible.md`）
- 游戏支柱和核心幻想
- 平台与性能约束（如果已配置，则来自 `.claude/docs/technical-preferences.md`）
- 头脑风暴期间选定的视觉识别锚点（来自 `design/gdd/game-concept.md`）

**提示词**：
> "检查这份美术圣经是否完整且内部一致。色彩系统是否符合情绪目标？形状语言是否源自视觉识别声明？
> 在平台约束下，资产标准是否可实现？角色设计方向是否为美术人员提供了足够的创作依据，同时没有规定得过于具体？
> 不同章节之间是否存在矛盾？外包团队能否仅依据这份文档制作资产，而无需额外简报？
> 返回 APPROVE（美术圣经已达到生产就绪状态）、CONCERNS [需要澄清的具体章节]，
> 或 REJECT [必须在资产制作开始前解决的根本性不一致问题]。"

**裁决**：APPROVE / CONCERNS / REJECT

---

### AD-PHASE-GATE — 阶段转换时的视觉就绪度

**触发条件**：始终在 `/gate-check` 时触发，与 CD-PHASE-GATE、TD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**传递的上下文**：
- 目标阶段名称
- 当前所有美术/视觉产物的列表（文件路径）
- 来自 `design/gdd/game-concept.md` 的视觉识别锚点（如果存在）
- 美术圣经路径（如果存在，则为 `design/art/art-bible.md`）

**提示词**：
> "从视觉方向的角度，检查当前项目状态是否满足 [目标阶段] 的门禁就绪条件。
> 视觉识别是否已经建立，并以该阶段所要求的深度完成记录？
> 正确的视觉产物是否已经到位？视觉团队能否在没有视觉方向缺口的情况下开始工作，从而避免后续代价高昂的返工？
> 是否有视觉决策被推迟到了其最晚责任时限之后？返回 READY、CONCERNS [可能导致生产返工的具体视觉方向缺口]，
> 或 NOT READY [必须在该阶段成功推进前解决的视觉阻塞项；请说明缺失的产物及其在当前阶段的重要性]。"

**裁决**：READY / CONCERNS / NOT READY

---

## 二级 — 负责人门禁

当工作流编排技能和高级技能需要领域专家的可行性签核时，会调用这些门禁。
二级负责人使用 Sonnet（默认）。

---

### LP-FEASIBILITY — 主程序员实施可行性

**触发条件**: 在主架构文档写成之后（`/create-architecture`
第 7b 阶段），或者在提出新的架构模式时

**传递的上下文**:
- 架构文档路径
- 技术需求基线摘要
- 带有状态的 ADR 列表

**提示词**:
> "审查这份架构的实施可行性。标出：
> (a) 任何在所述引擎和语言下难以或不可能实现的决策，(b) 程序员必须自行发明的缺失接口定义，
> (c) 任何会造成可避免技术债务，或与标准 [engine] 惯用法相冲突的模式。
> 请返回 FEASIBLE、CONCERNS [list]，或 INFEASIBLE [blockers that make this architecture unimplementable as written]。"

**裁决**: FEASIBLE / CONCERNS / INFEASIBLE

---

### LP-CODE-REVIEW — 主程序员代码审查

**触发条件**: 在开发故事完成后（`/dev-story`、`/story-done`），或
作为 `/code-review` 的一部分

**传递的上下文**:
- 实现文件路径
- 故事文件路径（用于验收标准）
- 相关 GDD 章节
- 约束此系统的 ADR

**提示词**:
> "根据故事验收标准和所依据的 ADR 审查这份实现。代码是否符合架构边界定义？是否存在编码标准违规或禁用模式？公共 API 是否可测试且已文档化？是否存在违反 GDD 规则的正确性问题？请返回 APPROVE、CONCERNS [specific issues]，或 REJECT [must be revised before merge]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### QL-STORY-READY — QA 负责人故事就绪检查

**触发条件**: 在故事被接受进入迭代之前——由 `/create-stories`、
`/story-readiness` 以及 `/sprint-plan` 在选故事时调用

**传递的上下文**:
- 故事文件路径
- 故事类型（Logic / Integration / Visual/Feel / UI / Config/Data）
- 验收标准列表（逐字摘自故事）
- 该故事覆盖的 GDD 需求（TR-ID 和文本）

**提示词**:
> "在故事进入迭代之前，审查其验收标准的可测试性。所有标准是否足够具体，以便开发者能毫无歧义地知道自己何时完成？对于 Logic 类型故事：每条标准是否都能通过自动化测试验证？对于 Integration 故事：每条标准是否都能在受控测试环境中观测到？标出那些过于模糊而难以实现对照的标准，并标出那些需要完整游戏构建才能测试的标准（将这些标记为 DEFERRED，而不是 BLOCKED）。请返回 ADEQUATE（标准按原样可实现）、GAPS [specific criteria needing refinement]，或 INADEQUATE [criteria are too vague — story must be revised before sprint inclusion]。"

**裁决**: ADEQUATE / GAPS / INADEQUATE

---

### QL-TEST-COVERAGE — QA 负责人测试覆盖率审查

**触发条件**: 在实现故事完成后、在标记 Epic 完成之前，或在
Production → Polish 的 `/gate-check` 时

**传递的上下文**:
- 已实现故事列表及故事类型（Logic / Integration / Visual / UI / Config）
- `tests/` 中的测试文件路径
- 该系统的 GDD 验收标准

**提示词**:
> "审查这些实现故事的测试覆盖率。所有 Logic 故事是否都有通过的单元测试覆盖？所有 Integration 故事是否都有集成测试或有记录的 playtest 覆盖？每一条 GDD 验收标准是否至少映射到一个测试？GDD 的 Edge Cases 部分是否存在未测试的边缘情况？请返回 ADEQUATE（覆盖率符合标准）、GAPS [specific missing tests]，或 INADEQUATE [critical logic is untested — do not advance]。"

**裁决**: ADEQUATE / GAPS / INADEQUATE

---

### ND-CONSISTENCY — 叙事总监一致性检查

**触发条件**: 在写完作者交付物（对话、设定、物品描述）之后，或当某个设计决策具有
叙事影响时

**传递的上下文**:
- 文档或内容文件路径
- 叙事圣经或语气指南路径（如果存在）
- 相关的世界构建规则
- 受影响的角色或阵营简介

**提示词**:
> "审查这份叙事内容的内部一致性以及对既定世界规则的遵循。角色声音是否与其既定设定一致？
> 设定是否与任何既定事实相矛盾？语气是否与游戏的叙事方向一致？
> 请返回 APPROVE、CONCERNS [specific inconsistencies to fix]，
> 或 REJECT [contradictions that break the narrative foundation]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### AD-VISUAL — 美术总监视觉一致性审查

**触发条件**: 在美术方向决策完成后、引入新资产类型时，或当技术美术决策
影响视觉风格时

**传递的上下文**:
- 美术圣经路径（如果存在于 `design/art-bible.md`）
- 正在审查的具体资产类型、风格决策或视觉方向
- 参考图片或风格描述
- 平台和性能约束

**提示词**:
> "审查这项视觉方向决策是否与既定美术风格和制作约束一致。它是否符合美术圣经？它是否能在该平台的性能预算内实现？
> 是否存在会带来技术风险的资源管线影响？请返回 APPROVE、CONCERNS [specific adjustments]，
> 或 REJECT [style violation or production risk that must be resolved first]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

## 并行门禁协议

当工作流在同一检查点需要多个总监时（最常见于 `/gate-check`），同时启动所有代理：

```
并行启动（在等待任何结果之前先发出所有 Task 调用）：
1. creative-director  → 门禁 CD-PHASE-GATE
2. technical-director → 门禁 TD-PHASE-GATE
3. producer           → 门禁 PR-PHASE-GATE

收集全部三个裁决，然后应用升级规则：
- 任何 NOT READY / REJECT → 总体裁决最低为 FAIL
- 任何 CONCERNS → 总体裁决最低为 CONCERNS
- 所有 READY / APPROVE → 具备 PASS 资格（仍需通过工件检查）
```

---

## 添加新门禁

当需要为新的技能或工作流添加新门禁时：

1. 分配一个门禁 ID：`[DIRECTOR-PREFIX]-[DESCRIPTIVE-SLUG]`
   - 前缀：`CD-` `TD-` `PR-` `LP-` `QL-` `ND-` `AD-`
   - 为新代理添加新前缀：`AudioDirector` → `AU-`，`UX` → `UX-`
2. 在适当的总监部分下添加该门禁，并包含全部五个字段：
   触发条件、传递的上下文、提示词、裁决，以及任何特殊处理说明
3. 在技能中仅按 ID 引用它——绝不要把提示词文本复制进技能里

---

## 按阶段的门禁覆盖

| 阶段 | 必需门禁 | 可选门禁 |
|-------|---------------|----------------|
| **概念** | CD-PILLARS | TD-FEASIBILITY, PR-SCOPE |
| **系统设计** | TD-SYSTEM-BOUNDARY, CD-SYSTEMS, PR-SCOPE, CD-GDD-ALIGN（每个 GDD） | ND-CONSISTENCY, AD-VISUAL |
| **技术准备** | TD-ARCHITECTURE, TD-ADR（每个 ADR）, LP-FEASIBILITY | TD-ENGINE-RISK |
| **前期制作** | PR-EPIC, QL-STORY-READY（每个故事）, PR-SPRINT, 所有三个 PHASE-GATE（通过 /gate-check） | CD-PLAYTEST |
| **制作** | LP-CODE-REVIEW（每个故事）, QL-STORY-READY, PR-SPRINT（每个迭代） | PR-MILESTONE, QL-TEST-COVERAGE |
| **润色** | QL-TEST-COVERAGE, CD-PLAYTEST, PR-MILESTONE | |
| **发布** | 所有三个 PHASE-GATE（通过 /gate-check） | QL-TEST-COVERAGE |
