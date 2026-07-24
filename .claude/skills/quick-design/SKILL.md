---
name: quick-design
description: "面向小型变更的轻量级设计规格——数值调整、轻量机制和平衡性修改。当系统 GDD 已存在，或变更过小而不值得单独编写完整文档时，跳过完整 GDD 编写。生成可直接嵌入故事文件的快速设计规格。"
argument-hint: "[brief description of the change]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# 快速设计

这是针对不需要完整 GDD 的变更的**轻量级设计路径**。
通过 `/design-system` 编写完整 GDD 是重量级路径。对于预计实现时间不超过约 4 小时的工作使用此技能，例如数值调整、轻微行为修改、向现有系统添加小功能，或小到不值得编写完整文档的独立功能。

**输出：** `design/quick-specs/[name]-[date].md`

**运行时机：** 当变更对于 `/design-system` 来说过小，但又重要到不能没有书面依据就实现时运行。

---

## 1. 分类变更

首先读取参数，并确定此变更属于以下哪一类：

- **Tuning** —— 在现有系统中修改数字或平衡性数值，但不改变行为（最小路径）。例如：“将跳跃高度从 5 个单位提高到 6 个单位”、“将敌人巡逻速度降低 10%”。
- **Tweak** —— 对现有系统进行小型行为修改，不引入新状态、分支或系统。例如：“让迭代在第 1 帧无敌”、“允许连招取消为翻滚”。
- **Addition** —— 向现有系统添加小型机制，可能引入 1-2 个新状态或交互。例如：“为格挡机制添加招架窗口”、“为基础攻击添加蓄力变体”。
- **New Small System** —— 足够小的独立功能，没有现有 GDD，且实现工作量约少于一周。例如：“成就弹窗系统”、“简单的昼夜视觉循环”。

如果变更不符合这些类别——例如引入具有大量跨系统依赖的新系统、需要超过一周的实现工作，或从根本上改变现有系统的核心规则——请停止并改用 `/design-system`。

如果没有参数，请用户描述变更（纯文本提示），然后使用上述标准进行分类。

使用 `AskUserQuestion` 呈现推断出的分类：
- 提示：“我将其分类为 **[inferred type]** —— [brief reason]。这样正确吗？”
- 选项：
  - `[A] 是 —— [inferred type] 正确`
  - `[B] Tuning —— 仅修改数字或平衡性数值`
  - `[C] Tweak —— 对现有系统进行小型行为修改`
  - `[D] Addition —— 向现有系统添加小型机制`
  - `[E] New Small System —— 独立功能，工作量少于一周`
  - `[F] 规模过大 —— 将我引导至 /design-system`

如果选择 [F]：停止。结论：**REDIRECTED** —— 对此变更使用 `/design-system`。
否则：继续使用选定的类型。

---

## 2. 上下文扫描

起草任何内容前，读取相关上下文：

- 在 `design/gdd/` 中搜索与此变更最相关的 GDD。读取此变更会影响的章节。
- 检查 `design/gdd/systems-index.md` 是否存在。如果存在，读取它以了解此系统在依赖图中的位置及其所属层级。如果不存在，记录 "No systems index found — skipping dependency tier check." 并继续。
- 检查 `design/quick-specs/` 中是否有涉及此系统的既有快速规格，避免与其矛盾。
- 如果这是 Tuning 变更，还要检查 `assets/data/` 中保存相关数值的数据文件。

报告发现的内容：“Found GDD at [path]. Relevant section: [section name]. No conflicting quick specs found.”（或注明发现的任何冲突。）

---

## 3. 起草快速设计规格

根据变更类别使用适当的规格格式。

### Tuning 变更

生成一个表格：

```markdown
# 快速设计规格：[Title]

**类型**：Tuning
**系统**：[System name]
**GDD 引用**：`design/gdd/[filename].md` — Tuning Knobs 章节
**日期**：[today]

## 变更

| 参数 | 旧值 | 新值 | 理由 |
|-----------|-----------|-----------|-----------|
| [param]   | [old]     | [new]     | [why]     |

## 调参项映射

映射到 GDD 调参项：[knob name and its documented range]。
新值[within / at the edge of / outside]文档规定的范围。
[If outside: explain why the range should be extended.]

## 验收标准

- [ ] [Parameter] 从 `assets/data/[file]` 读取 [new value]
- [ ] 在[具体上下文]中可以观察到行为差异
- [ ] [相关行为]没有回归
```

### Tweak 和 Addition 变更

```markdown
# 快速设计规格：[Title]

**类型**：[Tweak / Addition]
**系统**：[System name]
**GDD 引用**：`design/gdd/[filename].md`
**日期**：[today]

## 变更摘要

[用 1-2 句话描述变更内容及原因。]

## 动机

[为什么需要此变更？它解决了什么玩家体验问题？如果适用，请引用相关的 MDA 审美或玩家反馈。]

## 设计差异

当前 GDD 的内容如下（引用自 `design/gdd/[filename].md`，[section]）：

> [exact quote of the relevant rule or description]

此规格将其修改为：

[用与 GDD Detailed Rules 章节相同的精确程度书写新规则或描述。程序员应能够仅凭此文本完成实现。]

## 新规则 / 数值

[完整且明确地说明替换内容。如果引入新状态，请列出它们。如果引入新参数，请定义其范围。]

## 受影响的系统

| 系统 | 影响 | 所需操作 |
|--------|--------|-----------------|
| [system] | [how it is affected] | [update GDD / update data file / no action] |

## 验收标准

- [ ] [具体且可测试的标准 1]
- [ ] [具体且可测试的标准 2]
- [ ] [具体且可测试的标准 3]
- [ ] 无回归：[不得破坏的原有行为]

## 是否需要更新 GDD？

[Yes / No]
[If yes: which file, which section, and what the update should say.]
```

### New Small System 变更

使用精简版 GDD 结构。仅包含直接必要的章节；除非系统明确需要，否则跳过 Player Fantasy、完整 Formulas 和 Edge Cases。

```markdown
# 快速设计规格：[Title]

**类型**：New Small System
**范围**：[用 1-2 句话描述此系统做什么和不做什么]
**日期**：[today]
**预计实现时间**：[hours]

## 概述

[用一段新团队成员能够理解的文字说明。此系统做什么、何时激活，以及产生什么结果？]

## 核心规则

[明确无歧义地描述系统规则。对于顺序行为使用编号列表，对于条件使用项目符号列表。描述必须足够精确，使程序员无需提问即可实现。]

## 调参项

| 调参项 | 默认值 | 范围 | 类别 | 理由 |
|------|---------|-------|----------|-----------|
| [name] | [value] | [min–max] | [feel/curve/gate] | [why this default] |

所有数值必须存放在 `assets/data/[appropriate-file].json` 中，不得硬编码。

## 验收标准

- [ ] [功能标准：执行正确行为]
- [ ] [功能标准：处理边界情况]
- [ ] [体验标准：手感正确——试玩需要验证的内容]
- [ ] [回归标准：不破坏相邻系统]

## 系统索引

此系统当前不在 `design/gdd/systems-index.md` 中。
[If it should be added: suggest which layer and priority tier.]
[If it is too small to track: state "This system is below systems-index tracking threshold — quick spec is sufficient."]
```

---

## 4. 审批与归档

向用户完整呈现草稿。然后使用 `AskUserQuestion`：
- 提示：“这是快速设计规格草稿。你希望如何继续？”
- 选项：
  - `[A] 批准 —— 按当前内容写入`
  - `[B] 修改 —— 我会描述需要更改的内容`
  - `[C] 规模增长过大 —— 改用 /design-system`

如果选择 [B]：收集要求的变更，修改草稿，然后重新呈现此规格。
如果选择 [C]：停止。结论：**REDIRECTED** —— 对此变更使用 `/design-system`。

如果选择 [A]：询问“可以将此快速设计规格写入
`design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`？”

文件名使用当天日期。标题应为描述变更的 kebab-case 文本（例如：`jump-height-tuning-2026-03-10`、`parry-window-addition-2026-03-10`）。

如果同意，若 `design/quick-specs/` 目录不存在则创建它，然后写入文件。

如果需要更新 GDD（规格中已标记），写入快速规格后单独询问：

“此规格修改了 [System Name] 中的规则。可以更新
`design/gdd/[filename].md` ——具体更新 [section name] 章节吗？”

询问前展示将要变更的确切文本（旧内容与新内容）。没有明确批准不得编辑 GDD。

---

## 5. 交接

写入文件后输出：

```
快速设计规格已写入：design/quick-specs/[filename].md
类型：[Tuning / Tweak / Addition / New Small System]
系统：[system name]
GDD 更新：[Required — pending approval / Applied / Not required]

下一步：此规格已准备好在实现前通过 `/story-readiness` 验证。在故事的 GDD Reference 字段中引用此规格。
```

### 流程说明

结论：**COMPLETE** —— 快速设计规格已写入，可以开始实现。

快速设计规格按设计**跳过** `/design-review` 和 `/review-all-gdds`。它们用于小型、低风险且范围明确的变更，因为完整评审流程的成本高于变更本身的风险。

如果符合以下任一条件，则改用完整流程：
- 变更添加了应纳入系统索引的新系统
- 变更显著改变了跨系统行为，或改变了系统与其他系统之间的契约
- 变更引入了会影响游戏 MDA 审美平衡的新玩家机制
- 实现工作很可能超过一周

在这些情况下：“此变更已超出快速规格的范围。我建议使用 `/design-system` 为此编写完整 GDD。”

---

## 建议的后续步骤

- 运行 `/story-readiness [story-path]`，在开始实现前验证故事——在故事的 GDD Reference 字段中引用此规格
- 故事通过就绪检查后，运行 `/dev-story [story-path]` 进行实现
- 如果变更比预期更大，运行 `/design-system [system-name]` 改为编写完整 GDD
