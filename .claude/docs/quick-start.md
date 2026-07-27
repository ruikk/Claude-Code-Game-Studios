# Game Studio Agent Architecture -- 快速开始指南（Quick Start Guide）

## What Is This? / 这是什么？

这是一个面向游戏开发的完整 Claude Code 代理架构。它将 48 个专业 AI 代理组织为一个贴近真实游戏开发团队的工作室层级，并定义了职责边界、委派规则与协作协议。它包含 Godot、Unity、Unreal 的引擎专精代理体系，并为主要引擎子系统提供专门的下级专家。所有设计代理与模板都建立在成熟的游戏设计理论之上（MDA Framework、Self-Determination Theory、Flow State、Bartle Player Types）。请使用与你项目引擎匹配的那一套代理。

## How to Use / 如何使用

### 1. Understand the Hierarchy / 理解层级结构

代理分为三个层级：

- **Tier 1 (Opus)**：负责高层决策的总监
  - `creative-director` -- 愿景与创意冲突解决
  - `technical-director` -- 架构与技术决策
  - `producer` -- 排期、协同与风险管理

- **Tier 2 (Sonnet)**：负责各自领域的部门负责人
  - `game-designer`, `lead-programmer`, `art-director`, `audio-director`,
    `narrative-director`, `qa-lead`, `release-manager`, `localization-lead`

- **Tier 3 (Sonnet/Haiku)**：在领域内执行工作的专家
  - 设计师、程序员、美术、编剧、测试、工程师

### 2. Pick the Right Agent for the Job / 为任务选择合适代理

先问自己：“在真实工作室里，这件事该由哪个部门负责？”

| I need to... | Use this agent |
|-------------|---------------|
| 设计一个新机制 | `game-designer` |
| 编写战斗代码 | `gameplay-programmer` |
| 制作一个着色器 | `technical-artist` |
| 编写对话 | `writer` |
| 规划下一个冲刺 | `producer` |
| 评审代码质量 | `lead-programmer` |
| 编写测试用例 | `qa-tester` |
| 设计关卡 | `level-designer` |
| 修复性能问题 | `performance-analyst` |
| 配置 CI/CD | `devops-engineer` |
| 设计掉落表 | `economy-designer` |
| 解决创意冲突 | `creative-director` |
| 做架构决策 | `technical-director` |
| 管理发布 | `release-manager` |
| 准备翻译字符串 | `localization-lead` |
| 快速验证机制想法 | `prototyper` |
| 做安全问题代码审查 | `security-engineer` |
| 检查无障碍合规 | `accessibility-specialist` |
| 获取 Unreal Engine 建议 | `unreal-specialist` |
| 获取 Unity 建议 | `unity-specialist` |
| 获取 Godot 建议 | `godot-specialist` |
| 设计 GAS abilities/effects | `ue-gas-specialist` |
| 定义 BP/C++ 边界 | `ue-blueprint-specialist` |
| 实现 UE replication | `ue-replication-specialist` |
| 构建 UMG/CommonUI widgets | `ue-umg-specialist` |
| 设计 DOTS/ECS 架构 | `unity-dots-specialist` |
| 编写 Unity shaders/VFX | `unity-shader-specialist` |
| 管理 Addressable assets | `unity-addressables-specialist` |
| 构建 UI Toolkit/UGUI screens | `unity-ui-specialist` |
| 编写符合惯用法的 GDScript | `godot-gdscript-specialist` |
| 创建 Godot shaders | `godot-shader-specialist` |
| 构建 GDExtension modules | `godot-gdextension-specialist` |
| 规划实时运营活动与赛季 | `live-ops-designer` |
| 为玩家撰写补丁说明 | `community-manager` |
| 头脑风暴一个新游戏创意 | 使用 `/brainstorm` skill |

### 3. Use Slash Commands for Common Tasks / 用 Slash 命令处理常见任务

| Command | What it does |
|---------|-------------|
| `/start` | 首次引导：询问你当前所处阶段，并引导到正确工作流 |
| `/help` | 上下文感知的“下一步做什么？”——读取你当前阶段与产物 |
| `/project-stage-detect` | 分析项目状态、识别阶段、定位缺口 |
| `/setup-engine` | 配置引擎与版本，填充参考文档 |
| `/adopt` | 对现有项目进行棕地审计并生成迁移计划 |
| `/brainstorm` | 从零开始的引导式游戏概念创意 |
| `/map-systems` | 将概念拆解为系统、映射依赖，并引导按系统编写 GDD |
| `/design-system` | 针对单一游戏系统，按章节引导编写 GDD |
| `/quick-design` | 面向小改动的轻量规格：调优、微调、小幅新增 |
| `/review-all-gdds` | 跨 GDD 一致性与游戏设计理论审查 |
| `/propagate-design-change` | 找出受 GDD 变更影响的 ADR 与故事 |
| `/ux-design` | 编写 UX 规格（界面/流程、HUD、交互模式） |
| `/ux-review` | 校验 UX 规格的无障碍与 GDD 一致性 |
| `/create-architecture` | 生成游戏的主架构文档 |
| `/architecture-decision` | 创建 ADR |
| `/architecture-review` | 校验所有 ADR、依赖顺序与 GDD 可追踪性 |
| `/create-control-manifest` | 根据已接受 ADR 生成扁平化程序员规则表 |
| `/create-epics` | 将 GDD + ADR 转换为 epics（每个架构模块一个） |
| `/create-stories` | 将单个 epic 拆分为可实现的 story 文件 |
| `/dev-story` | 读取 story 并实现——自动路由到正确程序员代理 |
| `/sprint-plan` | 创建或更新冲刺计划 |
| `/sprint-status` | 快速 30 行冲刺快照 |
| `/story-readiness` | 在接手前校验 story 是否可实现 |
| `/story-done` | story 收尾评审——验证验收标准 |
| `/estimate` | 产出结构化工作量估算 |
| `/design-review` | 审查设计文档 |
| `/code-review` | 审查代码质量与架构 |
| `/balance-check` | 分析游戏数值平衡数据 |
| `/asset-audit` | 审计资产合规性 |
| `/content-audit` | 对照 GDD 规定内容与已实现内容——查找缺口 |
| `/scope-check` | 对照计划检测范围蔓延 |
| `/perf-profile` | 性能剖析与瓶颈定位 |
| `/tech-debt` | 扫描、追踪并排序技术债 |
| `/gate-check` | 验证阶段就绪度（PASS/CONCERNS/FAIL） |
| `/consistency-check` | 扫描所有 GDD 的跨文档不一致（冲突数值、命名、规则） |
| `/reverse-document` | 从现有代码反向生成设计/架构文档 |
| `/milestone-review` | 审查里程碑进度 |
| `/retrospective` | 执行冲刺/里程碑复盘 |
| `/bug-report` | 结构化缺陷报告创建 |
| `/playtest-report` | 创建或分析试玩测试反馈 |
| `/onboard` | 为某角色生成入门文档 |
| `/release-checklist` | 校验发布前检查清单 |
| `/launch-checklist` | 完整上线就绪度校验 |
| `/changelog` | 从 git 历史生成 changelog |
| `/patch-notes` | 生成面向玩家的补丁说明 |
| `/hotfix` | 带审计轨迹的紧急修复 |
| `/prototype` | 搭建一次性原型 |
| `/localize` | 本地化扫描、提取、校验 |
| `/team-combat` | 编排完整战斗团队流水线 |
| `/team-narrative` | 编排完整叙事团队流水线 |
| `/team-ui` | 编排完整 UI 团队流水线 |
| `/team-release` | 编排完整发布团队流水线 |
| `/team-polish` | 编排完整打磨团队流水线 |
| `/team-audio` | 编排完整音频团队流水线 |
| `/team-level` | 编排完整关卡制作流水线 |
| `/team-live-ops` | 为赛季、活动与上线后内容编排实时运营团队 |
| `/team-qa` | 编排完整 QA 团队周期——测试计划、测试用例、冒烟检查、签核 |
| `/qa-plan` | 为冲刺或功能生成 QA 测试计划 |
| `/bug-triage` | 重新排序开放缺陷优先级，分配到冲刺，并暴露系统性趋势 |
| `/smoke-check` | QA 交接前运行关键路径冒烟测试门禁（PASS/FAIL） |
| `/soak-test` | 为长时游玩会话生成 soak test 协议 |
| `/regression-suite` | 将覆盖映射到 GDD 关键路径，标记缺口并维护回归套件 |
| `/test-setup` | 为项目引擎搭建测试框架 + CI 流水线（只需运行一次） |
| `/test-helpers` | 生成引擎专用测试辅助库与工厂函数 |
| `/test-flakiness` | 从 CI 历史检测 flaky tests，标记为隔离或修复 |
| `/test-evidence-review` | 评审测试文件与手工证据质量——ADEQUATE/INCOMPLETE/MISSING |
| `/skill-test` | 校验 skill 文件的合规性与正确性（static / spec / audit） |

### 4. Use Templates for New Documents / 使用模板创建新文档

模板位于 `.claude/docs/templates/`：

- `game-design-document.md` -- 用于新机制与系统
- `architecture-decision-record.md` -- 用于技术决策
- `architecture-traceability.md` -- 将 GDD 需求映射到 ADR 与 story ID
- `risk-register-entry.md` -- 用于新增风险
- `narrative-character-sheet.md` -- 用于新角色
- `test-plan.md` -- 用于功能测试计划
- `sprint-plan.md` -- 用于冲刺规划
- `milestone-definition.md` -- 用于新里程碑
- `level-design-document.md` -- 用于新关卡
- `game-pillars.md` -- 用于核心设计支柱
- `art-bible.md` -- 用于视觉风格参考
- `technical-design-document.md` -- 用于按系统划分的技术设计
- `post-mortem.md` -- 用于项目/里程碑复盘
- `sound-bible.md` -- 用于音频风格参考
- `release-checklist-template.md` -- 用于平台发布检查清单
- `changelog-template.md` -- 用于面向玩家的补丁说明
- `release-notes.md` -- 用于面向玩家的发布说明
- `incident-response.md` -- 用于线上事故响应手册
- `game-concept.md` -- 用于初始游戏概念（MDA、SDT、Flow、Bartle）
- `pitch-document.md` -- 用于向干系人推介游戏
- `economy-model.md` -- 用于虚拟经济设计（sink/faucet model）
- `faction-design.md` -- 用于阵营定位、世界观与玩法角色
- `systems-index.md` -- 用于系统拆解与依赖映射
- `project-stage-report.md` -- 用于项目阶段检测输出
- `design-doc-from-implementation.md` -- 用于将现有代码反向文档化为 GDD
- `architecture-doc-from-code.md` -- 用于将代码反向文档化为架构文档
- `concept-doc-from-prototype.md` -- 用于将原型反向文档化为概念文档
- `ux-spec.md` -- 用于逐屏 UX 规格（布局区域、状态、事件）
- `hud-design.md` -- 用于整游戏 HUD 理念、分区与元素规格
- `accessibility-requirements.md` -- 用于项目级无障碍等级与功能矩阵
- `interaction-pattern-library.md` -- 用于标准 UI 控件与游戏特定交互模式
- `player-journey.md` -- 用于 6 阶段情绪曲线与按时间尺度划分的留存钩子
- `difficulty-curve.md` -- 用于难度维度、新手爬坡与跨系统交互
- `test-evidence.md` -- 用于记录手工测试证据（截图、走查笔记）

另有 `.claude/docs/templates/collaborative-protocols/`（供代理使用，通常不直接编辑）：

- `design-agent-protocol.md` -- 设计代理的问题-选项-草案-批准循环
- `implementation-agent-protocol.md` -- 编程代理从 story 接手到 /story-done 循环
- `leadership-agent-protocol.md` -- 总监层代理的跨部门委派与升级

### 5. Follow the Coordination Rules / 遵循协作规则

1. 工作沿层级向下流动：Directors -> Leads -> Specialists
2. 冲突沿层级向上升级
3. 跨部门工作由 `producer` 统筹
4. 未经委派，代理不得修改其领域外文件
5. 所有决策都要文档化

## First Steps for a New Project / 新项目第一步

**不知道从哪开始？** 运行 `/start`。它会询问你当前状态并路由到正确工作流。不会对你的游戏、引擎或经验水平做预设。

如果你已明确需求，可以直接跳到对应路径：

### Path A: "I have no idea what to build"

1. **运行 `/start`**（或 `/brainstorm open`）——引导式创意探索：
   你真正感兴趣的内容、玩过什么、有哪些约束
   - 生成 3 个概念，帮助你选 1 个，并定义核心循环与支柱
   - 产出游戏概念文档并推荐引擎
2. **配置引擎**——运行 `/setup-engine`（采用 brainstorm 推荐）
   - 配置 CLAUDE.md、检测知识缺口、填充参考文档
   - 创建 `.claude/docs/technical-preferences.md`，包含命名规范、
     性能预算与引擎特定默认值
   - 如果引擎版本新于 LLM 训练数据，它会从网络抓取最新文档，
     以便代理建议正确 API
3. **验证概念**——运行 `/design-review design/gdd/game-concept.md`
4. **拆解为系统**——运行 `/map-systems` 映射所有系统与依赖
5. **设计每个系统**——运行 `/design-system [system-name]`（或 `/map-systems next`）
   按依赖顺序编写 GDD
6. **测试核心循环**——运行 `/prototype [core-mechanic]`
7. **进行试玩测试**——运行 `/playtest-report` 验证假设
8. **规划首个冲刺**——运行 `/sprint-plan new`
9. 开始构建

### Path B: "I know what I want to build"

如果你已经有游戏概念和引擎选择：

1. **配置引擎**——运行 `/setup-engine [engine] [version]`
   （例如 `/setup-engine godot 4.6`）——也会创建技术偏好
2. **编写 Game Pillars**——委派给 `creative-director`
3. **拆解为系统**——运行 `/map-systems` 枚举系统与依赖
4. **设计每个系统**——运行 `/design-system [system-name]` 按依赖顺序编写 GDD
5. **创建初始 ADR**——运行 `/architecture-decision`
6. 在 `production/milestones/` 中**创建第一个里程碑**
7. **规划首个冲刺**——运行 `/sprint-plan new`
8. 开始构建

### Path C: "I know the game but not the engine"

如果你有概念，但不知道哪个引擎更合适：

1. **运行不带参数的 `/setup-engine`**——它会询问你游戏需求
   （2D/3D、平台、团队规模、语言偏好），并基于你的回答推荐
   合适引擎
2. 从 Path B 的第 2 步继续

### Path D: "I have an existing project"

如果你已经有设计文档、原型或代码：

1. **运行 `/start`**（或 `/project-stage-detect`）——分析现状，
   识别缺口并推荐下一步
2. 如果你已有 GDD、ADR 或 story，**运行 `/adopt`**——审计内部格式合规性，
   并生成编号迁移计划，在不覆盖既有成果的前提下补齐缺口
3. **必要时配置引擎**——若尚未配置，运行 `/setup-engine`
4. **验证阶段就绪度**——运行 `/gate-check` 查看当前位置
5. **规划下一个冲刺**——运行 `/sprint-plan new`

## File Structure Reference / 文件结构参考

```
CLAUDE.md                          -- 主配置（先读这个，约 60 行）
.claude/
  settings.json                    -- Claude Code hooks 和项目设置
  agents/                          -- 48 个代理定义（YAML frontmatter）
  skills/                          -- 68 个 slash command 定义（YAML frontmatter）
  hooks/                           -- 12 个由 settings.json 接线的 hook 脚本（.sh）
  rules/                           -- 11 个路径作用域规则文件
  docs/
    quick-start.md                 -- 本文件
    technical-preferences.md       -- 项目特定标准（由 /setup-engine 填充）
    coding-standards.md            -- 编码与设计文档标准
    coordination-rules.md          -- 代理协作规则
    context-management.md          -- 上下文预算与压缩说明
    directory-structure.md         -- 项目目录结构
    workflow-catalog.yaml          -- 7 阶段流水线定义（由 /help 读取）
    setup-requirements.md          -- 系统前置条件（Git Bash、jq、Python）
    settings-local-template.md     -- 个人 settings.local.json 指南
    templates/                     -- 37 个文档模板
```
