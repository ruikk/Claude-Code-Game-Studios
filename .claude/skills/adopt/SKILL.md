---
name: adopt
description: "棕地项目引导：审计现有项目产物是否符合模板格式（而不只是检查是否存在），按影响对差距分类，并生成编号迁移计划。适用于加入进行中的项目或从旧版模板升级。它不同于 /project-stage-detect（后者检查存在哪些内容）：本技能检查现有内容能否真正配合模板技能正常工作。"
argument-hint: "[范围: full | gdds | adrs | stories | infra]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
agent: technical-director
---

# Adopt：棕地项目模板接入

本技能审计现有项目产物与模板技能流水线的**格式兼容性**，
然后生成一份按优先级排列的迁移计划。

**本技能不是 `/project-stage-detect`。**
`/project-stage-detect` 回答：*存在哪些内容？*
`/adopt` 回答：*现有内容能否真正配合模板技能正常工作？*

一个项目可以已有 GDD、ADR 和故事，但如果这些产物的内部格式错误，
所有依赖格式的技能仍可能静默失败或生成错误结果。

**输出：** `docs/adoption-plan-[date].md`，一份持久、可核查的迁移计划。

**参数模式：**

**审计模式：** `$ARGUMENTS[0]`（留空 = `full`）

- **无参数 / `full`**：完整审计，涵盖所有产物类型
- **`gdds`**：仅审计 GDD 格式兼容性
- **`adrs`**：仅审计 ADR 格式兼容性
- **`stories`**：仅审计故事格式兼容性
- **`infra`**：仅审计基础设施产物差距（注册表、清单、sprint-status、stage.txt）

---

## 阶段 1：检测项目状态

读取前先输出一行：`"正在扫描项目产物..."`，以确认技能在静默读取阶段仍在运行。

然后静默读取，之后才能展示其他任何内容。

### 存在性检查
- `production/stage.txt`：如果存在，则读取它（权威阶段信息）
- `design/gdd/game-concept.md`：概念是否存在？
- `design/gdd/systems-index.md`：系统索引是否存在？
- 统计 GDD 文件：`design/gdd/*.md`（排除 game-concept.md 和 systems-index.md）
- 统计 ADR 文件：`docs/architecture/adr-*.md`
- 统计故事文件：`production/epics/**/*.md`（排除 EPIC.md）
- `.claude/docs/technical-preferences.md`：是否已配置引擎？
- `docs/engine-reference/`：是否存在引擎参考文档？
- 对 `docs/adoption-plan-*.md` 执行 Glob；如果存在先前计划，记录最新计划的文件名

### 推断阶段（没有 stage.txt 时）
使用与 `/project-stage-detect` 相同的启发式规则：
- `src/` 中有 10 个以上源文件 → Production
- `production/epics/` 中有故事 → Pre-Production
- 存在 ADR → Technical Setup
- 存在 systems-index.md → Systems Design
- 存在 game-concept.md → Concept
- 什么都没有 → Fresh（不是棕地项目，建议使用 `/start`）

如果项目看起来是全新项目（完全没有产物），使用 `AskUserQuestion`：
- “这看起来是一个全新项目，没有找到现有产物。`/adopt` 适用于已有工作需要迁移的项目。你想怎么做？”
  - “运行 `/start`，开始首次引导式接入”
  - “我的产物位于非标准位置，帮我找到它们”
  - “取消”

然后停止，无论用户选择哪个选项都不要继续审计
（每个选项都会进入不同技能或人工调查流程）。

报告：“检测到的阶段：[phase]。找到：[N] 个 GDD、[M] 个 ADR、[P] 个故事。”

---

## 阶段 2：格式审计

对于参数模式范围内的每种产物类型，不仅要检查文件是否存在，
还要检查其是否包含模板要求的内部结构。

### 2a：GDD 格式审计

对于找到的每个 GDD 文件，通过扫描标题检查以下 8 个必需章节：

| 必需章节 | 要查找的标题模式 |
|---|---|
| 概述 | `## Overview` |
| 玩家幻想 | `## Player Fantasy` |
| 详细规则 / 设计 | `## Detailed` 或 `## Core Rules` 或 `## Detailed Design` |
| 公式 | `## Formulas` 或 `## Formula` |
| 边界情况 | `## Edge Cases` |
| 依赖项 | `## Dependencies` 或 `## Depends` |
| 调优参数 | `## Tuning` |
| 验收标准 | `## Acceptance` |

对于每个 GDD，记录：
- 存在哪些章节
- 缺少哪些章节
- 已存在的章节中是有实际内容，还是只有占位文本
  （`[To be designed]` 或等效内容）

还要检查：每个 GDD 的头部块中是否有 `**Status**:` 字段？
有效值：`In Design`、`Designed`、`In Review`、`Approved`、`Needs Revision`。

### 2b：ADR 格式审计

对于找到的每个 ADR 文件，检查以下关键章节：

| 章节 | 缺失时的影响 |
|---|---|
| `## Status` | **阻塞**：`/story-readiness` 的 ADR 状态检查会静默放行所有内容 |
| `## ADR Dependencies` | 高：`/architecture-review` 中的依赖排序会失效 |
| `## Engine Compatibility` | 高：无法确定知识截止日期之后的 API 风险 |
| `## GDD Requirements Addressed` | 中：可追溯性矩阵会丢失覆盖关系 |
| `## Performance Implications` | 低：不是流水线关键项 |

对于每个 ADR，记录存在和缺失的章节；如果存在 Status 章节，还要记录当前 Status 值。

### 2c：systems-index.md 格式审计

如果 `design/gdd/systems-index.md` 存在：

1. **带括号的状态值**：使用 Grep 查找 Status 单元格中任何包含括号的值，
   例如 `"Needs Revision ("`、`"In Progress ("` 等。
   这些值会破坏 `/gate-check`、`/create-stories` 和 `/architecture-review`
   中的精确字符串匹配。**阻塞。**

2. **有效状态值**：检查 Status 列的值是否仅来自：
   `Not Started`、`In Progress`、`In Review`、`Designed`、`Approved`、`Needs Revision`
   标记所有无法识别的值。

3. **列结构**：检查表格至少包含 System name、Layer、Priority、Status 列。
   缺少这些列会削弱技能功能。

### 2d：故事格式审计

对于找到的每个故事文件：

- **`Manifest Version:` 字段**：故事头部是否存在？（低：缺失时自动通过）
- **TR-ID 引用**：故事是否包含 `TR-[a-z]+-[0-9]+` 模式？（中：无法跟踪陈旧状态）
- **ADR 引用**：故事是否至少引用一个 ADR？（检查 `ADR-` 模式）
- **Status 字段**：是否存在且可读？
- **验收标准**：故事是否包含复选框列表（`- [ ]`）？

### 2e：基础设施审计

| 产物 | 路径 | 缺失时的影响 |
|---|---|---|
| TR 注册表 | `docs/architecture/tr-registry.yaml` | 高：没有稳定的需求 ID |
| 控制清单 | `docs/architecture/control-manifest.md` | 高：故事没有分层规则 |
| 清单版本标记 | 清单头部中的 `Manifest Version:` | 中：陈旧状态检查失效 |
| Sprint 状态 | `production/sprint-status.yaml` | 中：`/sprint-status` 会回退到 Markdown |
| 阶段文件 | `production/stage.txt` | 中：阶段自动检测不可靠 |
| 引擎参考 | `docs/engine-reference/[engine]/VERSION.md` | 高：ADR 引擎检查失效 |
| 架构可追溯性 | `docs/architecture/architecture-traceability.md` | 中：没有持久矩阵 |

### 2f：技术偏好审计

读取 `.claude/docs/technical-preferences.md`。检查每个字段是否为 `[TO BE CONFIGURED]`：
- Engine、Language、Rendering、Physics：未配置时为高（ADR 技能会失败）
- Naming conventions：中
- Performance budgets：中
- Forbidden Patterns、Allowed Libraries：低（按设计初始为空）

---

## 阶段 3：差距分类和优先级排序

将所有审计中发现的每个差距归入四个严重级别：

**阻塞**：会导致模板技能*现在*静默生成错误结果。
示例：ADR 缺少 Status 字段、systems-index 中存在带括号的状态值、
已有 ADR 时引擎尚未配置。

**高**：会导致生成的故事缺少安全检查，或导致基础设施初始化失败。
示例：ADR 缺少 Engine Compatibility、GDD 缺少 Acceptance Criteria
（无法从中生成故事）、缺少 tr-registry.yaml。

**中**：会降低质量和流水线跟踪能力，但不会破坏功能。
示例：GDD 缺少 Tuning Knobs 或 Formulas 章节、故事缺少 TR-ID、
缺少 sprint-status.yaml。

**低**：适合追溯改进，但并不紧急。
示例：故事缺少 Manifest Version 标记、GDD 缺少 Open Questions 章节。

统计每个级别的总数。如果阻塞和高等级差距均为零，则报告项目与模板兼容，
只剩建议性改进。

---

## 阶段 4：构建迁移计划

编写一份按顺序编号的行动计划。排序规则：
1. 阻塞差距优先（修复前，任何流水线技能都无法可靠运行）
2. 高等级差距其次；基础设施先于 GDD/ADR 内容（初始化依赖正确格式）
3. 中等级差距按以下顺序：GDD 差距、ADR 差距、故事差距（故事依赖 GDD 和 ADR）
4. 低等级差距最后

对于每个差距，生成一个计划条目，其中包含：
- 清晰的问题陈述（一句话，不使用术语）
- 如果有技能可以处理，则给出准确的修复命令
- 如果需要直接编辑，则给出手动步骤
- 时间估算（粗略：5 分钟 / 30 分钟 / 1 个会话）
- 用于跟踪的复选框 `- [ ]`

**特殊情况：systems-index 中带括号的状态值：**
如果存在，这始终是第一项。显示需要更改的确切值和准确的替换文本。
在写入计划前，询问是否立即修复此问题。

**特殊情况：ADR 缺少 Status 字段：**
对于每个受影响的 ADR，修复命令是：
`/architecture-decision retrofit docs/architecture/adr-[NNNN]-[slug].md`
将每个 ADR 分别列为可勾选项。

**特殊情况：GDD 缺少章节：**
对于每个受影响的 GDD，列出缺少的章节和修复命令：
`/design-system retrofit design/gdd/[filename].md`

**基础设施初始化顺序**：始终按以下顺序出现：
1. 先修复 ADR 格式（注册表依赖读取 ADR Status 字段）
2. 运行 `/architecture-review` → 初始化 `tr-registry.yaml`
3. 运行 `/create-control-manifest` → 创建带版本标记的清单
4. 运行 `/sprint-plan update` → 创建 `sprint-status.yaml`
5. 运行 `/gate-check [phase]` → 以权威方式写入 `stage.txt`

**现有故事**：明确注明：
> “现有故事仍可配合所有模板技能正常工作：字段缺失时，所有新的格式检查都会自动通过。
> 在重新生成之前，它们不会获得 TR-ID 陈旧状态跟踪或清单版本检查能力。
> 这是有意设计的：不要重新生成已在进行中的故事。”

---

## 阶段 5：展示摘要并请求写入

写入前展示简洁摘要：

```
## 接入审计摘要
检测到的阶段：[phase]
引擎：[已配置 / 未配置]
已审计 GDD：[N] 个（[X] 个完全兼容，[Y] 个有差距）
已审计 ADR：[N] 个（[X] 个完全兼容，[Y] 个有差距）
已审计故事：[N] 个

差距数量：
  阻塞：[N]：不修复这些问题，模板技能将发生故障
  高：  [N]：运行 /create-stories 或 /story-readiness 不安全
  中：  [N]：质量下降
  低：  [N]：可选改进

预计修复工作量：[X 个阻塞项 × 每项约 Y 分钟 = 大约 Z 小时]
```

请求写入前，显示**差距预览**：
- 将每个阻塞差距列为单行项目符号，描述实际问题
  （例如 `systems-index.md：3 行包含带括号的状态值`、
  `adr-0002.md：缺少 ## Status 章节`）。不要只显示数量，要展示实际条目。
- 高 / 中 / 低只显示数量（例如 `高：4，中：2，低：1`）。

这能让用户在承诺写入文件前获得足够上下文来判断范围。

如果在阶段 1 检测到先前的接入计划，添加说明：
> “`docs/adoption-plan-[prior-date].md` 中存在先前计划。新计划将反映当前项目状态，
> 不会与上次运行结果进行差异比较。”

使用 `AskUserQuestion`：
- “准备好写入迁移计划了吗？”
  - “是，写入 `docs/adoption-plan-[date].md`”
  - “先显示完整计划预览（暂不写入）”
  - “取消，我将手动处理迁移”

如果用户选择“先显示完整计划预览”，以带围栏的 Markdown 代码块输出完整计划，
然后使用相同的三个选项再次询问。

---

## 阶段 6：写入接入计划

如果获得批准，按以下结构写入 `docs/adoption-plan-[date].md`：

```markdown
# 接入计划

> **生成日期**：[date]
> **项目阶段**：[phase]
> **引擎**：[名称 + 版本，或“未配置”]
> **模板版本**：v1.0+

按顺序完成以下步骤。每完成一项就将其勾选。
随时可以重新运行 `/adopt` 来检查剩余差距。

---

## 步骤 1：修复阻塞差距

[每个阻塞差距对应一个子章节，包含问题、修复命令、时间估算和复选框]

---

## 步骤 2：修复高优先级差距

[每个高等级差距对应一个子章节]

---

## 步骤 3：初始化基础设施

### 3a. 注册现有需求（创建 tr-registry.yaml）
运行 `/architecture-review`：即使 ADR 已经存在，本次运行仍会根据现有 GDD 和 ADR
初始化 TR 注册表。
**时间**：1 个会话（对于大型代码库，审查可能耗时较长）
- [ ] 已创建 tr-registry.yaml

### 3b. 创建控制清单
运行 `/create-control-manifest`
**时间**：30 分钟
- [ ] 已创建 docs/architecture/control-manifest.md

### 3c. 创建 Sprint 跟踪文件
运行 `/sprint-plan update`
**时间**：5 分钟（如果 Sprint 计划已作为 Markdown 存在）
- [ ] 已创建 production/sprint-status.yaml

### 3d. 设置权威项目阶段
运行 `/gate-check [current-phase]`
**时间**：5 分钟
- [ ] 已写入 production/stage.txt

---

## 步骤 4：中优先级差距

[每个中等级差距对应一个子章节]

---

## 步骤 5：可选改进

[每个低等级差距对应一个子章节]

---

## 现有故事的预期行为

现有故事仍可配合所有模板技能正常工作。字段缺失时，新的格式检查
（TR-ID 验证、清单版本陈旧状态检查）会自动通过，因此不会破坏任何内容。
重新生成之前，它们不会获得陈旧状态跟踪能力。不要重新生成进行中或已完成的故事。

---

## 重新运行

完成步骤 3 后再次运行 `/adopt`，验证所有阻塞和高等级差距均已解决。
新一轮运行将反映项目的当前状态。
```

---

## 阶段 6b：设置审查模式

写入接入计划后（或者用户取消写入时），检查 `production/review-mode.txt`
是否存在。

**如果存在**：读取它并注明当前模式：“审查模式已设置为 `[current]`。”，然后跳过提示。

**如果不存在**：使用 `AskUserQuestion`：

- **提示**：“还有一个设置步骤：在完成工作流的过程中，你希望接受多大程度的设计审查？”
- **选项**：
  - `Full`：Director 专家在每个关键工作流步骤进行审查。最适合团队、学习工作流，或希望每项决策都获得详尽反馈的情况。
  - `Lean (recommended)`：仅在阶段门转换（/gate-check）时由 Director 审查，跳过各技能审查。适合个人开发者和小团队的均衡选择。
  - `Solo`：完全没有 Director 审查，速度最快。最适合 Game Jam、原型，或认为审查会带来负担的情况。

选择后立即将选项写入 `production/review-mode.txt`，无需另行询问“可以写入吗？”：
- `Full` → 写入 `full`
- `Lean (recommended)` → 写入 `lean`
- `Solo` → 写入 `solo`

如果 `production/` 目录不存在，则创建它。

---

## 阶段 7：提供第一个行动项

写入计划后不要就此停止。选择优先级最高的一个差距，并使用 `AskUserQuestion`
询问是否立即处理。选择第一个适用的分支：

**如果 systems-index.md 中存在带括号的状态值：**
使用 `AskUserQuestion`：
- “最紧急的修复是 `systems-index.md`：[N] 行包含带括号的状态值
  （例如 `Needs Revision (参见备注)`），目前会破坏 /gate-check、
  /create-stories 和 /architecture-review。我可以直接在原文件中修复这些值。”
  - “立即修复，编辑 systems-index.md”
  - “我会自行修复”
  - “完成，只保留计划即可”

**如果 ADR 缺少 `## Status`（并且没有上述括号问题）：**
使用 `AskUserQuestion`：
- “最紧急的修复是为 [N] 个 ADR 添加 `## Status`：[list filenames]。
  缺少该章节时，/story-readiness 会静默放行所有 ADR 检查。
  是否从 [first affected filename] 开始？”
  - “是，立即改造 [first affected filename]”
  - “逐个改造全部 [N] 个 ADR”
  - “我会自行处理 ADR”

**如果 GDD 缺少 Acceptance Criteria（并且没有上述阻塞问题）：**
使用 `AskUserQuestion`：
- “最紧急的差距是 [N] 个 GDD 缺少 Acceptance Criteria：
  [list filenames]。缺少该章节时，/create-stories 无法生成故事。
  是否从 [highest-priority GDD filename] 开始？”
  - “是，立即向 [GDD filename] 添加 Acceptance Criteria”
  - “逐个处理全部 [N] 个 GDD”
  - “我会自行处理 GDD”

**如果不存在阻塞或高等级差距：**
使用 `AskUserQuestion`：
- “没有阻塞差距，该项目与模板兼容。下一步做什么？”
  - “引导我完成中优先级改进”
  - “运行 /project-stage-detect，进行更广泛的健康检查”
  - “完成，我会按自己的节奏执行计划”

> **接入计划已保存到 `docs/adoption-plan-[date].md`。** 在完成各项修复时，随时可以重新运行 `/adopt` 来复查剩余差距。

---

## 协作协议

1. **静默读取**：展示任何内容前，先完成完整审计
2. **先显示摘要**：请求写入前，让用户了解范围
3. **写入前询问**：创建接入计划文件前，始终先确认
4. **提供选择，不强迫执行**：计划仅供建议；由用户决定修复哪些内容以及何时修复
5. **一次只处理一个行动项**：交付计划后，只提供一个明确的下一步，
   不要同时列出六件要做的事
6. **绝不重新生成现有产物**：只填补现有内容中的差距；
   不要重写已有内容的 GDD、ADR 或故事
