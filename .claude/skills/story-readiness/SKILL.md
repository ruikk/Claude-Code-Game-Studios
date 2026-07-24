---
name: story-readiness
description: "验证故事文件是否已准备好实施。检查是否包含 GDD 需求、ADR 引用、引擎说明、明确的验收标准，以及是否不存在未解决的设计问题。生成 READY / NEEDS WORK / BLOCKED 结论并列出具体缺口。当用户询问“这个故事准备好了吗”“我可以开始这个故事了吗”或“故事 X 可以实施了吗”时使用。"
argument-hint: "[story-file-path or 'all' or 'sprint']"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, Task
model: sonnet
---

# 故事就绪度

此技能验证故事文件是否包含开发者开始实施所需的一切内容，避免迭代中途因设计问题中断、
避免猜测，也避免模糊的验收标准。请在分配故事之前运行此技能。

**此技能为只读。** 它绝不会编辑故事文件，而是报告发现的问题，
并询问用户是否需要帮助补齐缺口。

**输出：** 为每个故事给出结论（READY / NEEDS WORK / BLOCKED），并为每个未就绪的故事
列出具体缺口。

---

## 阶段 0：确定审查模式

启动时确定一次审查模式（存储该值，供本次运行中生成的所有关卡使用）：

1. 如果调用技能时提供了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认为 `lean`

完整的检查模式与模式定义请参阅 `.claude/docs/director-gates.md`。

---

## 1. 解析参数

**范围：** `$ARGUMENTS[0]`（留空 = 通过 AskUserQuestion 询问用户）

- **具体路径**（例如 `/story-readiness production/epics/combat/story-001-basic-attack.md`）：
  验证该单个故事文件。
- **`sprint`**：从 `production/sprints/` 读取当前迭代计划（最新文件），
  提取其中引用的每个故事路径并逐一验证。
- **`all`**：对 `production/epics/**/*.md` 执行 glob，排除 `EPIC.md` 索引文件，
  验证找到的每个故事文件。
- **无参数**：询问用户要验证的范围。

如果未提供参数，使用 `AskUserQuestion`：
- “您想验证哪些内容？”
  - 选项：“某个具体故事文件”“当前迭代中的所有故事”
    “production/epics/ 中的所有故事”“某个特定史诗的故事”

继续之前报告范围：“正在验证 [N] 个故事文件。”

---

## 2. 加载支持上下文

检查任何故事之前，一次性加载参考文档（不要按故事重复加载）：

- `design/gdd/systems-index.md` — 了解哪些系统已有获批的 GDD
- `docs/architecture/control-manifest.md` — 了解现有的清单规则
  （如果文件不存在，只记录一次缺失；不要为每个故事重复标记）
  如果文件存在，还要从头部区块提取 `Manifest Version:` 日期。
- `docs/architecture/tr-registry.yaml` — 按 `id` 为所有条目建立索引，用于
  验证故事中的 TR-ID。如果文件不存在，只记录一次；所有故事的 TR-ID
  检查将自动通过（注册表早于故事，因此缺少注册表意味着故事编写于引入 TR 跟踪之前）。
- 所有 ADR 状态字段 — 对待检查故事中引用的每个唯一 ADR，读取 ADR 文件并记录其
  `Status:` 字段。缓存这些状态，避免为每个故事重复读取同一 ADR。
- 当前迭代文件（如果范围为 `sprint`）— 用于识别 Must Have /
  Should Have 优先级，以便作出升级决策

---

## 3. 故事就绪度检查清单

对每个故事文件评估以下所有项目。只有全部项目通过，或明确标记为 N/A 并说明理由时，
故事才是 READY。

### 设计完整性

- [ ] **已引用 GDD 需求**：故事包含 `design/gdd/` 路径，且引用或链接了该 GDD 中的
  具体需求、验收标准或规则，而不只是 GDD 文件名。仅链接文档而未追溯到
  具体需求，不能通过检查。
- [ ] **需求可独立理解**：无需打开 GDD 即可理解故事中的验收标准。开发者不应需要
  阅读另一份文档才能理解 DONE 的含义。
- [ ] **验收标准可测试**：每项标准都是具体、可观察的条件，而不是“实施 X”或
  “系统正常工作”。反例：“实施跳跃机制。”正例：“按住跳跃时，
  在 0.3 秒内达到 5 单位的最大跳跃高度。”
- [ ] **验收标准不需要主观判断** *（`Type: Visual/Feel` 自动通过）*：如果没有明确的
  基准，“响应灵敏”或“看起来不错”等标准无法测试。对于 Logic、Integration、UI
  和 Config/Data 故事，必须将其替换为具体、可观察的条件。Visual/Feel 故事允许
  主观标准，此检查自动通过，但应改为验证每项主观标准是否配有试玩协议或证据要求
  （例如，“证据文档必须位于 `production/qa/evidence/[slug]-evidence.md`”）。
  如果验收标准末尾包含或附有对 `production/qa/evidence/[slug]-evidence.md` 等文件路径的明确引用，则为 PASS。如果标准完全主观且未指定证据文件路径，则为 NEEDS WORK。

### 架构完整性

- [ ] **已引用 ADR 或声明 N/A**：故事至少引用一个 ADR，
  或明确声明“No ADR applies”并简要说明理由。
  没有 ADR 引用且没有明确 N/A 说明的故事无法通过此检查。
- [ ] **ADR 为 Accepted（而非 Proposed）**：对每个引用的 ADR，使用第 2 节加载并缓存的
  ADR 状态检查其 `Status:` 字段。
  - 如果为 `Status: Accepted` → 通过。
  - 如果为 `Status: Proposed` → **BLOCKED**：ADR 在获批前可能发生变化，
    故事中的实施指导可能有误。
    修复：`BLOCKED: ADR-NNNN is Proposed — wait for acceptance before implementing.`
  - 如果 ADR 文件不存在 → **BLOCKED**：引用的 ADR 缺失。
  - 如果故事有明确的“No ADR applies”N/A 说明，则自动通过。
- [ ] **TR-ID 有效且处于活动状态**：如果故事包含 `TR-[system]-NNN` 引用，
  在第 2 节加载的 TR 注册表中查找该引用。
  - 如果 ID 存在且为 `status: active` → 通过。
  - 如果 ID 存在且为 `status: deprecated` 或 `status: superseded-by: ...` →
    NEEDS WORK：该需求已被移除或替换。
    修复：更新故事以引用当前需求 ID；如果已不再适用，则删除该引用。
  - 如果注册表中不存在该 ID → NEEDS WORK：ID 未注册
    （故事可能早于注册表，或注册表需要运行 `/architecture-review`）。
  - 如果故事没有 TR-ID 引用，或注册表不存在，则自动通过。
- [ ] **清单版本为当前版本**：如果故事头部含有 `Manifest Version:` 日期，
  且 `docs/architecture/control-manifest.md` 存在：
  - 如果故事版本与当前清单的 `Manifest Version:` 匹配 → 通过。
  - 如果故事版本早于当前清单 → NEEDS WORK：可能有新规则适用。
    修复：审查变更的清单规则；如果任何禁止/必需条目发生变化，则更新故事，
    然后将故事的 `Manifest Version:` 更新为当前版本。
  - 如果故事没有 `Manifest Version:` 字段，或清单不存在，则自动通过。
- [ ] **包含引擎说明**：对于此故事可能涉及的任何知识截止日期之后的引擎 API，
  应包含实施说明或验证要求。如果故事显然不涉及引擎 API（例如纯数据/配置变更），
  可以使用“N/A — no engine API involved”。
- [ ] **已注明控制清单规则**：引用控制清单中相关的层级规则，
  或声明“N/A — manifest not yet created”。如果 `docs/architecture/control-manifest.md`
  尚不存在，此项自动通过（不要惩罚在清单创建前编写的故事）。

### 范围清晰度

- [ ] **包含估算**：故事包含规模估算（小时、点数或 T 恤尺码）。
  没有估算的故事无法纳入计划。
- [ ] **已声明范围内/范围外边界**：故事说明不包含哪些内容，
  可通过明确的 Out of Scope 章节，或使用边界清晰、无歧义的语言。
  如果没有此项，实施期间很可能发生范围蔓延。
- [ ] **已列出故事依赖项**：如果此故事依赖其他故事先达到 DONE，
  则列出这些故事 ID。如果没有依赖项，应明确声明“None”，而不能只是省略。

### 待解决问题

- [ ] **没有未解决的设计问题**：故事的任何验收标准、实施说明或规则声明中，
  都不包含标记为“UNRESOLVED”“TBD”“TODO”“?”或类似标记的文本。
- [ ] **依赖故事不是 DRAFT**：对列为依赖项的每个故事，检查其文件是否存在，
  且状态不是 DRAFT。依赖 DRAFT 或缺失故事的故事应为 BLOCKED，
  而不仅仅是 NEEDS WORK。

### 资产引用检查

- [ ] **引用的资产存在**：扫描故事文本中的资产路径模式
  （包含 `assets/` 的路径，或扩展名为 `.png`、`.jpg`、`.svg`、
  `.wav`、`.ogg`、`.mp3`、`.glb`、`.gltf`、`.tres`、`.tscn`、`.res` 的文件）。
  - 对找到的每个资产路径：使用 Glob 检查文件是否存在。
  - 如果任何引用的资产不存在：**NEEDS WORK** — 记录缺失路径。
    （故事引用了尚未创建的资产。应删除引用、创建占位资源，或将其标记为
    对资产创建故事的明确依赖。）
  - 如果所有引用的资产都存在：记录“已验证引用的资产：找到 [count] 个。”
  - 如果故事中未引用资产路径：记录“故事中未找到资产引用 — 跳过资产检查。”
    此项自动通过。
  - 此检查只验证是否存在，不验证文件格式或内容。

### 完成定义

- [ ] **按故事类型满足最低可测试验收标准数量**：
  - Logic / Integration 故事：至少 3 项
  - Visual/Feel 和 UI 故事：至少 2 项
  - Config/Data 故事：至少 1 项
  应用与故事 `Type:` 字段匹配的阈值。如果故事少于最低数量，标记为 NEEDS WORK。
- [ ] **适用时注明性能预算**：如果此故事涉及游戏循环、渲染或物理的任何部分，
  应包含性能预算或“预计无性能影响 — [reason]”说明。
- [ ] **已声明故事类型**：故事头部包含 `Type:` 字段，
  用于标识测试类别（Logic / Integration / Visual/Feel / UI / Config/Data）。
  如果缺少此字段，故事关闭时便无法强制执行测试证据要求。
  修复：在故事头部添加 `Type: [Logic|Integration|Visual/Feel|UI|Config/Data]`。
- [ ] **测试证据要求明确**：如果已设置 Story Type，故事应包含 `## Test Evidence`
  章节，说明证据的存储位置（Logic/Integration 使用测试文件路径，
  Visual/Feel/UI 使用证据文档路径）。
  修复：添加 `## Test Evidence`，并注明该故事类型预期的证据位置。

---

## 4. 分配结论

为每个故事分配以下三种结论之一：

**READY** — 所有检查项均通过，或有明确的 N/A 理由。
故事可以立即分配。

**NEEDS WORK** — 一个或多个检查项未通过，但所有依赖故事均存在且不是 DRAFT。
故事可在分配前修正。

**BLOCKED** — 一个或多个依赖故事缺失或处于 DRAFT 状态，
或者关键设计问题（在标准或规则中标记为 UNRESOLVED）没有负责人。
在阻塞项解决之前不能分配故事。注意：BLOCKED 的故事也可能有 NEEDS WORK 项，
两者都要列出。

---

## 5. 输出格式

### 单个故事输出

```
## 故事就绪度：[story title]
文件：[path]
结论：[READY / NEEDS WORK / BLOCKED]

### 通过的检查项（N/[total]）
[list passing items briefly]

### 缺口
- [Checklist item]：[exact description of what is missing or wrong]
  修复：[specific text needed to resolve this gap]

### 阻塞项（如果为 BLOCKED）
- [What is blocking]：[story ID or design question that must resolve first]
```

### 多故事汇总输出

```
## 故事就绪度摘要 — [scope] — [date]

READY：     [N] 个故事
NEEDS WORK：[N] 个故事
BLOCKED：   [N] 个故事

### READY 故事
- [story title]（[path]）

### NEEDS WORK
- [story title]：[primary gap — one line]
- [story title]：[primary gap — one line]

### BLOCKED 故事
- [story title]：被 [story ID / design question] 阻塞

---
[Full detail for each non-ready story follows, using the single-story format]
```

### 迭代升级

如果范围为 `sprint`，且任何 Must Have 故事为 NEEDS WORK 或 BLOCKED，
在输出顶部添加醒目的警告：

```
警告：[N] 个 Must Have 故事尚未准备好实施。
[List them with their primary gap or blocker.]
请在迭代开始前解决这些问题，或使用 `/sprint-plan update` 重新规划。
```

---

## 6. 协作协议

此技能为只读。它绝不提议编辑，也不请求写入文件。

报告发现的问题后，询问：

“您是否需要帮助补齐这些故事中的缺口？我可以起草缺失的章节，供您审批。”

如果用户同意处理某个具体故事，仅在对话中起草缺失的章节。
不要使用 Write 或 Edit 工具，写入工作由用户（或 `/create-stories`）完成。

**重定向规则：**
- 如果故事文件完全不存在：“此故事文件完全缺失。请先运行 `/create-epics [layer]`，
  再运行 `/create-stories [epic-slug]`，根据 GDD 和 ADR 生成故事。”
- 如果故事没有 GDD 引用且工作量似乎较小：“此故事没有 GDD 引用。如果变更较小
  （少于约 4 小时），请运行 `/quick-design [description]` 创建快速设计规格，
  然后在故事中引用该规格。”
- 如果故事范围已超出原始估算：“此故事的范围似乎已经扩大。
  请考虑拆分故事，或在开始实施前升级给制作人。”

---

## 7. 后续故事交接

完成单故事就绪度检查后（范围不是 `all` 或 `sprint`）：

1. 从 `production/sprints/` 读取当前迭代文件（最新文件）。
2. 查找符合以下条件的故事：
   - Status: READY 或 NOT STARTED
   - 不是刚刚检查的故事
   - 未被未完成的依赖项阻塞
   - 位于 Must Have 或 Should Have 层级

如果找到符合条件的故事，最多展示 3 个：

```
### 本迭代中的其他就绪故事

1. [Story name] — [1-line description] — 估算：[X hrs]
2. [Story name] — [1-line description] — 估算：[X hrs]

开始前运行 `/story-readiness [path]` 进行验证。
```

如果迭代文件不存在，或未找到其他就绪故事，则静默跳过此章节。

---

## 阶段 8：主管关卡 — 故事就绪度审查

生成 QL-STORY-READY 之前，应用阶段 0 中确定的审查模式：

- `solo` → 跳过。记录：“QL-STORY-READY skipped — Solo mode.”然后进入收尾。
- `lean` → 跳过。记录：“QL-STORY-READY skipped — Lean mode.”然后进入收尾。
- `full` → 正常生成。

通过 Task 使用关卡 **QL-STORY-READY**（`.claude/docs/director-gates.md`）生成 `qa-lead`。

传递以下上下文：
- 故事标题
- 验收标准列表（故事验收标准章节中的所有项目）
- 依赖项状态（列出所有依赖项及其当前状态：存在 / DRAFT / 缺失）
- 阶段 4 的总体结论（READY / NEEDS WORK / BLOCKED）

根据 `director-gates.md` 中的标准规则处理结论：
- **ADEQUATE** → 故事通过，进入收尾。
- **GAPS [list]** → 通过 `AskUserQuestion` 向用户展示具体缺口：
  选项：`Update story with suggested gaps` / `Accept and proceed anyway` / `Discuss further`。
- **INADEQUATE** → 展示具体缺口，并询问用户要更新故事还是仍然继续。

---

## 建议的后续步骤

- 故事达到 READY 后，运行 `/dev-story [story-path]` 开始实施
- 运行 `/story-readiness sprint`，一次检查当前迭代中的所有故事
- 如果故事文件完全缺失，运行 `/create-stories [epic-slug]`
