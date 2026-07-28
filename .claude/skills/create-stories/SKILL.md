---
name: create-stories
description: "将单个史诗拆分为可实现的故事文件。读取史诗、对应的 GDD、主管 ADR 和控制清单。每个故事嵌入对应的 GDD 需求 TR-ID、ADR 指南、验收标准、故事类型和测试证据路径。为每个史诗运行 /create-epics 后使用。"
argument-hint: "[epic-slug | epic-path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
agent: lead-programmer
---

# 创建故事

故事是一项单独的可实现行为：足够小，可以在一次专注的会话中完成；自包含；并且能够完整追溯到一条 GDD 需求和一个 ADR 决策。故事是开发者领取的工作单元，史诗则是架构师定义的工作单元。

**每个史诗运行一次此技能**，不要按层运行。先处理 Foundation 层的史诗，再处理 Core 层，依此类推，并遵循依赖顺序。

**输出：** `production/epics/[epic-slug]/story-NNN-[slug].md` 文件

**前置步骤：** `/create-epics [system]`
**故事创建后的下一步：** `/story-readiness [story-path]`，然后运行 `/dev-story [story-path]`

---

## 1. 解析参数

如果存在，提取 `--review [full|lean|solo]`，并将其保存为本次运行的评审模式覆盖值。如果未提供，则读取 `production/review-mode.txt`（缺失时默认为 `lean`）。解析出的模式适用于此技能中的所有门禁生成：每次调用门禁前都应用 `.claude/docs/director-gates.md` 中的检查模式。

- `/create-stories [epic-slug]` — 例如 `/create-stories combat`
- `/create-stories production/epics/combat/EPIC.md` — 也接受完整路径
- 无参数 — 询问：“你想将哪个史诗拆分为故事？”
  使用 Glob 查找 `production/epics/*/EPIC.md`，并列出可用史诗及其状态。

---

## 2. 加载此史诗的全部资料

完整读取：

- `production/epics/[epic-slug]/EPIC.md` — 史诗概览、主管 ADR、GDD 需求表
- 史诗的 GDD（`design/gdd/[filename].md`）— 读取全部 8 个章节，尤其是“验收标准”“公式”和“边界情况”
- 史诗列出的所有主管 ADR — 读取“决策”“实施指南”“引擎兼容性”和“引擎说明”章节
- `docs/architecture/control-manifest.md` — 提取此史诗所属层的规则；记录标题中的“清单版本”日期
- `docs/architecture/tr-registry.yaml` — 加载此系统的全部 TR-ID

**ADR 存在性验证：** 从史诗读取主管 ADR 列表后，确认每个 ADR 文件都存在于磁盘中。如果找不到任一 ADR 文件，必须在拆分任何故事前立即停止：

> “史诗引用了 [ADR-NNNN: 标题]，但未找到 `docs/architecture/[adr-file].md`。
> 请检查史诗主管 ADR 列表中的文件名，或运行 `/architecture-decision`
> 创建该文件。所有引用的 ADR 文件就绪前无法创建故事。”

在确认所有引用的 ADR 文件都存在之前，不得进入第 3 步。

报告：“已加载史诗 [名称]、GDD [文件名]、[N] 个主管 ADR（均已确认存在）以及控制清单 v[日期]。”

---

## 3. 按类型分类故事

**故事类型分类** — 根据验收标准为每个故事分配类型：

| 故事类型 | 验收标准涉及以下内容时分配 |
|---|---|
| **Logic** | 公式、数值阈值、状态转换、AI 决策、计算 |
| **Integration** | 两个或更多系统交互、跨边界信号、存档/读档往返 |
| **Visual/Feel** | 动画行为、VFX、“响应感”、时序、屏幕震动、音频同步 |
| **UI** | 菜单、HUD 元素、按钮、屏幕、对话框、工具提示 |
| **Config/Data** | 平衡调优值、仅数据文件变更，不包含新的代码逻辑 |

混合故事：分配承载最高实现风险的类型。该类型决定在 `/story-done` 关闭故事前需要哪些测试证据。

---

## 4. 将 GDD 拆分为故事

针对每条 GDD 验收标准：

1. 将需要相同核心实现的相关标准分组
2. 每个分组 = 一个故事
3. 故事排序：先基础行为，最后边界情况，UI 最后

**故事规模规则：** 一个故事 = 一次专注的会话（约 2-4 小时）。如果一组标准需要更长时间，拆分为两个故事。

对每个故事确定：
- **GDD 需求**：它满足哪些验收标准？
- **TR-ID**：在 `tr-registry.yaml` 中查找。使用稳定 ID。如果没有匹配项，使用 `TR-[system]-???` 并发出警告。
- **主管 ADR**：哪个 ADR 规定了实现方式？
  - `Status: Accepted` → 正常嵌入
  - `Status: Proposed` → 将故事的 `Status` 设为 `Blocked`，并附注：“BLOCKED：ADR-NNNN 为 Proposed，请运行 `/architecture-decision` 推进其状态”
  - **多个 ADR 适用**：在故事的“主管 ADR”字段列出所有主管 ADR。将最直接控制实现模式的 ADR 指定为主要 ADR（列表第一项），其余列为次要参考。
  - **完全没有 ADR 适用**：在故事的 ADR 字段写入 `ADR: N/A — [简要原因，例如“纯数据配置，无需架构模式”]`。不要留空：空白 ADR 字段表示“尚未检查”，而不是“不适用”。
- **故事类型**：使用第 3 步的分类
- **引擎风险**：取自 ADR 的知识风险字段

---

## 4b. QA 主管故事就绪门禁

**评审模式检查** — 生成 QL-STORY-READY 前应用：
- `solo` → 跳过。注明：“已跳过 QL-STORY-READY：solo 模式。”进入第 5 步（提交故事评审）。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“已跳过 QL-STORY-READY：lean 模式。”进入第 5 步（提交故事评审）。
- `full` → 正常生成。

完成所有故事拆分（第 4 步完成）后、提交写入批准前，通过 Task 使用门禁 **QL-STORY-READY**（`.claude/docs/director-gates.md`）生成 `qa-lead`。

传入：完整故事列表、验收标准、故事类型和 TR-ID；并附上史诗的 GDD 验收标准作为参考。

展示 QA 主管的评估。对每个被标记为 GAPS 或 INADEQUATE 的故事，在继续前修订其验收标准；不可测试的标准无法被正确实现。所有故事达到 ADEQUATE 后再继续。

**生成测试规格前：** 使用 Glob 查找最近修改的 `production/qa/qa-plan-*.md`。如果找到，读取该文件并检查它是否包含此史诗故事的测试用例规格（查看计划“所需自动化测试”部分中的故事标题或 slug）。如果存在匹配规格：
- 使用 `AskUserQuestion`：
  - 提示：“[路径] 处已有 QA 计划，其中包含部分故事的测试规格。你想如何继续？”
  - 选项：
    - `使用 QA 计划中的现有规格，将其嵌入故事文件（推荐）`
    - `让 qa-lead 生成新规格，覆盖 QA 计划`
    - `跳过测试规格生成，我将手动填写“QA 测试用例”`
- 如果选择“使用现有规格”：从 qa-plan 提取每个匹配故事的测试用例规格，并直接嵌入“QA 测试用例”章节。无需为这些故事生成 qa-lead；仅为 QA 计划未覆盖的故事生成 qa-lead。
- 如果选择“生成新规格”：按正常流程生成 qa-lead。
- 如果选择“跳过”：在“QA 测试用例”中保留占位符：`*测试用例尚未定义，请运行 /qa-plan 生成。*`

**达到 ADEQUATE 后**（或导入 qa-plan 后）：对于每个 Logic 和 Integration 故事，请 qa-lead 生成具体测试用例规格，每条验收标准一条，格式如下：

```
测试：[标准文本]
  给定：[前置条件]
  当：[操作]
  则：[预期结果或断言]
  边界情况：[要测试的边界值或失败状态]
```

对于 Visual/Feel 和 UI 故事，改为生成手动验证步骤：
```
手动检查：[标准文本]
  准备：[如何进入该状态]
  验证：[要检查的内容]
  通过条件：[明确无歧义的通过描述]
```

这些测试用例规格直接嵌入每个故事的“QA 测试用例”章节。开发者根据这些用例实现。程序员不得从头编写测试；QA 已经定义了“完成”的标准。

---

## 5. 提交故事评审

写入任何文件前，展示完整的故事列表：

```
## 史诗故事：[名称]

故事 001：[标题] — Logic — ADR-NNNN
  覆盖：TR-[system]-001（[单行需求摘要]）
  所需测试：tests/unit/[system]/[slug]_test.[ext]

故事 002：[标题] — Integration — ADR-MMMM
  覆盖：TR-[system]-002、TR-[system]-003
  所需测试：tests/integration/[system]/[slug]_test.[ext]

故事 003：[标题] — Visual/Feel — ADR-NNNN
  覆盖：TR-[system]-004
  所需证据：production/qa/evidence/[slug]-evidence.md

[共 N 个故事：N 个 Logic、N 个 Integration、N 个 Visual/Feel、N 个 UI、N 个 Config/Data]
```

使用 `AskUserQuestion`：
- 提示：“可以将这 [N] 个故事写入 `production/epics/[epic-slug]/` 吗？”
- 选项：`[A] 是，写入全部 [N] 个故事` / `[B] 暂不写入，我想先评审或调整`

---

## 6. 写入故事文件

每个故事写入 `production/epics/[epic-slug]/story-[NNN]-[slug].md`：

```markdown
# 故事 [NNN]：[标题]

> **史诗**：[史诗名称]
> **状态**：Ready
> **层级**：[Foundation / Core / Feature / Presentation]
> **类型**：[Logic | Integration | Visual/Feel | UI | Config/Data]
> **估算**：[小时数或 T 恤尺码，迭代规划前填写]
> **清单版本**：[control-manifest.md 标题中的日期]
> **最后更新**：[/dev-story 开始实现时设置]

## 上下文

**GDD**: `design/gdd/[filename].md`
**需求**：`TR-[system]-NNN`
*（需求文本位于 `docs/architecture/tr-registry.yaml`，评审时重新读取）*

**主管实现的 ADR**：[ADR-NNNN：标题]
**ADR 决策摘要**：[用 1 至 2 句话概述 ADR 的决策]

**引擎**：[名称和版本] | **风险**：[LOW / MEDIUM / HIGH]
**引擎说明**：[来自 ADR 的引擎兼容性章节，包括知识截止日期之后的 API 和所需验证]

**控制清单规则（本层）**：
- 必须：[相关必需模式]
- 禁止：[相关禁止模式]
- 约束：[相关性能约束]

---

## 验收标准

*来自 GDD `design/gdd/[filename].md`，范围限定为本故事：*

- [ ] [标准 1，直接取自 GDD]
- [ ] [标准 2]
- [ ] [适用时填写性能标准]

---

## 实施说明

*源自 ADR-NNNN 实施指南：*

[来自 ADR 的具体可执行指南。不得以改变原意的方式转述。
程序员将阅读此处而非 ADR。]

---

## 范围之外

*由相邻故事处理，不要在此实现：*

- [故事 NNN+1]：[其处理内容]

---

## QA 测试用例

*由 qa-lead 在创建故事时编写。开发者据此实现，不要在实现期间自行发明新测试用例。*

**[Logic / Integration 故事使用自动化测试规格]：**

- **AC-1**：[标准文本]
  - 给定：[前置条件]
  - 当：[操作]
  - 则：[断言]
  - 边界情况：[边界值或失败状态]

**[Visual/Feel / UI 故事使用手动验证步骤]：**

- **AC-1**：[标准文本]
  - 准备：[如何进入该状态]
  - 验证：[要检查的内容]
  - 通过条件：[明确无歧义的通过描述]

---

## 测试证据

**故事类型**：[类型]
**所需证据**：
- Logic：`tests/unit/[system]/[story-slug]_test.[ext]`，必须存在且通过
- Integration：`tests/integration/[system]/[story-slug]_test.[ext]` 或试玩文档
- Visual/Feel：`production/qa/evidence/[story-slug]-evidence.md` 加签核
- UI：`production/qa/evidence/[story-slug]-evidence.md` 或交互测试
- Config/Data：冒烟检查通过（`production/qa/smoke-*.md`）

**状态**：[ ] 尚未创建

---

## 依赖项

- 依赖：[故事 NNN-1 必须为 DONE，或填写“无”]
- 解锁：[故事 NNN+1，或填写“无”]
```

### 同时更新 `production/epics/[epic-slug]/EPIC.md`

将 “Stories: Not yet created” 行替换为已填充的表格：

```markdown
## 故事

| # | 故事 | 类型 | 状态 | ADR |
|---|-------|------|--------|-----|
| 001 | [标题] | Logic | Ready | ADR-NNNN |
| 002 | [标题] | Integration | Ready | ADR-MMMM |
```

### 同时更新 `production/epics/index.md`

在索引表中找到与此史诗匹配的行（按史诗名称或 slug）。将其 `Stories` 列从 `Not yet created` 更新为 `[N] stories`，其中 N 是刚写入的数量。如果索引文件不存在，则静默跳过。

---

## 7. 写入后

使用 `AskUserQuestion`，以与上下文相关的下一步结束：

检查：
- `production/epics/` 中是否还有没有故事的其他史诗？列出它们。
- 这是否是最后一个史诗？如果是，将 `/sprint-plan` 作为选项。

交互控件：
- 提示：“已将 [N] 个故事写入 `production/epics/[epic-slug]/`。接下来做什么？”
- 选项（包含所有适用项）：
  - `[A] 开始实现，运行 /story-readiness [first-story-path]`（推荐）
  - `[B] 为 [next-epic-slug] 创建故事，运行 /create-stories [slug]`（仅当其他史诗尚无故事时）
  - `[C] 规划迭代，运行 /sprint-plan new`（仅当所有史诗都已有故事时）
  - `[D] 本次会话到此结束`

在输出中注明：“请按顺序处理故事，每个故事的‘依赖’字段说明了开始该故事前哪些工作必须为 DONE。”

---

## 协作协议

1. **展示前先读取** — 静默加载所有输入后再展示故事列表
2. **只询问一次** — 一次性展示该史诗的全部故事摘要，不要逐个询问
3. **警告阻塞故事** — 写入前标记所有使用 `Proposed` ADR 的故事
4. **写入前询问** — 在写入文件前获得整个故事集的批准
5. **不自行发明** — 验收标准来自 GDD，实施说明来自 ADR，规则来自控制清单
6. **绝不开始实现** — 此技能止于故事文件级别

写入后（或用户拒绝后）：

- **结论：COMPLETE** — 已将 [N] 个故事写入 `production/epics/[epic-slug]/`。运行 `/story-readiness` → `/dev-story` 开始实现。
- **结论：BLOCKED** — 用户拒绝。未写入故事文件。
