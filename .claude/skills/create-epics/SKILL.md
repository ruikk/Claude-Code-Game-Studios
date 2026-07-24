---
name: create-epics
description: "将已批准的 GDD 和架构转换为史诗，每个架构模块对应一个史诗。定义范围、主管 ADR、引擎风险和未追踪需求。不拆分为故事；每个史诗创建后运行 /create-stories [epic-slug]。"
argument-hint: "[system-name | layer: foundation|core|feature|presentation | all] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
agent: technical-director
---

# 创建史诗

史诗是一个有名称且边界明确的工作单元，对应一个架构模块。它定义需要构建的
**内容**以及在架构上由**谁负责**。它不规定实现步骤；那是故事的职责。

**在开发接近某一层时，每层运行一次此技能**。Core 层接近完成前不要创建 Feature
层史诗，因为设计届时可能已经发生变化。

**输出：** `production/epics/[epic-slug]/EPIC.md` + `production/epics/index.md`

**每个史诗之后的下一步：** `/create-stories [epic-slug]`

**运行时机：** `/create-control-manifest` 和 `/architecture-review` 通过后。

---

## 1. 解析参数

解析审查模式（只解析一次，并存储供本次运行的所有门禁调用使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认为 `lean`

完整检查模式见 `.claude/docs/director-gates.md`。

**模式：**
- `/create-epics all` — 按层级顺序处理所有系统
- `/create-epics layer: foundation` — 仅 Foundation 层
- `/create-epics layer: core` — 仅 Core 层
- `/create-epics layer: feature` — 仅 Feature 层
- `/create-epics layer: presentation` — 仅 Presentation 层
- `/create-epics [system-name]` — 特定系统
- 无参数 — 询问：“你希望为哪个层或系统创建史诗？”

---

## 2. 加载输入

### 步骤 2a —— 摘要扫描（快速）

在完整读取任何内容前，使用 Grep 从所有 GDD 中提取其 `## Summary` 章节：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 5
```

对于 `layer:` 或 `[system-name]` 模式：根据 Summary 快速参考仅筛选范围内的 GDD。
跳过范围外内容的完整读取。

### 步骤 2b —— 完整加载文档（仅限范围内系统）

根据步骤 2a 的 grep 结果确定范围内的系统。**仅为范围内系统**完整读取文档；不要读取范围外系统或层的 GDD 或 ADR。

范围内系统需要读取：

- `design/gdd/systems-index.md` —— 权威系统列表、层级和优先级
- 仅范围内的 GDD（状态为 Approved 或 Designed，并根据步骤 2a 结果筛选）
- `docs/architecture/architecture.md` —— 模块归属和 API 边界
- **仅覆盖范围内系统领域的** Accepted ADR —— 读取 “GDD Requirements Addressed”、“Decision” 和 “Engine Compatibility” 章节；跳过无关领域的 ADR
- `docs/architecture/control-manifest.md` —— 头部中的清单版本日期
- `docs/architecture/tr-registry.yaml` —— 将需求追踪到 ADR 覆盖情况
- `docs/engine-reference/[engine]/VERSION.md` —— 引擎名称、版本和风险级别

报告：“已加载 [N] 个 GDD、[M] 个 ADR，引擎：[名称 + 版本]。”

---

## 3. 处理顺序

按依赖安全的层级顺序处理：
1. **Foundation**（无依赖）
2. **Core**（依赖 Foundation）
3. **Feature**（依赖 Core）
4. **Presentation**（依赖 Feature + Core）

每层内部使用 `systems-index.md` 中的顺序。

---

## 4. 定义每个史诗

为每个系统从 `architecture.md` 映射到一个架构模块。

根据 TR 注册表检查 ADR 覆盖情况：
- **已追踪需求**：有 Accepted ADR 覆盖的 TR-ID
- **未追踪需求**：没有 ADR 的 TR-ID；继续前发出警告

在写入任何内容前向用户展示：

```
## 史诗：[系统名称]

**层级**：[Foundation / Core / Feature / Presentation]
**GDD**：design/gdd/[filename].md
**架构模块**：[architecture.md 中的模块名称]
**主管 ADR**：[ADR-NNNN, ADR-MMMM]
**引擎风险**：[LOW / MEDIUM / HIGH —— 主管 ADR 中的最高风险]
**ADR 已覆盖的 GDD 需求**：[N / 总数]
**未追踪需求**：[列出没有 ADR 的 TR-ID，若无则写“无”]
```

如果存在未追踪需求：
> “⚠️ [system] 中有 [N] 项需求没有 ADR。可以创建史诗，但这些需求的故事将标记为
> Blocked，直到对应 ADR 建立。请先运行 `/architecture-decision`，或使用占位内容继续。”

使用 `AskUserQuestion`：
- 提示：“是否创建史诗：[name]？”
- 选项：
  - `[A] 是，创建史诗`
  - `[B] 跳过此史诗`
  - `[C] 暂停 —— 我需要先编写 ADR`

---

## 4b. 制作人史诗结构门禁

**审查模式检查** —— 生成 PR-EPIC 前应用：
- `solo` → 跳过。备注：“PR-EPIC 已跳过 —— `solo` 模式。”继续步骤 5（写入史诗文件）。
- `lean` → 跳过（不是 PHASE-GATE）。备注：“PR-EPIC 已跳过 —— `lean` 模式。”继续步骤 5（写入史诗文件）。
- `full` → 按正常流程生成。

当前层的所有史诗定义完成后（所有范围内系统均完成步骤 4），并且在写入任何文件前，通过 Task 使用 **PR-EPIC** 门禁生成 `producer`（`.claude/docs/director-gates.md`）。

传入：完整的史诗结构摘要（所有史诗、各自的范围摘要、主管 ADR 数量）、正在处理的层、里程碑时间线和团队容量。

展示制作人的评估结果。

如果为 UNREALISTIC：提供修订史诗边界的选项（拆分范围过大的史诗或合并范围过小的史诗）。修订后重新运行门禁，再进行写入。

如果为 CONCERNS，使用 `AskUserQuestion`：
- 提示：“制作人对史诗结构提出了担忧。你希望如何继续？”
- 选项：
  - `[A] 按计划继续 —— 我接受制作人的担忧`
  - `[B] 修订史诗边界 —— 按建议拆分或合并`
  - `[C] 停止 —— 我想重新考虑范围`

如果选择 [A]：继续步骤 5。
如果选择 [B]：根据步骤 4 修订史诗定义，并重新运行制作人门禁。
如果选择 [C]：停止。结论：**BLOCKED** —— 用户希望重新考虑史诗范围。

在制作人门禁得出结论前，不要写入史诗文件。

---

## 5. 写入史诗文件

获得批准后，询问：“可以将史诗文件写入 `production/epics/[epic-slug]/EPIC.md` 吗？”

用户确认后，写入：

### `production/epics/[epic-slug]/EPIC.md`

```markdown
# 史诗：[系统名称]

> **层级**：[Foundation / Core / Feature / Presentation]
> **GDD**：design/gdd/[filename].md
> **架构模块**：[模块名称]
> **状态**：Ready
> **故事**：尚未创建 —— 运行 `/create-stories [epic-slug]`

## 概述

[用一段话说明此史诗实现的内容，依据 GDD 概述和架构模块中声明的职责编写]

## 主管 ADR

| ADR | 决策摘要 | 引擎风险 |
|-----|---------|----------|
| ADR-NNNN：[标题] | [单行摘要] | LOW/MEDIUM/HIGH |

## GDD 需求

| TR-ID | 需求 | ADR 覆盖情况 |
|-------|------|--------------|
| TR-[system]-001 | [注册表中的需求文本] | ADR-NNNN ✅ |
| TR-[system]-002 | [需求文本] | ❌ 无 ADR |

## 完成定义

此史诗在满足以下条件时完成：
- 所有故事均已实现、审查，并通过 `/story-done` 关闭
- `design/gdd/[filename].md` 中的所有验收标准均已验证
- 所有 Logic 和 Integration 故事在 `tests/` 中都有通过的测试文件
- 所有 Visual/Feel 和 UI 故事在 `production/qa/evidence/` 中都有已签核的证据文档

## 下一步

运行 `/create-stories [epic-slug]`，将此史诗拆分为可实现的故事。
```

### 更新 `production/epics/index.md`

创建或更新主索引：

```markdown
# 史诗索引

最后更新：[日期]
引擎：[名称 + 版本]

| 史诗 | 层级 | 系统 | GDD | 故事 | 状态 |
|------|------|------|-----|------|------|
| [名称] | Foundation | [system] | [file] | 尚未创建 | Ready |
```

---

## 6. 门禁检查提醒

写入请求范围内的所有史诗后：

- **Foundation + Core 完成**：这是通过 Pre-Production → Production 门禁的必要条件。运行 `/gate-check production` 检查就绪状态。
- **提醒**：史诗定义范围，故事定义实现步骤。开发者开始工作前，为每个史诗运行 `/create-stories [epic-slug]`。

---

## 协作协议

1. **一次一个史诗** —— 请求创建前展示每个史诗的定义
2. **警告缺口** —— 继续前标记未追踪需求
3. **写入前询问** —— 写入任何文件前取得每个史诗的批准
4. **不擅自编造** —— 所有内容均来自 GDD、ADR 和架构文档
5. **永远不要创建故事** —— 此技能在史诗层级停止

处理完所有请求的史诗后：

- **结论：COMPLETE** —— 已写入 [N] 个史诗。为每个史诗运行 `/create-stories [epic-slug]`。
- **结论：BLOCKED** —— 用户拒绝了所有史诗，或未找到符合条件的系统。
