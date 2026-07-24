---
name: gate-check
description: "验证项目是否准备好进入下一个开发阶段。输出包含具体阻塞项和所需工件的 PASS/CONCERNS/FAIL 判定。当用户询问“是否已准备好进入 X”“能否进入 Production”“能否开始下一阶段”或“通过阶段门”时使用。"
argument-hint: "[target-phase: systems-design | technical-setup | pre-production | production | polish | release] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: opus
---

# 阶段门验证

此技能验证项目是否准备好进入下一个开发阶段，包括所需工件、质量标准和阻塞项。

**不同于 `/project-stage-detect`**：后者是诊断性的（“我们现在在哪里？”）；本技能是规范性的（“我们是否准备好推进？”并给出正式判定）。

## 生产阶段（7 个）

项目按以下阶段推进：

1. **Concept** — 构思、游戏概念文档
2. **Systems Design** — 系统映射、编写 GDD
3. **Technical Setup** — 引擎配置、架构决策
4. **Pre-Production** — 原型制作、垂直切片验证
5. **Production** — 功能开发（Epic/Feature/Task 跟踪已启用）
6. **Polish** — 性能优化、试玩、修复缺陷
7. **Release** — 发布准备、认证

**门通过时**，将新阶段名称写入 `production/stage.txt`（单行，例如 `Production`），以立即更新状态行。

---

## 1. 解析参数

**目标阶段：** `$ARGUMENTS[0]`（为空时自动检测当前阶段，再验证下一次转换）。

同时解析评审模式（本次所有门检查子代理使用同一模式）：
1. 如果传入了 `--review [full|lean|solo]`，使用该值
2. 否则读取 `production/review-mode.txt`，使用其中的值
3. 否则默认使用 `lean`

注意：在 `solo` 模式下跳过主管子代理派生（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE），gate-check 仅检查工件是否存在。在 `lean` 模式下四位主管仍会运行，因为阶段门正是该模式的用途。

- **有参数**：`/gate-check production` — 验证进入指定阶段的准备情况
- **无参数**：使用与 `/project-stage-detect` 相同的启发式方法自动检测当前阶段，然后**必须先向用户确认**：

  使用 `AskUserQuestion`：
  - 提示："检测到的阶段：**[current stage]**。即将运行 [Current] → [Next] 转换门检查。是否正确？"
  - 选项：
    - `[A] 是——运行此门检查`
    - `[B] 否——选择其他门检查`（若选中，显示列出所有门选项的第二个组件：Concept → Systems Design、Systems Design → Technical Setup、Technical Setup → Pre-Production、Pre-Production → Production、Production → Polish、Polish → Release）

  未提供参数时不得跳过此确认步骤。

---

## 2. 阶段门定义

### 阶段门：Concept → Systems Design

**所需工件：**
- [ ] `design/gdd/game-concept.md` 存在且有内容
- [ ] 已定义游戏支柱（在概念文档中或 `design/gdd/game-pillars.md` 中）
- [ ] `design/gdd/game-concept.md` 存在 Visual Identity Anchor 章节（来自 `/brainstorm` 第 4 阶段的 `art-director` 输出）

**建议项（不阻塞）：**
- [ ] `prototypes/` 中存在概念原型，并有显示 PROCEED 判定的 `REPORT.md`（`/prototype [core-mechanic]`）。跳过此项意味着可能在一个尚未实际试玩的想法上编写 GDD；若概念已通过其他方式验证则可接受。

**质量检查：**
- [ ] 游戏概念已评审（`/design-review` 判定不是 MAJOR REVISION NEEDED）
- [ ] 核心循环已描述且得到理解
- [ ] 已确定目标受众
- [ ] Visual Identity Anchor 包含一条视觉规则和至少 2 条支持性视觉原则

---

### 阶段门：Systems Design → Technical Setup

**所需工件：**
- [ ] `design/gdd/systems-index.md` 存在，至少列出 MVP 系统
- [ ] `design/gdd/` 中存在所有 MVP 层级的 GDD，且每份单独通过 `/design-review`
- [ ] `design/gdd/` 中存在跨 GDD 评审报告（来自 `/review-all-gdds`）

**质量检查：**
- [ ] 所有 MVP GDD 通过单独设计评审（8 个必需章节，且判定不是 MAJOR REVISION NEEDED）
- [ ] `/review-all-gdds` 判定不是 FAIL（跨 GDD 一致性和设计理论检查通过）
- [ ] `/review-all-gdds` 标记的所有跨 GDD 一致性问题已解决或明确接受
- [ ] 系统依赖已映射到系统索引，且双向一致
- [ ] 已定义 MVP 优先级层级
- [ ] 没有标记为过时的 GDD 引用（较旧 GDD 已反映后续 GDD 作出的决定）

---

### 阶段门：Technical Setup → Pre-Production

**所需工件：**
- [ ] 已选择引擎（`CLAUDE.md` 的 Technology Stack 不是 `[CHOOSE]`）
- [ ] 已配置技术偏好（`.claude/docs/technical-preferences.md` 已填充）
- [ ] `design/art/art-bible.md` 中存在美术圣经，且至少包含第 1–4 节（视觉识别基础）
- [ ] `docs/architecture/` 中至少有 3 条覆盖 Foundation 层系统的架构决策记录（场景管理、事件架构、存档/读档）
- [ ] `docs/engine-reference/[engine]/` 中存在引擎参考文档
- [ ] 已初始化测试框架：存在 `tests/unit/` 和 `tests/integration/` 目录
- [ ] `.github/workflows/tests.yml`（或等效文件）中存在 CI/CD 测试工作流
- [ ] 至少存在一个示例测试文件，以确认框架可用
- [ ] `docs/architecture/architecture.md` 中存在主架构文档
- [ ] `docs/architecture/requirements-traceability.md` 中存在架构追踪索引
- [ ] 已运行 `/architecture-review`（`docs/architecture/` 中存在评审报告文件）
- [ ] 存在 `design/accessibility-requirements.md`，且无障碍层级已确定
- [ ] 存在 `design/ux/interaction-patterns.md`（模式库已初始化，即使内容很少）

**质量检查：**
- [ ] 架构决策覆盖核心系统（渲染、输入、状态管理）
- [ ] 技术偏好已设置命名约定和性能预算
- [ ] 已定义并记录无障碍层级（即使是 Basic 也可以，但不能未定义）
- [ ] 至少开始编写一个屏幕的 UX 规格（通常在 Technical Setup 期间设计主菜单或核心 HUD）
- [ ] 所有 ADR 都有 **Engine Compatibility** 章节，并标注引擎版本
- [ ] 所有 ADR 都有 **GDD Requirements Addressed** 章节，并明确关联 GDD
- [ ] 没有 ADR 引用 `docs/engine-reference/[engine]/deprecated-apis.md` 中列出的 API
- [ ] `VERSION.md` 所列的所有 HIGH RISK 引擎领域都已在架构文档中明确处理，或标记为开放问题
- [ ] 架构追踪矩阵没有 Foundation 层缺口（进入 Pre-Production 前，所有 Foundation 需求都必须有 ADR 覆盖）

**ADR 循环依赖检查**：读取 `docs/architecture/` 中每个 ADR 的 “ADR Dependencies” / “Depends On” 部分，构建依赖图（ADR-A → ADR-B 表示 A 依赖 B）。若检测到环（例如 A→B→A 或 A→B→C→A）：
- 标记为 **FAIL**："ADR 循环依赖：[ADR-X] → [ADR-Y] → [ADR-X]。只要循环存在，两者都无法达到 Accepted 状态。请删除一条 'Depends On' 边以打破循环。"

**引擎验证**（先读取 `docs/engine-reference/[engine]/VERSION.md`）：
- [ ] 涉及知识截止日期后引擎 API 的 ADR 已标记 `Knowledge Risk: HIGH/MEDIUM`
- [ ] `/architecture-review` 引擎审计显示没有废弃 API 使用
- [ ] 所有 ADR 使用同一引擎版本（没有过时的版本引用）

---

### 阶段门：Pre-Production → Production

**所需工件：**
- [ ] `prototypes/` 中存在带 `REPORT.md` 的垂直切片（运行 `/vertical-slice`）——**建议项，不阻塞**；缺失时标记为 CONCERNS
- [ ] `production/sprints/` 中存在第一份迭代计划
- [ ] 美术圣经已完成（全部 9 个章节），且 AD-ART-BIBLE 签署判定已记录在 `design/art/art-bible.md`
- [ ] `design/assets/entity-inventory.md` 中存在实体清单（建议运行不带参数的 `/asset-spec`，根据 GDD + 美术圣经协作生成）
- [ ] 系统索引中的所有 MVP 层级 GDD 已完成
- [ ] `docs/architecture/architecture.md` 中存在主架构文档
- [ ] `docs/architecture/` 中存在至少 3 条覆盖 Foundation 层决策的 ADR
- [ ] 所有 Foundation 和 Core 层 ADR 的状态为 `Accepted`（不是 `Proposed`）——在其主管 ADR 被接受前，故事不能解除阻塞
- [ ] `docs/architecture/control-manifest.md` 中存在控制清单（由 `/create-control-manifest` 根据 Accepted ADR 生成）
- [ ] `production/epics/` 中已定义史诗，且至少存在 Foundation 和 Core 层史诗（使用 `/create-epics layer: foundation` 和 `/create-epics layer: core`，再对每个史诗使用 `/create-stories [epic-slug]`）
- [ ] 垂直切片构建存在且可玩（不只是定义了范围）——**建议项，不阻塞**；缺失时标记为 CONCERNS
- [ ] 垂直切片至少完成 1 次有记录的试玩——**建议项，不阻塞**；缺失时标记为 CONCERNS
- [ ] 垂直切片试玩报告存在于 `production/playtests/` 或等效位置——**建议项，不阻塞**；缺失时标记为 CONCERNS
- [ ] 关键屏幕存在 UX 规格：主菜单、核心玩法 HUD（位于 `design/ux/`）、暂停菜单
- [ ] 若游戏有游戏内 HUD，存在 `design/ux/hud.md` 文档
- [ ] 所有关键屏幕 UX 规格已通过 `/ux-review`（判定为 APPROVED，或 NEEDS REVISION 已被接受）

**质量检查：**
- [ ] **核心循环的乐趣已验证**——试玩数据确认核心机制令人享受，而不仅是功能可用；明确检查垂直切片试玩报告
- [ ] UX 规格覆盖 MVP 层级 GDD 的全部 UI Requirements 章节
- [ ] 交互模式库记录关键屏幕使用的模式
- [ ] `design/accessibility-requirements.md` 中的无障碍层级已在所有关键屏幕 UX 规格中处理
- [ ] 迭代计划引用 `production/epics/` 中真实的故事文件路径（而不只是 GDD；故事必须嵌入 GDD 需求 ID 和 ADR 引用）
- [ ] **垂直切片已完成**，而不仅是定义范围——构建端到端展示完整核心循环，至少有一个完整的 [开始 → 挑战 → 解决] 循环可运行
- [ ] Foundation 或 Core 层中没有未解决的架构开放问题
- [ ] 所有 ADR 的 Engine Compatibility 章节都标注了引擎版本
- [ ] 所有 ADR 都有 ADR Dependencies 章节（即使所有字段均为 "None"）
- [ ] 手动验证 GDD、架构和史诗一致（若近期未运行，运行 `/review-all-gdds` 和 `/architecture-review`）
- [ ] **核心幻想已交付**——至少一名试玩者在未受提示的情况下，独立描述了符合核心系统 GDD Player Fantasy 章节的体验

**垂直切片验证**（仅当构建了垂直切片时运行）：
- [ ] 人类玩家在没有开发者指导的情况下完成核心循环
- [ ] 游戏在开始游玩后的前 2 分钟内传达了玩家要做什么
- [ ] 垂直切片构建没有关键的“乐趣阻塞”缺陷
- [ ] 核心机制交互手感良好（主观检查——询问用户）

> **垂直切片判定规则：**
> - **已构建切片，且任一验证项为 NO** → 判定自动为 FAIL。损坏或无趣的垂直切片不应进入 Production。
> - **未构建切片（已跳过）** → 仅降级为 CONCERNS，不是 FAIL。明确说明风险："在未经验证的垂直切片情况下推进，会增加后期调整设计方向的风险。建议在投入完整制作范围前完成验证。" 由用户决定。
> - 对独立开发者或时间受限的情况，跳过是有效选择；发布损坏的版本不是。

---

### 阶段门：Production → Polish

**所需工件：**
- [ ] `src/` 中有按子系统组织的有效代码
- [ ] GDD 中所有核心机制均已实现（将 `design/gdd/` 与 `src/` 交叉比对）
- [ ] 主要玩法路径可端到端游玩
- [ ] `tests/unit/` 和 `tests/integration/` 中存在覆盖 Logic 和 Integration 故事的测试文件
- [ ] 本迭代所有 Logic 故事在 `tests/unit/` 中都有对应的单元测试文件
- [ ] 已完成冒烟检查，判定为 PASS 或 PASS WITH WARNINGS，报告存在于 `production/qa/`
- [ ] `production/qa/` 中存在 QA 计划（由 `/qa-plan` 生成），覆盖本迭代或最终 Production 迭代
- [ ] `production/qa/` 中至少存在一个覆盖本 Production 阶段的 QA 计划——缺失时运行 `/qa-plan`（CONCERNS——建议项，不阻塞）
- [ ] `production/qa/` 中存在 QA 签署报告（由 `/team-qa` 生成），判定为 APPROVED 或 APPROVED WITH CONDITIONS
- [ ] `production/playtests/` 中记录至少 3 次不同的试玩会话
- [ ] 试玩报告覆盖：新玩家体验、游戏中期系统和难度曲线
- [ ] 游戏概念中的乐趣假设已明确验证或修订

**质量检查：**
- [ ] 测试通过（通过 Bash 运行测试套件）
- [ ] 缺陷跟踪器或已知问题中没有 critical/blocker 缺陷
- [ ] 核心循环按设计运行（对照 GDD 验收标准）
- [ ] 性能在预算内（检查 `technical-preferences.md` 中的目标）
- [ ] 试玩发现已评审，关键乐趣问题已解决（不只是记录）
- [ ] 没有“困惑循环”——游戏中没有超过 50% 的试玩者卡住且不知道原因的点
- [ ] 难度曲线符合难度曲线设计文档（若 `design/difficulty-curve.md` 存在）
- [ ] 所有已实现屏幕都有对应 UX 规格（没有“直接在代码中设计”的屏幕）
- [ ] 交互模式库已更新，包含实现中使用的所有模式
- [ ] 已根据 `design/accessibility-requirements.md` 中确定的层级验证无障碍合规性

---

### 阶段门：Polish → Release

**所需工件：**
- [ ] 里程碑计划中的所有功能已实现
- [ ] 内容完整（设计文档引用的所有关卡、资产、对话均存在）
- [ ] 本地化字符串已外置（`src/` 中没有硬编码的玩家可见文本）
- [ ] 存在 QA 测试计划（`/qa-plan` 在 `production/qa/` 中的输出）
- [ ] 存在 QA 签署报告（`/team-qa` 输出——APPROVED 或 APPROVED WITH CONDITIONS）
- [ ] 所有 Must Have 故事的测试证据都存在（Logic/Integration：测试文件通过；Visual/Feel/UI：`production/qa/evidence/` 中有签署文档）
- [ ] 发布候选构建的冒烟检查无误通过（PASS 判定）
- [ ] 没有上一迭代的测试回归（测试套件完整通过）
- [ ] 平衡性数据已评审（已运行 `/balance-check`）
- [ ] 发布检查清单已完成（已运行 `/release-checklist` 或 `/launch-checklist`）
- [ ] 已准备商店元数据（如适用）
- [ ] 已起草变更日志/补丁说明

**质量检查：**
- [ ] `qa-lead` 已签署完整 QA 通过报告
- [ ] 所有测试通过
- [ ] 所有目标平台均达到性能目标
- [ ] 没有已知的 critical、high 或 medium 严重度缺陷
- [ ] 已覆盖无障碍基础项（重映射、文本缩放，如适用）
- [ ] 所有目标语言均已验证本地化
- [ ] 已满足法律要求（EULA、隐私政策、年龄分级，如适用）
- [ ] 构建无误编译并打包

---

## 3. 运行门检查

**运行工件检查前**，如果存在则读取 `docs/consistency-failures.md`。提取领域与目标阶段匹配的条目（例如检查 Systems Design → Technical Setup 时，读取 Economy、Combat 或任意 GDD 领域；检查 Technical Setup → Pre-Production 时，读取 Architecture、Engine）。将其作为上下文；目标领域中反复出现的冲突模式应提高对相关检查的审查力度。

对目标门中的每一项：

### 工件检查
- 使用 `Glob` 和 `Read` 验证文件存在且有有效内容
- 不要只检查存在性——确认文件含有真实内容，而不是只有模板标题
- 对代码检查，验证目录结构和文件数量

**Systems Design → Technical Setup 阶段门——跨 GDD 评审检查**：
使用 `Glob('design/gdd/gdd-cross-review-*.md')` 查找 `/review-all-gdds` 报告。
若没有匹配文件，将“存在跨 GDD 评审报告”工件标记为 **FAIL**，并突出显示："在 `design/gdd/` 中未找到 `/review-all-gdds` 报告。进入 Technical Setup 前请先运行 `/review-all-gdds`。"
若找到文件，读取并检查判定行：FAIL 判定表示跨 GDD 一致性检查失败，进入下一阶段前必须解决。

### 质量检查
- 对测试检查：如果配置了测试运行器，通过 `Bash` 运行测试套件
- 对设计评审检查：读取 GDD 并检查 8 个必需章节
- 对性能检查：读取 `technical-preferences.md`，与 `tests/performance/` 中的性能分析数据或最近的 `/perf-profile` 输出对比
- 对本地化检查：在 `src/` 中用 `Grep` 查找硬编码字符串

### 交叉引用检查
- 将 `design/gdd/` 文档与 `src/` 实现对比
- 检查架构文档引用的每个系统都有对应代码
- 验证迭代计划引用真实工作项

---

## 4. 协作评估

对于无法自动验证的项目，**询问用户**：

- "我无法自动验证核心循环是否体验良好。是否进行过试玩？"
- "未找到试玩报告。是否进行过非正式测试？"
- "没有可用的性能分析数据。是否要运行 `/perf-profile`？"

**永远不要**对无法验证的项目假定 PASS。标记为 MANUAL CHECK NEEDED。

---

## 4b. 主管评审组评估

**生成任何主管前应用评审模式：**
- `solo` → 跳过全部四位主管。输出中注明："已跳过主管评审组——Solo 模式。阶段门判定仅依据工件和质量检查。" 然后进入第 5 阶段。
- `lean` → 生成全部四位主管（阶段门始终在 lean 模式下运行——这正是其用途）。
- `full` → 正常生成全部四位主管。

（评审模式已在第 1 阶段解析。此处使用已保存的值。）

生成最终判定前，按照 `.claude/docs/director-gates.md` 中的并行阶段门协议，使用 Task 将四位主管作为**并行子代理**生成。必须同时发起四个 Task 调用，不要等待其中一个完成后再启动下一个。

**并行生成：**

1. **`creative-director`** — 阶段门 **CD-PHASE-GATE**（`.claude/docs/director-gates.md`）
2. **`technical-director`** — 阶段门 **TD-PHASE-GATE**（`.claude/docs/director-gates.md`）
3. **`producer`** — 阶段门 **PR-PHASE-GATE**（`.claude/docs/director-gates.md`）
4. **`art-director`** — 阶段门 **AD-PHASE-GATE**（`.claude/docs/director-gates.md`）

传给每位主管：目标阶段名称、已存在工件列表，以及该阶段门定义中列出的上下文字段。

**收集四个响应，然后呈现主管评审组摘要：**

```
## 主管评审组评估

创意总监： [READY / CONCERNS / NOT READY]
  [反馈]

技术总监： [READY / CONCERNS / NOT READY]
  [反馈]

制作人：   [READY / CONCERNS / NOT READY]
  [反馈]

美术总监： [READY / CONCERNS / NOT READY]
  [反馈]
```

**应用到判定：**
- 任意主管返回 NOT READY → 判定最低为 FAIL（用户可以通过明确确认覆盖）
- 任意主管返回 CONCERNS → 判定最低为 CONCERNS
- 四位均 READY → 有资格判定 PASS（仍须满足第 3 节的工件和质量检查）

---

## 5. 输出判定

```
## 阶段门检查：[Current Phase] → [Target Phase]

**日期**：[date]
**检查者**：gate-check 技能

### 所需工件：[X/Y 个存在]
- [x] design/gdd/game-concept.md — 存在，2.4KB
- [ ] docs/architecture/ — 缺失（未找到 ADR）
- [x] production/sprints/ — 存在，1 份迭代计划

### 质量检查：[X/Y 项通过]
- [x] GDD 包含全部 8/8 个必需章节
- [ ] 测试——失败（tests/unit/ 中有 3 个失败项）
- [?] 核心循环已试玩——MANUAL CHECK NEEDED

### 阻塞项
1. **没有架构决策记录**——进入 Production 前，运行 `/architecture-decision` 创建一条覆盖核心系统架构的记录。
2. **3 个测试失败**——推进前修复 `tests/unit/` 中失败的测试。

### 建议
- [解决阻塞项的优先行动]
- [不构成阻塞的可选改进]

### Verdict: [PASS / CONCERNS / FAIL]
- **PASS**：所有必需工件均存在，所有质量检查均通过
- **CONCERNS**：存在少量缺口，但可在下一阶段处理
- **FAIL**：推进前必须解决关键阻塞项
```

---

## 5a. 验证链

在第 5 阶段起草判定后，最终确定前必须质疑该判定。

**第 1 步——生成 5 个质疑问题**：生成 5 个旨在推翻判定的问题：

> **工具操作要求**：以下 5 个质疑问题中至少 2 个必须通过重新读取指定文件（Read 工具）或重新运行指定检查（Grep 工具）回答，不能只靠反思。用 [TOOL ACTION] 标记实际使用了工具的问题。

对于 **PASS** 草稿：
- "哪些质量检查是我实际读取文件后验证的，哪些只是推断为通过？"
- "是否有未经用户确认就被我标记为 PASS 的 MANUAL CHECK NEEDED 项？[TOOL ACTION] 重新扫描检查清单，查找所有 [?] 或 MANUAL CHECK 项。"
- "我是否确认了所有列出的工件都有真实内容，而不只是空标题？[TOOL ACTION] 重新读取文件，检查其中包含非占位内容。"
- "是否有被我视为次要的阻塞项，实际上会妨碍该阶段成功？"
- "我最没有把握的是哪一项检查？为什么？"

对于 **CONCERNS** 草稿：
- "考虑项目当前状态，是否有列出的 CONCERN 应升级为阻塞项？"
- "该问题能否在下一阶段解决，还是会随时间累积？"
- "我是否为避免更严厉的判定，将某个 FAIL 条件弱化成了 CONCERN？"
- "是否有我未检查的工件可能暴露其他阻塞项？"
- "即使每项 CONCERN 单独看来都很轻微，它们合在一起是否会构成阻塞问题？"

对于 **FAIL** 草稿：
- "我是否准确区分了硬性阻塞项和强烈建议？"
- "是否有我评判过于宽松的 PASS 项？"
- "是否遗漏了用户应该知道的其他阻塞项？"
- "我能否给出达到 PASS 的最短路径——明确列出必须改变的 3 件事？"
- "该失败条件能否解决，还是表明存在更深层的设计问题？"

**第 2 步——独立回答每个问题**。不要引用判定草稿文本；重新检查具体文件或询问用户。

**第 3 步——按需修订：**
- 若答案发现遗漏的阻塞项 → 升级判定（PASS→CONCERNS 或 CONCERNS→FAIL）
- 若答案发现阻塞项被夸大 → 仅在引用具体证据时降级
- 若答案一致 → 确认判定不变

**第 4 步——在最终报告输出中注明验证结果：**
`Chain-of-Verification: 已检查 [N] 个问题——判定 [未变 | 从 X 修订为 Y]`

---

## 6. PASS 后更新阶段

当判定为 **PASS** 且用户确认要推进时：

1. 将新阶段名称写入 `production/stage.txt`（单行，无末尾换行符）
2. 这会立即更新所有后续会话的状态行

例如通过 "Pre-Production → Production" 阶段门：
```bash
echo -n "Production" > production/stage.txt
```

**写入前务必询问**："阶段门已通过。可以将 `production/stage.txt` 更新为 'Production' 吗？"

---

## 7. 结束时的后续步骤组件

在呈现判定且完成任何 `stage.txt` 更新后，使用 `AskUserQuestion` 以结构化后续步骤提示结束。

**根据刚运行的阶段门定制选项：**

对于 **systems-design PASS**：
```
阶段门已通过。下一步要做什么？
[A] 运行 /create-architecture——生成主架构蓝图和 ADR 工作计划（推荐的下一步）
[B] 先设计更多 GDD——所有 MVP 系统完成后再返回此处
[C] 本次会话到此结束
```

> **systems-design PASS 注意**：在编写任何 ADR 前，`/create-architecture` 是必需的下一步。它会生成主架构文档和待编写 ADR 的优先级计划。跳过这一步直接运行 `/architecture-decision`，等于没有蓝图就写 ADR，请自行承担风险。

对于 **technical-setup PASS**：
```
阶段门已通过。下一步要做什么？
[A] 运行 /create-control-manifest——根据 Accepted ADR 生成分层规则清单（先做这一步）
[B] 运行 /vertical-slice——构建垂直切片（编写史诗前先完成，优先验证乐趣）
[C] 先编写更多 ADR——运行 /architecture-decision [next-system]
[D] 本次会话到此结束
```

> **technical-setup PASS 注意**：Pre-Production 流程刻意先验证乐趣，再投入详细规划：
>
> 1. `/create-control-manifest` — 从 Accepted ADR 提取技术规则（史诗前必需）
> 2. `/vertical-slice` — **首先**构建垂直切片，再编写史诗或故事
> 3. 试玩 → `/playtest-report` — 至少 1 次会话才能通过 Pre-Production 阶段门；在投入完整团队前建议进行 3 次以上
> 4. `/ux-design [screen]` — 主菜单、核心 HUD、暂停菜单的 UX 规格（如未完成）
> 5. `/create-epics layer:foundation`，然后 `/create-epics layer:core` — 验证乐趣后再规划
> 6. 对每个史诗运行 `/create-stories [epic-slug]`
> 7. `/sprint-plan new`
>
> **为什么要先做原型再做史诗？** 如果原型揭示核心循环需要改变，在发现之前编写的史诗会部分失效。先低成本验证乐趣，再详细规划。这是 GDC 项目复盘数据揭示的首要经验。

对于其他所有阶段门，提供该阶段最合理的两个后续步骤，以及“到此结束”。

---

## 8. 后续行动

根据判定建议具体后续步骤：

- **没有美术圣经？** → `/art-bible` 创建视觉识别规范
- **有美术圣经但没有资产规格？** → `/asset-spec system:[name]` 根据已批准的 GDD 生成逐资产视觉规格和生成提示词
- **没有游戏概念？** → `/brainstorm` 创建一个
- **没有系统索引？** → `/map-systems` 将概念分解为系统
- **缺少设计文档？** → `/reverse-document` 或委托给 `game-designer`
- **需要小型设计变更？** → `/quick-design` 处理少于约 4 小时的变更（绕过完整 GDD 流程）
- **没有 UX 规格？** → `/ux-design [screen name]` 编写规格，或 `/team-ui [feature]` 运行完整流程
- **UX 规格未经评审？** → `/ux-review [file]` 或 `/ux-review all` 验证
- **没有无障碍需求文档？** → 运行 `/ux-design`，一步创建 `design/accessibility-requirements.md` 和 `design/ux/interaction-patterns.md`
- **没有交互模式库？** → `/ux-design patterns` 初始化
- **GDD 未经交叉评审？** → `/review-all-gdds`（所有 MVP GDD 单独批准后运行）
- **存在跨 GDD 一致性问题？** → 修复标记的 GDD，然后重新运行 `/review-all-gdds`
- **没有测试框架？** → `/test-setup` 为引擎搭建框架
- **当前迭代没有 QA 计划？** → `/qa-plan sprint` 在实现开始前生成
- **缺少 ADR？** → `/architecture-decision` 处理单项决策
- **没有主架构文档？** → `/create-architecture` 生成完整蓝图
- **ADR 缺少 Engine Compatibility 章节？** → 重新运行 `/architecture-decision`，或手动为现有 ADR 添加 Engine Compatibility 章节
- **缺少控制清单？** → `/create-control-manifest`（需要 Accepted ADR）
- **缺少史诗？** → `/create-epics layer: foundation`，然后运行 `/create-epics layer: core`（需要控制清单）
- **某个史诗缺少故事？** → `/create-stories [epic-slug]`（每个史诗创建后运行）
- **故事尚未达到实现就绪状态？** → `/story-readiness` 在开发者接手前验证故事
- **测试失败？** → 委托给 `lead-programmer` 或 `qa-tester`
- **没有试玩数据？** → `/playtest-report`
- **除最低要求外没有更多试玩会话？** → 额外会话可提供更可靠的信号；在投入完整团队前建议总计进行 3 次以上。使用 `/playtest-report` 整理发现。
- **没有难度曲线文档？** → 根据 `.claude/docs/templates/difficulty-curve.md` 的模板创建 `design/difficulty-curve.md`，或使用 `/quick-design "difficulty curve"` 进行引导式会话
- **没有玩家旅程图？** → 根据 `.claude/docs/templates/player-journey.md` 的模板创建 `design/player-journey.md`，或使用 `/ux-design` 第 2b 阶段协作编写
- **需要快速检查迭代？** → `/sprint-status` 查看当前迭代进度快照
- **性能未知？** → `/perf-profile`
- **尚未本地化？** → `/localize`
- **准备发布？** → `/launch-checklist`

---

## 协作协议

此技能遵循协作设计原则：

1. **先扫描**：检查所有工件和质量门
2. **询问未知项**：无法验证的项目不要假定 PASS
3. **呈现发现**：显示包含状态的完整检查清单
4. **用户决定**：判定是建议，最终决定由用户作出
5. **获取批准**：“可以将此阶段门检查报告写入 `production/gate-checks/` 吗？”
6. **永不自动修复**：缺少必需工件时，报告 FAIL 判定并指出要运行的技能（例如“运行 `/test-setup`”）。不要创建缺失文件，也不要自动重新运行阶段门。制造 PASS 会违背阶段门的目的。

**永远不要**阻止用户推进——判定仅供参考。记录风险，让用户决定是否带着顾虑继续。
