# 技能质量评分标准

供 `/skill-test category [name|all]` 使用，用于评估技能是否满足结构合规之外的要求。
每个类别定义 4–5 项针对该技能职责的二元 PASS/FAIL 指标。

如果技能的书面说明明确满足标准，则该指标为 PASS。
如果说明缺失、含糊或相互矛盾，则该指标为 FAIL。
如果说明仅部分涉及该标准，则该指标为 WARN。

---

## 技能类别

### `gate`

**技能**：gate-check

门禁技能控制阶段转换。它们必须在不自动推进阶段的前提下确保正确性，
并且必须遵循三种审查模式。

| 指标 | PASS 标准 |
|---|---|
| **G1 — 读取审查模式** | 技能在决定生成哪些总监代理之前读取 `production/session-state/review-mode.txt`（或等效内容） |
| **G2 — `full` 模式：生成全部 4 名总监代理** | 在 `full` 模式下，并行调用全部 4 名 Tier-1 总监代理（CD、TD、PR、AD）的 PHASE-GATE 提示 |
| **G3 — `lean` 模式：仅运行 PHASE-GATE** | 在 `lean` 模式下，仅运行 `*-PHASE-GATE` 门禁；跳过内联门禁（CD-PILLARS、TD-ARCHITECTURE 等） |
| **G4 — `solo` 模式：不生成总监代理** | 在 `solo` 模式下，不生成任何总监门禁；每项均标注为 "skipped — Solo mode" |
| **G5 — 不自动推进** | 未通过 "May I write" 获得用户明确确认时，技能绝不写入 `production/stage.txt` |

---

### `review`

**技能**：design-review、architecture-review、review-all-gdds

审查技能读取文档并给出结构化判定。它们主要执行只读操作，
且不得在分析阶段触发总监门禁。

| 指标 | PASS 标准 |
|---|---|
| **R1 — 强制只读** | 未经用户明确批准，技能不得修改被审查的文档；任何写入操作（审查日志、索引更新）均须先通过 "May I write" 获得许可 |
| **R2 — 检查 8 个章节** | 技能明确评估 GDD 要求的全部 8 个章节（或对应的架构章节） |
| **R3 — 使用正确的判定词汇** | 判定必须恰好为以下之一：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED（设计）或 PASS / CONCERNS / FAIL（架构） |
| **R4 — 分析期间无总监门禁** | 技能不得在分析阶段生成总监门禁；如果技能的范围和风险程度需要，则允许在分析后进行总监审查（如 architecture-review） |
| **R5 — 结构化发现** | 输出在最终判定之前包含按章节划分的状态表或检查清单 |

> **例外：**
> - `design-review`：其 `allowed-tools` 中包含 `Write, Edit`，用于支持可选的 "Revise now" 路径（所有写入均须用户批准）和写入审查日志。由于被审查的文档绝不会在未告知用户的情况下被修改，因此满足 R1。
> - `architecture-review`：在分析完成后生成 TD-ARCHITECTURE 和 LP-FEASIBILITY 门禁。这是有意为之，因为架构审查风险较高，适合由总监签核。由于门禁在分析后而非分析期间运行，因此满足 R4。

---

### `authoring`

**技能**：design-system、quick-design、architecture-decision、ux-design、ux-review、art-bible、create-architecture

编写技能以协作方式创建或更新设计文档。完整的 GDD/UX 编写技能
采用逐章节循环；轻量级编写技能则采用适合其较小范围的单次草稿模式。

| 指标 | PASS 标准 |
|---|---|
| **A1 — 逐章节循环** | 完整编写技能（design-system、ux-design、art-bible）每次编写一个章节，提交内容供批准后才继续下一章节。轻量级技能（quick-design、architecture-decision、create-architecture）可以先起草完整文档再请求批准；对于实现范围少于约 4 小时的文档，可以采用单次草稿模式。 |
| **A2 — 每章节写入前确认** | 完整编写技能在写入每个章节前询问 "May I write this to [filepath]?"。轻量级技能针对完整文档询问一次。 |
| **A3 — 改造模式** | 技能检测目标文件是否已存在，并提出更新特定章节，而不是覆盖整个文档。始终创建新文件的轻量级技能（quick-design）可豁免。 |
| **A4 — 在正确层级运行总监门禁** | 如果为此技能定义了总监门禁（例如 CD-GDD-ALIGN、TD-ADR），则在正确的模式阈值（full/lean）下运行，绝不在 solo 下运行 |
| **A5 — 先建骨架** | 完整编写技能在填充内容之前，先创建包含所有章节标题的文件骨架，以便会话中断时保留进度。轻量级技能可豁免。 |

> **完整编写技能**（必须通过全部 5 项指标）：`design-system`、`ux-design`、`art-bible`
> **轻量级编写技能**（A1、A2、A5 采用单次草稿模式；仅创建新文件的技能可豁免 A3）：`quick-design`、`architecture-decision`、`create-architecture`
> **审查模式技能**（依据审查指标评估）：`ux-review`

---

### `readiness`

**技能**：story-readiness、story-done

就绪度技能在实现前后验证故事。它们必须给出多维度判定，
并与总监门禁模式正确集成。

| 指标 | PASS 标准 |
|---|---|
| **RD1 — 多维度检查** | 技能检查至少 3 个相互独立的维度（例如设计（Design）、架构（Architecture）、范围（Scope）、完成定义（DoD）），并分别报告每个维度 |
| **RD2 — 三个判定级别** | 明确定义判定层级：READY/COMPLETE > NEEDS WORK/COMPLETE WITH NOTES > BLOCKED |
| **RD3 — BLOCKED 需要外部行动** | BLOCKED 判定仅用于故事作者无法独自解决的问题（例如 Proposed ADR、无法解决的依赖关系） |
| **RD4 — 在正确模式下运行总监门禁** | QL-STORY-READY 或 LP-CODE-REVIEW 门禁在 `full` 模式下生成，在 `lean`/`solo` 模式下跳过并注明跳过消息 |
| **RD5 — 移交下一个故事** | 完成后，技能显示当前迭代中的下一个 READY 故事 |

---

### `pipeline`

**技能**：create-epics、create-stories、dev-story、create-control-manifest、propagate-design-change、map-systems

管线技能生成供其他技能使用的产物。它们必须使用正确的模式写入文件，
遵循层级/优先级顺序，并在写入前获得许可。

| 指标 | PASS 标准 |
|---|---|
| **P1 — 正确的输出结构** | 每个生成的文件均遵循项目模板（EPIC.md、故事 front matter 等）；技能引用模板路径 |
| **P2 — 层级/优先级顺序** | 生成史诗或故事的技能遵循层级顺序（core → extended → meta）和优先级字段 |
| **P3 — 每项产物写入前确认** | 技能在创建每个输出文件前询问 "May I write [artifact]?"，而不是一次性批量批准所有文件 |
| **P4 — 在正确层级运行总监门禁** | 范围内的门禁（PR-EPIC、QL-STORY-READY、LP-CODE-REVIEW 等）在 `full` 下运行，在 `lean`/`solo` 下跳过并注明跳过消息 |
| **P5 — 先读后写** | 技能在生成产物前读取相关 GDD/ADR/清单（manifest），以确保一致性 |

---

### `analysis`

**技能**：consistency-check、balance-check、content-audit、code-review、tech-debt、
scope-check、estimate、perf-profile、asset-audit、security-audit、test-evidence-review、test-flakiness

分析技能扫描项目并呈现发现。它们在分析期间为只读，
且必须在建议写入任何文件前询问用户。

| 指标 | PASS 标准 |
|---|---|
| **AN1 — 只读扫描** | 分析阶段仅使用 Read/Glob/Grep 工具；扫描期间不使用 Write 或 Edit |
| **AN2 — 结构化发现表** | 输出包含发现表或检查清单（而非只有散文），并为每项发现标明严重程度/优先级 |
| **AN3 — 不自动写入** | 任何建议的文件写入（例如 `tech-debt` 登记表、修复补丁）均须先通过 "May I write" 获得许可 |
| **AN4 — 分析期间无总监门禁** | 分析技能不生成总监门禁；它们只提供发现供人工审查 |

---

### `team`

**技能**：team-combat、team-narrative、team-audio、team-level、team-ui、team-qa、
team-release、team-polish、team-live-ops

团队技能为一个部门编排多个专家代理。它们必须生成正确的代理，
并行运行彼此独立的代理，并立即呈现阻塞项。

| 指标 | PASS 标准 |
|---|---|
| **T1 — 具名代理列表** | 技能明确列出其生成的代理及生成顺序 |
| **T2 — 独立任务并行执行** | 输入互不依赖的代理应并行生成（在一条消息中发出多个 Task 调用） |
| **T3 — 呈现 BLOCKED** | 如果任何已生成的代理返回 BLOCKED 或失败，技能应立即呈现该结果并停止依赖它的工作，绝不静默跳过 |
| **T4 — 收集全部判定后再继续** | 依赖阶段须等待所有并行代理完成后再继续 |
| **T5 — 无参数时提示用法错误** | 如果缺少必需参数（例如功能名称），技能输出用法提示并停止，不生成代理 |

---

### `sprint`

**技能**：sprint-plan、sprint-status、milestone-review、retrospective、changelog、patch-notes

迭代技能读取制作状态并生成报告或规划产物。
它们在特定模式阈值下设有 PR-SPRINT 或 PR-MILESTONE 门禁。

| 指标 | PASS 标准 |
|---|---|
| **SP1 — 读取迭代/里程碑状态** | 技能在生成输出前读取 `production/sprints/` 或 `production/milestones/` |
| **SP2 — 正确的迭代门禁** | PR-SPRINT（用于规划）或 PR-MILESTONE（用于里程碑审查）门禁在 `full` 模式下运行，在 `lean`/`solo` 下跳过 |
| **SP3 — 结构化输出** | 输出采用一致的结构（速率表、风险列表、行动项），而不是自由散文 |
| **SP4 — 不自动提交** | 未通过 "May I write" 获得许可时，技能绝不写入迭代文件或里程碑记录 |

---

### `utility`

**技能**：start、help、brainstorm、onboard、adopt、hotfix、prototype、localize、
launch-checklist、release-checklist、smoke-check、soak-test、test-setup、test-helpers、
regression-suite、qa-plan、bug-triage、bug-report、playtest-report、asset-spec、
reverse-document、project-stage-detect、setup-engine、skill-test、skill-improve、
day-one-patch，以及不属于上述类别的任何其他技能

实用工具技能须通过 7 项标准静态检查。如果它们会生成总监门禁，
则门禁模式逻辑也必须正确。

| 指标 | PASS 标准 |
|---|---|
| **U1 — 通过全部 7 项静态检查** | `/skill-test static [name]` 返回 COMPLIANT，且 FAIL 数量为 0 |
| **U2 — 门禁模式正确（如适用）** | 如果技能生成任何总监门禁，则须读取 review-mode，并正确应用 full/lean/solo 逻辑 |

---

## 代理类别

用于验证 `tests/agents/` 中的代理规格文件。

### `director`

**代理**：creative-director、technical-director、art-director、producer

| 指标 | PASS 标准 |
|---|---|
| **D1 — 正确的判定词汇** | 返回 APPROVE / CONCERNS / REJECT（或领域对应词汇：producer 使用 REALISTIC/CONCERNS/UNREALISTIC） |
| **D2 — 遵守领域边界** | 不在其声明的领域之外作出有约束力的决定 |
| **D3 — 冲突升级** | 当两个部门发生冲突时，将问题升级给正确的上级（creative-director 或 technical-director），而不是单方面决定 |
| **D4 — Opus 模型层级** | 按 coordination-rules.md 为代理分配 Opus 模型 |

### `lead`

**代理**：lead-programmer、qa-lead、narrative-director、audio-director、game-designer、
systems-designer、level-designer

| 指标 | PASS 标准 |
|---|---|
| **L1 — 领域判定** | 返回特定于领域的判定（例如 lead-programmer 使用 FEASIBLE/INFEASIBLE，qa-lead 使用 PASS/FAIL） |
| **L2 — 升级给共同上级** | 将领域外冲突升级给 creative-director（设计）或 technical-director（技术） |
| **L3 — Sonnet 模型层级** | 按 coordination-rules.md 为代理分配 Sonnet 模型（默认） |

### `specialist`

**代理**：gameplay-programmer、ai-programmer、technical-artist、sound-designer、
engine-programmer、tools-programmer、network-programmer、security-engineer、
accessibility-specialist、ux-designer、ui-programmer、performance-analyst、prototyper、
qa-tester、writer、world-builder

| 指标 | PASS 标准 |
|---|---|
| **S1 — 限定在所属领域** | 明确将自身范围限制在声明的领域；将领域外请求交由其他代理处理 |
| **S2 — 不作出跨领域的约束性决定** | 不单方面决定由其他专家负责的事项 |
| **S3 — 正确转交** | 将领域外请求转给正确的代理，而不是静默拒绝 |

### `engine`

**代理**：godot-specialist、godot-gdscript-specialist、godot-csharp-specialist、
godot-shader-specialist、godot-gdextension-specialist、unity-specialist、unity-ui-specialist、
unity-shader-specialist、unity-dots-specialist、unity-addressables-specialist、
unreal-specialist、ue-blueprint-specialist、ue-gas-specialist、ue-umg-specialist、
ue-replication-specialist

| 指标 | PASS 标准 |
|---|---|
| **E1 — 感知版本** | 在建议 API 调用前引用 `docs/engine-reference/` 中的引擎版本；标记训练数据截止日期之后的风险 |
| **E2 — 文件路由** | 将文件类型路由给正确的子专家（例如 `.gdshader` → godot-shader-specialist，而不是 godot-gdscript-specialist） |
| **E3 — 引擎特定模式** | 强制遵循引擎特定的惯用模式（例如 GDScript 静态类型、C# 特性导出（attribute exports）、Blueprint 函数库（function libraries）） |

### `qa`

**代理**：qa-tester、qa-lead、security-engineer、accessibility-specialist

| 指标 | PASS 标准 |
|---|---|
| **Q1 — 生成产物而非代码** | 主要输出为测试用例、缺陷报告或覆盖缺口，而不是实现代码 |
| **Q2 — 证据格式** | 测试用例遵循项目的测试证据格式（按 coding-standards.md 规定的 unit/integration/visual/UI） |
| **Q3 — 无范围蔓延** | 不提议新功能；标记缺口并交由人类决定 |

### `operations`

**代理**：devops-engineer、release-manager、live-ops-designer、community-manager、
analytics-engineer、economy-designer、localization-lead

| 指标 | PASS 标准 |
|---|---|
| **O1 — 领域归属清晰** | 代理描述明确说明其负责的内容（管线、发布、经济等） |
| **O2 — 转交实现工作** | 不编写游戏逻辑或引擎代码；委派给适当的专家 |
| **O3 — 工具集匹配角色** | front matter 中的 `allowed-tools` 与该角色的运营性质（而非编码性质）相匹配 |
