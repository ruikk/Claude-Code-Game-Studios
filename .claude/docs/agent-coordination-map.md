# Agent Coordination and Delegation Map（代理协作与委派地图）

## Organizational Hierarchy（组织层级）

```
                           [Human Developer]
                                 |
                 +---------------+---------------+
                 |               |               |
         creative-director  technical-director  producer
                 |               |               |
        +--------+--------+     |        (协调全部)
        |        |        |     |
  game-designer art-dir  narr-dir  lead-programmer  qa-lead  audio-dir
        |        |        |         |                |        |
     +--+--+     |     +--+--+  +--+--+--+--+--+   |        |
     |  |  |     |     |     |  |  |  |  |  |  |   |        |
    sys lvl eco  ta   wrt  wrld gp ep  ai net tl ui qa-t    snd
                                 |
                             +---+---+
                             |       |
                          perf-a   devops   analytics

  Additional Leads (report to producer/directors):
    release-manager         -- 发布流水线、版本管理、部署
    localization-lead       -- i18n、字符串表、翻译流水线
    prototyper              -- 快速一次性原型（throwaway prototype）、概念验证
    security-engineer       -- 反作弊、漏洞利用、数据隐私、网络安全
    accessibility-specialist -- WCAG、色盲支持、按键重映射、文本缩放
    live-ops-designer       -- 赛季、活动、战斗通行证、留存、实时运营（live-ops）经济
    community-manager       -- 补丁说明、玩家反馈、危机沟通

  Engine Specialists (use the SET matching your engine):
    unreal-specialist  -- UE5 负责人：Blueprint/C++、GAS 总览、UE 子系统
      ue-gas-specialist         -- GAS：能力、效果、属性、标签、预测
      ue-blueprint-specialist   -- Blueprint：BP/C++ 边界、图表规范、优化
      ue-replication-specialist -- Networking：复制、RPC、预测、带宽
      ue-umg-specialist         -- UI：UMG、CommonUI、控件层级、数据绑定

    unity-specialist   -- Unity 负责人：MonoBehaviour/DOTS、Addressables、URP/HDRP
      unity-dots-specialist         -- DOTS/ECS：Jobs、Burst、混合渲染器
      unity-shader-specialist       -- Shaders：Shader Graph、VFX Graph、SRP 定制
      unity-addressables-specialist -- Assets：异步加载、bundle、内存、CDN
      unity-ui-specialist           -- UI：UI Toolkit、UGUI、UXML/USS、数据绑定

    godot-specialist   -- Godot 4 负责人：GDScript、node/scene、signals、resources
      godot-gdscript-specialist    -- GDScript：静态类型、模式、signals、性能
      godot-shader-specialist      -- Shaders：Godot 着色语言、可视化着色器、VFX
      godot-gdextension-specialist -- Native：C++/Rust 绑定、GDExtension、构建系统
```

### Legend（图例）
```
sys  = systems-designer       gp  = gameplay-programmer
lvl  = level-designer         ep  = engine-programmer
eco  = economy-designer       ai  = ai-programmer
ta   = technical-artist       net = network-programmer
wrt  = writer                 tl  = tools-programmer
wrld = world-builder          ui  = ui-programmer
snd  = sound-designer         qa-t = qa-tester
narr-dir = narrative-director perf-a = performance-analyst
art-dir = art-director
```

## Delegation Rules（委派规则）

### Who Can Delegate to Whom（谁可以向谁委派）

| From | Can Delegate To |
|------|----------------|
| creative-director | game-designer, art-director, audio-director, narrative-director |
| technical-director | lead-programmer, devops-engineer, performance-analyst, technical-artist (technical decisions) |
| producer | Any agent (task assignment within their domain only) |
| game-designer | systems-designer, level-designer, economy-designer |
| lead-programmer | gameplay-programmer, engine-programmer, ai-programmer, network-programmer, tools-programmer, ui-programmer |
| art-director | technical-artist, ux-designer |
| audio-director | sound-designer |
| narrative-director | writer, world-builder |
| qa-lead | qa-tester |
| release-manager | devops-engineer (release builds), qa-lead (release testing) |
| localization-lead | writer (string review), ui-programmer (text fitting) |
| prototyper | (works independently, reports findings to producer and relevant leads) |
| security-engineer | network-programmer (security review), lead-programmer (secure patterns) |
| accessibility-specialist | ux-designer (accessible patterns), ui-programmer (implementation), qa-tester (a11y testing) |
| [engine]-specialist | engine sub-specialists (delegates subsystem-specific work) |
| [engine] sub-specialists | (advises all programmers on engine subsystem patterns and optimization) |
| live-ops-designer | economy-designer (live economy), community-manager (event comms), analytics-engineer (engagement metrics) |
| community-manager | (works with producer for approval, release-manager for patch note timing) |

### Escalation Paths（升级路径）

| Situation | Escalate To |
|-----------|------------|
| Two designers disagree on a mechanic | game-designer |
| Game design vs narrative conflict | creative-director |
| Game design vs technical feasibility | producer (facilitates), then creative-director + technical-director |
| Art vs audio tonal conflict | creative-director |
| Code architecture disagreement | technical-director |
| Cross-system code conflict | lead-programmer, then technical-director |
| Schedule conflict between departments | producer |
| Scope exceeds capacity | producer, then creative-director for cuts |
| Quality gate disagreement | qa-lead, then technical-director |
| Performance budget violation | performance-analyst flags, technical-director decides |

## Common Workflow Patterns（常见工作流模式）

### Pattern 1: New Feature (Full Pipeline)（模式 1：新功能（完整流水线））

```
1. creative-director  -- 批准功能概念与愿景一致
2. game-designer      -- 创建完整规格的游戏设计文档
3. producer           -- 安排工作并识别依赖
4. lead-programmer    -- 设计代码架构并绘制接口草图
5. [specialist-programmer] -- 实现该功能
6. technical-artist   -- 实现视觉效果（如需要）
7. writer             -- 编写文本内容（如需要）
8. sound-designer     -- 创建音频事件清单（如需要）
9. qa-tester          -- 编写测试用例
10. qa-lead           -- 审核并批准测试覆盖率
11. lead-programmer   -- 代码评审
12. qa-tester         -- 执行测试
13. producer          -- 标记任务完成
```

### Pattern 2: Bug Fix（模式 2：缺陷修复）

```
1. qa-tester          -- 使用 /bug-report 提交缺陷报告
2. qa-lead            -- 分级严重性与优先级
3. producer           -- 分配到迭代（若非 S1）
4. lead-programmer    -- 定位根因并分配给程序员
5. [specialist-programmer] -- 修复缺陷
6. lead-programmer    -- 代码评审
7. qa-tester          -- 验证修复并执行回归
8. qa-lead            -- 关闭缺陷
```

### Pattern 3: Balance Adjustment（模式 3：平衡性调整）

```
1. analytics-engineer -- 从数据（或玩家报告）识别失衡
2. game-designer      -- 根据设计意图评估问题
3. economy-designer   -- 建模调整方案
4. game-designer      -- 批准新数值
5. [data file update] -- 修改配置值
6. qa-tester          -- 对受影响系统做回归测试
7. analytics-engineer -- 监控变更后的指标
```

### Pattern 4: New Area/Level（模式 4：新区域/关卡）

```
1. narrative-director -- 定义该区域的叙事目的与节奏节点
2. world-builder      -- 创建世界观与环境背景
3. level-designer     -- 设计布局、遭遇与节奏
4. game-designer      -- 评审遭遇的机制设计
5. art-director       -- 定义该区域的视觉方向
6. audio-director     -- 定义该区域的音频方向
7. [implementation by relevant programmers and artists]
8. writer             -- 编写区域专属文本内容
9. qa-tester          -- 测试完整区域
```

### Pattern 5: Sprint Cycle（模式 5：迭代周期）

```
1. producer           -- 使用 /sprint-plan new 规划迭代
2. [All agents]       -- 执行分配任务
3. producer           -- 使用 /sprint-plan status 进行每日状态同步
4. qa-lead            -- 迭代期间持续测试
5. lead-programmer    -- 迭代期间持续代码评审
6. producer           -- 通过 post-sprint hook 执行迭代复盘
7. producer           -- 融合经验教训规划下一轮迭代
```

### Pattern 6: Milestone Checkpoint（模式 6：里程碑检查点）

```
1. producer           -- 运行 /milestone-review
2. creative-director  -- 审查创意进展
3. technical-director -- 审查技术健康度
4. qa-lead            -- 审查质量指标
5. producer           -- 主持 go/no-go 讨论
6. [All directors]    -- 必要时就范围调整达成一致
7. producer           -- 记录决策并更新计划
```

### Pattern 7: Release Pipeline（模式 7：发布流水线）

```text
1. producer             -- 宣布发布候选版本，确认里程碑标准已达成
2. release-manager      -- 切出发布分支，生成 /release-checklist
3. qa-lead              -- 执行完整回归并签署质量确认
4. localization-lead    -- 验证所有字符串已翻译且文本适配通过
5. performance-analyst  -- 确认性能基准在目标范围内
6. devops-engineer      -- 构建发布产物并运行部署流水线
7. release-manager      -- 生成 /changelog、打发布标签、创建发布说明
8. technical-director   -- 对重大版本做最终签署
9. release-manager      -- 部署并监控 48 小时
10. producer            -- 标记发布完成
```

### Pattern 8: Concept Prototype (early — before GDDs)（模式 8：概念原型）

```text
1. game-designer        -- 定义假设与成功标准
2. prototyper           -- 用 /prototype 搭建概念原型
3. prototyper           -- 构建最小实现（1-3 天）
4. game-designer        -- 根据标准评估原型
5. prototyper           -- 在 REPORT.md 中记录发现
6. creative-director    -- 决定继续 / 转向 / 停止（仅完整版）
7. game-designer        -- 如果继续，则用原型的学习成果指导 GDD 编写
```

### Pattern 8b: Vertical Slice (pre-production — after GDDs and architecture)（模式 8b：垂直切片）

```text
1. game-designer        -- 根据游戏设计文档（GDD）确认切片范围
2. prototyper           -- 使用/vertical-slice 构建生产质量的端到端版本
3. prototyper           -- 进行内部试玩（至少一次）
4. prototyper           -- 在 REPORT.md 中记录发现
5. creative-director    -- 决定是否进入正式开发（全模式）
6. producer             -- 如果决定进行，安排生产史诗/迭代
```

### Pattern 9: Live Event / Season Launch（模式 9：实时活动 / 赛季上线）

```text
1. live-ops-designer     -- 设计活动/赛季内容、奖励与日程
2. game-designer         -- 验证活动玩法机制
3. economy-designer      -- 平衡活动经济与奖励数值
4. narrative-director    -- 提供赛季叙事主题
5. writer                -- 编写活动说明与 lore
6. producer              -- 安排实现工作
7. [implementation by relevant programmers]
8. qa-lead               -- 端到端测试活动流程
9. community-manager     -- 起草活动公告与补丁说明
10. release-manager      -- 部署活动内容
11. analytics-engineer   -- 监控活动参与度与指标
12. live-ops-designer    -- 活动后分析与复盘
```

## Cross-Domain Communication Protocols（跨域沟通协议）

### Design Change Notification（设计变更通知）

当游戏设计文档发生变更时，game-designer 必须通知：
- lead-programmer（实现影响）
- qa-lead（需要更新测试计划）
- producer（评估排期影响）
- 根据变更内容通知相关 specialist agents

### Architecture Change Notification（架构变更通知）

当 ADR 被创建或修改时，technical-director 必须通知：
- lead-programmer（需要代码改动）
- 所有受影响的 specialist programmers
- qa-lead（测试策略可能变化）
- producer（排期影响）

### Asset Standard Change Notification（资产规范变更通知）

当 art bible 或资产规范发生变更时，art-director 必须通知：
- technical-artist（流水线变更）
- 所有处理受影响资产的内容创作者
- devops-engineer（若构建流水线受影响）

## Anti-Patterns to Avoid（需避免的反模式）

1. **Bypassing the hierarchy**：specialist agent 未经协商不得做出应由其 lead 决定的事项。
2. **Cross-domain implementation**：未经相关 owner 明确委派，agent 不得修改其指定范围外的文件。
3. **Shadow decisions**：所有决策都必须文档化。无书面记录的口头约定会导致矛盾。
4. **Monolithic tasks**：分配给 agent 的每项任务应能在 1-3 天内完成。若更大，必须先拆分。
5. **Assumption-based implementation**：若规格含糊，实现者必须向规格制定者确认而非猜测。错误猜测的成本高于提问。
