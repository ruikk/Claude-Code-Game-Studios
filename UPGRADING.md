# 升级 Claude Code Game Studios

本指南说明如何将现有游戏项目仓库从模板的一个版本升级到下一版本。

**在 Git 日志中查找当前版本**：
```bash
git log --oneline | grep -i "release\|setup"
```
或者查看 `README.md` 中的版本徽章。

---

## 目录

- [升级策略](#升级策略)
- [v1.0.0-beta → v1.0](#v100-beta--v10)
- [v0.4.x → v1.0](#v04x--v10)
- [v0.4.0 → v0.4.1](#v040--v041)
- [v0.3.0 → v0.4.0](#v030--v040)
- [v0.2.0 → v0.3.0](#v020--v030)
- [v0.1.0 → v0.2.0](#v010--v020)

---

## 升级策略

有三种方式可以引入模板更新。请根据仓库的设置方式进行选择。

### 策略 A — Git 远程合并（推荐）

最适合：你克隆了模板，并在其基础上创建了自己的提交。

```bash
# Add the template as a remote (one-time setup)
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git

# Fetch the new version
git fetch template main

# Merge into your branch
git merge template/main --allow-unrelated-histories
```

Git 只会在模板和你都修改过的文件中标记冲突。逐一解决这些冲突：保留你的游戏内容，同时纳入结构改进。然后提交合并结果。

**提示：** 最可能发生冲突的文件是 `CLAUDE.md` 和
`.claude/docs/technical-preferences.md`，因为你已在其中填写引擎和项目设置。保留你的内容，并接受结构变更。

---

### 策略 B — Cherry-pick 特定提交

最适合：你只需要某项特定功能（例如只要新技能，而非完整更新）。

```bash
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git
git fetch template main

# Cherry-pick the specific commit(s) you want
git cherry-pick <commit-sha>
```

各版本的提交 SHA 列在下方对应的版本章节中。

---

### 策略 C — 手动复制文件

最适合：你没有使用 Git 设置模板（只是下载了 zip 压缩包）。

1. 在仓库旁边下载或克隆新版本。
2. 直接复制**“可安全覆盖”**下列出的文件。
3. 对于**“谨慎合并”**下的文件，并排打开两个版本，在保留你的内容的同时手动合并结构变更。

---

## v0.4.1

**发布日期：** 2026-04-02
**核心主题：** 美术指导集成、资产规格管线

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能** | `/art-bible` — 按章节引导编写视觉识别规范（9 个章节）。每个章节必须生成 art-director Task。设有 AD-ART-BIBLE 签核门禁。Technical Setup 阶段必需。 |
| **新技能** | `/asset-spec` — 为每项资产生成视觉规格和 AI 生成提示词。读取美术圣经及 GDD/关卡/角色文档。写入 `design/assets/specs/` 文件和 `design/assets/asset-manifest.md`。支持 Full/lean/solo 模式。 |
| **新增主管门禁（3 个）** | `AD-CONCEPT-VISUAL`（brainstorm Phase 4）、`AD-ART-BIBLE`（美术圣经签核）、`AD-PHASE-GATE`（gate-check 评审组） |
| **`/brainstorm` 更新** | 将 `Task` 添加到 allowed-tools（此前缺失，导致无法生成任何主管）。支柱锁定后，Art-director 现在与 creative-director 并行生成。Visual Identity Anchor 写入 game-concept.md。 |
| **`/gate-check` 更新** | 将 Art-director 添加为第 4 个并行主管（AD-PHASE-GATE）。视觉产物检查：Visual Identity Anchor（Concept 门禁）、美术圣经（Technical Setup 门禁）、AD-ART-BIBLE 签核及角色视觉档案（Pre-Production 门禁）。 |
| **`/team-level` 更新** | 将 Art-director 添加到 Step 1 并行生成流程（在布局前确定视觉方向）。Level-designer 现在会将 art-director 的目标作为明确约束接收。Step 4 中 art-director 的职责修正为仅负责 production-concepts。 |
| **`/team-narrative` 更新** | 将 Art-director 添加到 Phase 2 并行生成流程（角色视觉设计、环境叙事、电影化基调）。 |
| **`/design-system` 更新** | Combat、UI、Dialogue、Animation/VFX、Character 类别的路由表新增 art-director 和 technical-artist。7 个系统类别现在必须包含 Visual/Audio 章节（并生成 art-director Task）。 |
| **`workflow-catalog.yaml`** | 将 `/art-bible` 添加到 Technical Setup（必需）。将 `/asset-spec` 添加到 Pre-Production（可选、可重复）。 |

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/skills/art-bible/SKILL.md
.claude/skills/asset-spec/SKILL.md
.claude/docs/director-gates.md
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/team-level/SKILL.md
.claude/skills/team-narrative/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/docs/workflow-catalog.yaml
README.md
UPGRADING.md
```

### 文件：谨慎合并

无，所有变更都位于不含用户内容的基础设施文件中。

---

## v1.0.0-beta → v1.0

**发布日期：** 2026-05-13
**提交范围：** `49d1e45..HEAD`
**核心主题：** 新增 `/vertical-slice` 门禁、技能打磨与缺陷修复、贡献者文档

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能** | `/vertical-slice` — Pre-Production 门禁，在进入 Production 前通过生产质量的端到端构建验证完整游戏循环。与全面改造后的 `/prototype` 配套（紧接 `/brainstorm` 进行概念验证）。 |
| **新流程** | `/map-systems` 中的实体清单步骤，预先呈现所有命名实体，使后续 GDD 编写更清晰。 |
| **UX 打磨** | 为 7 个技能补充缺失的 `AskUserQuestion` 控件；全面审计技能的一致性、提示词和流程缺口；在所有 `team-*` 技能的 `argument-hints` 中公开 `--review` 标志。 |
| **缺陷修复** | `#21` log-agent 钩子将 `agent_type` 记录为 "unknown"；`#36` `/architecture-decision` 和 `/story-done` 缺少 `allowed-tools`；`#42` `rg --type gdscript` 无效（现使用 `--glob *.gd`）；`#43` session-start 预览显示最旧状态而非最新状态；`#45` `/architecture-decision` 中存在重复的 `## 0.` 标题和错误的步骤编号。 |
| **项目文档** | 新增 `CONTRIBUTING.md`（框架贡献指南）和 `SECURITY.md`（协调披露政策）。 |
| **计数/引用** | 同步 `WORKFLOW-GUIDE.md`、`README.md` 和代理名册中的代理/技能/钩子数量；修复过时的代理名和技能模型层级字段。 |

---

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/skills/vertical-slice/SKILL.md
CONTRIBUTING.md
SECURITY.md
```

**要覆盖的现有文件（不含用户内容）：**
- 提交范围内修改过的所有 `.claude/skills/` 下文件（技能审计 + AskUserQuestion 控件 + `--review` argument-hints）
- `.claude/hooks/log-agent.sh`（修复 #21）
- `README.md`, `docs/WORKFLOW-GUIDE.md`, `docs/examples/skill-flow-diagrams.md`
- `UPGRADING.md`

---

### 文件：谨慎合并

无，所有变更都位于不含用户内容的基础设施文件中。

---

## v0.4.x → v1.0

**发布日期：** 2026-03-29
**提交范围：** `6c041ac..HEAD`
**核心主题：** 主管门禁系统、门禁强度模式、Godot C# 专家

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新系统** | 主管门禁，共享于所有工作流技能的命名评审检查点。定义于 `.claude/docs/director-gates.md` |
| **新功能** | 门禁强度模式：`full`（所有主管门禁）、`lean`（仅阶段门禁）、`solo`（无主管）。在 `/start` 期间通过 `production/review-mode.txt` 全局设置，或在任何使用门禁的技能上用 `--review [mode]` 覆盖单次运行设置 |
| **新代理** | `godot-csharp-specialist` — 负责 Godot 4 项目中的 C# 代码质量 |
| **技能更新（13 个）** | 所有使用门禁的技能现在都会解析 `--review [full\|lean\|solo]`，并将其加入 argument-hint：`brainstorm`、`map-systems`、`design-system`、`architecture-decision`、`create-architecture`、`create-epics`、`create-stories`、`sprint-plan`、`milestone-review`、`playtest-report`、`prototype`、`story-done`、`gate-check` |
| **`/start` 更新** | 新增 Phase 3b，在引导期间设置评审模式并写入 `production/review-mode.txt` |
| **`/setup-engine` 更新** | 新增 Godot 语言选择步骤（GDScript 或 C#） |
| **文档** | `director-gates.md` — 完整门禁目录；`WORKFLOW-GUIDE.md` — Director Review Modes 章节；`README.md` — 评审强度自定义说明 |

---

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/agents/godot-csharp-specialist.md
.claude/docs/director-gates.md
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/map-systems/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/skills/architecture-decision/SKILL.md
.claude/skills/create-architecture/SKILL.md
.claude/skills/create-epics/SKILL.md
.claude/skills/create-stories/SKILL.md
.claude/skills/sprint-plan/SKILL.md
.claude/skills/milestone-review/SKILL.md
.claude/skills/playtest-report/SKILL.md
.claude/skills/prototype/SKILL.md
.claude/skills/story-done/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/start/SKILL.md
.claude/skills/quick-design/SKILL.md
.claude/skills/setup-engine/SKILL.md
README.md
docs/WORKFLOW-GUIDE.md
UPGRADING.md
```

---

### 文件：谨慎合并

此版本没有需要手动合并的文件。所有变更都位于不含用户内容的基础设施文件中。

---

### 新功能

#### 主管门禁系统

现在，所有主要工作流技能都会引用 `.claude/docs/director-gates.md` 中定义的命名门禁检查点。门禁通过领域前缀和名称标识（例如 `CD-CONCEPT`、`TD-ARCHITECTURE`、`LP-CODE-REVIEW`）。每个门禁都定义了要生成的主管、要传入的输入、裁决的含义，以及 lean/solo 模式对它的影响。

技能使用 `Task` 以及门禁 ID 和已记录的输入来生成门禁，而不是内嵌主管提示词。这样既能保持技能主体整洁，也能确保所有工作流阶段的门禁行为一致。

#### 门禁强度模式

三种模式可控制主管评审的强度：

- **`full`**（默认）— 在每个评审检查点运行所有主管门禁
- **`lean`** — 跳过各技能的主管评审；仍运行 `/gate-check` 中的阶段门禁
- **`solo`** — 任何位置都不运行主管门禁；`/gate-check` 仅检查产物是否存在

在 `/start` 期间进行全局设置（写入 `production/review-mode.txt`）。可在任何使用门禁的技能上通过 `--review [mode]` 覆盖单次运行设置：

```
/design-system combat --review lean
/gate-check concept --review full
/brainstorm my-game-idea --review solo
```

---

### 升级后

1. 运行一次 `/start` 以设置首选评审模式，或者手动创建 `production/review-mode.txt` 并写入 `full`、`lean` 或 `solo`。
2. 如果项目正在进行中，请查看 `.claude/docs/director-gates.md`，了解哪些门禁适用于当前阶段。
3. 运行 `/skill-test static all`，验证所有技能都通过结构检查。

---

## v0.4.0 → v0.4.1

**发布日期：** 2026-03-26
**提交范围：** `04ed5d5..HEAD`
**核心主题：** 不限定类型的代理、新技能、技能修复

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能（1 个）** | `/consistency-check` — 跨 GDD 实体一致性扫描器 |
| **技能修复（所有 team-*）** | 新增无参数防护、正式的 `Verdict: COMPLETE / BLOCKED` 关键字、每步骤 AskUserQuestion 门禁、相邻区域依赖检查（team-level）、道德规范强制执行（team-live-ops）、带 Phase 跳过的 NO-GO 路径（team-release） |
| **代理修复（4 个）** | game-designer、systems-designer、economy-designer、live-ops-designer 改用不限定游戏类型的表述，移除 RPG 专用术语 |

---

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/skills/consistency-check/SKILL.md
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/team-combat/SKILL.md      ← no-arg guard, verdict keywords, gate improvements
.claude/skills/team-narrative/SKILL.md   ← no-arg guard, verdict keywords, gate improvements
.claude/skills/team-ui/SKILL.md          ← no-arg guard, verdict keywords, gate improvements
.claude/skills/team-release/SKILL.md     ← no-arg guard, verdict keywords, NO-GO path
.claude/skills/team-polish/SKILL.md      ← no-arg guard, verdict keywords, gate improvements
.claude/skills/team-audio/SKILL.md       ← no-arg guard, verdict keywords, gate improvements
.claude/skills/team-level/SKILL.md       ← no-arg guard, verdict keywords, adjacent area checks
.claude/skills/team-live-ops/SKILL.md    ← no-arg guard, verdict keywords, ethics enforcement
.claude/skills/team-qa/SKILL.md          ← no-arg guard, verdict keywords, gate improvements
.claude/skills/map-systems/SKILL.md      ← verdict keywords
.claude/skills/create-epics/SKILL.md     ← "May I write" protocol fix, verdict keywords
.claude/skills/create-stories/SKILL.md   ← verdict keywords
.claude/agents/game-designer.md          ← genre-agnostic language
.claude/agents/systems-designer.md       ← genre-agnostic language
.claude/agents/economy-designer.md       ← genre-agnostic language
.claude/agents/live-ops-designer.md      ← genre-agnostic language
```

---

### 文件：谨慎合并

此版本没有需要手动合并的文件。所有变更都位于不含用户内容的基础设施文件中。

---

### 升级后

1. 运行 `/skill-test catalog`，验证所有技能均已编入索引。
2. 修改任何技能后运行 `/skill-test lint [skill-name]`，检查结构合规性。
3. 如果你自定义过任何 team-* 技能，请检查更新后的版本。现在所有 team-* 技能都必须包含无参数防护和 `Verdict:` 关键字。

---

## v0.3.0 → v0.4.0

**发布日期：** 2026-03-21
**提交范围：** `b1cad29..HEAD`
**核心主题：** 完整 UX/UI 管线、完整故事生命周期、棕地项目接入、综合 QA/测试框架、管线完整性、29 个新技能

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能（17 个）** | `/ux-design`、`/ux-review`、`/help`、`/quick-design`、`/review-all-gdds`、`/story-readiness`、`/story-done`、`/sprint-status`、`/adopt`、`/create-architecture`、`/create-control-manifest`、`/create-epics`、`/create-stories`、`/dev-story`、`/propagate-design-change`、`/content-audit`、`/architecture-review` |
| **新增 QA 技能（12 个）** | `/qa-plan`、`/smoke-check`、`/soak-test`、`/regression-suite`、`/test-setup`、`/test-helpers`、`/test-evidence-review`、`/test-flakiness`、`/skill-test`、`/bug-triage`、`/team-live-ops`、`/team-qa` |
| **新钩子（4 个）** | `log-agent-stop.sh` — 记录代理停止事件的审计追踪；`notify.sh` — Windows 桌面通知；`post-compact.sh` — 压缩后的会话恢复提醒；`validate-skill-change.sh` — 技能修改后建议运行 `/skill-test` |
| **新模板（8 个）** | `ux-spec.md`、`hud-design.md`、`accessibility-requirements.md`、`interaction-pattern-library.md`、`player-journey.md`、`difficulty-curve.md`，以及 2 个接入计划模板 |
| **新基础设施** | `workflow-catalog.yaml`（7 阶段管线，由 `/help` 读取）、`docs/architecture/tr-registry.yaml`（稳定的 TR-IDs）、`production/sprint-status.yaml` 数据结构 |
| **技能更新** | `/gate-check` — 现在有 3 个门禁要求 UX 产物；Pre-Production 门禁要求垂直切片（HARD 门禁） |
| **技能更新** | `/sprint-plan` — 写入 `sprint-status.yaml`；`/sprint-status` 读取该文件 |
| **技能更新** | `/story-done` — 8 阶段完成审查，更新故事文件并呈现下一个就绪故事 |
| **技能更新** | `/design-review` — 移除架构缺口检查（所处阶段不正确） |
| **技能更新** | `/team-ui` — 完整 UX 管线（ux-design → ux-review → 团队阶段） |
| **代理更新** | 14 个专家代理，新增 `memory: project` |
| **代理更新** | `prototyper` — `isolation: worktree`（在隔离的 Git 分支中进行一次性工作） |
| **模型路由** | 协调规则中记录了 Haiku/Sonnet/Opus 层级分配；技能在前置元数据中声明自身层级 |
| **目录 CLAUDE.md** | 搭建 `design/CLAUDE.md`、`src/CLAUDE.md`、`docs/CLAUDE.md`，为每个目录提供路径范围内的指令 |
| **管线完整性** | TR-ID 稳定性、清单版本控制、ADR 状态门禁、引用而非摘录 TR-ID |
| **GDD 模板** | 新增 `## Game Feel` 章节（输入响应、动画目标、冲击时刻） |

---

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/skills/ux-design/SKILL.md
.claude/skills/ux-review/SKILL.md
.claude/skills/help/SKILL.md
.claude/skills/quick-design/SKILL.md
.claude/skills/review-all-gdds/SKILL.md
.claude/skills/story-readiness/SKILL.md
.claude/skills/story-done/SKILL.md
.claude/skills/sprint-status/SKILL.md
.claude/skills/adopt/SKILL.md
.claude/skills/create-architecture/SKILL.md
.claude/skills/create-control-manifest/SKILL.md
.claude/skills/create-epics/SKILL.md
.claude/skills/create-stories/SKILL.md
.claude/skills/dev-story/SKILL.md
.claude/skills/propagate-design-change/SKILL.md
.claude/skills/content-audit/SKILL.md
.claude/skills/architecture-review/SKILL.md
.claude/skills/qa-plan/SKILL.md
.claude/skills/smoke-check/SKILL.md
.claude/skills/soak-test/SKILL.md
.claude/skills/regression-suite/SKILL.md
.claude/skills/test-setup/SKILL.md
.claude/skills/test-helpers/SKILL.md
.claude/skills/test-evidence-review/SKILL.md
.claude/skills/test-flakiness/SKILL.md
.claude/skills/skill-test/SKILL.md
.claude/skills/bug-triage/SKILL.md
.claude/skills/team-live-ops/SKILL.md
.claude/skills/team-qa/SKILL.md
.claude/hooks/log-agent-stop.sh
.claude/hooks/notify.sh
.claude/hooks/post-compact.sh
.claude/hooks/validate-skill-change.sh
.claude/docs/workflow-catalog.yaml
.claude/docs/templates/ux-spec.md
.claude/docs/templates/hud-design.md
.claude/docs/templates/accessibility-requirements.md
.claude/docs/templates/interaction-pattern-library.md
.claude/docs/templates/player-journey.md
.claude/docs/templates/difficulty-curve.md
design/CLAUDE.md
src/CLAUDE.md
docs/CLAUDE.md
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/gate-check/SKILL.md
.claude/skills/sprint-plan/SKILL.md
.claude/skills/sprint-status/SKILL.md
.claude/skills/design-review/SKILL.md
.claude/skills/team-ui/SKILL.md
.claude/skills/story-readiness/SKILL.md
.claude/skills/story-done/SKILL.md
.claude/docs/templates/game-design-document.md    ← adds Game Feel section
README.md
docs/WORKFLOW-GUIDE.md
UPGRADING.md
```

**要覆盖的代理文件**（如果你没有在其中编写自定义提示词）：
```
.claude/agents/prototyper.md         ← adds isolation: worktree
.claude/agents/art-director.md       ← adds memory: project
.claude/agents/audio-director.md     ← adds memory: project
.claude/agents/economy-designer.md   ← adds memory: project
.claude/agents/game-designer.md      ← adds memory: project
.claude/agents/gameplay-programmer.md ← adds memory: project
.claude/agents/lead-programmer.md    ← adds memory: project
.claude/agents/level-designer.md     ← adds memory: project
.claude/agents/narrative-director.md ← adds memory: project
.claude/agents/systems-designer.md   ← adds memory: project
.claude/agents/technical-artist.md   ← adds memory: project
.claude/agents/ui-programmer.md      ← adds memory: project
.claude/agents/ux-designer.md        ← adds memory: project
.claude/agents/world-builder.md      ← adds memory: project
```

---

### 文件：谨慎合并

#### `.claude/settings.json`

此版本注册了四个新钩子。如果你没有自定义 `settings.json`，可以安全覆盖。否则，请手动添加以下钩子条目：

- `log-agent-stop.sh` — `SubagentStop` 事件（记录代理停止事件的审计追踪）
- `notify.sh` — `Notification` 事件（Windows 桌面通知）
- `post-compact.sh` — `PostCompact` 事件（会话恢复提醒）
- `validate-skill-change.sh` — `PostToolUse` 事件，筛选对 `.claude/skills/` 的写入

#### 自定义代理文件

如果你在代理 `.md` 文件中添加了项目专用知识，请进行差异比较，并在适当位置手动将 `memory: project` 行添加到 YAML frontmatter。创意主管和技术主管代理有意保留 `memory: user`，只有专家代理使用 `memory: project`。

---

### 新功能

#### 完整故事生命周期

现在由两个技能强制执行正式的故事生命周期：

- **`/story-readiness`** — 在开发者接手故事前验证其是否已准备好实施。检查 Design（已关联 GDD 需求）、Architecture（ADR 已接受）、Scope（标准可测试）和 DoD（清单版本为当前版本）。Verdict: READY / NEEDS WORK / BLOCKED。
- **`/story-done`** — 实施后的 8 阶段完成审查。验证每项验收标准，检查是否偏离 GDD/ADR，提示进行代码审查，将故事文件更新为 `Status: Complete`，并呈现下一个就绪故事。

流程：`/story-readiness` → 实施 → `/story-done` → 下一个故事

#### 完整 UX/UI 管线

- **`/ux-design`** — 按章节引导编写 UX 规格。三种模式：screen/flow、HUD 或 interaction pattern library。读取 GDD UI 需求和玩家旅程。输出到 `design/ux/`。
- **`/ux-review`** — 根据 GDD 一致性、无障碍层级和模式库验证 UX 规格。Verdict: APPROVED / NEEDS REVISION / MAJOR REVISION。
- **`/team-ui`** 已更新：Phase 1 现在会在视觉设计开始前将 `/ux-design` + `/ux-review` 作为硬门禁运行。

#### 棕地项目接入

**`/adopt`** 将现有项目接入模板格式。审计 GDD、ADR、故事、systems-index 和基础设施的内部结构。对缺口分类（BLOCKING/HIGH/MEDIUM/LOW），并构建有序迁移计划。绝不重新生成现有产物，只填补缺口。

参数模式：`full | gdds | adrs | stories | infra`

此外，`/design-system retrofit [path]` 和 `/architecture-decision retrofit [path]` 会检测现有文件，并且只添加缺失章节。

#### 迭代跟踪 YAML

`production/sprint-status.yaml` 现在是权威的故事跟踪格式：
- 由 `/sprint-plan`（初始化所有故事）和 `/story-done`（将状态设为 `done`）写入
- 由 `/sprint-status`（快速快照）和 `/help`（production 阶段中每个故事的状态）读取
- 状态值：`backlog | ready-for-dev | in-progress | review | done | blocked`
- 如果文件不存在，会平稳回退到 Markdown 扫描

#### `/help` — 感知上下文的下一步

`/help` 会读取当前阶段和进行中的工作，检查哪些产物已完成，并准确告知下一步操作：一个主要必需步骤，加上可选机会。它不同于 `/start`（仅首次使用）和 `/project-stage-detect`（全面审计）。

#### 综合 QA 和测试框架

九个新的 QA/测试技能覆盖完整测试生命周期：

- **`/test-setup`** — 为引擎搭建测试框架和 CI/CD 管线
- **`/test-helpers`** — 生成引擎专用的测试辅助库（GDUnit4、NUnit 等）
- **`/qa-plan`** — 为迭代或功能生成 QA 测试计划，并按测试类型对故事分类
- **`/smoke-check`** — 在移交 QA 前运行关键路径冒烟测试门禁
- **`/soak-test`** — 为长时间游玩生成浸泡测试协议（稳定性、内存泄漏）
- **`/regression-suite`** — 将测试覆盖率映射到 GDD 关键路径，识别缺少回归测试的已修复缺陷
- **`/test-evidence-review`** — 对测试文件和手动证据文档进行质量审查
- **`/test-flakiness`** — 通过读取 CI 运行日志检测非确定性测试
- **`/skill-test`** — 验证技能文件的结构合规性和行为正确性（三种模式：lint、spec、catalog）

另有新技能：**`/bug-triage`** 会重新评估所有未解决缺陷的优先级、严重程度和归属。

#### 技能验证器（`/skill-test`）

`/skill-test` 是用于验证工具框架本身的元技能。编辑任何技能文件后都应运行它。包含三种模式：
- `lint` — 验证 YAML frontmatter 和必需字段
- `spec [skill-name]` — 对特定技能运行行为规格测试
- `catalog` — 检查 `.claude/skills/` 中的所有技能是否都已编入目录索引

修改技能文件时，新的 `validate-skill-change.sh` 钩子会自动提醒你运行 `/skill-test`。

#### Team Live-Ops 和 Team QA 编排

- **`/team-live-ops`** — 协调 live-ops-designer + economy-designer + community-manager + analytics-engineer 规划发布后内容（赛季活动、战斗通行证、留存）
- **`/team-qa`** — 编排 qa-lead + qa-tester + gameplay-programmer + producer 完成完整 QA 周期：策略、执行、覆盖率和签核

#### 模型层级路由

现在会根据任务复杂度将技能明确分配到 Haiku、Sonnet 或 Opus 层级。只读状态检查使用 Haiku；复杂的多文档综合使用 Opus；其他任务默认使用 Sonnet。层级分配记录在 `.claude/docs/coordination-rules.md` 中。

#### 目录 CLAUDE.md 文件

三个新的目录范围 CLAUDE.md 文件（`design/`、`src/`、`docs/`）为在这些目录中工作的代理提供路径专用指令。当 Claude Code 读取对应目录中的文件时，这些指令会自动加载。

---

### 升级后

1. **验证新钩子**已注册到 `.claude/settings.json`，确认以下四个钩子全部存在：`log-agent-stop.sh`、`notify.sh`、`post-compact.sh`、`validate-skill-change.sh`。

2. **测试审计追踪**：生成任意子代理，启动和停止事件都应出现在 `production/session-logs/` 中。

3. 如果正处于活跃的 production 阶段，请**生成 sprint-status.yaml**：
   ```
   /sprint-plan status
   ```

4. 如果现有 GDD 或 ADR 早于此模板版本，请**运行 `/adopt`**。它会识别需要添加的章节，而不会覆盖你的内容。

5. 修改任何技能后，使用 `/skill-test` **验证技能**。新的 `validate-skill-change.sh` 钩子会自动提醒你执行此操作。

---

## v0.2.0 → v0.3.0

**发布日期：** 2026-03-09
**提交范围：** `e289ce9..HEAD`
**核心主题：** `/design-system` GDD 编写、`/map-systems` 重命名、自定义状态行

### 破坏性变更

#### `/design-systems` 重命名为 `/map-systems`

为使含义更清晰，`/design-systems` 技能已重命名为 `/map-systems`（分解即*映射*，而非*设计*）。

**必须执行：** 更新所有调用 `/design-systems` 的文档、笔记或脚本。新的调用方式为 `/map-systems`。

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能** | `/design-system`（按章节引导编写 GDD） |
| **重命名技能** | `/design-systems` → `/map-systems`（破坏性重命名） |
| **新文件** | `.claude/statusline.sh`、`.claude/settings.json` 状态行配置 |
| **技能更新** | `/gate-check` — 裁决为 PASS 时写入 `production/stage.txt`，新增阶段定义 |
| **技能更新** | `brainstorm`、`start`、`design-review`、`project-stage-detect`、`setup-engine` — 修复交叉引用 |
| **缺陷修复** | `log-agent.sh`、`validate-commit.sh` — 修复钩子执行 |
| **文档** | 新增 `UPGRADING.md`，更新 `README.md` 和 `WORKFLOW-GUIDE.md` |

---

### 文件：可安全覆盖

**要添加的新文件：**
```
.claude/skills/design-system/SKILL.md
.claude/statusline.sh
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/map-systems/SKILL.md      ← was design-systems/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/brainstorm/SKILL.md
.claude/skills/start/SKILL.md
.claude/skills/design-review/SKILL.md
.claude/skills/project-stage-detect/SKILL.md
.claude/skills/setup-engine/SKILL.md
.claude/hooks/log-agent.sh
.claude/hooks/validate-commit.sh
README.md
docs/WORKFLOW-GUIDE.md
UPGRADING.md
```

**删除（已被重命名后的内容替代）：**
```
.claude/skills/design-systems/   ← entire directory; replaced by map-systems/
```

---

### 文件：谨慎合并

#### `.claude/settings.json`

新版本添加了一个指向 `.claude/statusline.sh` 的 `statusLine` 配置块。如果你没有自定义 `settings.json`，可以安全覆盖。否则，请手动添加此配置块：

```json
"statusLine": {
  "script": ".claude/statusline.sh"
}
```

---

### 新功能

#### 自定义状态行

`.claude/statusline.sh` 会在终端状态行中显示 7 阶段 production 管线面包屑：

```
ctx: 42% | claude-sonnet-4-6 | Systems Design
```

在 Production/Polish/Release 阶段，如果存在 `<!-- STATUS -->` 块，它还会显示 `production/session-state/active.md` 中活跃的 Epic/Feature/Task：

```
ctx: 42% | claude-sonnet-4-6 | Production | Combat System > Melee Combat > Hitboxes
```

当前阶段会根据项目产物自动检测，也可以通过将阶段名称写入 `production/stage.txt` 来固定。

#### `/gate-check` 阶段推进

确认门禁裁决为 PASS 后，`/gate-check` 现在会将新阶段名称写入 `production/stage.txt`。这会立即更新以后所有会话的状态行，无需手动编辑文件。

---

### 升级后

1. **删除旧技能目录：**
   ```bash
   rm -rf .claude/skills/design-systems/
   ```

2. 启动一个 Claude Code 会话来**测试状态行**，终端底部应显示阶段面包屑。

3. **验证钩子执行**仍然正常：
   ```bash
   bash .claude/hooks/log-agent.sh '{}' '{}'
   bash .claude/hooks/validate-commit.sh '{}' '{}'
   ```

---

## v0.1.0 → v0.2.0

**发布日期：** 2026-02-21
**提交范围：** `ad540fe..e289ce9`
**核心主题：** 上下文韧性、AskUserQuestion 集成、`/map-systems` 技能

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新技能** | `/start`（引导）、`/map-systems`（系统分解）、`/design-system`（引导式 GDD 编写） |
| **新钩子** | `session-start.sh`（恢复）、`detect-gaps.sh`（缺口检测） |
| **新模板** | `systems-index.md`、3 个协作协议模板 |
| **上下文管理** | 大幅重写，新增基于文件持久化的状态策略 |
| **代理更新** | 14 个设计/创意代理，集成 AskUserQuestion |
| **技能更新** | 全部 7 个 `team-*` 技能及 `brainstorm`，在阶段转换时使用 AskUserQuestion |
| **CLAUDE.md** | 从约 159 行精简到约 60 行；文档导入从 10 个减至 5 个 |
| **钩子更新** | 全部 8 个钩子，修复 Windows 兼容性并新增功能 |
| **移除的文档** | `docs/IMPROVEMENTS-PROPOSAL.md`、`docs/MULTI-STAGE-DOCUMENT-WORKFLOW.md` |

---

### 文件：可安全覆盖

这些完全属于基础设施，你尚未自定义它们。直接复制新版本不会危及项目内容。

**要添加的新文件：**
```
.claude/skills/start/SKILL.md
.claude/skills/map-systems/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/docs/templates/systems-index.md
.claude/docs/templates/collaborative-protocols/design-agent-protocol.md
.claude/docs/templates/collaborative-protocols/implementation-agent-protocol.md
.claude/docs/templates/collaborative-protocols/leadership-agent-protocol.md
.claude/hooks/detect-gaps.sh
.claude/hooks/session-start.sh
production/session-state/.gitkeep
docs/examples/README.md
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/feature_request.md
.github/PULL_REQUEST_TEMPLATE.md
```

**要覆盖的现有文件（不含用户内容）：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/design-review/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/project-stage-detect/SKILL.md
.claude/skills/setup-engine/SKILL.md
.claude/skills/team-audio/SKILL.md
.claude/skills/team-combat/SKILL.md
.claude/skills/team-level/SKILL.md
.claude/skills/team-narrative/SKILL.md
.claude/skills/team-polish/SKILL.md
.claude/skills/team-release/SKILL.md
.claude/skills/team-ui/SKILL.md
.claude/hooks/log-agent.sh
.claude/hooks/pre-compact.sh
.claude/hooks/session-stop.sh
.claude/hooks/validate-assets.sh
.claude/hooks/validate-commit.sh
.claude/hooks/validate-push.sh
.claude/rules/design-docs.md
.claude/docs/hooks-reference.md
.claude/docs/skills-reference.md
.claude/docs/quick-start.md
.claude/docs/directory-structure.md
.claude/docs/context-management.md
docs/COLLABORATIVE-DESIGN-PRINCIPLE.md
docs/WORKFLOW-GUIDE.md
README.md
```

**要覆盖的代理文件**（如果你没有在其中编写自定义提示词）：
```
.claude/agents/art-director.md
.claude/agents/audio-director.md
.claude/agents/creative-director.md
.claude/agents/economy-designer.md
.claude/agents/game-designer.md
.claude/agents/level-designer.md
.claude/agents/live-ops-designer.md
.claude/agents/narrative-director.md
.claude/agents/producer.md
.claude/agents/systems-designer.md
.claude/agents/technical-director.md
.claude/agents/ux-designer.md
.claude/agents/world-builder.md
.claude/agents/writer.md
```

如果你*已经*自定义代理提示词，请参阅下方的“谨慎合并”。

---

### 文件：谨慎合并

这些文件同时包含模板结构和项目专用内容。**不要**覆盖它们，请手动合并变更。

#### `CLAUDE.md`

模板版本从约 159 行精简到约 60 行。关键结构变更是移除了 5 个文档导入，因为 Claude Code 本来就会自动加载它们（agent-roster、skills-reference、hooks-reference、rules-reference、review-workflow）。

**你的版本中需要保留的内容：**
- `## Technology Stack` 章节（你的引擎/语言选择）
- 你添加的任何项目专用内容

**需要从新版本采用的内容：**
- 更精简的导入列表（如果存在 5 个冗余的 `@` 导入，请将其删除）
- 更新后的协作协议表述

#### `.claude/docs/technical-preferences.md`

如果运行过 `/setup-engine`，此文件会包含你的引擎配置、命名约定和性能预算。请全部保留。模板版本只是空占位文件。

#### `.claude/docs/templates/game-concept.md`

有一项小型结构更新：新增指向 `/map-systems` 的 `## Next Steps` 章节。如果需要更新后的指导，可以将该章节添加到你的副本中，但这不是必需操作。

#### `.claude/settings.json`

检查新版本是否添加了你需要的权限规则。此次变更很小（schema 更新）。如果你没有自定义 `settings.json`，可以安全覆盖。

#### 自定义代理文件

如果你在任何代理 `.md` 文件中添加了项目专用知识或自定义行为，请进行差异比较并手动添加新的 AskUserQuestion 集成章节，而不是覆盖文件。每个代理的变更都是系统提示词末尾的标准化协作协议块。

---

### 文件：删除

这些文件已在 v0.2.0 中移除。如果仓库中仍有这些文件，可以安全删除，它们已有组织方式更好的替代内容。

```
docs/IMPROVEMENTS-PROPOSAL.md      → superseded by WORKFLOW-GUIDE.md
docs/MULTI-STAGE-DOCUMENT-WORKFLOW.md → content merged into context-management.md
```

---

### 升级后

1. **运行 `/project-stage-detect`**，验证系统能通过新的检测逻辑正确读取项目。

2. 如果尚未使用过，请运行一次 **`/start`**。它现在能正确识别你的阶段，并跳过已经完成的引导步骤。

3. **检查 `production/session-state/`** 是否存在且已被 Git 忽略：
   ```bash
   ls production/session-state/
   cat .gitignore | grep session-state
   ```

4. **测试钩子执行**。如果使用 Windows，请验证新钩子能在 Git Bash 中无错误运行：
   ```bash
   bash .claude/hooks/detect-gaps.sh '{}' '{}'
   bash .claude/hooks/session-start.sh '{}' '{}'
   ```

---

*未来每个版本都将在此文件中拥有独立章节。*
