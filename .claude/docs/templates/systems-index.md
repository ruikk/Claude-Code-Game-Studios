# 系统索引（Systems Index）: [Game Title]

> **状态（Status）**: [Draft / Under Review / Approved]
> **创建时间（Created）**: [Date]
> **最后更新（Last Updated）**: [Date]
> **来源概念（Source Concept）**: design/gdd/game-concept.md

---

## 概述（Overview）

[用一段话说明游戏的机制范围。这个游戏需要哪些系统？
请参考核心循环（core loop）与游戏支柱（game pillars）。
这段内容应帮助任何团队成员理解需要设计和构建内容的“全局图景”。]

---

## 系统枚举（Systems Enumeration）

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | [e.g., Player Controller] | Core | MVP | [Not Started / In Design / In Review / Approved / Implemented] | [design/gdd/player-controller.md or "—"] | [e.g., Input System, Physics] |
| 2 | [e.g., Camera System] | Core | MVP | Not Started | — | Player Controller |

[为每个已识别系统添加一行。
使用下方定义的类别与优先级层级。
对于“推断得出”（概念文档中未显式写出）的系统，请在系统名称中加上“(inferred)”。]

---

## 类别（Categories）

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | 一切系统所依赖的基础系统 | 玩家控制器、输入、物理、相机、场景管理、状态机 |
| **Gameplay** | 让游戏好玩的系统 | 战斗、AI、潜行、移动能力、交互 |
| **Progression** | 玩家随时间成长的方式 | 经验/升级、技能树、解锁、成就、声望 |
| **Economy** | 资源的生成与消耗 | 货币、战利品、制作、商店、物品数据库、掉落表 |
| **Persistence** | 存档状态与连续性 | 存档/读档、设置、云同步、档案管理 |
| **UI** | 面向玩家的信息展示 | HUD、菜单、背包界面、对话 UI、地图、通知 |
| **Audio** | 声音与音乐系统 | 音乐管理器、SFX 总线、环境音、自适应音乐、语音 |
| **Narrative** | 剧情与对话传达 | 对话系统、任务追踪、过场、日志、世界观条目 |
| **Meta** | 核心游戏循环之外的系统 | 数据分析、新手引导/教程、无障碍选项、拍照模式 |

[并非每个游戏都需要所有类别。删除不适用类别。
如有需要，可添加自定义类别。]

---

## 优先级层级（Priority Tiers）

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | 核心循环可运作所必需。缺少这些系统，就无法测试“这是否好玩？” | 首个可玩原型（throwaway prototype） | 最先设计 |
| **Vertical Slice** | 一个完整、精修区域所必需。用于展示完整体验。 | vertical slice / demo | 第二优先设计 |
| **Alpha** | 所有功能以粗略形态齐备。机制范围完整，可接受占位内容。 | Alpha 里程碑 | 第三优先设计 |
| **Full Vision** | 润色（polish）、边缘情况、锦上添花项与内容完整功能。 | Beta / Release | 按需设计 |

---

## 依赖项图（Dependency Map）

[按依赖顺序排序系统——从上到下进行设计与构建。
顶部系统是基础，底部系统是封装层。]

### 基础层（Foundation Layer，no dependencies）

1. [System] — [说明该系统为何是基础的一行理由]

### 核心层（Core Layer，depends on foundation）

1. [System] — depends on: [list]

### 功能层（Feature Layer，depends on core）

1. [System] — depends on: [list]

### 表现层（Presentation Layer，depends on features）

1. [System] — depends on: [list]

### 打磨层（Polish Layer，depends on everything）

1. [System] — depends on: [list]

---

## 推荐设计顺序（Recommended Design Order）

[结合依赖排序与优先级层级。请按此顺序设计这些系统。
每个系统的 GDD 应在开始下一个系统前完成并通过评审；
同一层中相互独立的系统可并行设计。]

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | [First system to design] | MVP | Foundation | game-designer | [S/M/L] |
| 2 | [Second system] | MVP | Foundation | game-designer | [S/M/L] |

[工作量估算：S = 1 个会话，M = 2-3 个会话，L = 4+ 个会话。
一个“会话”指一次聚焦式设计对话，产出一份完整 GDD。]

---

## 循环依赖（Circular Dependencies）

[列出分析过程中发现的所有循环依赖链。
这些情况需要特别的架构关注——要么通过接口打破循环，
要么同步设计相关系统。]

- [None found] OR
- [System A <-> System B: 对循环关系的描述与建议解决方案]

---

## 高风险系统（High-Risk Systems）

[技术上未验证、设计不确定、或范围风险高的系统。
无论优先级层级如何，都应尽早进行原型验证。]

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| [System] | [Technical / Design / Scope] | [What could go wrong] | [Prototype, research, or scope fallback] |

---

## 进度追踪（Progress Tracker）

| Metric | Count |
|--------|-------|
| 已识别系统总数 | [N] |
| 已开始设计文档 | [N] |
| 已评审设计文档 | [N] |
| 已批准设计文档 | [N] |
| 已完成设计的 MVP 系统 | [N/total MVP] |
| 已完成设计的 Vertical Slice 系统 | [N/total VS] |

---

## 下一步（Next Steps）

- [ ] 评审并批准本系统枚举
- [ ] 先设计 MVP 层级系统（使用 `/design-system [system-name]`）
- [ ] 对每个完成的 GDD 运行 `/design-review`
- [ ] 当 MVP 系统完成设计后，运行 `/gate-check pre-production`
- [ ] 尽早为最高风险系统制作原型（`/prototype [system]`）
