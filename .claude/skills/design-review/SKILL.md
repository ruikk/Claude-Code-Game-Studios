---
name: design-review
description: "审查游戏设计文档的完整性、内部一致性、可实现性及其对项目设计标准的遵循情况。在将设计文档交给程序员之前使用。"
argument-hint: "[path-to-design-doc] [--depth full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

## Phase 0: 解析参数

如果存在，提取 `--depth [full|lean|solo]`，并将其保存为本次运行的评审深度覆盖值。如果未提供，则读取 `production/review-mode.txt`（缺失时默认为 `full`）。

**注意**：`--depth` 控制*此技能的分析深度*（生成多少专家代理）。它与 `production/review-mode.txt` 中的全局评审模式是独立概念，后者控制导演门禁生成。这是两个不同的概念 —— `--depth` 关于此技能分析文档的彻底程度。

- **`full`**：完整评审 —— 所有阶段 + 专家代理委派（Phase 3b）
- **`lean`**：所有阶段，无专家代理 —— 更快，单会话分析
- **`solo`**：仅 Phases 1-4，无委派，无 Phase 5 下一步提示 —— 从其他技能内调用时使用

---

## Phase 1: 加载文档

完整读取目标设计文档。读取 CLAUDE.md 以了解项目上下文和标准。读取目标文档中引用或暗示的相关设计文档（检查 `design/gdd/` 中是否存在相关系统）。

**依赖关系图验证**：对于依赖项（`Dependencies`）部分中列出的每个系统，使用 Glob 检查其 GDD 文件是否存在于 `design/gdd/` 中。标记任何不存在的文件 —— 这些是下游作者会遇到的中断引用。

**世界观/叙事对齐**：如果存在 `design/gdd/game-concept.md` 或 `design/narrative/` 中的任何文件，请读取。注意此 GDD 中与已建立的世界规则、基调或设计支柱相矛盾的任何机制选择。将此上下文传递给阶段 3b 中的 `game-designer`。

**先前评审检查**：检查是否存在 `design/gdd/reviews/[doc-name]-review-log.md`。如果存在，读取最新条目 —— 注意给出的结论和列出的阻塞项。此会话是重新评审；跟踪是否已解决先前的问题。

---

## Phase 2: 完整性检查

根据设计文档标准清单进行评估：

- [ ] 有概述（`Overview`）章节（一段式摘要）
- [ ] 有玩家幻想（`Player Fantasy`）章节（预期感受）
- [ ] 有详细规则（`Detailed Rules`）章节（明确的机制）
- [ ] 有公式（`Formulas`）章节（所有数学已定义，含变量）
- [ ] 有边界情况（`Edge Cases`）章节（处理了异常情况）
- [ ] 有依赖项（`Dependencies`）章节（列出了其他系统）
- [ ] 有调优参数（`Tuning Knobs`）章节（标识了可配置值）
- [ ] 有验收标准（`Acceptance Criteria`）章节（可测试的成功条件）

## Phase 3: 一致性和可实现性

**内部一致性**：
- 公式是否产生与描述行为匹配的值？
- 边界情况是否与主要规则矛盾？
- 依赖关系是否双向（其他系统是否了解此系统）？

**可实现性**：
- 规则是否足够精确，程序员无需猜测即可实现？
- 是否存在一笔带过、缺少细节的章节？
- 是否考虑了性能影响？

**跨系统一致性**：
- 此设计是否与现有机制冲突？
- 是否会与其他系统产生非预期的交互？
- 是否与游戏的既定基调和支柱一致？

---

## Phase 3b: 对抗性专家评审（仅 full 模式）

**在 `lean` 或 `solo` 模式下跳过此阶段。**

**此阶段在 full 模式下是强制性的。** 不要跳过它。

**在生成任何代理之前**，打印此通知：
> "完整评审：正在并行启动专家代理。通常需要 8-15 分钟。使用 `--review lean` 可进行更快的单会话分析。"

### 步骤 1 — 识别 GDD 触及的所有域

读取 GDD 并识别其中存在的每个域。一个 GDD 可能同时触及多个域 —— 要彻底。常见信号：

| 如果 GDD 包含... | 生成这些代理 |
|------------------------|-------------------|
| 成本、价格、掉落、奖励、经济 | `economy-designer` |
| 战斗属性、伤害、生命值、DPS | `game-designer`、`systems-designer` |
| AI 行为、寻路、瞄准 | `ai-programmer` |
| 关卡布局、生成、波次结构 | `level-designer` |
| 玩家进程、XP、解锁 | `economy-designer`、`game-designer` |
| UI、HUD、菜单、面向玩家的显示 | `ux-designer`、`ui-programmer` |
| 对话、任务、故事、传说 | `narrative-director` |
| 动画、手感、时机、表现力 | `gameplay-programmer` |
| 多人游戏、同步、复制 | `network-programmer` |
| 音频提示、音乐触发 | `audio-director` |
| 性能、绘制调用、内存 | `performance-analyst` |
| 引擎特定模式或 API | 主引擎专家（来自 `.claude/docs/technical-preferences.md`） |
| 验收标准、测试覆盖 | `qa-lead` |
| 数据架构、资源结构 | `systems-designer` |
| 任何游戏玩法系统 | `game-designer`（始终） |

对于所有描述游戏玩法机制或面向玩家规则的 GDD,生成 `game-designer`。
对于所有包含公式或系统交互规则的 GDD,生成 `systems-designer`。
这些是最常见的基线 —— 但对于纯 UI 规格、音频规格或传说文档不是必需的。使用上面的域表来确定哪些专家真正相关。

### 步骤 2 — 并行生成所有相关专家

**关键：此技能中的 Task 会生成一个子代理 —— 一个独立的 Claude 会话，
拥有自己的上下文窗口。它不是任务跟踪。不要在内部模拟专家视角。
不要自己推理域观点。你必须发出实际的 Task 调用。模拟评审不是专家评审。**

同时发出所有 Task 调用。不要逐个生成。

**以对抗性方式提示每个专家：**
> "这是 [system] 的 GDD,以及主评审目前的结构性发现。
> 你的工作不是验证此设计 —— 你的工作是找出问题。
> 从你的域专业知识挑战设计选择。哪里有错误、
> 欠缺规格、可能导致问题,或完全缺失?
> 要具体和批判。欢迎与主评审意见相左。"

**每种代理类型的附加指令:**

- **`game-designer`**: 将你的评审锚定到此 GDD B 章节中陈述的玩家幻想。此设计是否真正实现了该幻想?玩家是否会感受到预期体验?标记任何服务于可实现性但削弱所陈述感受的规则。

- **`systems-designer`**: 对于 GDD 中的每个公式,代入边界值(最小和最大合理输入)。报告是否有任何输出退化 —— 负值、除以零、无穷大,或在极端处的无意义结果。

- **`qa-lead`**: 评审每个验收标准。标记任何不可独立测试的标准 —— 如"感觉平衡"、"工作正常"、"性能良好"等短语不是 AC。为任何未通过此测试的标准建议具体改写。

### 步骤 3 — 高级主审评审

所有专家回应后,生成 `creative-director` 作为**高级评审员**:
- 提供:GDD、所有专家发现、它们之间的任何分歧
- 询问:"综合这些发现。最重要的问题是什么?你同意专家的观点吗?你对这个设计的总体结论是什么?"
- creative-director 的综合成为 Phase 4 中的**最终结论**。

### 步骤 4 — 呈现分歧

如果专家之间或与 creative-director 之间意见相左,不要默默选择一种观点。在 Phase 4 中明确呈现分歧,以便用户裁决。

用来源标记每个发现:`[game-designer]`、`[economy-designer]`、`[creative-director]` 等。

---

## Phase 4: 输出评审

```
## 设计评审：[文档标题]
已咨询专家：[生成的代理列表]
重新评审：[是 —— 先前结论为 X，日期 YYYY-MM-DD / 否 —— 首次评审]

### 完整性：[存在 X/8 章节]
[列出缺失章节]

### 依赖关系图
[列出每个声明的依赖及其 GDD 文件是否存在于磁盘]
- ✓ enemy-definition-data.md — 存在
- ✗ loot-system.md — 未找到(文件尚不存在)

### 实现前必需项
[编号列表 —— 仅阻塞问题。每项标记来源代理。]

### 建议修订
[编号列表 —— 重要但不阻塞。标记来源。]

### 专家分歧
[任何代理之间或与主评审意见相左的情况。
呈现双方观点 —— 不要默默解决。]

### 可选改进
[次要改进,低优先级。]

### 高级结论 [creative-director]
[创意总监的综合和总体评估。]

### 范围信号
基于以下因素估算实现范围:依赖数量、公式数量、
触及的系统,以及是否需要新的 ADR。
- **S** —— 单系统,无公式,无新 ADR,<3 依赖
- **M** —— 中等复杂度,1-2 个公式,3-6 依赖
- **L** —— 多系统集成,3+ 公式,可能需要新 ADR
- **XL** —— 跨切面关注点,5+ 依赖,可能需要多个新 ADR
清晰标注："粗略范围信号：M（制作人应在迭代规划前验证）"

### 结论：[APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
```

此技能是只读的 —— Phase 4 期间不写入任何文件。

---

## Phase 5: 下一步

所有收尾交互使用 `AskUserQuestion`。绝不使用纯文本。

**第一个组件 —— 接下来做什么:**

如果 APPROVED（首次通过，无需修订），直接进入 systems-index 组件、review-log 组件，然后是最终收尾组件。不要显示单独的“下一步”组件 —— 最终收尾组件已涵盖下一步。

如果 NEEDS REVISION 或 MAJOR REVISION NEEDED,选项:
- `[A] 立即修订 GDD —— 一起处理阻塞项`
- `[B] 到此为止 —— 在单独会话中修订`
- `[C] 按现状接受并继续（仅当所有项均为建议时）`

**如果用户选择 [A] —— 立即修订:**

处理所有阻塞项,仅在你无法从 GDD 和现有文档单独解决该问题时询问设计决策。在做出任何编辑之前,将所有设计决策问题组合到单个多标签 `AskUserQuestion` 中 —— 不要在修订过程中逐个阻塞项打断。

所有修订完成后,显示一个汇总表(阻塞项 → 应用的修复),并使用 `AskUserQuestion` 进行**修订后收尾组件**:

- 提示：“修订完成 —— 已解决 [N] 个阻塞项。接下来做什么？”
- 注意当前上下文使用：如果上下文超过 ~50%，添加：“（建议：在重新评审前执行 /clear —— 此会话已使用 X% 上下文。完整重新评审运行 5 个代理，需要干净的上下文。）”
- 选项:
  - `[A] 在新会话中重新评审 —— 在 /clear 后运行 /design-review [doc-path]`
  - `[B] 接受修订并标记为 Approved —— 更新系统索引,跳过重新评审`
  - `[C] 转到下一个系统 —— /design-system [next-system]（设计顺序中的 #N）`
  - `[D] 到此为止`

绝不要以纯文本结束修订流程。始终以此组件收尾。

**第二个组件 —— 跟踪记录（合并，用于 APPROVED 路径）：**

当结论为 APPROVED 时,使用单个带 `multiSelect: true` 的 `AskUserQuestion` 批量处理两个跟踪更新:
- 提示：“结论：APPROVED。我现在可以更新跟踪记录。选择你想让我完成的任何项：”
- 选项:
  - `将 systems-index.md 中 [system] 的状态更新为 'Approved'`
  - `将批准条目追加到 design/gdd/reviews/[doc-name]-review-log.md`

如果选择 review-log 选项,追加与下面相同的格式。在显示最终收尾组件之前执行所有选定的操作。

当结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED 时,使用单独的组件,如下所示:

使用第二个 `AskUserQuestion`:
- 提示：“我可以更新 `design/gdd/systems-index.md`，将 [system] 标记为 [In Review / Approved] 吗？”
- 选项:`[A] 是 —— 更新它` / `[B] 否 —— 保持原样`

使用第三个 `AskUserQuestion`:
- 提示：“我可以将此评审摘要追加到 `design/gdd/reviews/[doc-name]-review-log.md` 吗？这会创建修订历史，以便未来的重新评审可以跟踪变更。”
- 选项:`[A] 是 —— 追加到评审日志` / `[B] 否 —— 跳过`

如果是,按以下格式追加条目:
```
## Review — [YYYY-MM-DD] — Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
Scope signal: [S/M/L/XL]
Specialists: [列表]
Blocking items: [数量] | Recommended: [数量]
Summary: [来自 creative-director 结论的关键发现的 2-3 句摘要]
Prior verdict resolved: [Yes / No / First review]
```

---

**最终收尾组件 —— 在所有文件写入完成后始终显示:**

一旦 systems-index 和 review-log 组件得到回答,检查项目状态并显示一个最终的 `AskUserQuestion`:

在构建选项之前,读取:
- `design/gdd/systems-index.md` —— 查找任何状态为 Status: In Review 或 NEEDS REVISION 的系统（刚评审的除外）
- 统计 `design/gdd/` 中的 `.md` 文件数（排除 game-concept.md、systems-index.md），以确定是否值得提供 `/review-all-gdds`（≥2 个 GDD）
- 查找设计顺序中状态为 Status: Not Started 的下一个系统

动态构建选项列表 —— 仅包含真正是下一步的选项:
- `[_] 运行 /design-review [other-gdd-path] —— [system name] 仍为 [In Review / NEEDS REVISION]`（如果另一个 GDD 需要评审则包含）
- `[_] 运行 /consistency-check —— 验证此 GDD 的值不与现有 GDD 冲突`（如果存在 ≥1 个其他 GDD 则始终包含）
- `[_] 运行 /review-all-gdds —— 跨所有已设计系统的整体设计理论评审`（如果存在 ≥2 个 GDD 则包含）
- `[_] 运行 /design-system [next-system] —— 设计顺序中的下一个`（始终包含，指明实际系统）
- `[_] 到此为止`

仅为包含的选项分配字母 A、B、C…。将最能推进流程的选项标记为 `(recommended)`。

文件写入后绝不要以纯文本结束技能。始终以此组件收尾。
