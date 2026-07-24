---
name: map-systems
description: "将游戏概念分解为单独的系统,映射依赖关系,优先排序设计顺序,并创建系统索引。"
argument-hint: "[next | system-name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, TodoWrite, Task
model: sonnet
---

当调用此技能时:

## 解析参数

两种模式:

- **无参数**:`/map-systems` —— 运行完整分解工作流(Phase 1-5)
  来创建或更新系统索引。
- **`next`**:`/map-systems next` —— 从索引中选择最高优先级的未设计系统
  并交接给 `/design-system`(Phase 6)。

同时解析评审模式(一次解析,本次运行的所有门禁生成都使用):
1. 如果传递了 `--review [full|lean|solo]` → 使用它
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式见 `.claude/docs/director-gates.md`。

---

## Phase 1: 读取概念(必需上下文)

读取游戏概念和任何现有的设计工作。这提供了系统分解的原材料。

**必需:**
- 读取 `design/gdd/game-concept.md` —— **如果缺失则失败并给出清晰消息**:
  > "在 `design/gdd/game-concept.md` 未找到游戏概念。先运行 `/brainstorm`
  > 创建一个,然后回来将其分解为系统。"

**可选(如果存在则读取):**
- 读取 `design/gdd/game-pillars.md` —— 支柱约束优先级和范围
- 读取 `design/gdd/systems-index.md` —— 如果存在,**从上次离开的地方恢复**
  (更新,不要从头重建)
- Glob `design/gdd/*.md` —— 检查哪些系统 GDD 已存在

**如果系统索引已存在:**
- 读取它并向用户呈现当前状态
- 使用 `AskUserQuestion` 询问:
  "系统索引已存在,包含 [N] 个系统([M] 已设计,[K] 未开始)。
  你想做什么?"
  - 选项:"用新系统更新索引"、"设计下一个未设计的系统"、
    "评审和修订优先级"

---

## Phase 2: 系统枚举(协作)

提取并识别游戏需要的所有系统。这是技能的创意核心 —— 它需要人工判断,因为概念文档很少显式枚举每个系统。

### 步骤 2a: 提取显式系统

扫描游戏概念中直接提及的系统和机制:
- 核心机制章节(最显式)
- 核心循环章节(暗示什么系统驱动每个循环层级)
- 技术考量章节(网络、程序化生成等)
- MVP 定义章节(必需功能 = 必需系统)

### 步骤 2b: 识别隐式系统

对于每个显式系统,识别它暗示的**隐藏系统**。游戏总是需要比概念文档提及的更多系统。使用此推理模式:

- "物品栏"暗示:物品数据库、装备槽、重量/容量规则、物品栏 UI、物品序列化用于存档/读取
- "战斗"暗示:伤害计算、生命值系统、命中检测、状态效果、敌人 AI、战斗 UI(血条、伤害数字)、死亡/重生
- "开放世界"暗示:流式加载/分块、LOD 系统、快速旅行、地图/小地图、兴趣点追踪、世界状态持久化
- "多人游戏"暗示:网络层、大厅/匹配、状态同步、反作弊、网络 UI(延迟、玩家列表)
- "制作"暗示:配方数据库、材料采集、制作 UI、成功/失败机制、配方发现/学习
- "对话"暗示:对话树系统、对话 UI、选择追踪、NPC 状态管理、本地化钩子
- "进程"暗示:XP 系统、升级机制、技能树、解锁追踪、进程 UI、进程存档数据

在对话文本中解释每个隐式系统为何需要(附示例)。

### 步骤 2c: 用户评审

按类别呈现组织好的枚举。对于每个系统,显示:
- 名称
- 类别
- 简短描述(1 句话)
- 是显式的(来自概念)还是隐式的(推断的)

然后使用 `AskUserQuestion` 捕获反馈:
- "此列表中是否缺少系统?"
- "是否有任何应该合并或拆分?"
- "是否列出了此游戏不需要的系统?"

迭代直到用户批准枚举。

---

## Phase 3: 依赖映射(协作)

对于每个系统,确定它依赖什么。一个系统"依赖"另一个系统,如果它不能在另一个系统先存在的情况下运行。

### 步骤 3a: 映射依赖

对于每个系统,列出其依赖。使用这些依赖启发式:
- **输入/输出依赖**:系统 A 产生系统 B 需要的数据
- **结构依赖**:系统 A 提供系统 B 插入的框架
- **UI 依赖**:每个游戏玩法系统都有相应的 UI 系统依赖于它(但 UI 在游戏玩法系统之后设计)

### 步骤 3b: 按依赖顺序排序

将系统安排到层级中:
1. **Foundation**:零依赖的系统(先设计和构建)
2. **Core**:仅依赖 Foundation 系统的系统
3. **Feature**:依赖 Core 系统的系统
4. **Presentation**:包裹游戏玩法系统的 UI 和反馈系统
5. **Polish**:元系统、教程、分析、无障碍

### 步骤 3c: 检测循环依赖

检查依赖图中的环。如果发现:
- 向用户高亮它们
- 提出解决方案(接口抽象、同时设计、通过定义两个系统之间的契约来打破环)

### 步骤 3d: 呈现给用户

以分层列表显示依赖图。高亮:
- 任何循环依赖
- 任何"瓶颈"系统(许多其他系统依赖它们 —— 这些是高风险)
- 任何无依赖者的系统(叶节点 —— 风险较低,可以晚些设计)

使用 `AskUserQuestion` 询问:"这个依赖顺序看起来对吗?有我遗漏或应该删除的依赖吗?"

**评审模式检查** —— 在生成 TD-SYSTEM-BOUNDARY 之前应用:
- `solo` → 跳过。注意:"TD-SYSTEM-BOUNDARY skipped — Solo mode。"进入优先级分配。
- `lean` → 跳过(非 PHASE-GATE)。注意:"TD-SYSTEM-BOUNDARY skipped — Lean mode。"进入优先级分配。
- `full` → 正常生成。

**在依赖映射获批后,通过 Task 使用门禁 TD-SYSTEM-BOUNDARY(`.claude/docs/director-gates.md`)生成 `technical-director`,然后再进入优先级分配。**

传递:依赖图摘要、层级分配、瓶颈系统列表、任何循环依赖的解决方案。

呈现评估。如果 REJECT,在进入优先级分配前与用户修订系统边界。如果 CONCERNS,在系统索引中内联记录并继续。

---

## Phase 4: 优先级分配(协作)

根据系统在哪个里程碑需要,将每个系统分配到优先级层级。

### 步骤 4a: 基于概念自动分配

使用这些启发式进行初始分配:
- **MVP**:概念中"MVP 必需"章节提及的系统,加上它们的 Foundation 层依赖
- **Vertical Slice**:在一个区域完成完整体验所需的系统
- **Alpha**:所有剩余的游戏玩法系统
- **Full Vision**:打磨、元系统和可有可无的系统

### 步骤 4b: 用户评审

以表格形式呈现优先级分配。对于每个层级,解释系统为何被放在那里。

使用 `AskUserQuestion` 询问:"这些优先级分配符合你的愿景吗?哪些系统应该更高或更低优先级?"

在对话中解释理由:"我将 [system] 放在 MVP 中,因为核心循环需要它 —— 没有 [system],30 秒循环无法运行。"

**"Why"列指导**:在解释每个系统为何被放在某个优先级层级时,混合技术必要性和玩家体验理由。不要使用纯技术理由如"战斗需要伤害数学" —— 在相关处联系到玩家体验。好的"Why"条目示例:
- "核心循环必需 —— 没有它,放置决策就没有后果(Pillar 2:Placement is the Puzzle)"
- "弩炮的穿透特性在此建立 —— 此属性定义是使其感觉与 Archer 不同的关键"
- "所有经济决策的基础 —— 玩家必须理解升级成本才能做出有意义的放置选择"

当系统直接影响玩家体验时,纯技术必要性("X 依赖 Y")本身是不充分的。

**评审模式检查** —— 在生成 PR-SCOPE 之前应用:
- `solo` → 跳过。注意:"PR-SCOPE skipped — Solo mode。"进入写入系统索引。
- `lean` → 跳过(非 PHASE-GATE)。注意:"PR-SCOPE skipped — Lean mode。"进入写入系统索引。
- `full` → 正常生成。

**在优先级获批后,通过 Task 使用门禁 PR-SCOPE(`.claude/docs/director-gates.md`)生成 `producer`,然后再写入索引。**

传递:每个里程碑层级的系统总数、每层级的估算实现量(系统数 × 平均复杂度)、团队规模、已声明的项目时间线。

呈现评估。如果 UNREALISTIC,在写入索引前提供修订优先级层级分配。如果 CONCERNS,记录并继续。

### 步骤 4c: 确定设计顺序

结合依赖排序 + 优先级层级来产生最终设计顺序:
1. MVP Foundation 系统优先
2. MVP Core 系统其次
3. MVP Feature 系统第三
4. Vertical Slice Foundation/Core 系统
5. ……以此类推

这是团队编写 GDD 的顺序。

---

## Phase 5: 创建系统索引(写入)

### 步骤 5a: 起草文档

使用 `.claude/docs/templates/systems-index.md` 的模板,用 Phase 2-4 的所有数据填充系统索引:
- 填充枚举表
- 填充依赖图
- 填充推荐设计顺序
- 填充高风险系统
- 填充进度跟踪器(所有系统初始为"Not Started",除非 GDD 已存在)

### 步骤 5b: 审批

呈现文档摘要:
- 按类别的系统总数
- MVP 系统数
- 设计顺序中的前 3 个系统
- 任何高风险项

询问:"我可以将系统索引写入 `design/gdd/systems-index.md` 吗?"

等待审批。仅在"是"后写入文件。

**评审模式检查** —— 在生成 CD-SYSTEMS 之前应用:
- `solo` → 跳过。注意:"CD-SYSTEMS skipped — Solo mode。"进入 Phase 7 下一步。
- `lean` → 跳过(非 PHASE-GATE)。注意:"CD-SYSTEMS skipped — Lean mode。"进入 Phase 7 下一步。
- `full` → 正常生成。

**在系统索引写入后,通过 Task 使用门禁 CD-SYSTEMS(`.claude/docs/director-gates.md`)生成 `creative-director`。**

传递:系统索引路径、游戏支柱和核心幻想(来自 `design/gdd/game-concept.md`)、MVP 优先级层级系统列表。

呈现评估。如果 REJECT,在 GDD 编写开始前与用户修订系统集。如果 CONCERNS,在系统索引中相关层级章节顶部作为 `> **Creative Director Note**` 记录。

### 步骤 5c: 更新会话状态

写入后,创建 `production/session-state/active.md`(如果不存在),然后更新:
- Task:Systems decomposition
- Status:Systems index created
- File:design/gdd/systems-index.md
- Next:Design individual system GDDs

**结论:COMPLETE** —— 系统索引已写入 `design/gdd/systems-index.md`。
如果用户拒绝:**结论:BLOCKED** —— 用户未批准写入。

---

## Phase 6: 设计单独系统(交接给 /design-system)

此阶段在以下情况进入:
- 用户在创建索引后说"是"要设计系统
- 用户调用 `/map-systems [system-name]`
- 用户调用 `/map-systems next`

### 步骤 6a: 选择系统

- 如果提供了系统名称,在系统索引中查找它
- 如果使用了 `next`,选择最高优先级的未设计系统(按设计顺序)
- 如果用户刚完成索引,询问:
  "你想现在开始设计单独的系统吗?设计顺序中的第一个系统是 [name]。
  还是你想到此为止,以后再来?"

使用 `AskUserQuestion`:"现在开始设计 [system-name],选择不同的系统,还是到此为止?"

### 步骤 6b: 交接给 /design-system

一旦选择了系统,调用 `/design-system [system-name]` 技能。

`/design-system` 技能处理完整的 GDD 编写流程:
- 从游戏概念、系统索引和依赖 GDD 收集上下文
- 立即创建文件骨架
- 逐一走查所有 8 个必需章节(协作、增量)
- 交叉引用现有文档以防止矛盾
- 路由到专家代理获取域专业知识
- 每个章节一旦获批即写入文件
- 完成时运行 `/design-review`
- 更新系统索引

**不要在此处重复 /design-system 工作流。** 此技能拥有系统*索引*;`/design-system` 拥有单独的系统 *GDD*。

### 步骤 6c: 循环或停止

`/design-system` 完成后,使用 `AskUserQuestion`:
- "继续下一个系统([next system name])?"
- "选择不同的系统?"
- "此会话到此为止?"

如果继续,返回步骤 6a。

---

## Phase 7: 建议下一步

在系统索引创建后(或设计了一些系统后),使用 `AskUserQuestion` 呈现下一步操作:

- "系统索引已写入。你接下来想做什么?"
  - [A] 开始设计 GDD —— 运行 `/design-system [first-system-in-order]`
  - [B] 运行 `/gate-check systems-design` —— 自动触发 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 门禁,获得系统集的正式总监签核
  - [C] 此会话到此为止

**gate-check 选项 ([B]) 值得高亮**:运行 `/gate-check systems-design` 触发 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 两个门禁,在范围问题、缺失系统和边界问题被锁定到许多文档中之前捕获它们。它是可选的,但对于新项目推荐。

任何单独 GDD 完成后:
- "在全新会话中运行 `/design-review design/gdd/[system].md` 验证质量"
- "所有 MVP GDD 完成时运行 `/gate-check systems-design`"

---

## 协作协议

此技能在每个阶段遵循协作设计原则:

1. 每步**提问 -> 选项 -> 决定 -> 草稿 -> 审批**
2. 每个决策点使用 **AskUserQuestion**(解释 -> 捕获模式):
   - Phase 2:"缺少系统?合并还是拆分?"
   - Phase 3:"依赖顺序正确?"
   - Phase 4:"优先级分配符合你的愿景?"
   - Phase 5:"我可以写入系统索引吗?"
   - Phase 6:"开始设计、选择不同,还是停止?"然后交接给 `/design-system`
3. 每次文件写入前**"我可以写入 [filepath] 吗?"**
4. **增量写入**:每个系统设计完成后更新系统索引
5. **交接**:单独 GDD 编写由 `/design-system` 拥有,它处理增量章节写入、交叉引用、设计评审和索引更新
6. **会话状态更新**:每个里程碑后写入 `production/session-state/active.md`
   (索引创建、系统设计、优先级变更)

**绝不**在未经评审的情况下自动生成完整系统列表并写入。
**绝不**在未经用户确认的情况下开始设计系统。
**始终**显示枚举、依赖和优先级供用户验证。

## 上下文窗口感知

如果上下文在任何时候达到或超过 70%,追加此通知:

> **上下文接近限制(≥70%)。** 系统索引已保存到
> `design/gdd/systems-index.md`。打开全新的 Claude Code 会话继续
> 设计单独的 GDD —— 运行 `/map-systems next` 从上次离开的地方继续。

---

## 推荐下一步

- 运行 `/design-system [first-system-in-order]` 编写第一个 GDD(使用索引中的设计顺序)
- 运行 `/map-systems next` 始终自动选择最高优先级的未设计系统
- 每个 GDD 编写完成后,在全新会话中运行 `/design-review design/gdd/[system].md`
- 所有 MVP GDD 编写并评审后运行 `/gate-check pre-production`
