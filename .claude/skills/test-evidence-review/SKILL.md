---
name: test-evidence-review
description: "对测试文件和手动证据文档进行质量审查。不仅检查是否存在，还会评估断言覆盖率、边界情况处理、命名约定和证据完整性。为每个故事给出 ADEQUATE/INCOMPLETE/MISSING 结论。在 QA 签核前或按需运行。"
argument-hint: "[story-path | sprint | system-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---

# 测试证据审查

`/smoke-check` 验证测试文件是否**存在**并且能否**通过**。本技能
会进一步审查这些测试和证据文档的**质量**。
即使测试文件存在且测试通过，也仍可能遗漏关键行为。
即使手动证据文档存在，也可能缺少关闭故事所需的签核。

**输出：** 摘要报告（在对话中）+ 可选的 `production/qa/evidence-review-[date].md`

**运行时机：**
- QA 移交签核前（`/team-qa` Phase 5）
- 任何测试质量存疑的故事
- 作为里程碑审查的一部分，对 Logic 和 Integration 故事进行质量审计

---

## 1. 解析参数

**模式：**
- `/test-evidence-review [story-path]` — 审查单个故事的证据
- `/test-evidence-review sprint` — 审查当前迭代中的所有故事
- `/test-evidence-review [system-name]` — 审查某个史诗/系统中的所有故事
- 无参数 — 询问审查范围："单个故事"、"当前迭代"、"一个系统"

---

## 2. 加载范围内的故事

根据参数执行：

**单个故事**：直接读取故事文件。提取 Story Type、Test
Evidence 章节、故事 slug 和系统名称。

**迭代**：读取 `production/sprints/` 中最近修改的文件。
从迭代计划中提取故事文件路径列表。读取每个故事文件。

**系统**：使用 Glob 匹配 `production/epics/[system-name]/story-*.md`。逐个读取。

为每个故事收集：
- `Type:` 字段（Logic / Integration / Visual/Feel / UI / Config/Data）
- `## Test Evidence` 章节 — 声明的预期测试文件路径或证据文档
- 故事 slug（来自文件名）
- 系统名称（来自目录路径）
- Acceptance Criteria 列表（所有复选框条目）

---

## 3. 定位证据文件

为每个故事查找证据：

**Logic 故事**：使用 Glob 匹配 `tests/unit/[system]/[story-slug]_test.*`
  - 如果未找到，还应尝试：使用 Grep 在 `tests/unit/[system]/` 中查找
    包含故事 slug 的文件

**Integration 故事**：使用 Glob 匹配 `tests/integration/[system]/[story-slug]_test.*`
  - 同时检查 `production/session-logs/` 中提及该故事的试玩记录

**Visual/Feel 和 UI 故事**：使用 Glob 匹配 `production/qa/evidence/[story-slug]-evidence.*`

**Config/Data 故事**：使用 Glob 匹配 `production/qa/smoke-*.md`（任意冒烟检查报告）

记录每个故事找到的内容（路径），或未找到的内容（缺口）。

---

## 4. 审查自动化测试质量（Logic / Integration）

读取找到的每个测试文件并评估：

### 断言覆盖率

统计不同断言的数量（包含 assert、expect、check、verify 或
引擎专用断言模式的行）。断言数量少是一个质量信号：如果每个测试函数
仅有 1 个断言，可能无法覆盖预期行为的完整范围。

阈值：
- **每个测试函数 3 个以上断言** → 正常
- **每个测试函数 1-2 个断言** → 标记为可能过于薄弱
- **0 个断言**（测试存在但无断言）→ 标记为 BLOCKING：
  测试会空洞地通过，无法证明任何内容

### 边界情况覆盖率

对于故事中每个包含数值、阈值或“当 X 发生时”条件的验收标准：
检查测试函数名称或测试主体是否引用了该具体情况。

启发式检查：
- 使用 Grep 在测试文件中查找 "zero"、"max"、"null"、"empty"、"min"、"invalid"、
  "boundary"、"edge"，出现任意一个都是积极信号
- 如果故事包含具有明确边界的 Formulas 章节：检查测试是否覆盖
  最小值/最大值

### 命名质量

测试函数名称应描述：场景 + 预期结果。
格式：`test_[scenario]_[expected_outcome]`

将使用通用名称的函数（`test_1`、`test_run`、`testBasic`）标记为
**命名问题**，因为这类名称会增加诊断失败的难度。

### 公式可追溯性

对于 GDD 中包含 Formulas 章节的 Logic 故事：检查测试文件中是否至少有一个
测试，其名称或注释引用了公式名称或公式值。如果测试覆盖了公式却未提及其
名称，公式变更时会更难维护。

---

## 5. 审查手动证据质量（Visual/Feel / UI）

读取找到的每份证据文档并评估：

### 标准关联

证据文档应引用故事中的每项验收标准。
检查证据文档是否包含每项标准（或清晰的改写）。
缺少标准意味着该标准从未得到验证。

### 签核完整性

检查是否有三行签核记录（或等效字段）：
- 开发人员签核
- 设计师/美术负责人签核（适用于 Visual/Feel）
- QA 负责人签核

如果任何一项缺失或为空：标记为 INCOMPLETE，因为缺少任何必要签核时，
故事都不能完全关闭。

### 截图/产物完整性

对于 Visual/Feel 故事：检查证据文档是否引用了截图文件路径。
如果有引用，使用 Glob 确认文件存在。

对于 UI 故事：检查是否有演练序列（逐步交互日志）。

### 日期覆盖范围

证据文档应包含日期。如果日期早于故事最后一次重大变更
（启发式方法：与迭代计划中的迭代开始日期比较），则标记为 POTENTIALLY STALE，
因为该证据可能未覆盖最终实现。

---

## 6. 生成审查报告

为每个故事给出结论：

| 结论 | 含义 |
|---------|---------|
| **ADEQUATE** | 测试/证据存在，通过质量检查，且覆盖所有标准 |
| **INCOMPLETE** | 测试/证据存在，但有质量缺口（断言薄弱、缺少签核） |
| **MISSING** | 对于需要测试或证据的故事类型，未找到相应内容 |

迭代/系统的总体结论取现有故事结论中最差的一项。

```markdown
## 测试证据审查

> **日期**：[date]
> **范围**：[single story path | Sprint [N] | [system name]]
> **已审查故事数**：[N]
> **总体结论**：ADEQUATE / INCOMPLETE / MISSING

---

### 逐故事结果

#### [Story Title] — [Type] — [ADEQUATE/INCOMPLETE/MISSING]

**测试/证据路径**：`[path]`（已找到）/（未找到）

**自动化测试质量** *（仅适用于 Logic/Integration）*：
- 断言覆盖率：[N per function on average] — [adequate / thin / none]
- 边界情况：[covered / partial / not found]
- 命名：[consistent / [N] generic names flagged]
- 公式可追溯性：[yes / no — formula names not referenced in tests]

**手动证据质量** *（仅适用于 Visual/Feel/UI）*：
- 标准关联：[N/M criteria referenced]
- 签核：[Developer ✓ | Designer ✗ | QA Lead ✗]
- 产物：[screenshots present / missing / N/A]
- 时效性：[dated [date] — current / potentially stale]

**问题**：
- BLOCKING：[description] *（阻止 story-done）*
- ADVISORY：[description] *（应在发布前修复）*

---

### 摘要

| 故事 | Type | 结论 | 问题 |
|-------|------|---------|--------|
| [title] | Logic | ADEQUATE | 无 |
| [title] | Integration | INCOMPLETE | 断言薄弱（avg 1.2/function） |
| [title] | Visual/Feel | INCOMPLETE | 缺少 QA 负责人签核 |
| [title] | Logic | MISSING | 未找到测试文件 |

**BLOCKING 项**（必须先解决，故事才能关闭）：[N]
**ADVISORY 项**（应在发布前处理）：[N]
```

---

## 7. 写入输出（可选）

在对话中展示报告。

询问："可以将这份测试证据审查写入
`production/qa/evidence-review-[date].md` 吗？"

此步骤可选，报告本身可独立使用。仅在用户希望保留持久记录时写入。

报告之后：

- 对于 BLOCKING 项："必须先解决这些问题，`/story-done` 才能将故事标记为
  Complete。你想现在处理其中的任何问题吗？"
- 对于断言薄弱问题："可以考虑运行 `/test-helpers [system]`，查看
  常见情况的脚手架断言模式。"
- 对于缺少签核的问题："需要 [role] 进行手动签核。请与其共享
  `[evidence-path]` 以完成签核。"

结论：**COMPLETE** — 证据审查已完成。如果发现 BLOCKING 项，则使用 CONCERNS。

---

## 协作协议

- **报告质量问题，不要修复问题**：本技能只读取和评估，
  不修改测试文件或证据文档
- **ADEQUATE 表示足以发布，而非完美**：不要吹毛求疵地挑剔
  已正常运行且足够全面、足以建立信心的测试
- **区分 BLOCKING 与 ADVISORY 很重要**：仅当缺口导致
  某项故事标准确实未验证时，才标记为 BLOCKING
- **写入前先询问**：报告文件是可选的，写入前始终需要确认
