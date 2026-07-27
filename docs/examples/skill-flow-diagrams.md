# 技能流程图

展示技能如何贯穿 7 个开发阶段并彼此串联的可视化地图。
图中显示每项技能前后运行的内容，以及工件如何在技能之间流转。

---

## 完整流水线概览（从零到发布）

```
阶段 1：概念
   /start ──────────────────────────────────────────────────────► 路由至 A/B/C/D
  /brainstorm ──────────────────────────────────────────────────► design/gdd/game-concept.md
  /setup-engine ────────────────────────────────────────────────► CLAUDE.md + technical-preferences.md
  /prototype [core-mechanic] ───────────────────────────────────► prototypes/[name]-concept/REPORT.md
        │ PROCEED                                                  （在编写 GDD 前验证想法）
        ▼
   /design-review [game-concept.md] ────────────────────────────► 概念已验证
  /gate-check ─────────────────────────────────────────────────► PASS → advance to systems-design
        │
        ▼
阶段 2：系统设计
  /map-systems ────────────────────────────────────────────────► design/gdd/systems-index.md
        │
        ▼ （按依赖顺序处理每个系统）
  /design-system [name] ──────────────────────────────────────► design/gdd/[system].md
   /design-review [system].md ─────────────────────────────────► GDD 审查意见
        │
        ▼ （所有 MVP GDD 完成后）
  /review-all-gdds ────────────────────────────────────────────► design/gdd/gdd-cross-review-[date].md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to technical-setup
        │
        ▼
阶段 3：技术设置
  /create-architecture ────────────────────────────────────────► docs/architecture/master.md
  /architecture-decision (×N) ─────────────────────────────────► docs/architecture/[adr-nnn].md
  /architecture-review ────────────────────────────────────────► 审查报告 + docs/architecture/tr-registry.yaml
  /create-control-manifest ────────────────────────────────────► docs/architecture/control-manifest.md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to pre-production
        │
        ▼
阶段 4：前期制作
   [UX —— 在史诗之前完成，以便编写故事时已有规格]
  /ux-design [screen/hud/patterns] ────────────────────────────► design/ux/*.md
   /ux-review ──────────────────────────────────────────────────► UX 规格已批准（/team-ui 的硬门禁）

   [测试基础设施 —— 在故事引用测试前搭建]
   /test-setup ─────────────────────────────────────────────────► 测试框架 + CI/CD 流水线
  /test-helpers ───────────────────────────────────────────────► tests/helpers/[engine-specific].gd

   [垂直切片 —— 在史诗之前验证完整游戏循环]
  /vertical-slice ─────────────────────────────────────────────► prototypes/[name]-vertical-slice/REPORT.md
  /playtest-report ────────────────────────────────────────────► production/playtests/

   [故事 + 迭代计划 —— 仅在垂直切片 PROCEEDS 后进行]
  /create-epics [layer] ───────────────────────────────────────► production/epics/*/EPIC.md
  /create-stories [epic-slug] ─────────────────────────────────► production/epics/*/story-*.md
  /sprint-plan new ────────────────────────────────────────────► production/sprints/sprint-01.md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to production
        │
        ▼
阶段 5：制作（重复迭代循环）
   /sprint-status ──────────────────────────────────────────────► 迭代快照
   /story-readiness [story] ────────────────────────────────────► 故事已验证为 READY
        │
        ▼ （接手并实现）
   /dev-story [story] ──────────────────────────────────────────► 路由至正确的程序员代理
        │
        ▼ （实现期间按需进行）
   /code-review ────────────────────────────────────────────────► 代码审查报告
   /scope-check ────────────────────────────────────────────────► 检测到范围蔓延 / 范围清晰
   /content-audit ──────────────────────────────────────────────► 已识别 GDD 内容缺口
  /bug-report ─────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
   /bug-triage ─────────────────────────────────────────────────► 缺陷已重新排序并分配

   [功能领域团队技能 —— 完整开发某项功能时启动]
  /team-combat / /team-narrative / /team-ui / /team-level / /team-audio

   [每次迭代的 QA 循环]
  /qa-plan ────────────────────────────────────────────────────► production/qa/qa-plan-sprint-NN.md
   /smoke-check ────────────────────────────────────────────────► 冒烟测试门禁（PASS/FAIL）
   /regression-suite ───────────────────────────────────────────► 覆盖率缺口 + 缺失的回归测试
   /test-evidence-review ───────────────────────────────────────► 测试证据质量报告
   /test-flakiness ─────────────────────────────────────────────► 不稳定测试报告
        │
        ▼
   /story-done [story] ─────────────────────────────────────────► 故事已关闭 + 显示下一个故事
   /sprint-plan [next] ─────────────────────────────────────────► 下一个迭代
        │
        ▼ （Production 里程碑后）
   /milestone-review ───────────────────────────────────────────► 里程碑报告
  /gate-check ─────────────────────────────────────────────────► PASS → advance to polish
        │
        ▼
阶段 6：打磨
   /perf-profile ───────────────────────────────────────────────► 性能报告 + 修复
   /balance-check ──────────────────────────────────────────────► 平衡性报告 + 修复
   /asset-audit ────────────────────────────────────────────────► 资产合规报告
  /tech-debt ──────────────────────────────────────────────────► docs/tech-debt-register.md
   /soak-test ──────────────────────────────────────────────────► 浸泡测试协议 + 结果
   /localize ───────────────────────────────────────────────────► 本地化就绪报告
   /team-polish ────────────────────────────────────────────────► 打磨迭代已编排
   /team-qa ────────────────────────────────────────────────────► 完整 QA 循环签核
  /gate-check ─────────────────────────────────────────────────► PASS → advance to release
        │
        ▼
阶段 7：发布
   /launch-checklist ───────────────────────────────────────────► 上线就绪报告
   /release-checklist ──────────────────────────────────────────► 平台专用清单
  /changelog ──────────────────────────────────────────────────► CHANGELOG.md
   /patch-notes ────────────────────────────────────────────────► 面向玩家的说明
   /team-release ───────────────────────────────────────────────► 发布流水线已编排
        │
        ▼ （上线后持续进行）
   /hotfix ─────────────────────────────────────────────────────► 带审计记录的紧急修复
   /team-live-ops ──────────────────────────────────────────────► live-ops 内容计划
```

---

## 技能链：/design-system 详解

单个 GDD 如何编写、审查并移交架构阶段：

```
systems-index.md (input)
game-concept.md (input)
上游 GDD（input，如有）
        │
        ▼
/design-system [name]
        │
        ├── 预检查：可行性表 + 引擎风险标记
        │
        ├── 章节循环 × 8：
        │     提问 → 选项 → 决定 → 草稿 → 批准 → WRITE
        │     [每节获批后立即写入文件]
        │
        └── 输出：design/gdd/[system].md（完整，包含全部 8 个章节）
                │
                ▼
        /design-review design/gdd/[system].md
                │
                ├── APPROVED → 在 systems-index 中标记 DONE，进入下一个系统
                ├── NEEDS REVISION → 代理展示具体问题，重新进入章节循环
                └── MAJOR REVISION → 需要重大重新设计后才能进入下一个系统
                        │
                        ▼ （所有 MVP GDD 完成并交叉审查后）
                /review-all-gdds
                        │
                        └── 输出：gdd-cross-review-[date].md
```

---

## 技能链：UX / UI 流水线详解

UX 规格在阶段 4（前期制作）编写，早于史诗创建，因此故事验收标准可以引用具体的 UX 工件。

```
design/gdd/*.md（提取出的 UI/UX 需求）
design/player-journey.md（情绪弧线，如已编写）
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → UX 规格就绪，进入 /create-epics
        ├── NEEDS REVISION → 列出阻塞问题 → 修复 → 重新运行审查
        └── MAJOR REVISION → 存在根本性 UX 问题 → 在史诗之前重新设计
                │
                ▼ （APPROVED 后——阶段 5 实现 UI 功能时）
        /team-ui
                │
                ├── 阶段 1：/ux-design（如仍缺少规格）+ /ux-review
                ├── 阶段 2：视觉设计（art-director）
                ├── 阶段 3：布局实现（ui-programmer）
                ├── 阶段 4：无障碍审计（accessibility-specialist）
                └── 阶段 5：最终审查

注意：/ux-design 和 /ux-review 属于阶段 4（前期制作）。
      /team-ui 属于阶段 5（制作），在构建 UI 功能时使用。
```

---

## 技能链：开发故事流程详解

故事如何从待办列表走向关闭：

```
/story-readiness [story]
        │
        ├── READY → Status: ready-for-dev → 接手实现
        ├── NEEDS WORK → 代理展示具体缺口 → 解决 → 重新运行就绪检查
        └── BLOCKED → ADR 仍为 Proposed，或上游故事未完成
                │
                ▼ （READY 后）
        /dev-story [story]
                │
                ├── 读取：故事文件、关联的 GDD 需求、ADR 决策、控制清单
                ├── 路由至：gameplay-programmer / engine-programmer / ui-programmer / 等
                │
                └── 开始实现
                        │
                 ▼ （可选，实现期间或之后）
                 /code-review          → 变更集架构审查
                 /scope-check          → 验证相对于原故事标准没有范围蔓延
                 /test-evidence-review → 验证测试文件和手动证据质量
                        │
                        ▼
                /story-done [story]
                        │
                        ├── COMPLETE → Status: Complete，更新 sprint-status.yaml，显示下一个故事
                        ├── COMPLETE WITH NOTES → 已完成，但部分标准延期（已记录）
                        └── BLOCKED → 无法验证验收标准 → 调查阻塞原因
```

---

## 技能链：故事生命周期（从待办到关闭）

故事如何从待办列表走向关闭（摘要视图）：

```
/create-epics [layer]
        │
        └── 输出：production/epics/[slug]/EPIC.md
                │
                ▼
        /create-stories [epic-slug]
                │
                └── 输出：production/epics/[slug]/story-NNN-[slug].md
                             （Status: Ready，或在 ADR 为 Proposed 时为 Blocked）
                │
                ▼
        /story-readiness [story]
                │
                ├── READY → /dev-story → 实现 → /story-done
                ├── NEEDS WORK → 解决缺口 → 重新运行
                └── BLOCKED → 先修复上游依赖
```

---

## 技能链：QA 流水线详解

```
[阶段 4 —— 一次性基础设施设置]
/test-setup ────────────────────────────────────────────────────► 测试框架已搭建 + CI/CD 已接入
/test-helpers ──────────────────────────────────────────────────► tests/helpers/[engine].gd（GDUnit4、NUnit 等）

[阶段 5 —— 每次迭代的 QA 循环]
/qa-plan [sprint or feature]
        │
        ├── 读取：故事文件、GDD、验收标准
        ├── 按测试类型分类每个故事：
        │     Logic → 自动化单元测试（BLOCKING）
        │     Integration → 集成测试或有文档记录的试玩（BLOCKING）
        │     Visual/Feel → 截图 + 负责人签核（ADVISORY）
        │     UI → 手动演练或交互测试（ADVISORY）
        │     Config/Data → 冒烟检查（ADVISORY）
        └── 输出：production/qa/qa-plan-sprint-NN.md
                │
                ▼
        /smoke-check
                │
                ├── PASS → QA 移交已放行
                └── FAIL → 阻止迭代关闭 → 先修复关键路径
                        │
                        ▼
                /regression-suite
                        │
                        └── 覆盖率缺口 + 没有回归测试的已修复缺陷列表
                                │
                                ▼
                        /test-evidence-review
                                │
                                └── 验证证据质量，而不只是存在性
                                        │
                                        ▼ （如果有 CI 运行历史）
                        /test-flakiness
                                │
                                └── 不稳定测试报告 + 修复建议

[阶段 6 —— 延长稳定性测试]
/soak-test ─────────────────────────────────────────────────────► 浸泡测试协议 + 观察结果
/team-qa ───────────────────────────────────────────────────────► 发布门禁所需的完整 QA 循环签核

[持续进行 —— 缺陷管理]
/bug-report ────────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
/bug-triage ────────────────────────────────────────────────────► 开放缺陷已重新排序并分配

[元流程 —— 工具框架验证]
/skill-test [lint|spec|catalog] ────────────────────────────────► 技能文件结构与行为检查
```

---

## 棕地项目引导流程

适用于已有成果的项目（使用 `/start` 选项 D，或直接运行）：

```
/project-stage-detect    → 阶段检测报告
        │
        ▼
/adopt
        │
        ├── 阶段 1：检测现有内容
        ├── 阶段 2：FORMAT 审计（不只是检查存在性）
        ├── 阶段 3：分类缺口（BLOCKING / HIGH / MEDIUM / LOW）
        ├── 阶段 4：有序迁移计划
        ├── 阶段 5：写入 docs/adoption-plan-[date].md
        └── 阶段 6：直接修复最紧急的缺口（可选）
                │
                ▼
         /design-system retrofit [path]    → 填补缺失的 GDD 章节
         /architecture-decision retrofit [path] → 填补缺失的 ADR 章节
         /gate-check                       → 当前处于流水线的哪个位置？
```

---

## 如何阅读这些图

| 符号 | 含义 |
|--------|---------|
| `──►` | 生成此工件 |
| `│ ▼` | 流向下一步 |
| `├──` | 分支（多个可能结果） |
| `×N` | 运行 N 次（每个系统、故事等一次） |
| `(input)` | 由技能读取，但不在此处生成 |
| `[optional]` | 通过阶段门不需要 |
| `WRITE`（大写） | 立即写入磁盘的文件 |

---

## 常见入口

| 你所在的位置 | 运行此命令 |
|---------------|---------|
| 全新项目，没有想法 | `/start` → `/brainstorm` |
| 有概念，没有引擎 | `/setup-engine` |
| 有概念 + 引擎 | `/map-systems` |
| 正在进行系统设计 | `/design-system [next system]` 或 `/map-systems next` |
| 所有 GDD 已完成 | `/review-all-gdds` → `/gate-check` |
| 正在进行技术设置 | `/create-architecture` → `/architecture-decision` |
| 开始 UX 设计 | `/ux-design screen [name]` 或 `/ux-design hud` |
| 搭建测试 | `/test-setup` → `/test-helpers` |
| 有故事，准备编码 | `/story-readiness [story]` → `/dev-story [story]` |
| 故事完成 | `/story-done [story]` |
| 为迭代运行 QA | `/qa-plan` → `/smoke-check` → `/regression-suite` |
| 需要整理缺陷待办 | `/bug-triage` |
| 延长稳定性测试 | `/soak-test` |
| 不确定 | `/help` |
| 现有项目 | `/adopt` |
