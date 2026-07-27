# 示例会话：/adopt — 棕地项目引导

**背景：**开发者在发现此代理系统前已经开发游戏 3 个月。他们有代码、一些设计文档和粗略笔记，但没有符合技能使用要求的格式。

**起始状态：**
- `src/gameplay/` — 约 4000 行 Godot 4.6 GDScript
- `design/` — 3 个包含粗略设计笔记的 Markdown 文件（不是 GDD 模板格式）
- 没有 `design/gdd/` 目录
- 没有 `docs/architecture/` 目录
- 没有 `production/` 目录
- 没有 `design/gdd/systems-index.md`
- CLAUDE.md 已存在（引擎已配置：Godot 4.6）

**会话时长：**约 30 分钟
**轮次：**8
**结果：**引导计划已写入，最紧迫的缺口（缺少系统索引）已立即修复

---

## 第 1 轮：用户调用 /adopt

**用户：**
> /adopt

## 第 2 轮：代理检测项目状态

**代理（technical-director，通过 /adopt，上下文：fork）：**
> 正在运行棕地审计……
>
> **阶段 1：项目状态检测**
>
> | 产物类别 | 已找到 | 备注 |
> |------------------|-------|-------|
> | 引擎配置 | ✅ | CLAUDE.md 中的 Godot 4.6 |
> | 源代码 | ✅ | `src/gameplay/` 中约 4000 行 |
> | 设计文档 | ⚠️ | `design/` 中有 3 个文件，但不是 GDD 格式 |
> | 架构文档 | ❌ | 缺少 `docs/architecture/` |
> | 系统索引 | ❌ | 缺少 `design/gdd/systems-index.md` |
> | 制作跟踪 | ❌ | 缺少 `production/` 目录 |
> | 迭代/故事文件 | ❌ | 无 |
>
> **阶段 2：格式审计（现有文件）**
>
> 正在检查 3 个设计文件的内部结构……
>
> *`design/combat-notes.md`：*
> - 有非正式笔记，没有 GDD 模板部分
> - 包含：一些规则描述、伤害公式、粗略平衡数值
> - GDD 模板缺少：概述、玩家幻想、边界情况、依赖项、调节项、验收标准（8 个部分中缺少 6 个）
>
> *`design/crafting-ideas.md`：*
> - 头脑风暴式笔记，没有结构
> - 没有公式，也没有验收标准
> - 代表早期概念思考，可作为 GDD 的输入，但还不是 GDD
>
> *`design/inventory.md`：*
> - 最接近 GDD，已有概述和规则部分
> - 缺少：玩家幻想、公式、边界情况、调节项、验收标准（8 个部分中缺少 5 个）
>
> **阶段 3：缺口分类**
>
> | 缺口 | 严重程度 | 原因 |
> |-----|----------|--------|
> | 缺少系统索引 | BLOCKING | `/design-system`、`/create-stories`、`/gate-check` 都需要它 |
> | GDD 文件不是模板格式 | HIGH | 技能无法引用格式错误的 GDD 中的 TR-ID |
> | 没有架构文档 | HIGH | 无法运行 `/architecture-review` 或 `/create-control-manifest` |
> | 没有制作跟踪 | MEDIUM | 迭代和故事技能无法工作，但进入制作阶段前并不需要 |
> | `design/crafting-ideas.md` — GDD 前置内容 | LOW | 可作为输入；在阻塞其他事项前需要完整编写 GDD |

## 第 3 轮：代理提出迁移计划

**代理：**
> **阶段 4：迁移计划**
>
> 通过 7 个有序步骤使项目完全符合规范。绝不会覆盖现有内容，每一步只填补缺口。
>
> | # | 步骤 | 技能 | 优先级 | 备注 |
> |---|------|-------|----------|-------|
> | 1 | 创建 `design/gdd/systems-index.md` | `/map-systems` 或 `/adopt` 内联 | BLOCKING | 解锁所有下游技能 |
> | 2 | 将 `design/inventory.md` 改造为 GDD 格式 | `/design-system retrofit design/inventory.md` | HIGH | 增加缺少的 5 个部分，保留现有内容 |
> | 3 | 将 `design/combat-notes.md` 改造为 GDD 格式 | `/design-system retrofit design/combat-notes.md` | HIGH | 增加缺少的 6 个部分 |
> | 4 | 将 `design/crafting-ideas.md` 转换为完整 GDD | `/design-system crafting`（全新编写，以想法为输入） | MEDIUM | 不是改造，内容过于非正式 |
> | 5 | 根据现有代码创建架构 ADR | `/reverse-document` + `/architecture-decision` | HIGH | 记录代码中已经做出的决策 |
> | 6 | 创建主架构文档 | `/create-architecture` | HIGH | 在 ADR 之后 |
> | 7 | 设置制作跟踪 | `/sprint-plan new` | MEDIUM | 在架构阶段之后 |
>
> **重要：**第 1 步必须先于其他步骤。其余步骤可以并行执行，或根据你的优先级重新排序。
>
> 可以将此计划写入 `docs/adoption-plan-2026-03-12.md` 吗？

**用户：**
> 可以，写入吧。

**代理写入引导计划。**

## 第 4 轮：代理提出修复最紧迫的缺口

**代理：**
> BLOCKING 缺口是缺少 `design/gdd/systems-index.md`。
>
> 我现在可以通过阅读现有代码和设计文档来推断你已经构建的系统，并创建该文件。这比从头运行 `/map-systems` 更快：我会根据已有内容填充，然后由你确认或调整。
>
> 你希望我现在这样做吗？

**用户：**
> 可以，做吧。

## 第 5 轮：代理读取代码库并起草系统索引

**代理：**
> 正在读取 `src/gameplay/` 以推断系统……
>
> 在代码中发现以下系统边界：
>
> - `src/gameplay/combat/` — 伤害计算、命中检测、状态效果
> - `src/gameplay/inventory/` — 物品管理、重量、堆叠
> - `src/gameplay/crafting/` — 配方查找、结果生成（引用库存）
> - `src/gameplay/movement/` — CharacterBody2D、地形修正（战斗引用它来处理站位）
> - `src/gameplay/ui/` — HUD、库存界面、对话框
> - `src/gameplay/world/` — TileMap、地形类型、区块加载
>
> **系统索引草稿：**
>
> | 系统 | 类别 | 优先级 | 依赖项 | GDD 状态 |
> |--------|----------|----------|--------------|------------|
> | Movement | 基础 | MVP | None | ❌ Missing |
> | World/Terrain | 基础 | MVP | Movement | ❌ Missing |
> | Combat | 核心 | MVP | Movement | ⚠️ Needs retrofit |
> | Inventory | 核心 | MVP | None | ⚠️ Needs retrofit |
> | Crafting | 功能 | MVP | Inventory | ❌ Pre-GDD only |
> | UI / HUD | 表现 | MVP | Combat, Inventory, Movement | ❌ Missing |
>
> 看起来正确吗？有没有遗漏或分类错误？

**用户：**
> 看起来正确。增加 Stamina 系统，它现在位于 combat/ 中，但应该作为独立系统。

**代理：**
> 已将 Stamina 添加为核心 / MVP 系统：
>
> | Stamina | 核心 | MVP | Movement, Combat | ❌ Missing |
>
> 已更新依赖项：Movement 依赖 Stamina（移动会消耗体力）。
>
> 可以将此内容写入 `design/gdd/systems-index.md` 吗？

## 第 6 轮：用户批准

**用户：**
> 是

**代理写入 `design/gdd/systems-index.md`。**

## 第 7 轮：代理展示现在已解锁的内容

**代理：**
> 已创建 `design/gdd/systems-index.md`。
>
> **BLOCKING 缺口已解决。**现在可以运行以下技能：
>
> - ✅ `/design-system [name]` — 为任意系统引导式编写 GDD
> - ✅ `/design-system retrofit [path]` — 填补现有文档中缺少的部分
> - ✅ `/gate-check` — 现在有系统索引可供验证
> - ✅ `/help` — 现在可以展示正确的阶段工作流
>
> **建议的后续步骤（来自引导计划）：**
>
> 1. 运行 `/design-system retrofit design/inventory.md` — 这是现有最完整的文档，最容易取得成果
> 2. 运行 `/design-system retrofit design/combat-notes.md`
> 3. 运行 `/design-system crafting` — 以想法文件为输入编写制作 GDD
>
> 完成这 3 步后，7 个系统中会有 5 个拥有完整 GDD。然后运行 `/review-all-gdds`，在进行架构工作前发现跨系统一致性问题。

## 第 8 轮：用户确认计划

**用户：**
> 完美。我会先改造库存文档。

**代理：**
> 运行：
> ```
> /design-system retrofit design/inventory.md
> ```
>
> 该技能会检测已有的概述和规则部分，展示 8 个部分中缺少哪些内容，并仅针对缺口运行部分编写流程。现有内容不会被修改。

---

## 此示例展示的内容

- **审计格式，而不是审计存在性**：`/adopt` 不只是检查文件是否存在，还会检查内部结构是否符合技能预期。名为 `gdd.md` 但没有模板部分的文件会被标记为缺口。
- **迁移，而不是替换**：现有内容绝不会被覆盖，计划只填补缺口。
- **优先暴露 BLOCKING 缺口**：缺少系统索引会阻止大多数技能运行，因此被识别为 BLOCKING。
- **内联创建紧急缺口**：代理不只是报告缺口，还会在同一会话中主动提出立即修复。
- **从代码推断**：系统索引根据代码库结构启动，而不是从零编写，棕地代码已经包含答案。
- **改造与全新编写的区别**：`/design-system retrofit` 处理已有但不完整的文档；完整的 `/design-system` 处理全新文档。引导计划会区分每个文件适用的方式。
- **上下文：fork**：`/adopt` 在分叉上下文中运行，避免对整个代码库进行大量读取污染主会话。
