# 可用技能（Slash Commands）

按阶段组织的 68 个 slash commands。在 Claude Code 中输入 `/` 即可访问任意命令。

## 入门与导航（Onboarding & Navigation）

| Command | 目的 |
|---------|---------|
| `/start` | 首次引导 — 先询问你当前所处状态，然后引导你进入正确的 workflow |
| `/help` | 上下文感知的“下一步做什么？”— 读取当前阶段并给出必须执行的下一步 |
| `/project-stage-detect` | 完整项目审计 — 检测阶段、识别存在性缺口，并推荐下一步 |
| `/setup-engine` | 配置引擎 + 版本，检测知识缺口，并填充具备版本感知的参考文档 |
| `/adopt` | Brownfield 格式审计 — 检查现有 GDDs/ADRs/stories 的内部结构，并产出迁移计划 |

## 游戏设计（Game Design）

| Command | 目的 |
|---------|---------|
| `/brainstorm` | 使用专业工作室方法进行引导式创意发散（MDA、SDT、Bartle、verb-first） |
| `/map-systems` | 将游戏概念拆解为系统，映射依赖关系，并确定设计优先顺序 |
| `/design-system` | 面向单个游戏系统的分章节引导式 game design document（游戏设计文档）编写 |
| `/quick-design` | 用于小改动的轻量设计规范 — 调优、小修、小型新增 |
| `/review-all-gdds` | 对所有设计文档执行跨 GDD 一致性与整体性（holism）评审 |
| `/propagate-design-change` | 当 GDD 被修订时，定位受影响 ADR 并生成影响报告 |

## UX 与界面设计（UX & Interface Design）

| Command | 目的 |
|---------|---------|
| `/ux-design` | 引导式分章节 UX 规范编写（screen/flow、HUD 或 pattern library） |
| `/ux-review` | 校验 UX 规范与 GDD 对齐情况、无障碍可达性以及 pattern 合规性 |

## 架构（Architecture）

| Command | 目的 |
|---------|---------|
| `/create-architecture` | 引导式编写主架构文档 |
| `/architecture-decision` | 创建 architecture decision record（架构决策记录，ADR） |
| `/architecture-review` | 校验全部 ADR 的完整性、依赖顺序与 GDD 覆盖度 |
| `/create-control-manifest` | 从已接受的 ADR 生成扁平化程序员规则表（control manifest） |

## 故事与迭代（Stories & Sprints）

| Command | 目的 |
|---------|---------|
| `/create-epics` | 将 GDDs + ADRs 转换为 epics — 每个架构模块一个 |
| `/create-stories` | 将单个 epic 拆分为可实现的 story 文件 |
| `/dev-story` | 读取 story 并实现 — 路由到正确的程序员 agent |
| `/sprint-plan` | 生成或更新 sprint 计划；初始化 sprint-status.yaml |
| `/sprint-status` | 快速 30 行 sprint 快照（读取 sprint-status.yaml） |
| `/story-readiness` | 在接手前验证 story 是否已准备好实现（READY/NEEDS WORK/BLOCKED） |
| `/story-done` | 实现后的 8 阶段完成评审；更新 story 文件并给出下一条 story |
| `/estimate` | 结构化工作量估算，含复杂度、依赖与风险拆解 |

## 评审与分析（Reviews & Analysis）

| Command | 目的 |
|---------|---------|
| `/design-review` | 对 game design document（游戏设计文档）进行完整性与一致性评审 |
| `/code-review` | 面向文件或变更集的架构级代码评审 |
| `/balance-check` | 分析游戏平衡数据、公式与配置 — 标记异常值 |
| `/asset-audit` | 审计资产命名规范、文件体积预算与 pipeline 合规性 |
| `/content-audit` | 对照 GDD 规定内容数量与已实现内容进行审计 |
| `/scope-check` | 对照原计划分析功能或 sprint 范围，标记 scope creep（范围蔓延） |
| `/perf-profile` | 结构化性能剖析并识别瓶颈 |
| `/tech-debt` | 扫描、跟踪、排序并报告技术债 |
| `/gate-check` | 校验是否可推进开发阶段（PASS/CONCERNS/FAIL） |
| `/consistency-check` | 扫描所有 GDD 与实体注册表，检测跨文档不一致（相互矛盾的属性、名称、规则） |

## QA 与测试（QA & Testing）

| Command | 目的 |
|---------|---------|
| `/qa-plan` | 为 sprint 或功能生成 QA 测试计划 |
| `/smoke-check` | 在 QA 交接前执行关键路径 smoke test gate |
| `/soak-test` | 为长时游戏会话生成 soak test 协议 |
| `/regression-suite` | 将测试覆盖映射到 GDD 关键路径，识别缺少回归测试的已修复 bug |
| `/test-setup` | 为项目引擎搭建测试框架与 CI/CD pipeline |
| `/test-helpers` | 为测试套件生成引擎特定测试辅助库 |
| `/test-evidence-review` | 对测试文件与手工证据文档做质量评审 |
| `/test-flakiness` | 从 CI 运行日志检测非确定性（flaky）测试 |
| `/skill-test` | 校验 skill 文件的结构合规性与行为正确性 |

## 生产（Production）

| Command | 目的 |
|---------|---------|
| `/milestone-review` | 评审里程碑进度并生成状态报告 |
| `/retrospective` | 执行结构化 sprint 或里程碑复盘 |
| `/bug-report` | 创建结构化 bug 报告 |
| `/bug-triage` | 读取所有 open bug，重新评估优先级与严重度，分配 owner 与标签 |
| `/reverse-document` | 从现有实现反向生成设计或架构文档 |
| `/playtest-report` | 生成结构化 playtest（玩家测试）报告，或分析已有 playtest 记录 |

## 发布（Release）

| Command | 目的 |
|---------|---------|
| `/release-checklist` | 为当前构建生成并校验预发布检查清单 |
| `/launch-checklist` | 跨所有部门完成上线就绪性校验 |
| `/changelog` | 基于 git commits 与 sprint 数据自动生成 changelog |
| `/patch-notes` | 基于 git 历史与内部数据生成面向玩家的 patch notes |
| `/hotfix` | 带审计轨迹的紧急修复 workflow，绕过常规 sprint 流程 |

## 创意与内容（Creative & Content）

| Command | 目的 |
|---------|---------|
| `/prototype` | 快速 throwaway prototype（一次性原型）以验证机制（标准放宽、隔离 worktree） |
| `/onboard` | 为新贡献者或 agent 生成上下文化 onboarding 文档 |
| `/localize` | 本地化 workflow：字符串提取、校验、翻译就绪性 |

## 团队编排（Team Orchestration）

在单一功能领域协调多个 agents：

| Command | Coordinates |
|---------|-------------|
| `/team-combat` | game-designer + gameplay-programmer + ai-programmer + technical-artist + sound-designer + qa-tester |
| `/team-narrative` | narrative-director + writer + world-builder + level-designer |
| `/team-ui` | ux-designer + ui-programmer + art-director + accessibility-specialist |
| `/team-release` | release-manager + qa-lead + devops-engineer + producer |
| `/team-polish` | performance-analyst + technical-artist + sound-designer + qa-tester |
| `/team-audio` | audio-director + sound-designer + technical-artist + gameplay-programmer |
| `/team-level` | level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester |
| `/team-live-ops` | live-ops-designer + economy-designer + community-manager + analytics-engineer |
| `/team-qa` | qa-lead + qa-tester + gameplay-programmer + producer |
