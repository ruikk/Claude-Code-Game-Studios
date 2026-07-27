# 难度曲线（Difficulty Curve）: [Game Title]

> **Status**: Draft | In Review | Approved
> **Author**: [game-designer / systems-designer]
> **Last Updated**: [Date]
> **Links To**: `design/gdd/game-concept.md`
> **Relevant GDDs**: [e.g., `design/gdd/combat.md`, `design/gdd/progression.md`]

---

## 难度哲学（Difficulty Philosophy）

[用一个段落确立本游戏与“难度”的关系。这不是机制描述，而是一条设计价值声明；所有调优决策都必须服务于它。

四种常见的难度哲学如下：

1. **以“受苦式挑战”作为核心玩家幻想（player fantasy）**：难度本身就是产品。克服难度就是情绪回报。降低难度会移除游戏的核心意义。（Dark Souls，Celeste 关闭最高辅助时）
2. **易于进入，可选深度**：基础体验应让大多数玩家可以通关；深度与挑战对想要它的玩家是可选项。（Hades，Hollow Knight 搭配无障碍模式）
3. **难度服务叙事节奏**：挑战随剧情节点起伏。故事收束时玩家要感到“我能做到”，故事危机时玩家要感到“我受到了威胁”。（The Last of Us，God of War）
4. **轻松投入**：挑战存在但从不成为焦点。失败温和且不频繁。体验优先舒适与表达，而非障碍本身。（Stardew Valley，Animal Crossing）

请明确写出你的哲学，并补充一句：玩家被允许感受到什么？是否允许挫败？允许持续多久后设计必须介入？失败的可接受代价是什么？]

---

## 难度轴（Difficulty Axes）

> **Guidance**: 大多数游戏都有多个彼此独立的挑战维度。
> 明确识别这些维度，可以避免只调一个轴（通常是操作执行难度）而忽略其他维度。
> 一款游戏在操作上可能“简单”，却在决策复杂度上令人不堪重负——玩家会把这种感受体验为“困惑”，而非“投入”。
>
> 对每个轴，请回答：玩家能否通过选择、build（构筑）或设置来控制或降低这个轴？
> 如果不能，它就是一个“强制挑战维度”——你必须非常有意识地使用它。

| Axis | Description | Primary Systems | Player Control? |
|------|-------------|----------------|-----------------|
| **Execution difficulty** | [核心动作对精度与时机的要求。例如：“闪避敌人攻击需要在 200ms 窗口内做出正确时机判断。”] | [e.g., Combat, movement] | [Yes — practice reduces this / No — fixed mechanical threshold] |
| **Knowledge difficulty** | [“不知道信息”的代价。例如：“敌人弱点没有明确提示；未发现弱点的玩家会承受显著更高伤害。”] | [e.g., Enemy design, UI, lore] | [Yes — through in-game discovery / No — requires external knowledge] |
| **Resource pressure** | [推进所需资源有多稀缺？例如：“生命消耗品有限；要维持长地牢流程，必须高效游玩。”] | [e.g., Economy, loot, crafting] | [Yes — through build optimization / Partially] |
| **Time pressure** | [玩家是否有时间思考，还是游戏要求快速决策？例如：“敌人刷新计时器和攻击窗口要求实时反应。”] | [e.g., Combat pacing, timers] | [Yes — through difficulty settings / No — core to genre] |
| **Decision complexity** | [玩家需要同时评估多少“有意义”的选择？例如：“构筑决策跨 4 个系统联动；次优组合会叠加劣势。”] | [e.g., Progression, inventory, skills] | [Yes — through UI and tutorialization / No — inherent to strategy depth] |
| **[Add axis]** | [Description] | [Systems] | [Player control] |

---

## 难度曲线总览（Difficulty Curve Overview）

> **Guidance**: 该表描述全游戏预期的挑战弧线。
> 难度等级采用 1-10 标度：1 = 几乎无实质挑战，10 = 游戏可提供的最高挑战。
> 该标度相对于“本游戏”的设计意图——魂类中的 6/10 并不等于休闲模拟中的 6/10。
>
> “Primary challenge type”指本阶段承担主要压力的难度轴（见上表）。
> “New systems introduced”只列“首次引入”的系统——学习新系统本身就是一种难度（认知负荷）。
>
> “Target player state”是设计师期望的玩家情绪状态。
> 如果 playtest（玩家测试）结果与预期不一致，本列就是应达成的目标状态。

| Phase | Duration | Difficulty Level (1-10) | Primary Challenge Type | New Systems Introduced | Target Player State |
|-------|----------|------------------------|----------------------|----------------------|---------------------|
| [Prologue / Tutorial] | [e.g., 0-15 min] | [2/10] | [Knowledge] | [Core movement, basic interaction] | [Safe, curious, building confidence] |
| [Early game] | [e.g., 15 min - 2 hrs] | [3-5/10] | [Execution] | [Combat, inventory, first upgrade path] | [Learning, occasional failure, clear cause-effect] |
| [Mid game - opening] | [e.g., 2-6 hrs] | [5-7/10] | [Decision complexity] | [Build choices, advanced enemies, crafting] | [Engaged, strategizing, feeling growth] |
| [Mid game - depth] | [e.g., 6-15 hrs] | [6-8/10] | [Resource pressure] | [Elite enemies, optional hard content, endgame previews] | [Challenged, invested, approaching mastery] |
| [Late game] | [e.g., 15-25 hrs] | [7-9/10] | [Execution + knowledge] | [Endgame systems, NG+ or equivalent] | [Mastery, confident in build identity, seeking peak challenge] |
| [Optional / Endgame] | [e.g., 25+ hrs] | [8-10/10] | [All axes combined] | [Mastery challenges, achievement targets] | [Expert play, self-imposed goals, community comparison] |

---

## 上手爬坡（Onboarding Ramp）

> **Guidance**: 第一个小时值得单独做细化拆解，因为它承担了最难的设计任务：
> 在不让玩家觉得“被上课”的前提下，教会所有基础技能；
> 并建立足够投入感，让玩家愿意继续旅程。
> 玩家留存研究显示，大多数流失发生在前 30 分钟——不一定是游戏差，而是 onboarding 没连上玩家。
>
> 支架式教学原则（维果茨基“最近发展区”在游戏设计中的改编）：
> 每个机制先单独引入，再与其他机制组合。
> 玩家无法在压力下同时学会两种技能。

### 玩家在各阶段知道什么（What the Player Knows at Each Stage）

| Time | What the Player Knows | What They Do Not Know Yet |
|------|-----------------------|--------------------------|
| [0 min] | [真的什么都不知道——把这一行当作最重要的 UX 审计。玩家仅从标题画面能推断出什么？] | [Everything] |
| [5 min] | [核心移动动词、基础世界解读] | [All progression systems, all secondary mechanics] |
| [15 min] | [核心交互核心循环（core loop）、首个目标] | [Build depth, advanced mechanics, danger severity] |
| [30 min] | [已做出至少一个策略性选择] | [Whether that choice was optimal] |
| [60 min] | [对核心循环（core loop）已有可运行的心智模型] | [Late-game depth, optional systems] |

### 机制引入顺序（Mechanic Introduction Sequence）

> 机制按什么顺序引入，是有真实后果的设计决策。
> 先引入最关键的核心动词。
> “修改其他机制”的机制应在基础机制内化后再引入。
> 同一场遭遇中不要引入两个新机制。

| Mechanic | Introduced At | Introduction Method | Stakes at Introduction |
|----------|--------------|--------------------|-----------------------|
| [Core movement / primary verb] | [e.g., First 30 seconds] | [Tutorial prompt / environmental design / NPC instruction] | [None — safe space to experiment] |
| [Primary interaction / action] | [e.g., First 2 minutes] | [Method] | [Low — reversible, forgiving window] |
| [First resource mechanic] | [e.g., 5 min] | [Method] | [Low — abundant at introduction] |
| [First strategic choice] | [e.g., 15 min] | [Method] | [Low — choice can be changed or revisited] |
| [First real failure risk] | [e.g., 20-30 min] | [Method] | [Moderate — player should feel genuine threat but have fair tools to respond] |
| [Add mechanic] | [Timing] | [Method] | [Stakes] |

### 第一次失败（The First Failure）

[描述玩家第一次可能发生“有意义失败”的设计意图。这是全游戏最关键的节拍之一。

设计良好的第一次失败，应当“教学”而非“惩罚”。
玩家应能立刻识别：自己做错了什么、下次会怎么做。
如果失败原因模糊，玩家会把责任归咎于游戏。

请回答：第一次失败由什么触发？玩家从中学到什么？
能多快重试？代价是什么？
游戏是否提供任何反馈来连接因果？]

### 玩家第一次感到“我会了”的时刻（When the Player First Feels Competent）

[请定位一个“具体时刻”——不是模糊时间段，而是明确节拍——
在这个点，玩家应从“学习”切换到“执行”。

这是首次胜任时刻：玩家第一次对游戏的预测被验证，
或第一次执行一个计划并成功。

这个时刻必须出现在第一小时内。
如果没有，玩家通常到不了旅程第三阶段（First Mastery）。
必须刻意设计，不能交给运气。

这个时刻是什么？由哪些系统共同创造？
玩家做了什么触发它？
游戏如何传达“你成功了”？]

---

## 难度峰谷（Difficulty Spikes and Valleys）

> **Guidance**: 健康的难度曲线应呈锯齿形
> （将 Csikszentmihalyi 流模型应用到宏观结构）：
> 张力在一个序列中爬升，在里程碑处释放，再以略高基线重新拉起。
> 平坦难度会无聊；持续不间断爬升会疲劳。
>
> Spike（峰）是有意设计的高点，用来检验累计技能。
> Valley（谷）是有意设计的低点，给玩家呼吸、试验、感受强大的空间，再进入下一次爬升。
> 两者都应被设计，而非“自然冒出来”。
>
> “Recovery design”至关重要：峰值之后立刻发生什么？
> 玩家离开高压时应感到“我做到了”，而不是“我被榨干了”。
> 给他们一个谷、一个奖励，或一个叙事回报。

| Name | Location in Game | Type | Purpose | Recovery Design |
|------|-----------------|------|---------|-----------------|
| [e.g., "The First Boss"] | [e.g., End of Area 1, ~1 hr] | [Spike] | [Tests all skills introduced in Area 1. Acts as a gate confirming the player is ready for increased complexity.] | [Post-boss: safe area, upgrade opportunity, story beat that provides emotional relief before Area 2 escalation begins.] |
| [e.g., "The Safe Zone"] | [e.g., Hub area between Areas 1 and 2, ~1.5 hrs] | [Valley] | [Player feels powerful from boss win. Space to experiment with build options before stakes rise.] | [N/A — this IS the recovery from the preceding spike.] |
| [e.g., "The Knowledge Wall"] | [e.g., Area 3 first encounter, ~4 hrs] | [Spike — knowledge type] | [Forces players to engage with a mechanic they may have been avoiding. Survival requires understanding it.] | [Clear feedback on what killed them. Tutorial hint surfaces on third failure. Mechanic becomes standard after this point.] |
| [e.g., "Pre-Climax Valley"] | [e.g., Just before final act, ~20 hrs] | [Valley] | [Emotional breathing room before the final escalation. Player reflects on how far they have come.] | [N/A — designed as relief before the finale's spike.] |
| [Add spike/valley] | [Location] | [Type] | [Purpose] | [Recovery] |

---

## 平衡调节杆（Balancing Levers）

> **Guidance**: 平衡调节杆是各阶段用于调优难度的具体数值与参数。
> 集中记录它们，可以在不翻遍各个 GDD 的情况下调整全游戏难度曲线。
> 每个调节杆都应交叉引用其归属 GDD。
>
> “Current setting”是写作时的设计意图；
> 实装数值存放在 `assets/data/`。
> “Tuning range”是安全运行区间：超出该范围会稳定破坏预期体验。

| Lever | Phase(s) | Effect | Current Setting | Tuning Range | Notes |
|-------|----------|--------|----------------|-------------|-------|
| [Enemy health multiplier] | [All] | [越高 = 战斗越长 = 资源压力与执行时间越大] | [1.0x] | [0.7x - 1.5x] | [低于 0.7x，战斗在玩家读懂敌人模式前就结束。高于 1.5x，损耗战取代了技巧。] |
| [Enemy aggression timer] | [Mid game onward] | [敌人两次攻击间隔；越低 = 反应时间越少] | [e.g., 2.0s] | [1.2s - 3.0s] | [低于 1.2s，反应窗口接近非人类阈值。高于 3.0s，遭遇会显得被动。] |
| [Resource drop rate] | [Early game] | [越低 = 资源压力越高 = 对低效率惩罚更重] | [e.g., 1.5x baseline] | [0.8x - 2.0x] | [上手期宽松；默认中期下调，因假设玩家技能已提升。] |
| [New mechanic introduction density] | [First hour] | [每分钟引入多少新概念；过高 = 认知过载] | [e.g., 1 new mechanic per 8 min] | [1 per 5 min (max) to 1 per 15 min (slow)] | [前期高于每 5 分钟 1 个会导致留存下降。低于每 15 分钟 1 个会导致无聊。] |
| [Failure cost] | [All] | [失败损失的时间；越高 = 惩罚越强 = 张力越高] | [e.g., 2 min setback] | [30s - 8 min] | [必须随遭遇频率缩放。高频失败需要快速恢复。] |
| [Add lever] | [Phase] | [Effect] | [Setting] | [Range] | [Notes] |

---

## 玩家技能假设（Player Skill Assumptions）

> **Guidance**: 每款游戏都会隐含假设玩家会在流程中习得一组技能。
> 把这些假设显式化，团队才能验证：每个技能是否在被硬测前真正被教过，
> 且“引入”到“高压测试”之间是否有足够内化时间。
>
> 同场遭遇中“引入并硬测”同一技能，会形成突发难度峰值。
> “被假设会但从未正式引入”的技能，会形成未记录的知识墙。
> 两者都可修复——前提是先记录下来。
>
> “Taught by”指教学机制：教程提示、环境设计、安全练习机会、NPC 指导或自然发现。
>
> “Tested by”指首次“必须掌握该技能才能生存且不付出明显代价”的遭遇。

| Skill | Introduced In | Expected Mastered By | Taught By | First Hard Test |
|-------|--------------|---------------------|-----------|-----------------|
| [Core movement / dodging] | [Tutorial area, 0-5 min] | [End of Area 1, ~1 hr] | [Safe practice zone with visible hazards] | [First Elite enemy, ~45 min] |
| [Resource management] | [First shop encounter, ~10 min] | [Mid game, ~4 hrs] | [Resource scarcity in Area 2 forces planning] | [Boss that requires consumables to survive efficiently] |
| [Build decision-making] | [First upgrade choice, ~20 min] | [End of mid game, ~10 hrs] | [Multiple playthroughs / community discussion / in-game build advisor] | [Endgame encounters that punish build incoherence] |
| [Enemy pattern reading] | [Area 1 basic enemies] | [Area 3, ~4 hrs] | [Enemy telegraphs visible and consistent from introduction] | [Elite enemy with 3+ distinct attack patterns] |
| [Add skill] | [When introduced] | [When mastered] | [Taught by] | [First hard test] |

---

## 无障碍考量（Accessibility Considerations）

> **Guidance**: 难度设计中的无障碍，不是“把游戏变简单”；
> 而是确保不同需求与技能画像的玩家，都能抵达预期情绪体验。
> 请明确什么“可以调”，什么“不能调”，并解释理由。
>
> 依据自我决定理论（Self-Determination Theory）：
> 玩家需要感到“我有能力（competent）”。
> 帮助玩家获得能力感、又不剥夺能动性的无障碍选项，通常都值得加入。
> 让“能力感失去意义”的选项，会削弱核心体验。

### 可调整项（What Can Be Adjusted）

| Adjustment | Method | Effect on Experience | Tradeoff |
|-----------|--------|---------------------|----------|
| [e.g., Enemy speed reduction] | [Difficulty setting / accessibility menu] | [降低执行难度，不改变知识与决策要求] | [降低战斗时机张力；对叙事型玩家可接受] |
| [e.g., Extended input windows] | [Accessibility menu] | [让运动障碍玩家在更宽时间窗内达成同等技能结果] | [影响极小——保留技能表达，仅放宽阈值] |
| [e.g., Hint frequency] | [Settings toggle] | [按玩家偏好更积极或更克制地提供情境提示] | [更高提示会降低知识难度；偏好自主探索的玩家可能觉得被过度引导] |
| [Add option] | [Method] | [Effect] | [Tradeoff] |

### 不可调整项（及原因）（What Cannot Be Adjusted (and Why)）

| Fixed Element | Why It Cannot Change | Design Reasoning |
|--------------|---------------------|-----------------|
| [e.g., Permadeath in roguelike run] | [移除后会破坏所有遭遇平衡所依赖的“资源压力轴”] | [每次决策的重量来自“不可逆”；没有它，核心循环（core loop）将失去意义] |
| [e.g., Core narrative pacing] | [难度谷值与叙事节点强绑定；可调节节奏会使挑战与叙事意图脱耦] | [故事与难度被设计为一条弧线，而非两条独立轨道] |
| [Add fixed element] | [Why] | [Reasoning] |

---

## 跨系统难度交互（Cross-System Difficulty Interactions）

> **Guidance**: 当两个系统同时运作时，其合成难度常常大于两者之和——有时也会更低。
> 这些交互往往并非有意设计，而是在 playtest（玩家测试）中才暴露。
> 在此记录“预期交互”，可形成 QA 与 playtest 的核查清单。
>
> “Is this intended?” 中：
> Yes = 这是设计特性；
> No = 需要缓解；
> Partial = 少量可接受，但若成为主导体验则有问题。

| System A | System B | Combined Effect | Intended? |
|----------|----------|----------------|-----------|
| [Combat difficulty] | [Resource scarcity] | [资源贫乏玩家在战斗中可用选项更少，会放大已经在挣扎玩家的难度。可能形成“死亡螺旋”：失败会制造更差的下一次条件。] | [Partial — intended as stakes, not as a trap. Pity mechanics required to prevent unrecoverable states.] |
| [Build complexity] | [Time pressure] | [仍在学习构筑的玩家在时间压力下做决策更慢，认知负荷会超出任一单系统原定挑战。] | [No — reduce decision complexity demand in high time-pressure encounters.] |
| [New mechanic introduction] | [Resource pressure] | [在资源压力下引入新系统，会迫使玩家同时“学习+优化”。] | [No — new mechanics should be introduced in low-resource-pressure environments.] |
| [Enemy density] | [Execution difficulty] | [高敌群密度 + 单体高执行要求，会让难度呈指数而非线性增长。] | [Partial — intended for optional challenge content only; not acceptable on the critical path.] |
| [Add System A] | [Add System B] | [Combined effect description] | [Yes / No / Partial] |

---

## 验证清单（Validation Checklist）

> **Guidance**: 这些检查点用于组织 playtest（玩家测试）会话，以验证难度曲线是否达成设计意图。
> 每项至少经过 3 场 playtester 会话后再勾选完成。
> 请记录暴露问题的 playtester 画像——难度问题几乎总是“玩家画像相关”。

### 上手期（0-30 min）
- [ ] 无同类型经验的玩家可在无外部帮助下完成教程区域
- [ ] 前 5 分钟内，0 位玩家表示“我不知道该做什么”
- [ ] 至少 1 名 playtester 在 15 分钟内自发说出“我想看看后面有什么”
- [ ] 第一次失败时刻能触发可见学习反应（玩家能口述自己哪里做错）

### 前期（30 min - 2 hrs）
- [ ] 平均玩家可在 60 分钟内抵达首次胜任时刻
- [ ] 首个大型遭遇（Boss 或等价）平均 3-5 次尝试内通过
- [ ] 无玩家认为某机制“出现得过于突然、毫无预警”
- [ ] 玩家无需提示即可描述当前目标

### 中期（2-10 hrs）
- [ ] 玩家可通过自然游玩（不看攻略）发现至少 1 个深度机制
- [ ] playtest 会话中出现“下把我想试另一种 build / strategy”
- [ ] 没有单一难度轴主导玩家抱怨——挫败分布是均衡的
- [ ] 中期遭遇失败的玩家可在不被告知情况下正确识别失败原因

### 后期（10+ hrs）
- [ ] 玩家反馈最终挑战像是对其所学一切的总检验
- [ ] 后期内容失败不会被感知为“不公平”（即便它确实很难）
- [ ] 通关主线后，玩家仍能表达继续游玩的理由

### 无障碍（Accessibility）
- [ ] 所列全部无障碍选项可用，且不破坏遭遇设计意图
- [ ] 使用无障碍设置的玩家反馈是“有能力感”，而非“被居高临下对待”
- [ ] 固定难度要素被无障碍 playtester 遇到并接受，未引发负面反馈

---

## 开放问题（Open Questions）

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [Is the onboarding ramp correctly calibrated for players without prior genre experience?] | [game-designer] | [Date] | [Unresolved — schedule genre-naive playtester sessions] |
| [Does the first boss represent the correct difficulty spike or is it a wall?] | [game-designer, systems-designer] | [Date] | [Unresolved — requires 5+ playtester sessions to establish average attempt count] |
| [Do any cross-system interactions produce unrecoverable states?] | [systems-designer] | [Date] | [Unresolved — requires targeted playtest with resource-constrained starting conditions] |
| [Add question] | [Owner] | [Date] | [Resolution] |
