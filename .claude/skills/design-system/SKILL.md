---
name: design-system
description: "用于按章节协作编写单个游戏系统的 GDD：收集现有文档上下文，逐项完成必需章节，交叉引用依赖，并增量写入文件。"
argument-hint: "<system-name> [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, TodoWrite
model: sonnet
---

调用此技能时：

## 1. 解析参数并验证

解析审查模式（仅解析一次，并在本次运行的所有门禁代理调用中复用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认使用 `lean`

完整检查模式见 `.claude/docs/director-gates.md`。

必须提供系统名称或改造路径。如果缺失：

1. 检查 `design/gdd/systems-index.md` 是否存在。
2. 如果存在：读取它，找到状态为 "Not Started" 或等价状态且优先级最高的系统，然后使用 `AskUserQuestion`：
   - 提示："设计顺序中的下一个系统是 **[system-name]**（[priority] | [layer]）。开始设计吗？"
   - 选项： `[A] Yes — design [system-name]` / `[B] Pick a different system` / `[C] Stop here`
   - [A]：使用该系统名称继续。[B]：用纯文本询问要设计哪个系统。[C]：退出。
3. 如果不存在系统索引，则以以下信息失败：
   > "用法：`/design-system <system-name>`——例如 `/design-system movement`
   > 如需补全现有 GDD：`/design-system retrofit design/gdd/[system-name].md`
   > 未找到系统索引。请先运行 `/map-systems`，梳理系统并获得设计顺序。"

**检测改造模式：**
如果参数以 `retrofit` 开头，或参数是 `design/gdd/` 中现有 `.md` 文件的路径，则进入**改造模式**：

1. 读取现有 GDD 文件。
2. 识别 8 个必需章节中哪些已经存在（扫描章节标题）。
   必需章节：概述、玩家幻想、详细规则、公式、边界情况、依赖、调优旋钮、验收标准。
3. 识别哪些章节只有占位文本（`[To be designed]` 或等价内容，即空白、单行或明显不完整）。
4. 在执行任何操作前向用户展示：
   ```
   ## 改造：[System Name]
   文件：design/gdd/[filename].md

    已写入章节（不会修改）：
   ✓ [section name]
   ✓ [section name]

    缺失或不完整章节（将要编写）：
   ✗ [section name] — 缺失
   ✗ [section name] — 仅有占位内容
   ```
5. 询问："是否填充缺失的 [N] 个章节？我不会修改任何现有内容。"
6. 如果同意：正常进入**Phase 2（收集上下文）**，但在**Phase 3**跳过创建骨架（文件已存在），并在**Phase 4**跳过已经完成的章节。只对缺失或不完整的章节运行章节循环。
7. **绝不覆盖现有章节内容。** 使用 Edit 工具只替换
   `[To be designed]` 占位符或空章节正文。

如果不在 retrofit 模式中，将系统名称规范化为 kebab-case 作为文件名（例如，"combat system" 变为 `combat-system`）。

---

## 2. 收集上下文（读取阶段）

在向用户提问前 **先** 读取所有相关上下文。这是本技能相较于临时设计的主要优势：先掌握信息再开始。

### 2a: 必需读取项

- **游戏概念**：读取 `design/gdd/game-concept.md` —— 缺失则失败：
  > "未找到游戏概念。请先运行 `/brainstorm`。"
- **系统索引**：读取 `design/gdd/systems-index.md` —— 缺失则失败：
  > "未找到系统索引。请先运行 `/map-systems` 梳理系统。"
- **目标系统**：在索引中查找该系统。如果未列出，警告：
  > "[system-name] 不在系统索引中。要将它加入索引，还是作为索引外系统进行设计？"
- **实体注册表**：如果存在，读取 `design/registry/entities.yaml`。
  提取所有被此系统引用或与之相关的条目（grep
  `referenced_by.*[system-name]` 和 `source.*[system-name]`）。将这些
  作为**已知事实**保存在上下文中 —— 即其他 GDD 已经确立的值，
  本 GDD 不得与之矛盾。
- **反思日志**：如果存在，读取 `docs/consistency-failures.md`。
  提取 Domain 与此系统类别匹配的条目。这些是反复出现的冲突模式 ——
  在Phase 2d 上下文摘要的“历史失败模式”下展示，让用户
  知道此域之前在哪些地方出现过错误。

### 2b: 依赖读取项

从系统索引中识别：
- **上游依赖**：此系统依赖的系统。如果它们的 GDD 存在则读取
  （其中包含此系统必须遵守的决策）。
- **下游依赖方**：依赖此系统的系统。如果它们的 GDD 存在则读取
  （其中包含此系统必须满足的期望）。

对于每个存在的依赖 GDD，提取并在上下文中保存：
- 关键接口（系统间流动的数据）
- 引用此系统输出的公式
- 假定此系统行为的边界情况
- 输入此系统的调优旋钮

### 2c: 可选读取项

- **游戏支柱**：如果存在，读取 `design/gdd/game-pillars.md`
- **现有 GDD**：如果存在，读取 `design/gdd/[system-name].md`（恢复而非从头开始）
- **相关 GDD**：Glob `design/gdd/*.md`，读取任何主题相关的
  （例如，如果正在设计的系统与另一个系统在范围上重叠，即使
  不是正式依赖，也要读取相关的 GDD）

### 2d: 呈现上下文摘要

在开始设计工作前，向用户呈现简要摘要：

> **正在设计：[System Name]**
> - 优先级：[from index] | 层级：[from index]
> - 依赖于：[列表，标注哪些有 GDD，哪些尚未设计]
> - 被依赖方：[列表，标注哪些有 GDD，哪些尚未设计]
> - 需遵守的现有决策：[来自依赖 GDD 的关键约束]
> - 支柱对齐：[此系统主要服务于哪些支柱]
> - **已知跨系统事实（来自注册表）：**
>   - [entity_name]: [attribute]=[value], [attribute]=[value] (owned by [source GDD])
>   - [item_name]: [attribute]=[value], [attribute]=[value] (owned by [source GDD])
>   - [formula_name]: variables=[list], output=[min–max] (owned by [source GDD])
>   - [constant_name]: [value] [unit] (owned by [source GDD])
>   *(这些值已锁定 —— 如果本 GDD 需要不同的值，在写入前
>   暴露冲突。不要静默使用不同的数字。)*
>
> 如果没有相关的注册表条目：省略“已知跨系统事实”部分。

如果任何上游依赖尚未设计，警告：
> "[dependency] 还没有 GDD。我们需要对其接口作出假设。可考虑先设计它；也可以先定义预期契约，并将其标记为临时内容。"

### 2e: 技术可行性预检

在要求用户开始设计前，加载引擎上下文并暴露
任何将影响设计的约束或知识缺口。

**步骤 1 —— 确定此系统的引擎域：**
将系统类别（来自 systems-index.md）映射到引擎域：

| 系统类别 | 引擎域 |
|----------------|--------------|
| 战斗、物理、碰撞 | Physics |
| 渲染、视觉效果、着色器 | Rendering |
| UI、HUD、菜单 | UI |
| 音频、声音、音乐 | Audio |
| AI、寻路、行为树 | Navigation / Scripting |
| 动画、IK、骨骼 | Animation |
| 网络、多人游戏、同步 | Networking |
| 输入、控制、按键绑定 | Input |
| 存档/读档、持久化、数据 | Core |
| 对话、任务、叙事 | Scripting |

**步骤 2 —— 读取引擎上下文（如果可用）：**
- 读取 `.claude/docs/technical-preferences.md` 以识别引擎和版本
- 如果已配置引擎，读取 `docs/engine-reference/[engine]/VERSION.md`
- 如果存在，读取 `docs/engine-reference/[engine]/modules/[domain].md`
- 读取 `docs/engine-reference/[engine]/breaking-changes.md` 中域相关的条目
- Glob `docs/architecture/adr-*.md`，读取域匹配的 ADR
  （检查 Engine Compatibility 表的 "Domain" 字段）

**步骤 3 —— 呈现可行性简报：**

如果引擎参考文档存在，在开始设计前呈现：

```
## 技术可行性简报：[System Name]
引擎：[name + version]
领域：[domain]

### 已知引擎能力（已针对 [version] 验证）
- [capability relevant to this system]
- [capability 2]

### 将影响此设计的引擎约束
- [constraint from engine-reference or existing ADR]

### 知识缺口（承诺采用前必须验证）
- [post-cutoff feature this design might rely on — mark HIGH/MEDIUM risk]

### 约束此系统的现有 ADR
- ADR-XXXX：[decision summary] — 意味着[implication for this GDD]
  （或“暂无”）
```

如果不存在引擎参考文档（尚未配置引擎），显示简短说明：
> "尚未配置引擎——跳过技术可行性检查。如果还未运行 `/setup-engine`，请在进入架构阶段前运行。"

**步骤 4 —— 继续前询问：**

使用 `AskUserQuestion`：
- “开始前还有约束需要补充吗？还是按已记录的内容继续？”
  - 选项：“按已记录的内容继续”、“先补充一项约束”、“我需要检查引擎文档——暂时停在这里”

---

使用 `AskUserQuestion`：
- “准备好开始设计 [system-name] 了吗？”
  - 选项：“是，开始吧”、“先显示更多上下文”、“先设计一个依赖系统”

---

## 3. 创建文件骨架

用户确认后，**立即**创建带有空章节标题的 GDD 文件。
这确保增量写入有目标。

使用 `.claude/docs/templates/game-design-document.md` 中的模板结构

询问：“可以在 `design/gdd/[system-name].md` 创建骨架文件吗？”

如果用户拒绝：以以下信息停止：
> "结论：**BLOCKED**——用户拒绝创建骨架。后续所有阶段都以骨架文件为基础，因此设计会话无法继续。准备好创建文件后，请重新运行 `/design-system [system]`。"
不要继续到章节 A。

写入后，更新 `production/session-state/active.md`：
- 使用 Glob 检查文件是否存在。
- 如果**不存在**：使用 **Write** 工具创建它。绝不尝试 Edit 可能不存在的文件。
- 如果**已存在**：使用 **Edit** 工具更新相关字段。

文件内容：
- Task: 设计 [system-name] GDD
- Current section: 开始（骨架已创建）
- File: design/gdd/[system-name].md

---

## 4. 逐章节设计

按顺序遍历每个章节。对于**每个章节**，遵循此循环：

### 章节循环

```
上下文  ->  问题  ->  选项  ->  决定  ->  草稿  ->  审批  ->  写入
```

1. **上下文**：说明此章节需要包含什么，并暴露依赖 GDD 中
   约束此章节的相关决策。

2. **问题**：询问此章节特有的澄清问题。对受限问题使用
   `AskUserQuestion`，对开放式探索使用对话文本。

3. **选项**：在章节涉及设计选择（不仅仅是文档记录）的地方，
   呈现 2-4 种方法及其优缺点。在对话文本中解释推理，
   然后使用 `AskUserQuestion` 捕获决策。

4. **决定**：用户选择一种方法或提供自定义方向。

5. **草稿**：在对话文本中编写章节内容供评审。标记任何
   关于未设计依赖的临时假设。

6. **审批**：草稿之后立即——在同一响应中——使用
   `AskUserQuestion`。**绝不使用纯文本。绝不跳过此步骤。**
   - 提示：“批准 [Section Name] 章节吗？”
   - 选项：`[A] 批准——写入文件` / `[B] 修改——描述需要修正的内容` / `[C] 重新开始`

   **草稿和批准组件必须出现在同一响应中。
   如果草稿出现时没有组件，用户将面对空白提示
   无法继续 —— 这是协议违规。**

7. **写入**：使用 Edit 工具将占位符替换为已批准的内容。
   **关键**：始终在 `old_string` 中包含章节标题以确保
   唯一性 —— 绝不单独匹配 `[To be designed]`，因为多个章节使用
   相同的占位符，Edit 工具要求唯一匹配。使用此模式：
   ```
   old_string: "## [Section Name]\n\n[To be designed]"
   new_string: "## [Section Name]\n\n[approved content]"
   ```
   确认写入。

8. **注册表冲突检查**（仅章节 C 和 D——详细规则与公式）：
   写入后，扫描章节内容中出现在注册表中的实体名称、物品名称、公式
   名称和数字常量。对于每个匹配：
   - 将刚写入的值与注册表条目比较。
   - 如果不同：**立即暴露冲突**，在开始下一个
     章节前。不要静默继续。
     > "注册表冲突：[name] 在 [source GDD] 中登记为 [registry_value]。
     > 本章节刚写入 [new_value]。哪个值才是正确的？"
   - 如果是新的（不在注册表中）：标记为注册表注册候选项
     （将在阶段 5 中处理）。

写入每个章节后，更新 `production/session-state/active.md` 记录
已完成的章节名称。使用 Glob 检查文件是否存在 —— 不存在则用 Write 创建，
存在则用 Edit 更新。

### 各章节专属指导

每个章节有独特的设计考量，可能需要专家代理：

---

### 章节 A：概述

**目标**：一段陌生人能读懂并理解的话。

**在构建组件前推导推荐选项**：从阶段 2 上下文中读取系统类别和层级，然后确定每个标签的推荐选项：
- **定位标签**：Foundation/Infrastructure 层 → 推荐 `[A]`。面向玩家的类别（Combat、UI、Dialogue、Character、Animation、Visual Effects、Audio）→ 推荐 `[C] 两者兼顾`。
- **ADR 引用标签**：Glob `docs/architecture/adr-*.md`，在任意 ADR 的 GDD Requirements 章节中 grep 系统名称。如果找到匹配 ADR → 推荐 `[A] 是——引用 ADR`。如果未找到 → 推荐 `[B] 否`。
- **幻想标签**：Foundation/Infrastructure 层 → 推荐 `[B] 否`。所有其他类别 → 推荐 `[A] 是`。

在每个标签的适当选项文本后附加“（推荐）”。

**框架问题（草稿前询问）**：使用 `AskUserQuestion` 的多标签组件：
- 标签“定位”——“概述应如何定位此系统？”选项：`[A] 作为数据/基础设施层（技术定位）` / `[B] 通过其面向玩家的效果（设计定位）` / `[C] 两者兼顾——描述数据层及其对玩家的影响`
- 标签“ADR 引用”——“概述是否应引用此系统的现有 ADR？”选项：`[A] 是——引用 ADR 获取实现细节` / `[B] 否——让 GDD 保持纯设计层面`
- 标签“幻想”——“此系统是否有值得陈述的玩家幻想？”选项：`[A] 是——玩家能直接感受到` / `[B] 否——纯基础设施，玩家只感受它所实现的效果`

使用用户的回答来塑造草稿。不要自己回答这些问题并自动草拟。

**需要询问的问题**：
- 用一句话描述这个系统是什么？
- 玩家如何与之交互？（主动/被动/自动）
- 这个系统为什么存在 —— 没有它游戏会失去什么？

**交叉引用**：检查描述与系统索引的描述是否
一致。标记差异。

**设计与实现的边界**：概述问题必须停留在行为
层面——系统*做什么*，而非*如何构建*。如果概述期间出现
实现问题（例如，“这里应该使用 Autoload 单例还是信号总线？”），将其标注为“→ 转为 ADR”并继续。实现模式属于
`/architecture-decision`，不属于 GDD。GDD 描述行为；ADR
描述用于实现行为的技术方法。

---

### 章节 B：玩家幻想

**目标**：情感目标 —— 玩家应该*感受到*什么。

**在构建组件前推导推荐选项**：从阶段 2 上下文中读取系统类别和层级：
- 面向玩家的类别（Combat、UI、Dialogue、Character、Animation、Audio、Level/World）→ 推荐 `[A] 直接`
- Foundation/Infrastructure 层 → 推荐 `[B] 间接`
- 混合类别（Camera/input、Economy、有可见玩家效果的 AI）→ 推荐 `[C] 两者兼有`

在适当的选项文本后附加“（推荐）”。

**框架问题（草稿前询问）**：使用 `AskUserQuestion`：
- 提示：“玩家会直接与此系统交互，还是通过基础设施间接体验它？”
- 选项：`[A] 直接——玩家主动使用或感受此系统` / `[B] 间接——玩家体验其效果，而非系统本身` / `[C] 两者兼有——既有直接交互层，也有底层基础设施`

使用回答来适当构建 玩家幻想（Player Fantasy）章节。不要假设答案。

**需要询问的问题**：
- 这服务于什么情感或力量幻想？
- 哪些参考游戏完美呈现了这种感觉？具体是什么创造了它？
- 这是一个"你喜欢参与的系统"还是"你注意不到的基础设施"？

**交叉引用**：必须与游戏支柱一致。如果系统服务于某个支柱，
引用相关支柱文本。

**审查模式检查**（生成前应用）：
- `solo` → 跳过此代理生成。不使用专家草拟章节。添加说明：“未咨询 `creative-director`——当前为 Solo 模式。进入制作前请手动评审。”
- `lean` → 除非这是有 HIGH 实现风险的章节（仅章节 D 和 H），否则跳过。对于其他章节，不使用代理草拟。
- `full` → 如下所述生成。

**代理委派（强制）**：在框架回答给出后但在草拟前，
通过 Task 生成 `creative-director`：
- 提供：系统名称、框架回答（direct/indirect/both）、游戏支柱、用户提到的任何参考游戏、游戏概念摘要
- 询问：“塑造此系统的玩家幻想。它应服务于什么情感或力量幻想？应锚定哪个玩家时刻？什么基调和语言符合游戏已经确立的感受？请具体给出 2–3 种候选定位。”
- 收集 creative-director 的框架建议，并与草稿一起呈现给用户。

**不要在未先咨询 `creative-director` 的情况下草拟章节 B。** 框架
回答告诉我们幻想*是什么类型*；creative-director 塑造*如何描述
它* —— 基调、语言、要锚定的具体玩家时刻。

---

### 章节 C：详细规则（核心规则、状态、交互）

**目标**：程序员无需提问即可实现的明确规范。

这通常是最大的章节。将其分解为子章节：

1. **核心规则**：基本机制。对顺序
   流程使用编号规则，对属性使用项目符号。
2. **状态与转换**：如果系统有状态，映射每个状态和
   每个有效转换。使用表格。
3. **与其他系统的交互**：对于每个依赖（上游和下游），
   指定什么数据流入、什么流出、谁拥有接口。

**需要询问的问题**：
- 逐步带我走一遍此系统的典型使用
- 玩家面临的决策点是什么？
- 玩家不能做什么？（约束与能力同样重要）

**审查模式检查**（生成前应用）：
- `solo` → 跳过此代理生成。不使用专家草拟章节。添加说明：“未咨询专家代理——当前为 Solo 模式。进入制作前请手动评审。”
- `lean` → 除非这是有 HIGH 实现风险的章节（仅章节 D 和 H），否则跳过。对于其他章节，不使用代理草拟。
- `full` → 如下所述生成。

**代理委派（强制）**：草拟章节 C 前，通过 Task 并行生成专家代理：
- 在路由表（本技能章节 6）中查找系统类别
- 生成该类别列出的主代理和辅助代理
- 为每个代理提供：系统名称、游戏概念摘要、支柱集、依赖 GDD 摘录、正在处理的特定章节
- 在草拟前收集它们的发现
- 通过 `AskUserQuestion` 向用户暴露代理间的任何分歧
- 仅在收到专家输入后草拟

**不要在未先咨询适当专家的情况下草拟章节 C。** 审查规则和机制的 `systems-designer` 会发现主会话无法发现的设计缺口。

**交叉引用**：对于列出的每个交互，验证它与
依赖 GDD 指定的内容是否匹配。如果依赖定义了一个值或公式，而此
系统期望不同的东西，标记冲突。

---

### 章节 D：公式

**目标**：每个数学公式，变量已定义，范围已指定，
边界情况已标注。

**完成引导 —— 每个公式始终以此确切结构开头：**

```
[formula_name] 公式定义如下：

`[formula_name] = [expression]`

**变量：**
| 变量 | 符号 | 类型 | 范围 | 描述 |
|----------|--------|------|-------|-------------|
| [name] | [sym] | float/int | [min–max] | [what it represents] |

**输出范围：**正常游戏中为 [min] 到 [max]；[behaviour at extremes]
**示例：**[worked example with real numbers]
```

不要写 `[Formula TBD]` 或在没有变量
表的情况下用散文描述公式。没有定义变量的公式无法在没有猜测的情况下实现。

**需要询问的问题**：
- 此系统执行的核心计算是什么？
- 缩放应该是线性、对数还是阶梯式的？
- 在游戏早期/中期/后期，输出范围应该是什么？

**审查模式检查**（生成前应用）：
- `solo` → 跳过此代理生成。不使用专家草拟章节。添加说明：“未咨询 `systems-designer`——当前为 Solo 模式。进入制作前请手动评审。”
- `lean` → 除非这是有 HIGH 实现风险的章节（仅章节 D 和 H），否则跳过。对于其他章节，不使用代理草拟。
- `full` → 如下所述生成。

**代理委派（强制）**：在提出任何公式或平衡值前，通过 Task 并行生成专家代理：
- **始终生成 `systems-designer`**：提供章节 C 的核心规则、用户的调优目标、依赖 GDD 的平衡上下文。要求它们提出带变量表和输出范围的公式。
- **对于经济/成本系统，也生成 `economy-designer`**：提供放置成本、升级成本意图和进程目标。要求它们验证成本曲线和比率。
- 通过 `AskUserQuestion` 将专家的提案呈现给用户评审
- 用户决定；主会话写入文件
- **不要在没有专家输入的情况下发明公式值或平衡数字。** 没有平衡设计专业知识的用户无法评估原始数字 —— 他们需要专家的推理。

**交叉引用**：如果依赖 GDD 定义了一个输出输入到
此系统的公式，显式引用它。不要重新发明 —— 连接。

---

### 章节 E：边界情况

**目标**：显式处理异常情况，使它们不会变成 bug。

**完成引导 —— 每个边界情况格式化为：**
- **如果 [condition]**：[exact outcome]。[rationale if non-obvious]

示例（将术语适配到游戏的域）：
- **如果 [protective condition] 生效时 [resource] 降至 0**：保持在最小值，直到条件结束，再应用后果。
- **如果两个 [triggers/events] 同时触发**：按 [defined priority order] 解决；优先级相同时使用 [defined tiebreak rule]。

不要写“适当处理”这样的模糊条目——每个都必须命名确切的
条件和确切的解决方案。没有解决方案的边界情况是一个开放
设计问题，不是规范。

**需要询问的问题**：
- 零值时发生什么？最大值时？超出范围时？
- 两条规则同时适用时发生什么？
- 玩家发现非预期交互时发生什么？（识别退化策略）

**审查模式检查**（生成前应用）：
- `solo` → 跳过此代理生成。不使用专家草拟章节。添加说明：“未咨询 `systems-designer`——当前为 Solo 模式。进入制作前请手动评审。”
- `lean` → 除非这是有 HIGH 实现风险的章节（仅章节 D 和 H），否则跳过。对于其他章节，不使用代理草拟。
- `full` → 如下所述生成。

**代理委派（强制）**：在最终确定边界情况前通过 Task 生成 `systems-designer`。提供：已完成的章节 C 和 D，要求它们识别主会话可能遗漏的公式和规则空间中的边界情况。对于叙事系统，也生成 `narrative-director`。呈现它们的发现并询问用户要包含哪些。

**交叉引用**：对照依赖 GDD 检查边界情况。如果依赖
定义了此系统可能违反的下限、上限或解决方案规则，标记它。

---

### 章节 F：依赖

**目标**：映射每个系统连接的方向和性质。

此章节部分从上下文收集阶段预填充。呈现
系统索引中的已知依赖并询问：
- 有没有遗漏的依赖？
- 对于每个依赖，具体的数据接口是什么？
- 哪些依赖是硬依赖（没有它系统无法运行），哪些是软依赖
  （有它更好但没有它也能工作）？

**交叉引用**：此章节必须双向一致。如果此系统
列出“依赖 Combat”，那么 Combat GDD 应该列出“被 [this system] 依赖”。标记任何单向依赖以供更正。

---

### 章节 G：调优旋钮

**目标**：每个设计者可调整的值，含安全范围和极端行为。

**需要询问的问题**：
- 设计者应该能在不更改代码的情况下调整哪些值？
- 对于每个旋钮，设得太高会出什么问题？太低呢？
- 哪些旋钮相互交互？（改变 A 使 B 无关）

**代理委派**：如果公式复杂，委派给 `systems-designer`
从公式变量推导调优旋钮。

**交叉引用**：如果依赖 GDD 列出了影响此系统的调优旋钮，
在此引用它们。不要创建重复旋钮 —— 指向事实来源。

---

### 章节 H：验收标准

**目标**：证明系统按设计工作的可测试条件。

**完成引导 —— 每条标准格式化为 Given-When-Then：**
- **GIVEN** [initial state]，**WHEN** [action or trigger]，**THEN** [measurable outcome]

示例（将术语适配到游戏的域）：
- **GIVEN** [initial state]，**WHEN** [player action or system trigger]，**THEN** [specific measurable outcome]。
- **GIVEN** [a constraint is active]，**WHEN** [player attempts an action]，**THEN** [feedback shown and action result]。

至少包含：章节 C 中每条核心规则一条标准，以及章节 D 中
每个公式一条。不要写“系统按设计运行”——每条标准必须
能被 QA 测试员独立验证，无需阅读 GDD。

**审查模式检查**（生成前应用）：
- `solo` → 跳过此代理生成。不使用专家草拟章节。添加说明：“未咨询 `qa-lead`——当前为 Solo 模式。进入制作前请手动评审。”
- `lean` → 除非这是有 HIGH 实现风险的章节（仅章节 D 和 H），否则跳过。对于其他章节，不使用代理草拟。
- `full` → 如下所述生成。

**代理委派（强制）**：在最终确定验收标准前通过 Task 生成 `qa-lead`。提供：已完成的 GDD 章节 C、D、E，要求它们验证标准可独立测试并覆盖所有核心规则和公式。向用户暴露任何缺口或不可测试的标准。

**需要询问的问题**：
- 证明此系统有效的最小测试集是什么？
- 此系统的性能预算是多少？（帧时间、内存）
- QA 测试员首先会检查什么？

**交叉引用**：包含验证跨系统交互的标准，
而不仅是此系统孤立运行。

---

### 可选章节：视觉/音频、UI 需求、开放问题

这些章节包含在模板中。视觉/音频对于视觉系统类别是**必需的**，并非可选。在询问前确定需求级别：

**视觉/音频为必需项（强制——不要提供跳过选项）的系统类别：**
- 战斗、伤害、生命值
- UI 系统（HUD、菜单）
- 动画、角色移动
- 视觉效果、粒子、着色器
- 角色系统
- 对话、任务、传说
- 关卡/世界系统

对于必需系统：在草拟此章节前**通过 Task 生成 `art-director`**。提供：系统名称、游戏概念、游戏支柱、如果存在的美术圣经章节 1–4。要求它们指定：(1) 此系统事件的 VFX 和视觉反馈需求，(2) 任何动画或视觉风格约束，(3) 哪些美术圣经原则最直接适用于此系统。呈现它们的输出；对于视觉系统不要将此章节留为 `[To be designed]`。

对于**所有其他系统类别**（Foundation/Infrastructure、Economy、AI/pathfinding、Camera/input），在必需章节后提供可选章节：

使用 `AskUserQuestion`：
- “8 个必需章节已完成。是否还要定义视觉/音频需求、UI 需求，或记录开放问题？”
  - 选项：“是，三项都要”、“只记录开放问题”、“跳过——稍后再添加”

对于**视觉/音频**（非必需系统）：如果需要细节，与 `art-director` 和 `audio-director` 协调。在 GDD 阶段通常简短说明即可。

> **资产规格标志**：在视觉/音频章节写入真实内容后，输出此通知：
> “📌 **资产规格**——视觉/音频需求已定义。美术圣经获批后，运行 `/asset-spec system:[system-name]`，根据本章节生成逐资产的视觉描述、尺寸和生成提示词。”

对于 **UI 需求**：对于复杂 UI 系统与 `ux-designer` 协调。
写入此章节后，检查它是否包含真实内容（不仅仅是
`[To be designed]` 或此系统无 UI 的说明）。如果确实有真实
UI 需求，立即输出此标志：

> **📌 UX Flag — [System Name]**: This system has UI requirements. In Phase 4
> (Pre-Production), run `/ux-design` to create a UX spec for each screen or
> HUD element this system contributes to **before** writing epics. Stories that
> reference UI should cite `design/ux/[screen].md`, not the GDD directly.
>
> 如果更新此系统的系统索引，请在其中注明这一点。

对于**开放问题**：捕获设计过程中出现但未完全
解决的任何问题。每个问题应有负责人和目标解决日期。

---

## 5. 设计后验证

所有章节写入后：

### 5a: 自检

从文件回读完整的 GDD（不从对话记忆 —— 文件是
事实来源）。验证：
- 所有 8 个必需章节有真实内容（不是占位符）
- 公式引用已定义的变量
- 边界情况有解决方案
- 依赖列出了接口
- 验收标准可测试

### 5a-bis：创意总监支柱评审

**审查模式检查**——生成 CD-GDD-ALIGN 前应用：
- `solo` → 跳过。说明：“已跳过 CD-GDD-ALIGN——当前为 Solo 模式。”进入步骤 5b。
- `lean` → 跳过（不是 PHASE-GATE）。说明：“已跳过 CD-GDD-ALIGN——当前为 Lean 模式。”进入步骤 5b。
- `full` → 正常生成。

在最终确定 GDD 前，通过 Task 使用门禁 **CD-GDD-ALIGN**（`.claude/docs/director-gates.md`）生成 `creative-director`。

传入：已完成的 GDD 文件路径、游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`）、MDA 美学目标。

按 `director-gates.md` 中的标准规则处理结论。解决后，在 GDD 的 Status 头部记录结论：
`> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]`

---

### 5b: 更新实体注册表

扫描完成的 GDD 中应注册的跨系统事实：
- 带有属性或掉落的命名实体（敌人、NPC、boss）
- 带有值、重量或类别的命名物品
- 带有已定义变量和输出范围的命名公式
- 在多处按值引用的命名常量

对于每个候选项，检查它是否已存在于 `design/registry/entities.yaml`：
```
Grep pattern="  - name: [candidate_name]" path="design/registry/entities.yaml"
```

呈现摘要：
```
本 GDD 中的注册表候选项：
  NEW（尚未登记）：
    - [entity_name] [entity]: [attribute]=[value], [attribute]=[value]
    - [item_name] [item]: [attribute]=[value], [attribute]=[value]
    - [formula_name] [formula]: variables=[list], output=[min–max]
  ALREADY REGISTERED（将更新 referenced_by）：
    - [constant_name] [constant]：value=[N] ← 与注册表一致 ✅
```

询问：“可以将这 [N] 个新条目写入 `design/registry/entities.yaml`，并更新现有条目的 `referenced_by` 吗？”

如果同意：追加新条目并更新 `referenced_by` 数组。绝不修改
现有的 `value` / 属性字段，除非先暴露为冲突。

### 5c: 提供设计评审

呈现完成摘要：

> **GDD 已完成：[System Name]**
> - 已写入章节：[列表]
> - 临时假设：[列出关于未设计依赖的任何假设]
> - 发现的跨系统冲突：[列表或 "none"]

> **要验证此 GDD，请打开一个新的 Claude Code 会话并运行：**
> `/design-review design/gdd/[system-name].md`
>
> **绝不要在运行 `/design-system` 的同一会话中运行 `/design-review`。** 评审代理必须独立于编写上下文。在这里运行会继承完整的设计历史，无法进行独立批评。

**绝不提供内联运行 `/design-review`。** 始终引导用户到新窗口。

### 5d: 更新系统索引

GDD 完成后（以及可选地评审后）：

- 读取系统索引
- 更新目标系统的行：
  - 如果运行了 design-review 且结论为 APPROVED：Status → `Approved`
  - 如果运行了 design-review 且结论为 NEEDS REVISION：Status → `In Review`
  - 如果跳过了 design-review：Status → `Designed`（待评审）
  - 如果用户选择“我先自行评审”：Status → `Designed`
  - Design Doc：链接到 `design/gdd/[system-name].md`
- 更新 Progress Tracker 计数

询问：“可以更新 `design/gdd/systems-index.md` 中的系统索引吗？”

### 5e: 更新会话状态

更新 `production/session-state/active.md`：
- Task: [system-name] GDD
- Status: Complete（如果运行了 design-review 则为 In Review）
- File: design/gdd/[system-name].md
- Sections: 8 个章节均已写入
- Next: [从设计顺序建议下一个系统]

### 5f: 建议下一步

使用 `AskUserQuestion`：
- “下一步做什么？”
  - 选项：
    - “运行 `/consistency-check`——验证此 GDD 的数值不与现有 GDD 冲突（建议在设计下一个系统前运行）”
    - “设计下一个系统（[next-in-order]）”——如果还有未设计的系统
    - “修复评审发现”——如果 design-review 标记了问题
    - “本次会话在此停止”
    - “运行 `/gate-check`”——如果已设计足够的 MVP 系统

---

## 6. 专家代理路由

此技能委派给专家代理获取域专业知识。主会话
编排整体流程；代理提供专家内容。

| 系统类别 | 主代理 | 辅助代理 |
|----------------|---------------|---------------------|
| **Foundation/Infrastructure**（事件总线、存档/读档、场景管理、服务定位器） | `systems-designer` | `gameplay-programmer`（可行性）、`engine-programmer`（引擎集成） |
| 战斗、伤害、生命值 | `game-designer` | `systems-designer`（公式）、`ai-programmer`（敌人 AI）、`art-director`（命中反馈的视觉方向、VFX 意图） |
| 经济、战利品、制作 | `economy-designer` | `systems-designer`（曲线）、`game-designer`（循环） |
| 成长、XP、技能 | `game-designer` | `systems-designer`（曲线）、`economy-designer`（资源消耗） |
| 对话、任务、传说 | `game-designer` | `narrative-director`（故事）、`writer`（内容）、`art-director`（角色视觉档案、演出基调） |
| UI 系统（HUD、菜单） | `game-designer` | `ux-designer`（流程）、`ui-programmer`（可行性）、`art-director`（视觉风格方向）、`technical-artist`（渲染/着色器约束） |
| 音频系统 | `game-designer` | `audio-director`（方向）、`sound-designer`（规格） |
| AI、寻路、行为 | `game-designer` | `ai-programmer`（实现）、`systems-designer`（评分） |
| 关卡/世界系统 | `game-designer` | `level-designer`（空间设计）、`world-builder`（传说） |
| 摄像机、输入、控制 | `game-designer` | `ux-designer`（体验）、`gameplay-programmer`（可行性） |
| 动画、角色移动 | `game-designer` | `art-director`（动画风格、姿势语言）、`technical-artist`（骨骼绑定/混合约束）、`gameplay-programmer`（体验） |
| 视觉效果、粒子、着色器 | `game-designer` | `art-director`（VFX 视觉方向）、`technical-artist`（性能预算、着色器复杂度）、`systems-designer`（触发条件/状态集成） |
| 角色系统（属性、原型） | `game-designer` | `art-director`（角色视觉原型）、`narrative-director`（角色弧光对齐）、`systems-designer`（属性公式） |

**通过 Task 工具委派时**：
- 提供：系统名称、游戏概念摘要、依赖 GDD 摘录、正在处理的
  特定章节，以及需要专家输入的问题
- 代理将分析/提案返回给主会话
- 主会话通过 `AskUserQuestion` 将代理的输出呈现给用户
- 用户决定；主会话写入文件
- 代理不直接写入文件 —— 主会话拥有所有文件写入

---

## 7. 恢复与续接

如果会话中断（压缩、崩溃、新会话）：

1. 读取 `production/session-state/active.md` —— 它记录了当前系统和
   哪些章节已完成
2. 读取 `design/gdd/[system-name].md` —— 有真实内容的章节已完成；
   带有 `[To be designed]` 的章节仍需工作
3. 从下一个未完成的章节恢复 —— 无需重新讨论已完成的

这就是增量写入重要的原因：每个已批准的章节都能在任何
中断中存活。

---

## 协作协议

此技能在每个步骤都遵循协作设计原则：

1. 每个章节都使用**提问 -> 选项 -> 决定 -> 草稿 -> 审批**
2. 每个决策点都使用 **AskUserQuestion**（解释 -> 捕获模式）：
   - 阶段 2：“准备好开始了吗？还是需要更多上下文？”
   - 阶段 3：“可以创建骨架吗？”
   - 阶段 4（每个章节）：设计问题、方法选项、草稿批准
   - 阶段 5：“运行设计评审？更新系统索引？下一步做什么？”
3. 在骨架前和每次章节写入前询问**“可以写入 [filepath] 吗？”**
4. **增量写入**：每个章节在批准后立即写入文件
5. **会话状态更新**：每次章节写入后
6. **交叉引用**：每个章节检查现有 GDD 是否有冲突
7. **专家路由**：复杂章节获取专家代理输入，呈现给
   用户决策 —— 绝不静默写入

**绝不**自动生成完整 GDD 并作为既成事实呈现。
**绝不**在未经用户批准的情况下写入章节。
**绝不**与现有已批准 GDD 矛盾而不标记冲突。
**始终**显示决策来源（依赖 GDD、支柱、用户选择）。

## 上下文窗口意识

这是一个长时间运行的技能。写入每个章节后，检查状态行
是否显示上下文达到或超过 70%。如果是，在响应中附加此通知：

> **上下文即将达到上限（≥70%）。** 当前进度已保存——所有获批章节均已写入 `design/gdd/[system-name].md`。
> 准备继续时，请打开一个新的 Claude Code 会话并运行 `/design-system [system-name]`；它会检测已完成的章节，并从下一章节恢复。

---

## 建议的后续步骤

- 在**新会话**中运行 `/design-review design/gdd/[system-name].md` 独立验证已完成的 GDD
- 运行 `/consistency-check` 验证此 GDD 的值与其他 GDD 不冲突
- 运行 `/map-systems next` 移至下一个最高优先级的未设计系统
- 当所有 MVP GDD 已编写并评审后，运行 `/gate-check pre-production`
