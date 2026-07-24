# Claude Code Game Studios -- 完整工作流指南

> **如何使用代理架构从零开始，最终发布一款游戏。**
>
> 本指南将引导你使用由 49 个代理、73 条斜杠命令和 12 个自动化钩子组成的系统，
> 完成游戏开发的每个阶段。阅读本指南前，请确保已安装 Claude Code，并在项目根目录下工作。
>
> 整个流程分为 7 个阶段。每个阶段都设有正式门禁（`/gate-check`），
> 只有通过后才能进入下一阶段。权威的阶段顺序定义在
> `.claude/docs/workflow-catalog.yaml` 中，由 `/help` 读取。

---

## 目录

1. [快速开始](#快速开始)
2. [阶段 1：概念](#阶段-1概念)
3. [阶段 2：系统设计](#阶段-2系统设计)
4. [阶段 3：技术搭建](#阶段-3技术搭建)
5. [阶段 4：前期制作](#阶段-4前期制作)
6. [阶段 5：制作](#阶段-5制作)
7. [阶段 6：打磨](#阶段-6打磨)
8. [阶段 7：发布](#阶段-7发布)
9. [贯穿各阶段的事项](#贯穿各阶段的事项)
10. [附录 A：代理速查表](#附录-a代理速查表)
11. [附录 B：斜杠命令速查表](#附录-b斜杠命令速查表)
12. [附录 C：常用工作流](#附录-c常用工作流)

---

## 快速开始

### 所需工具

开始之前，请确保已具备：

- 已安装且可正常使用的 **Claude Code**
- **Git**，以及 Git Bash（Windows）或标准终端（Mac/Linux）
- **jq**（可选但建议安装；缺少时钩子会改用 `grep`）
- **Python 3**（可选；部分钩子用它验证 JSON）

### 第 1 步：克隆并打开项目

```bash
git clone <repo-url> my-game
cd my-game
```

### 第 2 步：运行 /start

如果这是你的第一次会话：

```
/start
```

该引导式入门流程会询问你当前的进度，并将你引导至正确的阶段：

- **路径 A** -- 尚无想法：转到 `/brainstorm`
- **路径 B** -- 想法模糊：携带初始构想转到 `/brainstorm`
- **路径 C** -- 概念清晰：转到 `/setup-engine` 和 `/map-systems`
- **路径 D1** -- 已有项目，但产物很少：采用正常流程
- **路径 D2** -- 已有项目，且存在 GDD/ADR：先运行 `/project-stage-detect`，
  再运行 `/adopt` 完成棕地迁移

### 第 3 步：确认钩子正常工作

启动新的 Claude Code 会话。你应该会看到 `session-start.sh` 钩子的输出：

```
=== Claude Code Game Studios -- Session Context ===
Branch: main
Recent commits:
  abc1234 Initial commit
===================================
```

看到这些内容即表示钩子工作正常。否则，请检查 `.claude/settings.json`，
确认钩子路径与你的操作系统相符。

### 第 4 步：随时获取帮助

你可以随时运行：

```
/help
```

该命令会从 `production/stage.txt` 读取当前阶段，检查已有产物，
并准确告诉你下一步该做什么。它会区分必需步骤和可选事项。

### 第 5 步：创建目录结构

目录按需创建。系统预期采用以下布局：

```
src/                  # 游戏源代码
  core/               # 引擎/框架代码
  gameplay/           # 玩法系统
  ai/                 # AI 系统
  networking/         # 多人游戏代码
  ui/                 # UI 代码
  tools/              # 开发工具
assets/               # 游戏资产
  art/                # 精灵、模型、纹理
  audio/              # 音乐、音效
  vfx/                # 粒子效果
  shaders/            # 着色器文件
  data/               # JSON 配置/平衡性数据
design/               # 设计文档
  gdd/                # 游戏设计文档
  narrative/          # 故事、背景设定、对话
  levels/             # 关卡设计文档
  balance/            # 平衡性表格和数据
  ux/                 # UX 规格
docs/                 # 技术文档
  architecture/       # 架构决策记录
  api/                # API 文档
  postmortems/        # 项目复盘
tests/                # 测试套件
prototypes/           # 一次性原型
production/           # 迭代计划、里程碑、发布
  sprints/
  milestones/
  releases/
  epics/              # 史诗和故事文件（由 /create-epics + /create-stories 生成）
  playtests/          # 试玩报告
  session-state/      # 临时会话状态（gitignored）
  session-logs/       # 会话审计记录（gitignored）
```

> **提示：** 第一天无需创建所有目录。进入需要某个目录的阶段时再创建即可。
> 关键在于创建时遵循此结构，因为**规则系统**会根据文件路径执行相应规范。
> `src/gameplay/` 中的代码适用玩法规则，`src/ai/` 中的代码适用 AI 规则，依此类推。

---

## 阶段 1：概念

### 本阶段的工作

你将从“没有想法”或“想法模糊”，推进到一份明确设计支柱和玩家旅程的
结构化游戏概念文档。在此阶段，你要确定自己在做**什么**以及**为什么**要做。

### 阶段 1 流程

```
/brainstorm  -->  game-concept.md  -->  /design-review  -->  /setup-engine
     |                                        |                    |
     v                                        v                    v
   10 个概念       包含支柱、MDA、       概念文档验证        在 technical-preferences.md
   MDA 分析        核心循环和 USP                             中锁定引擎
   玩家动机        的概念文档
                                                                   |
                                                                   v
                                                             /prototype
                                                        （概念原型，1 至 3 天）
                                                        PROCEED ↓     PIVOT → /brainstorm
                                                                   |
                                                                    v（PROCEED）
                                                             /map-systems
                                                                   |
                                                                   v
                                                            systems-index.md
                                                             （所有系统、依赖关系、
                                                              优先级层次）
```

### 第 1.1 步：使用 /brainstorm 构思

这是起点。运行 brainstorm 技能：

```
/brainstorm
```

也可以提供类型提示：

```
/brainstorm roguelike deckbuilder
```

**具体过程：** brainstorm 技能会采用专业工作室方法，引导你完成六阶段协作构思流程：

1. 询问你的兴趣、主题和限制条件
2. 生成 10 个概念种子，并进行 MDA（机制、动态、美学）分析
3. 由你选出最喜欢的 2 至 3 个进行深入分析
4. 绘制玩家动机图谱并定位目标受众
5. 由你选定最终概念
6. 将其正式整理为 `design/gdd/game-concept.md`

概念文档包括：

- 一句话提案
- 核心幻想（玩家想象自己正在做什么）
- MDA 分解
- 目标受众（Bartle 类型、人口统计特征）
- 核心循环图
- 独特卖点
- 可比游戏及差异化
- 游戏支柱（3 至 5 项不可妥协的设计价值）
- 反支柱（游戏有意避免的内容）

### 第 1.2 步：评审概念（可选但建议执行）

```
/design-review design/gdd/game-concept.md
```

在继续之前验证文档结构和完整性。

### 第 1.3 步：选择引擎

```
/setup-engine
```

也可以指定引擎：

```
/setup-engine godot 4.6
```

**`/setup-engine` 的作用：**

- 在 `.claude/docs/technical-preferences.md` 中填写命名约定、性能预算和引擎专用默认值
- 检测知识缺口（引擎版本晚于 LLM 训练数据），并建议对照 `docs/engine-reference/`
- 在 `docs/engine-reference/` 中创建锁定版本的参考文档

**为什么重要：** 设置引擎后，系统便知道该使用哪些引擎专家代理。
如果选择 Godot，`godot-specialist`、`godot-gdscript-specialist` 和
`godot-shader-specialist` 等代理将成为你的首选专家。

### 第 1.4 步：将概念分解为系统

编写各个 GDD 前，先列出游戏所需的全部系统：

```
/map-systems
```

该命令会创建主跟踪文档 `design/gdd/systems-index.md`，其中：

- 列出游戏所需的每个系统（战斗、移动、UI 等）
- 标明系统间的依赖关系
- 分配优先级层次（MVP、Vertical Slice、Alpha、Full Vision）
- 确定设计顺序（Foundation > Core > Feature > Presentation > Polish）

进入阶段 2 前**必须**完成此步骤。对 155 份游戏项目复盘的研究表明，
跳过系统枚举会使制作阶段的成本增加 5 至 10 倍。

### 阶段 1 门禁

```
/gate-check concept
```

**通过要求：**

- 已在 `technical-preferences.md` 中配置引擎
- `design/gdd/game-concept.md` 存在且包含设计支柱
- `design/gdd/systems-index.md` 存在且包含依赖顺序

**结论：** PASS / CONCERNS / FAIL。CONCERNS 表示确认风险后仍可通过；
FAIL 会阻止进入下一阶段。

---

## 阶段 2：系统设计

### 本阶段的工作

你将创建定义游戏运作方式的全部设计文档。此时不编写任何代码，只进行设计。
系统索引中的每个系统都有独立 GDD，按章节编写并逐一评审，最后再交叉检查所有 GDD 的一致性。

### 阶段 2 流程

```
/map-systems next  -->  /design-system  -->  /design-review
       |                     |                     |
       v                     v                     v
   从 systems-index     逐章编写 GDD           验证 8 个必需章节
   选择下一个系统       （增量写入）            APPROVED/NEEDS REVISION
       |
        |  （对每个 MVP 系统重复）
       v
/review-all-gdds
       |
       v
   跨 GDD 一致性 + 设计理论评审
  PASS / CONCERNS / FAIL
```

### 第 2.1 步：编写系统 GDD

按照依赖顺序，使用引导式工作流设计各个系统：

```
/map-systems next
```

该命令会选择优先级最高且尚未设计的系统，并交给 `/design-system`，
后者会引导你逐章创建其 GDD。

你也可以直接设计指定系统：

```
/design-system combat-system
```

**`/design-system` 的作用：**

1. 读取游戏概念、系统索引及所有上下游 GDD
2. 执行技术可行性预检查（领域映射和可行性简报）
3. 逐一引导你完成 GDD 必需的 8 个章节
4. 每章均遵循：背景 > 问题 > 选项 > 决定 > 草稿 > 审批 > 写入
5. 每章获批后立即写入文件，崩溃后仍可保留
6. 标记与现有已批准 GDD 的冲突
7. 按类别转交专家代理（数学问题交给 systems-designer，经济问题交给
   economy-designer，故事系统交给 narrative-director）

**GDD 必需的 8 个章节：**

| # | 章节 | 内容 |
|---|---------|---------------|
| 1 | **概述** | 用一个段落概括系统 |
| 2 | **玩家幻想** | 玩家使用该系统时想象或感受到什么 |
| 3 | **详细规则** | 无歧义的机制规则 |
| 4 | **公式** | 所有计算，以及变量定义和取值范围 |
| 5 | **边界情况** | 异常情况下会发生什么？必须明确解决。 |
| 6 | **依赖关系** | 与哪些其他系统关联（双向） |
| 7 | **调节参数** | 设计师可安全修改哪些值，以及安全范围 |
| 8 | **验收标准** | 如何测试系统有效？必须具体且可度量。 |

此外还需包含**游戏手感**章节：手感参考、输入响应速度（毫秒/帧）、
动画手感目标（启动/生效/恢复）、冲击瞬间和重量感特征。

### 第 2.2 步：评审每份 GDD

开始下一个系统前，先验证当前系统：

```
/design-review design/gdd/combat-system.md
```

检查 8 个章节是否完整、公式是否清晰、边界情况是否解决、
依赖关系是否双向，以及验收标准是否可测试。

**结论：** APPROVED / NEEDS REVISION / MAJOR REVISION。只有 APPROVED 的 GDD 才能继续推进。

### 第 2.3 步：无需完整 GDD 的小型变更

对于不值得编写完整 GDD 的参数调整、小型补充或微调：

```
/quick-design "add 10% damage bonus for flanking attacks"
```

该命令会在 `design/quick-specs/` 中创建轻量规格，而非包含 8 个章节的完整 GDD。
它适用于参数调整、数值变更和小型补充。

### 第 2.4 步：跨 GDD 一致性评审

所有 MVP 系统 GDD 均单独获批后：

```
/review-all-gdds
```

该命令会同时读取全部 GDD，并执行两个分析阶段：

**阶段 1 -- 跨 GDD 一致性：**
- 依赖关系是否双向（A 引用了 B，B 是否也引用 A？）
- 系统间的规则矛盾
- 对已重命名或删除系统的过时引用
- 归属冲突（两个系统都声称负责同一职责）
- 公式范围兼容性（系统 A 的输出是否适合系统 B 的输入？）
- 验收标准交叉检查

**阶段 2 -- 设计理论（游戏设计整体观）：**
- 相互竞争的成长循环（两个系统是否争夺同一奖励空间？）
- 认知负荷（是否同时存在超过 4 个活跃系统？）
- 支配策略（是否有一种方法让其他方法都失去意义？）
- 经济循环分析（产出与消耗是否平衡？）
- 各系统间难度曲线是否一致
- 是否符合设计支柱、是否违反反支柱
- 玩家幻想是否连贯

**输出：** 带有结论的 `design/gdd/gdd-cross-review-[date].md`。

### 第 2.5 步：叙事设计（如适用）

如果游戏包含故事、背景设定或对话，应在此时构建：

1. **世界构建** -- 使用 `world-builder` 定义派系、历史、地理和世界规则
2. **故事结构** -- 使用 `narrative-director` 设计故事线、角色弧光和叙事节拍
3. **角色档案** -- 使用 `narrative-character-sheet.md` 模板

### 阶段 2 门禁

```
/gate-check systems-design
```

**通过要求：**

- `systems-index.md` 中所有 MVP 系统的状态均为 `Status: Approved`
- 每个 MVP 系统都有经过评审的 GDD
- 跨 GDD 评审报告（`design/gdd/gdd-cross-review-*.md`）存在，
  且结论为 PASS 或 CONCERNS（不能是 FAIL）

---

## 阶段 3：技术搭建

### 本阶段的工作

你将作出关键技术决策，将其记录为架构决策记录（Architecture Decision Record，ADR），
通过评审加以验证，并生成一份为程序员提供扁平、可执行规则的控制清单。
你还会建立 UX 基础。

### 阶段 3 流程

```
/create-architecture  -->  /architecture-decision (x N)  -->  /architecture-review
        |                          |                                   |
        v                          v                                   v
   覆盖所有系统的             位于 docs/architecture/        验证完整性、
   主架构文档                 adr-*.md 中的逐项 ADR           依赖顺序和引擎兼容性
                                                                      |
                                                                      v
                                                         /create-control-manifest
                                                                      |
                                                                      v
                                                         扁平化程序员规则
                                                         docs/architecture/
                                                         control-manifest.md
         本阶段还包括：
        -------------------
        /ux-design  -->  /ux-review
         无障碍要求文档
         交互模式库
```

### 第 3.1 步：主架构文档

```
/create-architecture
```

在 `docs/architecture/architecture.md` 中创建总体架构文档，
涵盖系统边界、数据流和集成点。

### 第 3.2 步：架构决策记录（ADR）

针对每项重大技术决策：

```
/architecture-decision "State Machine vs Behavior Tree for NPC AI"
```

**具体过程：** 该技能会引导你创建包含以下内容的 ADR：
- 背景和决策驱动因素
- 所有选项的优缺点及引擎兼容性
- 所选方案及理由
- 后果（正面、负面和风险）
- 依赖关系（Depends On、Enables、Blocks、Ordering Note）
- 涉及的 GDD 需求（通过 TR-ID 关联）

ADR 的生命周期为：Proposed > Accepted > Superseded/Deprecated。

执行门禁检查前，**至少需要 3 份 Foundation 层 ADR**。

**改造现有 ADR：** 如果棕地项目中已经存在 ADR：

```
/architecture-decision retrofit docs/architecture/adr-005.md
```

该命令会检测缺失的模板章节，仅补充这些章节，绝不覆盖现有内容。

### 第 3.3 步：架构评审

```
/architecture-review
```

统一验证所有 ADR：
- 对 ADR 依赖关系进行拓扑排序（检测循环）
- 验证引擎兼容性
- GDD 修订标记（根据 ADR 选择，标出需要更新的 GDD 章节）
- 维护 TR-ID 注册表（`docs/architecture/tr-registry.yaml`）

### 第 3.4 步：控制清单

```
/create-control-manifest
```

根据所有 Accepted ADR 生成一份扁平的程序员规则表：

```
docs/architecture/control-manifest.md
```

其中按代码层整理了必需模式、禁止模式和约束规则。
后续创建的故事会嵌入清单版本日期，以便检测内容是否过时。

### 第 3.5 步：无障碍要求

使用模板创建 `design/accessibility-requirements.md`。选定一个级别
（Basic / Standard / Comprehensive / Exemplary），并填写四轴功能矩阵
（视觉、运动、认知、听觉）。

阶段 3 必须提供此文档，因为阶段 4 编写的 UX 规格会引用该级别。
它是设计前提，而非 UX 交付物。

### 阶段 3 门禁

```
/gate-check technical-setup
```

**通过要求：**

- `docs/architecture/architecture.md` 存在
- 至少存在 3 份 ADR，且均为 Accepted
- 架构评审报告存在
- `docs/architecture/control-manifest.md` 存在
- `design/accessibility-requirements.md` 存在

---

## 阶段 4：前期制作

### 本阶段的工作

你将为关键界面创建 UX 规格，为高风险机制制作原型，将设计文档转化为可实现的故事，
规划第一次迭代，并构建一个证明核心循环有趣的垂直切片（Vertical Slice）。

### 阶段 4 流程

```
/ux-design  -->  /vertical-slice  -->  /create-epics  -->  /create-stories  -->  /sprint-plan
    |                   |                   |                   |                       |
    v                   v                   v                   v                       v
   UX 规格        制作质量的端到端版本  production/ 中的     production/ 中的        包含优先故事的
   design/ux/     位于 prototypes/     史诗文件             故事文件                第一次迭代
                 in prototypes/       epics/*/EPIC.md     epics/*/story-*.md      production/sprints/
                  PROCEED/PIVOT/KILL   （每个模块一份）      （每项行为一份）          sprint-*.md
    |                                                          |
    v                                                          v
 /ux-review                                             /story-readiness
  （在编写史诗前                                       （领取前验证每个故事）
   验证规格）
                                                               |
                                                               v
                                                           /dev-story
                                                          （实现故事并转交
                                                           正确的代理）
```

### 第 4.1 步：关键界面的 UX 规格

编写史诗前先创建 UX 规格，让故事作者了解有哪些界面，以及必须支持哪些玩家交互。

**UX 规格：**

```
/ux-design main-menu
/ux-design core-gameplay-hud
```

共有三种模式：界面/流程、HUD 和交互模式。输出存入 `design/ux/`。
每份规格包括玩家需求、布局区域、状态、交互图、数据要求、触发事件、无障碍和本地化。

该命令会读取阶段 3 编写的 `accessibility-requirements.md`，以及
`technical-preferences.md` 中的输入方式配置，用于无障碍和输入覆盖检查，
无需在每个界面中重复说明。

> **提示：** `/design-system` 会为每个有 UI 要求的系统生成 UX 标记。
> 可用这些标记检查哪些界面需要规格。

**交互模式库：**

```
/ux-design interaction-patterns
```

创建 `design/ux/interaction-patterns.md`，其中包含 16 种标准控件，
以及游戏专用模式（物品栏槽位、技能图标、HUD 条、对话框等）的动画和声音标准。

**UX 评审：**

```
/ux-review all
```

验证 UX 规格是否符合 GDD 和无障碍级别要求。
给出 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 结论。

### 第 4.2 步：构建垂直切片

垂直切片是达到制作质量的证明，用来确认你能在全面投入制作前端到端构建完整游戏循环。

```
/vertical-slice
```

**验证内容：** 玩家能否从零开始，在没有开发者指导的情况下，于几分钟内体验到核心幻想？

**构建内容：** 一个接近制作质量的可玩版本，至少覆盖一次完整的
[开始 → 挑战 → 解决] 循环。它使用真实的架构层和命名约定，不含硬编码值，
但不要求最终美术或音频。它不像概念原型那样用完即弃，而是用于证明制作管线可行。

**关于概念原型：** 如果你在阶段 1（概念）运行过 `/prototype`，就已经验证了核心创意是否有趣。
垂直切片则验证你能否正确实现它，两者回答的是不同问题。如果跳过了概念原型，
此时可以先制作一个，再投入完整垂直切片。

**结论：** 垂直切片会给出 PROCEED / PIVOT / KILL 结论。
- **PROCEED** → 进入第 4.3 步（史诗和故事）
- **PIVOT** → 使用 `/design-system [mechanic]` 修订受影响的 GDD，然后重新运行 `/vertical-slice`
- **KILL** → 带着所得经验返回 `/brainstorm`

### 第 4.3 步：根据设计产物创建史诗和故事

```
/create-epics layer: foundation
/create-stories [epic-slug]   # 对每个史诗重复
/create-epics layer: core
/create-stories [epic-slug]   # 对每个核心史诗重复
```

`/create-epics` 会读取 GDD、ADR 和架构来定义史诗范围，每个架构模块对应一个史诗。
随后，`/create-stories` 将各史诗拆分为 `production/epics/[slug]/` 中可实现的故事文件。
每个故事都会嵌入：
- GDD 需求引用（使用 TR-ID 而非引用原文，以保持最新）
- ADR 引用（仅限 Accepted ADR；Proposed ADR 会导致 `Status: Blocked`）
- 控制清单版本日期（用于检测是否过时）
- 引擎专用实现说明
- GDD 中的验收标准

故事创建后，运行 `/dev-story [story-path]` 即可实现其中一个；
该命令会自动转交正确的程序员代理。

### 第 4.4 步：领取前验证故事

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

检查设计完整性、架构覆盖、范围清晰度和完成定义。
结论：READY / NEEDS WORK / BLOCKED。

### 第 4.5 步：工作量估算

```
/estimate production/epics/combat/story-combat-damage-calc.md
```

提供包含风险评估的工作量估算。

### 第 4.6 步：规划第一次迭代

```
/sprint-plan new
```

**具体过程：** `producer` 代理会与你协作规划迭代：
- 询问迭代目标和可用时间
- 将目标拆分为 Must Have / Should Have / Nice to Have 任务
- 识别风险和阻塞项
- 创建 `production/sprints/sprint-01.md`
- 填充 `production/sprint-status.yaml`（机器可读的故事跟踪文件）

### 第 4.7 步：垂直切片（硬门禁）

进入制作阶段前，必须构建并试玩一个垂直切片：

- 一个完整的端到端核心循环，可从头玩到尾
- 具有代表性的质量（不能全部使用占位内容）
- 至少进行 3 次无指导试玩
- 已编写试玩报告（`/playtest-report`）

这是一个**硬门禁**。如果没有真人无指导试玩该版本，`/gate-check` 会自动判定为 FAIL。

### 阶段 4 门禁

```
/gate-check pre-production
```

**通过要求：**

- `design/ux/` 中至少有 1 份经过评审的 UX 规格
- UX 评审已完成（APPROVED，或 NEEDS REVISION 且风险已有记录）
- 至少有 1 个带 README 的原型
- `production/epics/[epic-slug]/` 中存在故事文件
- 至少存在 1 份迭代计划
- 至少存在 1 份试玩报告（垂直切片已试玩 3 次以上）

---

## 阶段 5：制作

### 本阶段的工作

这是核心制作循环。你将按迭代工作（通常为 1 至 2 周），逐个故事实现功能、跟踪进度，
并通过结构化完成评审关闭故事。此阶段会不断重复，直至游戏内容全部完成。

### 阶段 5 流程（每次迭代）

```
/sprint-plan new  -->  /story-readiness  -->  实现  -->  /story-done
       |                     |                    |                |
       v                     v                    v                v
   已创建迭代           已验证故事            已编写代码       八阶段评审：
   sprint-status.yaml   READY 结论            测试通过         验证标准、
   已填充                                                    检查偏差、
                                                             更新故事状态
       |
        |  （逐个故事重复，直至迭代完成）
       v
  /sprint-status  （随时生成 30 行快速快照）
  /scope-check    （范围扩大时）
  /retrospective  （迭代结束时）
```

### 第 5.1 步：故事生命周期

制作阶段以**故事生命周期**为核心：

```
/story-readiness  -->  实现  -->  /story-done  -->  下一个故事
```

**1. 故事就绪检查：** 领取故事前先进行验证：

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

该命令会检查设计完整性、架构覆盖、ADR 状态（仍为 Proposed 时阻塞）、
控制清单版本（过时时警告）和范围清晰度。
结论：READY / NEEDS WORK / BLOCKED。

**2. 实现：** 与合适的代理协作：

- `gameplay-programmer` 负责玩法系统
- `engine-programmer` 负责核心引擎工作
- `ai-programmer` 负责 AI 行为
- `network-programmer` 负责多人游戏
- `ui-programmer` 负责 UI 代码
- `tools-programmer` 负责开发工具

所有代理都遵循协作协议：读取设计文档、提出澄清问题、展示架构选项、
获得你的批准，然后实现。

**3. 故事完成：** 故事完成后：

```
/story-done production/epics/combat/story-combat-damage-calc.md
```

该命令会执行八阶段完成评审：
1. 查找并读取故事文件
2. 加载引用的 GDD、ADR 和控制清单
3. 验证验收标准（可自动检查、手动检查、延期检查）
4. 检查是否偏离 GDD/ADR（BLOCKING / ADVISORY / OUT OF SCOPE）
5. 提示进行代码评审
6. 生成完成报告（COMPLETE / COMPLETE WITH NOTES / BLOCKED）
7. 使用完成说明将故事更新为 `Status: Complete`
8. 显示下一个就绪故事

评审中发现的技术债务会记录到 `docs/tech-debt-register.md`。

### 第 5.2 步：迭代跟踪

随时检查进度：

```
/sprint-status
```

从 `production/sprint-status.yaml` 读取并生成 30 行的快速快照。

如果范围正在扩大：

```
/scope-check production/sprints/sprint-03.md
```

该命令会对照原计划比较当前范围，标记范围增长并建议删减项。

### 第 5.3 步：内容跟踪

```
/content-audit
```

将 GDD 规定的内容与已实现内容进行比较，及早发现内容缺口。

### 第 5.4 步：传播设计变更

创建故事后，如果 GDD 发生变更：

```
/propagate-design-change design/gdd/combat-system.md
```

该命令会使用 Git 比较 GDD，查找受影响的 ADR，生成影响报告，
并引导你决定将其 Superseded、更新或保留。

### 第 5.5 步：多系统功能（团队编排）

对于跨越多个领域的功能，请使用团队技能：

```
/team-combat "healing ability with HoT and cleanse"
/team-narrative "Act 2 story content"
/team-ui "inventory screen redesign"
/team-level "forest dungeon level"
/team-audio "combat audio pass"
```

每个团队技能都会协调六阶段协作工作流：
1. **设计** -- game-designer 提问并展示选项
2. **架构** -- lead-programmer 提出代码结构
3. **并行实现** -- 专家同时工作
4. **集成** -- gameplay-programmer 将所有部分连接起来
5. **验证** -- qa-tester 按验收标准执行测试
6. **报告** -- 协调者汇总状态

编排过程自动执行，但**决策权始终在你手中**。

### 第 5.6 步：迭代评审和下一次迭代

迭代结束时：

```
/retrospective
```

分析计划与实际完成情况、速率、阻塞项及可执行的改进措施。

然后规划下一次迭代：

```
/sprint-plan new
```

### 第 5.7 步：里程碑评审

到达里程碑检查点时：

```
/milestone-review "alpha"
```

生成有关功能完整度、质量指标和风险评估的报告，并提出继续/停止建议。

### 阶段 5 门禁

```
/gate-check production
```

**通过要求：**

- 所有 MVP 故事均已完成
- 进行 3 次试玩，覆盖新玩家、中期游戏和难度曲线
- 已验证趣味性假设
- 试玩数据中不存在困惑循环

---

## 阶段 6：打磨

### 本阶段的工作

游戏功能已经完整，现在要提升其品质。本阶段重点关注性能、平衡性、无障碍、
音频、视觉打磨和试玩。

### 阶段 6 流程

```
/perf-profile  -->  /balance-check  -->  /asset-audit  -->  /playtest-report (x3)
       |                  |                    |                    |
       v                  v                    v                    v
   分析 CPU/GPU       分析公式和数据，      验证命名、          覆盖：新玩家、
   与内存，优化       查找异常成长曲线      格式和大小          中期游戏、难度曲线
   瓶颈

  /tech-debt  -->  /team-polish
       |                |
       v                v
   跟踪技术债务     协调式打磨：
   并确定优先级     性能 + 美术 +
                    音频 + UX + QA
```

### 第 6.1 步：性能分析

```
/perf-profile
```

引导你完成结构化性能分析：
- 确定目标（FPS、内存、平台）
- 按影响程度识别并排列瓶颈
- 生成可执行的优化任务，注明代码位置和预期收益

### 第 6.2 步：平衡性分析

```
/balance-check assets/data/combat_damage.json
```

分析平衡性数据中的统计异常值、异常成长曲线、退化策略和经济失衡。

### 第 6.3 步：资产审计

```
/asset-audit
```

验证所有资产的命名约定、文件格式标准和大小预算。

### 第 6.4 步：试玩（必须进行 3 次）

```
/playtest-report
```

生成结构化试玩报告。必须进行 3 次试玩，覆盖：
- 新玩家体验
- 中期游戏系统
- 难度曲线

### 第 6.5 步：技术债务评估

```
/tech-debt
```

扫描 TODO/FIXME/HACK 注释、重复代码、过度复杂的函数、缺失的测试和过时依赖。
对每一项进行分类并确定优先级。

### 第 6.6 步：协调式打磨

```
/team-polish "combat system"
```

并行协调 4 位专家：
1. 性能优化（performance-analyst）
2. 视觉打磨（technical-artist）
3. 音频打磨（sound-designer）
4. 手感与表现力（gameplay-programmer + technical-artist）

你设定优先级；团队在每一步获得你的批准后执行。

### 第 6.7 步：本地化与无障碍

```
/localize src/
```

扫描硬编码字符串、会破坏翻译的字符串拼接、未预留文本扩展空间的内容，
以及缺失的区域设置文件。

根据阶段 3 无障碍要求文档中确定的级别进行无障碍审计。

### 阶段 6 门禁

```
/gate-check polish
```

**通过要求：**

- 至少存在 3 份试玩报告
- 已完成协调式打磨（`/team-polish`）
- 不存在阻塞性性能问题
- 已满足无障碍级别要求

---

## 阶段 7：发布

### 本阶段的工作

游戏已经完成打磨和测试，一切就绪。现在可以发布了。

### 阶段 7 流程

```
/release-checklist  -->  /launch-checklist  -->  /team-release
        |                       |                      |
        v                       v                      v
  跨代码、内容、商店      完整的跨部门验证         协调：
  和法务的发布前验证      （各部门 Go/No-Go）      构建、QA 签核、
                                                   部署、发布
                    另包括：/changelog、/patch-notes、/hotfix
```

### 第 7.1 步：发布清单

```
/release-checklist v1.0.0
```

生成全面的发布前清单，涵盖：
- 构建验证（所有平台均可编译并运行）
- 认证要求（平台专用）
- 商店元数据（描述、截图、预告片）
- 法律合规（EULA、隐私政策、分级）
- 存档兼容性
- 分析系统验证

### 第 7.2 步：上线就绪检查（完整验证）

```
/launch-checklist
```

完整的跨部门验证：

| 部门 | 检查内容 |
|-----------|---------------|
| **工程** | 构建稳定性、崩溃率、内存泄漏、加载时间 |
| **设计** | 功能完整度、教程流程、难度曲线 |
| **美术** | 资产质量、缺失纹理、LOD 级别 |
| **音频** | 缺失声音、混音电平、空间音频 |
| **QA** | 按严重程度统计的未解决缺陷数、回归测试套件通过率 |
| **叙事** | 对话完整性、背景设定一致性、拼写错误 |
| **本地化** | 所有字符串均已翻译、无截断、区域设置测试 |
| **无障碍** | 合规清单、辅助功能测试 |
| **商店** | 元数据完整、截图获批、价格已设定 |
| **市场营销** | 新闻资料包就绪、发布预告片、社交媒体排期 |
| **社区** | 更新说明草稿、FAQ、支持渠道就绪 |
| **基础设施** | 服务器已扩容、CDN 已配置、监控已启用 |
| **法务** | EULA 已定稿、隐私政策、符合 COPPA/GDPR 要求 |

每一项都会获得 **Go / No-Go** 状态。全部为 Go 才能发布。

### 第 7.3 步：生成面向玩家的内容

```
/patch-notes v1.0.0
```

根据 Git 历史和迭代数据生成便于玩家理解的更新说明，
将开发者用语转化为玩家用语。

```
/changelog v1.0.0
```

生成内部变更日志（技术性更强，供团队使用）。

### 第 7.4 步：协调发布

```
/team-release
```

协调 release-manager、QA 和 DevOps 完成：
1. 发布前验证
2. 构建管理
3. 最终 QA 签核
4. 部署准备
5. Go/No-Go 决策

### 第 7.5 步：发布

推送到 `main` 或 `develop` 时，`validate-push` 钩子会发出警告。
这是有意为之，发布推送应当经过慎重确认：

```bash
git tag v1.0.0
git push origin main --tags
```

### 第 7.6 步：上线后

针对严重线上缺陷的**热修复工作流**：

```
/hotfix "Players losing save data when inventory exceeds 99 items"
```

绕过正常迭代流程，同时保留完整审计记录：
1. 创建热修复分支
2. 实现修复
3. 确保将修复回传至开发分支
4. 记录事件

上线稳定后进行**项目复盘**：

```
让 Claude 使用以下模板创建项目复盘：
.claude/docs/templates/post-mortem.md
```

---

## 贯穿各阶段的事项

以下主题适用于所有阶段。

### 总监评审模式

总监门禁是由专家代理在工作流关键步骤对工作进行评审的机制。
默认情况下，每个检查点都会运行。你可以控制评审强度。

**在 `/start` 期间设置一次评审强度。** 设置会保存到 `production/review-mode.txt`。

| 模式 | 运行内容 | 最适合 |
|------|-----------|----------|
| `full` | 每一步都运行所有总监门禁 | 新项目、学习本系统 |
| `lean` | 仅在阶段转换（`/gate-check`）时运行总监评审 | 经验丰富的开发者 |
| `solo` | 不进行总监评审 | 游戏创作活动、原型、追求最高速度 |

**仅覆盖单次运行**，不更改全局设置：

```
/brainstorm space horror --review full
/architecture-decision --review solo
```

`--review` 标志适用于所有使用门禁的技能。你可以随时直接编辑
`production/review-mode.txt` 或重新运行 `/start` 来更改全局模式。

完整的门禁定义和检查模式见：`.claude/docs/director-gates.md`

---

### 协作协议

本系统采用**用户驱动的协作方式**，而非自主执行。

**模式：** 提问 > 选项 > 决定 > 草稿 > 审批

每次代理交互都遵循此模式：
1. 代理提出澄清问题
2. 代理展示 2 至 4 个选项，并说明权衡和理由
3. 由你决定
4. 代理根据你的决定起草内容
5. 由你评审并完善
6. 写入前，代理会询问“可以将此内容写入 [filepath] 吗？”

包含示例的完整协议见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

### AskUserQuestion 工具

代理使用 `AskUserQuestion` 工具以结构化方式展示选项。
其模式是先解释、再收集：先在对话文本中给出完整分析，再通过简洁的 UI 选项器收集决定。
它适用于设计选择、架构决策和战略问题，不适用于开放式探索问题或简单的是/否确认。

### 代理协调（三级层次结构）

```
第 1 级（总监）：      creative-director, technical-director, producer
                                          |
第 2 级（主管）：      game-designer, lead-programmer, art-director,
                       audio-director, narrative-director, qa-lead,
                       release-manager, localization-lead
                                          |
第 3 级（专家）：      gameplay-programmer, engine-programmer,
                       ai-programmer, network-programmer, ui-programmer,
                       tools-programmer, systems-designer, level-designer,
                       economy-designer, world-builder, writer,
                       technical-artist, sound-designer, ux-designer,
                       qa-tester, performance-analyst, devops-engineer,
                       analytics-engineer, accessibility-specialist,
                       live-ops-designer, prototyper, security-engineer,
                       community-manager, godot-specialist,
                       godot-gdscript-specialist, godot-shader-specialist,
                       godot-csharp-specialist, godot-gdextension-specialist,
                       unity-specialist, unity-dots-specialist,
                       unity-shader-specialist, unity-addressables-specialist,
                       unity-ui-specialist, unreal-specialist,
                       ue-blueprint-specialist, ue-gas-specialist,
                       ue-replication-specialist, ue-umg-specialist
```

**协调规则：**
- 纵向转交：总监 > 主管 > 专家。复杂决策绝不能跨级处理。
- 横向协商：同级代理可以相互协商，但不得对自身领域之外的事项作出约束性决定。
- 冲突解决：设计冲突交给 `creative-director`，技术冲突交给 `technical-director`，
  范围冲突交给 `producer`。
- 不得单方面进行跨领域变更。

### 自动化钩子（安全网）

系统包含 12 个自动运行的钩子：

| 钩子 | 触发时机 | 作用 |
|------|---------|-------------|
| `session-start.sh` | 会话开始 | 显示分支和最近提交，并检测 `active.md` 以恢复会话 |
| `detect-gaps.sh` | 会话开始 | 检测全新项目（无引擎、无概念）并建议运行 `/start` |
| `pre-compact.sh` | 压缩前 | 将会话状态写入对话，以便自动恢复 |
| `post-compact.sh` | 压缩后 | 提醒 Claude 从 `active.md` 恢复会话状态 |
| `notify.sh` | 通知事件 | 通过 PowerShell 显示 Windows 浮动通知 |
| `validate-commit.sh` | 提交前 | 检查设计文档引用、JSON 有效性和硬编码值 |
| `validate-push.sh` | 推送前 | 推送到 `main`/`develop` 时发出警告 |
| `validate-assets.sh` | 提交前 | 检查资产命名和大小 |
| `validate-skill-change.sh` | 写入技能文件时 | 修改 `.claude/skills/` 后建议运行 `/skill-test` |
| `log-agent.sh` | 代理启动 | 记录代理调用，形成审计记录 |
| `log-agent-stop.sh` | 代理停止 | 完成代理审计记录（启动 + 停止） |
| `session-stop.sh` | 会话结束 | 记录最终会话日志 |

### 上下文韧性

**会话状态文件：** `production/session-state/active.md` 是持续更新的检查点。
每个重要里程碑后都应更新。发生任何中断（压缩、崩溃、`/clear`）后，先读取此文件。

**增量写入：** 创建多章节文档时，每章获批后立即写入文件。
这样，已完成章节可在崩溃和上下文压缩后保留，已经写入的章节所对应的早期讨论也可安全压缩。

**自动恢复：** `session-start.sh` 钩子会自动检测并预览 `active.md`。
`pre-compact.sh` 钩子会在压缩前将状态写入对话。

**迭代状态跟踪：** `production/sprint-status.yaml` 是机器可读的故事跟踪文件。
由 `/sprint-plan`（初始化）和 `/story-done`（状态更新）写入；由 `/sprint-status`、
`/help` 和 `/story-done`（下一个故事）读取，从而避免不可靠的 Markdown 扫描。

### 棕地项目采用

对于已有部分产物的现有项目：

```
/adopt
```

也可以指定目标：

```
/adopt gdds
/adopt adrs
/adopt stories
/adopt infra
```

该命令审计现有产物的**格式**（而非是否存在），将差距分类为
BLOCKING/HIGH/MEDIUM/LOW，构建有序迁移计划，并写入
`docs/adoption-plan-[date].md`。核心原则是 MIGRATION 而非 REPLACEMENT：
绝不重新生成现有成果，只补充缺失内容。

各项技能也支持改造模式：

```
/design-system retrofit design/gdd/combat-system.md
/architecture-decision retrofit docs/architecture/adr-005.md
```

这些命令会检测已有和缺失的章节，只补充缺失内容。

### 门禁系统

阶段门禁是正式检查点。使用转换名称运行 `/gate-check`：

```
/gate-check concept              # 概念 -> 系统设计
/gate-check systems-design       # 系统设计 -> 技术搭建
/gate-check technical-setup      # 技术搭建 -> 前期制作
/gate-check pre-production       # 前期制作 -> 制作
/gate-check production           # 制作 -> 打磨
/gate-check polish               # 打磨 -> 发布
```

**结论：**
- **PASS** -- 满足所有要求，可进入下一阶段
- **CONCERNS** -- 满足要求且已确认风险，可以通过
- **FAIL** -- 未满足要求，阻止推进并给出具体补救措施

门禁通过后（且仅在此时）会更新 `production/stage.txt`，
该文件控制状态行和 `/help` 的行为。

### 反向文档化

对于已有代码但缺少设计文档的情况（棕地项目采用后很常见）：

```
/reverse-document src/gameplay/combat/
```

读取现有代码，并据此生成 GDD 格式的设计文档。

---

## 附录 A：代理速查表

### “我需要做 X，应该使用哪个代理？”

| 我需要…… | 代理 | 级别 |
|-------------|-------|------|
| 构思游戏创意 | `/brainstorm` 技能 | -- |
| 设计游戏机制 | `game-designer` | 2 |
| 设计具体公式/数值 | `systems-designer` | 3 |
| 设计游戏关卡 | `level-designer` | 3 |
| 设计掉落表/经济系统 | `economy-designer` | 3 |
| 构建世界背景设定 | `world-builder` | 3 |
| 编写对话 | `writer` | 3 |
| 规划故事 | `narrative-director` | 2 |
| 规划迭代 | `producer` | 1 |
| 作出创意决策 | `creative-director` | 1 |
| 作出技术决策 | `technical-director` | 1 |
| 实现玩法代码 | `gameplay-programmer` | 3 |
| 实现核心引擎系统 | `engine-programmer` | 3 |
| 实现 AI 行为 | `ai-programmer` | 3 |
| 实现多人游戏 | `network-programmer` | 3 |
| 实现 UI | `ui-programmer` | 3 |
| 构建开发工具 | `tools-programmer` | 3 |
| 评审代码架构 | `lead-programmer` | 2 |
| 创建着色器/VFX | `technical-artist` | 3 |
| 定义视觉风格 | `art-director` | 2 |
| 定义音频风格 | `audio-director` | 2 |
| 设计音效 | `sound-designer` | 3 |
| 设计 UX 流程 | `ux-designer` | 3 |
| 编写测试用例 | `qa-tester` | 3 |
| 规划测试策略 | `qa-lead` | 2 |
| 分析性能 | `performance-analyst` | 3 |
| 搭建 CI/CD | `devops-engineer` | 3 |
| 设计分析系统 | `analytics-engineer` | 3 |
| 检查无障碍 | `accessibility-specialist` | 3 |
| 规划在线运营 | `live-ops-designer` | 3 |
| 管理发布 | `release-manager` | 2 |
| 管理本地化 | `localization-lead` | 2 |
| 快速制作原型 | `prototyper` | 3 |
| 审计安全性 | `security-engineer` | 3 |
| 与玩家沟通 | `community-manager` | 3 |
| 获取 Godot 专用帮助 | `godot-specialist` | 3 |
| 获取 GDScript 专用帮助 | `godot-gdscript-specialist` | 3 |
| 获取 Godot 着色器帮助 | `godot-shader-specialist` | 3 |
| 开发 GDExtension 模块 | `godot-gdextension-specialist` | 3 |
| 获取 Unity 专用帮助 | `unity-specialist` | 3 |
| 使用 Unity DOTS/ECS | `unity-dots-specialist` | 3 |
| 使用 Unity 着色器/VFX | `unity-shader-specialist` | 3 |
| 使用 Unity Addressables | `unity-addressables-specialist` | 3 |
| 使用 Unity UI Toolkit | `unity-ui-specialist` | 3 |
| 获取 Unreal 专用帮助 | `unreal-specialist` | 3 |
| 使用 Unreal GAS | `ue-gas-specialist` | 3 |
| 使用 Unreal Blueprints | `ue-blueprint-specialist` | 3 |
| 实现 Unreal 网络复制 | `ue-replication-specialist` | 3 |
| 使用 Unreal UMG/CommonUI | `ue-umg-specialist` | 3 |

### 代理层次结构

```
                    creative-director / technical-director / producer
                                         |
          ---------------------------------------------------------------
          |            |           |           |          |        |       |
    game-designer  lead-prog  art-dir  audio-dir  narr-dir  qa-lead  release-mgr
          |            |           |           |          |        |        |
     specialists  programmers  tech-art  snd-design  writer   qa-tester  devops
     (systems,    (gameplay,             (sound)     (world-  (perf,     (analytics,
      economy,     engine,                           builder)  access.)   security)
      level)       ai, net,
                   ui, tools)
```

**升级规则：** 如果两个代理意见不一致，向上升级。设计冲突交给
`creative-director`，技术冲突交给 `technical-director`，范围冲突交给 `producer`。

---

## 附录 B：斜杠命令速查表

### 按类别划分的全部 73 条命令

#### 入门与导航（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/start` | 引导式入门，转到正确工作流 | 任意（首次会话） |
| `/help` | 根据上下文回答“下一步做什么？” | 任意 |
| `/project-stage-detect` | 全面审计项目并确定当前阶段 | 任意 |
| `/setup-engine` | 配置引擎、锁定版本、设置偏好 | 1 |
| `/adopt` | 棕地项目审计和迁移计划 | 任意（现有项目） |
| `/skill-improve` | 通过测试-修复-重测循环改进技能 | 任意 |

#### 游戏设计（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/brainstorm` | 采用 MDA 分析的协作式构思 | 1 |
| `/map-systems` | 将概念分解为系统索引 | 1-2 |
| `/design-system` | 引导式逐章编写 GDD | 2 |
| `/quick-design` | 小型变更的轻量规格 | 2+ |
| `/review-all-gdds` | 跨 GDD 一致性和设计理论评审 | 2 |
| `/propagate-design-change` | 查找受 GDD 变更影响的 ADR/故事 | 5 |

#### UX 与界面（2）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/ux-design` | 编写 UX 规格（界面/流程、HUD、模式） | 4 |
| `/ux-review` | 验证 UX 规格是否符合无障碍要求和 GDD | 4 |

#### 架构（4）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/create-architecture` | 主架构文档 | 3 |
| `/architecture-decision` | 创建或改造 ADR | 3 |
| `/architecture-review` | 验证所有 ADR 及依赖顺序 | 3 |
| `/create-control-manifest` | 根据 Accepted ADR 生成扁平化程序员规则 | 3 |

#### 故事与迭代（8）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/create-epics` | 将 GDD + ADR 转化为史诗（每个模块一个） | 4 |
| `/create-stories` | 将单个史诗拆分为故事文件 | 4 |
| `/dev-story` | 实现故事，并转交正确的程序员代理 | 5 |
| `/sprint-plan` | 创建或管理迭代计划 | 4-5 |
| `/sprint-status` | 生成 30 行迭代快速快照 | 5 |
| `/story-readiness` | 验证故事是否已准备好实施 | 4-5 |
| `/story-done` | 八阶段故事完成评审 | 5 |
| `/estimate` | 包含风险评估的工作量估算 | 4-5 |

#### 评审与分析（13）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/design-review` | 按 8 章节标准验证 GDD | 1-2 |
| `/code-review` | 架构代码评审 | 5+ |
| `/balance-check` | 游戏平衡性公式分析 | 5-6 |
| `/asset-audit` | 验证资产命名、格式和大小 | 6 |
| `/asset-spec` | 为各项资产生成视觉规格和 AI 生成提示词 | 5-6 |
| `/content-audit` | 对比 GDD 规定内容与已实现内容 | 5 |
| `/consistency-check` | 扫描跨 GDD 实体和公式的不一致 | 2+ |
| `/scope-check` | 检测范围蔓延 | 5 |
| `/perf-profile` | 性能分析工作流 | 6 |
| `/tech-debt` | 扫描技术债务并确定优先级 | 6 |
| `/gate-check` | 给出 PASS/CONCERNS/FAIL 的正式阶段门禁 | 所有转换 |
| `/reverse-document` | 根据现有代码生成设计文档 | 任意 |
| `/security-audit` | 安全漏洞审计（存档、网络、输入） | 6-7 |

#### QA 与测试（9）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/qa-plan` | 为迭代或功能生成 QA 测试计划 | 5 |
| `/smoke-check` | 移交 QA 前的关键路径冒烟测试门禁 | 5-6 |
| `/soak-test` | 长时间试玩的浸泡测试协议 | 6 |
| `/regression-suite` | 映射测试覆盖率，识别缺少回归测试的已修复缺陷 | 5-6 |
| `/test-setup` | 搭建测试框架和 CI/CD 管线 | 4 |
| `/test-helpers` | 生成引擎专用测试辅助库 | 4-5 |
| `/test-evidence-review` | 评审测试文件和手动证据的质量 | 5 |
| `/test-flakiness` | 根据 CI 日志检测非确定性测试 | 5-6 |
| `/skill-test` | 验证技能文件的结构和行为正确性 | 任意 |

#### 制作管理（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/milestone-review` | 里程碑进度和 go/no-go 评估 | 5 |
| `/retrospective` | 迭代复盘分析 | 5 |
| `/bug-report` | 创建结构化缺陷报告 | 5+ |
| `/bug-triage` | 重新评估未解决缺陷的优先级、严重程度和负责人 | 5+ |
| `/playtest-report` | 结构化试玩会话报告 | 4-6 |
| `/onboard` | 引导新团队成员入门 | 任意 |

#### 发布（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/release-checklist` | 发布前验证 | 7 |
| `/launch-checklist` | 完整的跨部门上线就绪检查 | 7 |
| `/changelog` | 自动生成内部变更日志 | 7 |
| `/patch-notes` | 面向玩家的更新说明 | 7 |
| `/hotfix` | 紧急修复工作流 | 7+ |
| `/day-one-patch` | 针对黄金母版后发现问题的限定范围补丁 | 7+ |

#### 创意（4）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/prototype` | 概念原型，在编写 GDD 前验证核心创意 | 1 |
| `/art-bible` | 引导式编写美术圣经，定义视觉识别规范 | 1-2 |
| `/vertical-slice` | 制作阶段前达到制作质量的端到端版本 | 4 |
| `/localize` | 字符串提取和验证 | 6-7 |

#### 团队编排（9）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/team-combat` | 战斗功能：从设计到实现 | 5 |
| `/team-narrative` | 叙事内容：从结构到对话 | 5 |
| `/team-ui` | UI 功能：从 UX 规格到打磨后的实现 | 5 |
| `/team-level` | 关卡：从布局到布置好的遭遇战 | 5 |
| `/team-audio` | 音频：从方向制定到事件实现 | 5-6 |
| `/team-polish` | 协调式打磨：性能 + 美术 + 音频 + QA | 6 |
| `/team-release` | 发布协调：构建 + QA + 部署 | 7 |
| `/team-live-ops` | 在线运营规划：赛季活动、战斗通行证、留存 | 7+ |
| `/team-qa` | 完整 QA 周期：策略、执行、覆盖、签核 | 6-7 |

---

## 附录 C：常用工作流

### 工作流 1：“我刚开始，还没有游戏创意”

```
1. /start（根据当前进度引导你）
2. /brainstorm（协作式构思，选择一个概念）
3. /setup-engine（锁定引擎和版本）
4. 对概念文档运行 /design-review（可选，建议执行）
5. /map-systems（将概念分解为带有依赖关系和优先级的系统）
6. /gate-check concept（验证是否已准备好进入系统设计）
7. 对每个系统运行 /design-system（引导式编写 GDD）
```

### 工作流 2：“我已有设计，想开始编码”

```
1. 对每份 GDD 运行 /design-review（确保内容可靠）
2. /review-all-gdds（跨 GDD 一致性）
3. /gate-check systems-design
4. /create-architecture + /architecture-decision（每项重大决策运行一次）
5. /architecture-review
6. /create-control-manifest
7. /gate-check technical-setup
8. /create-epics layer: foundation + /create-stories [slug]（定义史诗并拆分为故事）
9. /sprint-plan new
10. /story-readiness -> 实现 -> /story-done（故事生命周期）
```

### 工作流 3：“我需要在制作中途添加复杂功能”

```
1. /design-system 或 /quick-design（视范围而定）
2. 运行 /design-review 进行验证
3. 如果修改现有 GDD，运行 /propagate-design-change
4. 使用 /estimate 估算工作量和风险
5. /team-combat、/team-narrative、/team-ui 等（合适的团队技能）
6. 完成后运行 /story-done
7. 如果影响游戏平衡性，运行 /balance-check
```

### 工作流 4：“线上出现故障”

```
1. /hotfix "description of the issue"
2. 在热修复分支上实现修复
3. 对修复运行 /code-review
4. 运行测试
5. 对热修复构建运行 /release-checklist
6. 部署并回传修复
```

### 工作流 5：“我有一个现有项目，想使用本系统”

```
1. /start（选择路径 D，即现有项目）
2. /project-stage-detect（确定当前阶段）
3. /adopt（审计现有产物并构建迁移计划）
4. /design-system retrofit [path]（补充 GDD 缺失内容）
5. /architecture-decision retrofit [path]（补充 ADR 缺失内容）
6. 在适当的转换点运行 /gate-check
```

### 工作流 6：“开始新的迭代”

```
1. /retrospective（评审上一次迭代）
2. /sprint-plan new（创建下一次迭代）
3. /scope-check（确保范围可控）
4. 领取每个故事前运行 /story-readiness
5. 实现故事
6. 每完成一个故事，运行 /story-done
7. 使用 /sprint-status 快速检查进度
```

### 工作流 7：“发布游戏”

```
1. /gate-check polish（验证打磨阶段是否完成）
2. /tech-debt（决定发布时可接受哪些技术债务）
3. /localize（最终本地化检查）
4. /release-checklist v1.0.0
5. /launch-checklist（完整的跨部门验证）
6. /team-release（协调发布）
7. /patch-notes 和 /changelog
8. 发布！
9. 上线后如有故障，运行 /hotfix
10. 上线稳定后进行项目复盘
```

### 工作流 8：“我迷失了方向/不知道下一步做什么”

```
1. /help（读取当前阶段、检查产物并告知下一步）
2. 如果 /help 没有解决问题：/project-stage-detect（全面审计）
3. 如果阶段似乎有误：在你认为所处的转换点运行 /gate-check
```

---

## 充分发挥本系统作用的技巧

1. **始终先设计，再实现。** 代理系统的基本前提是编写代码前已有设计文档。
   代理会持续引用 GDD。

2. **跨领域功能使用团队技能。** 不要尝试自行手动协调 4 个代理，
   让 `/team-combat`、`/team-narrative` 等技能处理编排。

3. **信任规则系统。** 当规则标记代码中的问题时，请修复它。
   这些规则凝聚了来之不易的游戏开发经验（数据驱动值、增量时间、无障碍等）。

4. **主动压缩。** 上下文使用量达到约 65% 至 70% 时，执行压缩或 `/clear`。
   压缩前钩子会保存进度，不要等到达到上限。

5. **使用正确级别的代理。** 不要让 `creative-director` 编写着色器，
   也不要让 `qa-tester` 作出设计决策。层次结构的存在自有其理由。

6. **不确定时运行 /help。** 它会读取项目的实际状态，并告诉你最重要的下一步。

7. **将设计交给程序员前运行 `/design-review`。** 这样可尽早发现不完整的规格，避免返工。

8. **每项重大功能完成后运行 `/code-review`。** 在架构问题扩散前发现它们。

9. **先为高风险机制制作原型。** 一天的原型制作，可以避免在不可行的机制上浪费一周制作时间。

10. **如实制定迭代计划。** 定期使用 `/scope-check`。范围蔓延是独立游戏的头号杀手。

11. **使用 ADR 记录决策。** 记录事物为何以当前方式构建，未来的你会感谢现在的自己。

12. **严格遵循故事生命周期。** 领取前运行 `/story-readiness`，完成后运行
    `/story-done`。这样可尽早发现偏差，并确保管线反映真实情况。

13. **尽早并频繁写入文件。** 逐章增量写入可让设计决策在崩溃和压缩后保留下来。
    文件才是记忆，而非对话。
