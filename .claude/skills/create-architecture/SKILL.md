---
name: create-architecture
description: "以分章节引导的方式编写游戏的主架构文档。读取所有 GDD、系统索引、现有 ADR 和引擎参考库，在编写任何代码之前生成完整的架构蓝图。感知引擎版本：标记知识缺口，并根据锁定的引擎版本验证决策。"
argument-hint: "[focus-area: full | layers | data-flow | api-boundaries | adr-audit] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion, Task
model: sonnet
agent: technical-director
---

# 创建架构

此技能生成 `docs/architecture/architecture.md`，即把所有已批准 GDD 转化为
具体技术蓝图的主架构文档。它位于设计与实现之间，必须在 Sprint 规划开始前存在。

**与 `/architecture-decision` 不同**：ADR 记录单个具体决策。
此技能创建全系统蓝图，为 ADR 提供上下文。

确定评审模式（仅确定一次，并存储供本次运行的所有门禁子代理使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认为 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

**参数模式：**
- **无参数 / `full`**：完整引导式流程，从头到尾覆盖所有章节
- **`layers`**：仅聚焦系统分层图
- **`data-flow`**：仅聚焦模块间的数据流
- **`api-boundaries`**：仅聚焦 API 边界定义
- **`adr-audit`**：仅审计现有 ADR 的引擎兼容性缺口

---

## 阶段 0：加载全部上下文

在执行任何其他操作之前，按以下顺序加载完整的项目上下文：

### 0a. 引擎上下文（关键）

完整读取引擎参考库：

1. `docs/engine-reference/[engine]/VERSION.md`
   → 提取：引擎名称、版本、LLM 截止点、截止点后版本的风险级别
2. `docs/engine-reference/[engine]/breaking-changes.md`
   → 提取：所有 HIGH 和 MEDIUM 风险变更
3. `docs/engine-reference/[engine]/deprecated-apis.md`
   → 提取：应避免使用的 API
4. `docs/engine-reference/[engine]/current-best-practices.md`
   → 提取：与训练数据不同的截止点后最佳实践
5. `docs/engine-reference/[engine]/modules/` 中的所有文件
   → 提取：各领域的当前 API 模式

如果尚未配置引擎，停止并提示：
> "尚未配置引擎。请先运行 `/setup-engine`。如果不知道目标引擎及其版本，
> 就无法编写架构。"

### 0b. 设计上下文 + 技术需求提取

读取所有已批准的设计文档，并从每份文档中提取技术需求：

1. `design/gdd/game-concept.md` — 游戏支柱、类型、核心循环
2. `design/gdd/systems-index.md` — 所有系统、依赖关系、优先级层次
3. `.claude/docs/technical-preferences.md` — 命名约定、性能预算、
   允许使用的库、禁止使用的模式
4. **`design/gdd/` 中的每份 GDD** — 从每份文档中提取技术需求：
   - 游戏规则隐含的数据结构
   - 明示或暗示的性能约束
   - 系统所需的引擎能力
   - 跨系统通信模式（什么与什么通信、如何通信）
   - 必须持久化的状态（存档/读档影响）
   - 线程或时序要求

构建 **Technical Requirements Baseline**，即从所有 GDD 中提取的全部需求的
扁平列表，编号格式为 `TR-[gdd-slug]-[NNN]`。这是架构必须覆盖的完整需求集合。
按以下格式展示：

```
## Technical Requirements Baseline
提取自 [N] 份 GDD | 共 [X] 项需求

| Req ID | GDD | System | Requirement | Domain |
|--------|-----|--------|-------------|--------|
| TR-combat-001 | combat.md | 战斗 | 每帧检测碰撞箱 | 物理 |
| TR-combat-002 | combat.md | 战斗 | 连击状态机 | 核心 |
| TR-inventory-001 | inventory.md | 物品栏 | 物品持久化 | 存档/读档 |
```

此基线将输入后续每个阶段。本次会话结束时，不得有任何 GDD 需求缺少
支持它的架构决策。

### 0c. 现有架构决策

读取 `docs/architecture/` 中的所有文件，了解已经作出的决策。
列出找到的所有 ADR 及其所属领域。

### 0d. 生成知识缺口清单

继续之前，展示结构化摘要：

```
## Engine Knowledge Gap Inventory
Engine: [name + version]
LLM Training Covers: 最高约为 [version]
Post-Cutoff Versions: [list]

### HIGH RISK Domains（必须对照引擎参考资料验证后再作决策）
- [Domain]: [Key changes]

### MEDIUM RISK Domains（验证关键 API）
- [Domain]: [Key changes]

### LOW RISK Domains（在训练数据范围内，可能可靠）
- [Domain]: [no significant post-cutoff changes]

### Systems from GDD that touch HIGH/MEDIUM risk domains:
- [GDD system name] → [domain] → [risk level]
```

使用 `AskUserQuestion`：
- 提示："一个或多个引擎领域属于 HIGH RISK，LLM 在这些领域的知识可能不可靠。在执行这些领域的架构建议之前，应先与引擎文档交叉核对。你希望如何继续？"
- 选项：
  - [A] 继续，在整个输出中标记 HIGH RISK 领域
  - [B] 让我先检查引擎参考资料，在此暂停
  - [C] 显示哪些领域属于 HIGH RISK 及其原因

---

## 阶段 1：系统分层映射

将 `systems-index.md` 中的每个系统映射到一个架构层。标准游戏架构层如下：

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │  ← UI、HUD、菜单、VFX、音频
├─────────────────────────────────────────────┤
│  FEATURE LAYER                              │  ← 玩法系统、AI、任务
├─────────────────────────────────────────────┤
│  CORE LAYER                                 │  ← 物理、输入、战斗、移动
├─────────────────────────────────────────────┤
│  FOUNDATION LAYER                           │  ← 引擎集成、存档/读档、
│                                             │    场景管理、事件总线
├─────────────────────────────────────────────┤
│  PLATFORM LAYER                             │  ← 操作系统、硬件、引擎 API 表面
└─────────────────────────────────────────────┘
```

针对每个 GDD 系统，询问：
- 它属于哪一层？
- 它的模块边界是什么？
- 它独占哪些内容？（数据、状态、行为）

展示建议的分层分配，并在进入下一章节前请求批准。
立即将已批准的分层图写入骨架文件。

**引擎感知检查**：对于分配到 Core 和 Foundation 层的每个系统，
如果它涉及 HIGH 或 MEDIUM 风险的引擎领域，则予以标记。内联显示相关的引擎参考摘录。

---

## 阶段 2：模块所有权映射

为阶段 1 中定义的每个模块明确所有权：

- **Owns**：此模块独自负责哪些数据和状态
- **Exposes**：其他模块可以读取或调用什么
- **Consumes**：它从其他模块读取什么
- **Engine APIs used**：此模块直接调用哪些具体的引擎类/节点/信号
  （注明版本和风险级别）

按层分别以表格呈现，然后给出 ASCII 依赖关系图。

**引擎感知检查**：对于列出的每个引擎 API，对照相关模块参考文档进行验证。
如果 API 属于截止点后版本，则予以标记：

```
⚠️  [ClassName.method()] — Godot 4.6（截止点后版本，HIGH 风险）
    Verified against: docs/engine-reference/godot/modules/[domain].md
    Behaviour confirmed: [yes / NEEDS VERIFICATION]
```

写入前，获取用户对所有权映射的批准。

---

## 阶段 3：数据流

定义关键游戏场景中数据如何在模块间流动。至少覆盖：

1. **帧更新路径**：输入 → 核心系统 → 状态 → 渲染
2. **事件/信号路径**：系统如何在不紧耦合的情况下通信
3. **存档/读档路径**：哪些状态被序列化、哪个模块负责序列化
4. **初始化顺序**：哪些模块必须先于其他模块启动

适当时使用 ASCII 时序图。针对每条数据流：
- 指明传输的数据
- 确定生产者和消费者
- 说明它是同步调用、信号/事件还是共享状态
- 标记跨越线程边界的任何数据流

每个场景均需获得用户批准后再写入。

---

## 阶段 4：API 边界

定义模块间的公开契约。针对每个边界：

- 模块向系统其余部分公开的接口是什么？
- 入口点是什么（函数/信号/属性）？
- 调用方必须遵守哪些不变量？
- 模块必须向调用方保证什么？

使用伪代码或项目的实际语言（取自技术偏好）编写。
这些内容将成为程序员据以实现的契约。

**引擎感知检查**：如果任何接口使用引擎特定类型（例如 Godot 中的
`Node`、`Resource`、`Signal`），标记其版本，并验证该类型在目标引擎版本中
存在且签名未发生变化。

---

## 阶段 5：ADR 审计 + 可追溯性检查

根据阶段 1-4 构建的架构以及阶段 0b 中的 Technical Requirements Baseline，
评审阶段 0c 中的所有现有 ADR。

### ADR 质量检查

针对每个 ADR：
- [ ] 是否包含 Engine Compatibility 章节？
- [ ] 是否记录了引擎版本？
- [ ] 是否标记了截止点后 API？
- [ ] 是否包含 "GDD Requirements Addressed" 章节？
- [ ] 是否与本次会话中作出的分层/所有权决策冲突？
- [ ] 对锁定的引擎版本而言是否仍然有效？

| ADR | Engine Compat | Version | GDD Linkage | Conflicts | Valid |
|-----|--------------|---------|-------------|-----------|-------|
| ADR-0001: [title] | ✅/❌ | ✅/❌ | ✅/❌ | None/[conflict] | ✅/⚠️ |

### 可追溯性覆盖检查

将 Technical Requirements Baseline 中的每项需求映射到现有 ADR。
对于每项需求，检查是否有 ADR 的 "GDD Requirements Addressed" 章节
或决策文本覆盖它：

| Req ID | Requirement | ADR Coverage | Status |
|--------|-------------|--------------|--------|
| TR-combat-001 | 每帧检测碰撞箱 | ADR-0003 | ✅ |
| TR-combat-002 | 连击状态机 | — | ❌ GAP |

统计：X 项已覆盖，Y 项存在缺口。每个缺口都成为一个 **Required New ADR**。

### Required New ADRs

列出本次架构会话（阶段 1-4）中作出但尚无对应 ADR 的所有决策，
再加上所有未覆盖的 Technical Requirements。按层分组，Foundation 优先：

**Foundation Layer（开始编写任何代码之前必须创建）：**
- `/architecture-decision [title]` → 覆盖：TR-[id], TR-[id]

**Core Layer：**
- `/architecture-decision [title]` → 覆盖：TR-[id]

---

## 阶段 6：缺失 ADR 列表

根据完整架构，生成应当存在但尚不存在的完整 ADR 列表。
按优先级分组：

**开始编码前必须具备（Foundation 和 Core 决策）：**
- [e.g. "Scene management and scene loading strategy"]
- [e.g. "Event bus vs direct signal architecture"]

**应在构建相关系统前具备：**
- [e.g. "Inventory serialisation format"]

**可推迟到实现阶段：**
- [e.g. "Specific shader technique for water"]

---

## 阶段 7：编写主架构文档

所有章节均获批准后，将完整文档写入
`docs/architecture/architecture.md`。

用一个段落概述文档将包含的内容（分层、模块、数据流、ADR 缺口）。然后使用 `AskUserQuestion`：
- "All sections approved. May I write the master architecture document?"
  - [A] 是，立即写入 `docs/architecture/architecture.md`
  - [B] 先内联显示完整草稿，然后再次询问
  - [C] 暂不写入，我还有更多变更需要讨论

文档结构：

```markdown
# [Game Name] — 总体架构文档

## 文档状态（Document Status）
- 版本: [N]
- 最后更新: [date]
- 引擎: [name + version]
- 覆盖游戏设计文档 (GDD): [list]
- 引用架构决策记录 (ADR): [list]

## 引擎知识缺口汇总（Engine Knowledge Gap Summary）
[Condensed from Phase 0d inventory — 高 / 中风险领域及其影响说明]

## 系统层级图（System Layer Map）
[From Phase 1]

## 模块权责归属（Module Ownership）
[From Phase 2]

## 数据流设计（Data Flow）
[From Phase 3]

## API 边界定义（API Boundaries）
[From Phase 4]

## 架构决策记录审计（ADR Audit）
[From Phase 5]

## 待新增架构决策记录（Required ADRs）
[From Phase 6]

## 架构设计原则（Architecture Principles）    
[3–5 条核心准则，指导本项目全部技术决策；
依据游戏概念、游戏设计文档与技术选型偏好制定]

## 待决议题（Open Questions）
[延后确定的事项 — 必须在对应层级开发前完成决策]
```

---

## 阶段 7b：技术总监签核 + 主程序员可行性评审

写入主架构文档后，在移交前执行明确签核。

**步骤 1 — 技术总监自评审**（此技能以 technical-director 身份运行）：

应用 **TD-ARCHITECTURE** 门禁（`.claude/docs/director-gates.md`）进行自评审。
根据已完成文档检查该门禁定义中的全部四项标准。

**评审模式检查** — 在生成 LP-FEASIBILITY 子代理前执行：
- `solo` → 跳过。注明："LP-FEASIBILITY skipped — Solo mode." 继续进入阶段 8 移交。
- `lean` → 跳过（不是 PHASE-GATE）。注明："LP-FEASIBILITY skipped — Lean mode." 继续进入阶段 8 移交。
- `full` → 正常生成子代理。

**步骤 2 — 通过 Task 生成 `lead-programmer` 子代理，并使用 LP-FEASIBILITY 门禁（`.claude/docs/director-gates.md`）：**

传入：架构文档路径、技术需求基线摘要、ADR 列表。

**步骤 3 — 向用户展示两份评估：**

并排显示技术总监评估和主程序员裁决。

使用 `AskUserQuestion`："技术总监和主程序员已评审该架构。你希望如何继续？"
选项：`接受并继续移交` / `先修订已标记的项目` / `讨论具体问题`

**步骤 4 — 在架构文档中记录签核：**

更新 Document Status 章节：
```
- 技术总监 签字确认: [date] — APPROVED / APPROVED WITH CONDITIONS
- 主程可行性评估: FEASIBLE / CONCERNS ACCEPTED / REVISED
```

内联显示拟议的 Document Status 区块，然后使用 `AskUserQuestion`：
- "可以用签核结果更新 Document Status 章节吗？"
  - [A] 是，应用到 `docs/architecture/architecture.md`
  - [B] 暂不更新，我想先重新审视这些问题

---

## 阶段 8：移交

**步骤 1 — 更新会话状态**：展示拟写入的摘要，并使用 `AskUserQuestion` 询问用户是否可以更新 `production/session-state/active.md`。获得批准后，再写入已写入的产物、TD/LP 签核裁决、任何阻塞项、剩余的必需 ADR 和下一步。

**步骤 2 — 输出移交内容**，严格使用以下模板（不使用自由格式散文，不改写章节标题）：

---

## Architecture Complete

`docs/architecture/architecture.md` v1.0 — [TD verdict: APPROVED / APPROVED WITH CONCERNS / CONCERNS]. [One sentence on what the architecture covers.]

---

## Run These ADRs Next

**1. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[One sentence: what it defines and what it unblocks.]

**2. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[One sentence.]

**3. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[One sentence.]

按优先级顺序列出阶段 6 中最优先的 3 项。如果剩余不足 3 项，只列出尚未完成的项。

---

## Gate-Check Readiness

> **运行 `/gate-check [stage]` 前必须完成：**
> - [ ] Accept ADRs: [list Proposed ADR IDs that must be Accepted]
> - [ ] Write ADRs: [list ADR IDs that must still be written]
> - [ ] 运行 `/test-setup` — 搭建 `tests/unit/`、`tests/integration/`、CI 工作流和示例测试文件
> - [ ] 运行 `/ux-design` — 创建 `design/ux/interaction-patterns.md` 和 `design/accessibility-requirements.md`
>
> 所有复选框均勾选后，运行 `/gate-check [stage]`。

如果没有任何阻塞项，改为写入：
> 无阻塞项，立即运行 `/gate-check [stage]`。

---

## Open Questions to Watch

| ID | Summary | Priority | Resolution Path |
|----|---------|----------|-----------------|
| QQ-XX | [short description] | High / Medium / Low | [ADR or system that resolves it] |

如果没有未解决的 QQ，则完全省略此章节。

---

（移交结束。结束分隔线后不要添加尾随说明。）

---

## 协作协议

此技能在每个阶段都遵循协作设计原则：

1. **静默加载上下文** — 不叙述文件读取过程
2. **展示发现** — 显示知识缺口清单和分层建议
3. **决策前询问** — 为每个架构选择提供选项
4. **批准前展示草稿** — 请求写入前，先内联显示内容。
   不得请求批准用户尚未看过的章节。
5. **使用 `AskUserQuestion` 请求写入批准** — 纯文本的“可以吗？”并不足够。
    使用带 [A]/[B]/[C] 标记选项的结构化工具（立即写入 / 先显示完整草稿 /
   暂不写入）。对于多文件变更集，列出每个文件及其变更，然后集中询问一次，
   不要针对每个文件分别用纯文本询问。
6. **增量写入** — 立即写入每个已批准的章节；不要积累所有内容后在最后一次性写入。
   这样可以承受会话崩溃。

不得在没有用户输入的情况下作出有约束力的架构决策。如果用户不确定，
提供 2-4 个选项及其优缺点，然后再请用户决定。

---

## 建议的后续步骤

- 为阶段 6 中列出的每个必需 ADR 运行 `/architecture-decision [title]`，优先处理 Foundation 层 ADR
- 运行 `/architecture-review`，根据刚编写的 ADR 初始化 Requirements Traceability Matrix 和 TR 注册表。这是 Pre-Production 门禁前的必需步骤。
- 运行 `/test-setup` 以搭建 `tests/unit/`、`tests/integration/`、CI 工作流和示例测试（gate-check 必需）
- 运行 `/ux-design` 以初始化 `design/ux/interaction-patterns.md` 和 `design/accessibility-requirements.md`（gate-check 必需）
- 编写完必需 ADR 后，运行 `/create-control-manifest` 以生成分层规则清单
- 完成所有必需 ADR、`/test-setup` 和 `/ux-design` 后，运行 `/gate-check pre-production`
