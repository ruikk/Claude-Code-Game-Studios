---
name: start
description: "首次引导：先询问用户当前所处阶段，再引导其进入正确的工作流，不作任何假设。"
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# 引导式入门

此技能会写入一个文件：`production/review-mode.txt`（在阶段 3b 中设置的审查模式配置）。

此技能是新用户的入口。它不会假设你已有游戏创意、引擎偏好或任何相关经验，而是先提问，再引导你进入正确的工作流。

---

## 阶段 1：检测项目状态

在提出任何问题之前，先静默收集上下文，以便提供有针对性的指导。除非用户询问，否则不要展示这些结果；它们用于支撑建议，而不是作为对话开场白。

检查：
- **是否已配置引擎？** 读取 `.claude/docs/technical-preferences.md`。如果 Engine 字段包含 `[TO BE CONFIGURED]`，则引擎尚未设置。
- **是否已有游戏概念？** 检查 `design/gdd/game-concept.md`。
- **是否已有源代码？** 使用 Glob 查找 `src/` 中的源文件（`*.gd`、`*.cs`、`*.cpp`、`*.h`、`*.rs`、`*.py`、`*.js`、`*.ts`）。
- **是否已有原型？** 检查 `prototypes/` 中是否存在子目录。
- **是否已有设计文档？** 统计 `design/gdd/` 中的 Markdown 文件。
- **是否已有制作产物？** 检查 `production/sprints/` 或 `production/milestones/` 中是否存在文件。

在内部保存这些发现，用于核对用户的自我评估并调整建议。

---

## 阶段 2：询问用户当前所处阶段

这是用户最先看到的内容。使用 `AskUserQuestion` 并提供以下确切选项，让用户可以点击选择而无须输入：

- **提示**："欢迎使用 Claude Code Game Studios！在提出建议之前，我想先了解你的起点。你目前的游戏创意处于什么阶段？"
- **选项**：
  - `A) No idea yet` — 我还完全没有游戏概念，想先探索并弄清楚要做什么。
  - `B) Vague idea` — 我脑中有一个粗略的主题、感觉或类型（例如“与太空有关的内容”或“一款温馨的农场游戏”），但还没有具体想法。
  - `C) Clear concept` — 我已经知道核心创意，包括类型、基础机制，也许还有一句宣传语，但尚未将其正式整理成文档。
  - `D) Existing work` — 我已经有设计文档、原型、代码或较完整的规划，想整理或继续现有工作。

等待用户选择。在用户回复之前不要继续。

---

## 阶段 3：根据回答引导路径

#### 如果选择 A：尚无创意

用户首先需要进行创意探索。

1. 说明从零开始完全没有问题
2. 简要说明 `/brainstorm` 的作用（使用专业框架进行引导式创意构思，包括 MDA、玩家心理和动词优先设计）。指出它有两种模式：使用 `/brainstorm open` 进行完全开放的探索；如果用户已有模糊主题（例如“太空”“温馨”“恐怖”），则使用 `/brainstorm [hint]`。
3. 建议下一步运行 `/brainstorm open`，同时说明如果想到任何线索，也可以将其作为提示使用
4. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm open` — 探索游戏概念
   - `/setup-engine` — 配置引擎（brainstorm 会推荐一个）
   - `/prototype` — 构建一次性概念原型：在设计前验证核心创意是否有趣（1–3 天）
   - `/art-bible` — 定义视觉识别（使用 brainstorm 产出的视觉识别锚点）
   - `/map-systems` — 将概念拆分为各个系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 检查跨系统一致性
   - `/gate-check` — 在架构工作前验证就绪状态
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 清单
   - `/architecture-decision (×N)` — 按照必需 ADR 清单记录关键技术决策
   - `/create-control-manifest` — 将决策汇编为可执行的规则表
   - `/architecture-review` — 验证架构覆盖情况
   **前期制作阶段：**
   - `/ux-design` — 为关键界面编写 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 构建达到生产质量的端到端版本，以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩
   - `/create-epics` — 将系统映射为史诗
   - `/create-stories` — 将史诗拆分为可实施的故事
   - `/sprint-plan` — 规划第一个迭代
   **制作阶段：** → 使用 `/dev-story` 开始处理故事

#### 如果选择 B：有模糊创意

1. 请用户分享模糊创意，哪怕只有几个词也足够
2. 肯定这个创意可以作为起点，不要评判或引导其转向
3. 建议运行 `/brainstorm [their hint]` 来完善创意
4. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm [hint]` — 将创意发展为完整概念
   - `/setup-engine` — 配置引擎
   - `/prototype` — 构建一次性概念原型：在设计前验证核心创意是否有趣（1–3 天）
   - `/art-bible` — 定义视觉识别（使用 brainstorm 产出的视觉识别锚点）
   - `/map-systems` — 将概念拆分为各个系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 检查跨系统一致性
   - `/gate-check` — 在架构工作前验证就绪状态
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 清单
   - `/architecture-decision (×N)` — 按照必需 ADR 清单记录关键技术决策
   - `/create-control-manifest` — 将决策汇编为可执行的规则表
   - `/architecture-review` — 验证架构覆盖情况
   **前期制作阶段：**
   - `/ux-design` — 为关键界面编写 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 构建达到生产质量的端到端版本，以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩
   - `/create-epics` — 将系统映射为史诗
   - `/create-stories` — 将史诗拆分为可实施的故事
   - `/sprint-plan` — 规划第一个迭代
   **制作阶段：** → 使用 `/dev-story` 开始处理故事

#### 如果选择 C：概念清晰

1. 请用户用一句话描述概念，包括类型和核心机制。使用纯文本提问，不要使用 AskUserQuestion（这是开放式回答）。
2. 对该概念作出回应，然后使用 `AskUserQuestion` 提供两条路径：
   - **提示**："你希望如何继续？"
   - **选项**：
     - `Formalize it first` — 运行 `/brainstorm [concept]`，将其整理成规范的游戏概念文档
     - `Jump straight in` — 立即进入 `/setup-engine`，之后再手动编写 GDD
3. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm` 或 `/setup-engine` —（采用其在步骤 2 中的选择）
   - `/prototype` — 构建一次性概念原型：在设计前验证核心创意是否有趣（1–3 天）
   - `/art-bible` — 定义视觉识别（如果运行了 brainstorm，则在其后进行；否则在概念文档存在后进行）
   - `/design-review` — 验证概念文档
   - `/map-systems` — 将概念拆分为独立系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 检查跨系统一致性
   - `/gate-check` — 在架构工作前验证就绪状态
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 清单
   - `/architecture-decision (×N)` — 按照必需 ADR 清单记录关键技术决策
   - `/create-control-manifest` — 将决策汇编为可执行的规则表
   - `/architecture-review` — 验证架构覆盖情况
   **前期制作阶段：**
   - `/ux-design` — 为关键界面编写 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 构建达到生产质量的端到端版本，以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩
   - `/create-epics` — 将系统映射为史诗
   - `/create-stories` — 将史诗拆分为可实施的故事
   - `/sprint-plan` — 规划第一个迭代
   **制作阶段：** → 使用 `/dev-story` 开始处理故事

#### 如果选择 D：已有工作成果

1. 分享在阶段 1 中发现的内容：
   - "我看到你已有 [X source files / Y design docs / Z prototypes]……"
   - "你的引擎[configured as X / not yet configured]……"

2. **子情况 D1：早期阶段**（引擎尚未配置，或只有游戏概念）：
   - 如果引擎尚未配置，建议先运行 `/setup-engine`
   - 然后运行 `/project-stage-detect` 盘点缺口

   **子情况 D2：已经存在 GDD、ADR 或故事：**
   - 解释："存在文件并不代表模板技能能够使用它们。GDD 可能缺少必需章节，`/adopt` 会专门检查这一点。"
   - 建议：
     1. `/project-stage-detect` — 了解当前阶段以及完全缺失的内容
     2. `/adopt` — 审核现有产物是否采用正确的内部格式

3. 展示 D2 的推荐路径：
   - `/project-stage-detect` — 阶段检测 + 文件存在性缺口
   - `/adopt` — 格式合规审计 + 迁移计划
   - `/setup-engine` — 如果引擎尚未配置
   - `/design-system retrofit [path]` — 补充缺失的 GDD 章节
   - `/architecture-decision retrofit [path]` — 补充缺失的 ADR 章节
   - `/architecture-review` — 初始化 TR 需求注册表
   - `/gate-check` — 验证进入下一阶段的就绪状态

---

## 阶段 3c：写入初始阶段文件

确认起始路径后（并在询问审查模式之前），将初始阶段写入 `production/stage.txt`。如果 `production/` 目录不存在，则创建它。

阶段映射：
- **路径 A、B 或 C（从零开始）**：写入 `Concept`
- **路径 D，现有项目，引擎尚未配置或只有游戏概念**：写入 `Concept`
- **路径 D，现有项目，已有 GDD 但没有架构文档**：写入 `Systems Design`
- **路径 D，现有项目，已有完整架构（ADR、架构文档）**：写入 `Technical Setup`

静默执行此操作；写入这个单行文件时无须询问“可以写入吗？”。

告知用户："我已将 `production/stage.txt` 设置为 `[stage]`，它将作为状态行和阶段检测的基准。"

---

## 阶段 3b：设置审查模式

检查 `production/review-mode.txt` 是否已存在。

**如果已存在**：读取文件并显示当前模式："审查模式已设置为 `[current]`。" 然后进入阶段 4，不要再次询问。

**如果不存在**：使用 `AskUserQuestion`：

- **提示**："还有一项设置：在执行工作流的过程中，你希望进行多大程度的设计审查？"
- **选项**：
  - `Full` — 由总监专家在每个关键工作流步骤进行审查。最适合团队、正在学习工作流的用户，或希望每项决策都得到全面反馈的情况。
  - `Lean (recommended)` — 总监仅在阶段门禁转换（/gate-check）时参与，跳过每个技能的单独审查。适合个人开发者和小型团队的均衡方案。
  - `Solo` — 完全不进行总监审查，速度最快。最适合 Game Jam、原型开发，或认为审查负担过重的情况。

用户选择后，立即将选项写入 `production/review-mode.txt`。无须另行询问
“可以写入吗？”，因为写入操作是该选择的直接结果：
- `Full` → 写入 `full`
- `Lean (recommended)` → 写入 `lean`
- `Solo` → 写入 `solo`

如果 `production/` 目录不存在，则创建它。

---

## 阶段 4：继续前先确认

展示推荐路径后，使用 `AskUserQuestion` 询问用户希望先执行哪一步。绝不要自动运行下一个技能。

- **提示**："你想先从 [recommended first step] 开始吗？"
- **选项**：
  - `Yes, let's start with [recommended first step]`
  - `I'd like to do something else first`

---

## 阶段 5：移交

用户确认下一步后，只用一句简短的话回复："输入 `[skill command]` 即可开始。" 不要添加其他内容，不要再次解释该技能，也不要补充鼓励性话语。至此，`/start` 技能的任务已完成。

结论：**COMPLETE** — 已完成用户引导并移交至下一步。

---

## 边缘情况

- **用户选择 D，但项目为空**：温和地重新引导："这个项目似乎是一个尚无任何产物的新模板。路径 A 或 B 是否更适合你？"
- **用户选择 A，但项目中已有代码**：说明发现的情况："我注意到 `src/` 中已经有代码。你原本是否想选择 D（已有工作成果）？"
- **用户再次使用此技能（引擎已配置、概念已存在）**：完全跳过入门引导："你似乎已经完成了初始设置！你的引擎是 [X]，并且 `design/gdd/game-concept.md` 中已有游戏概念。审查模式：`[read from production/review-mode.txt, or 'lean (default)' if missing]`。想从上次中断的地方继续吗？可以尝试 `/sprint-plan`，也可以直接告诉我你想做什么。"
- **用户不符合任何选项**：让用户用自己的话描述情况，并据此调整。

---

## 协作协议

1. **先提问** — 绝不假设用户的状态或意图
2. **提供选项** — 给出清晰路径，而不是强制要求
3. **由用户决定** — 由用户选择方向
4. **不自动执行** — 推荐下一个技能，未经询问不要运行
5. **灵活调整** — 如果用户的情况不符合模板，先倾听，再调整
