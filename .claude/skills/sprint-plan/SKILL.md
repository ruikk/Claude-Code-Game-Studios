---
name: sprint-plan
description: "根据当前里程碑、已完成工作和可用产能生成新的迭代计划或更新现有计划。从制作文档和设计待办中获取上下文。"
argument-hint: "[new|update|status] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
context: |
  !ls production/sprints/ 2>/dev/null
---

## 阶段 0：解析参数

提取模式参数（`new`、`update` 或 `status`），并确定评审模式（仅确定一次，供本次运行中所有关卡生成使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用文件中的值
3. 否则 → 默认为 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

**评审模式检查**（关卡运行前）：
- 如果 `production/review-mode.txt` 存在，读取并使用其中的模式。
- 如果文件不存在且这是一个 `new` 迭代：使用 `AskUserQuestion`：
  - 提示："尚未设置评审模式。你希望本次迭代采用哪种评审深度？"
  - 选项：
    - `[A] full — 生成所有总监和主管关卡`
    - `[B] lean — 跳过非阶段关卡的总监评审（推荐用于大多数迭代）`
    - `[C] solo — 跳过所有关卡生成`
  - 选择后：将所选模式写入 `production/review-mode.txt`。说明："评审模式已设置为 [mode]，并保存至 production/review-mode.txt。"
- 如果文件不存在且这不是 `new` 迭代（例如正在更新现有迭代）：静默默认为 `lean`。

---

## 阶段 1：收集上下文

1. 从 `production/milestones/` **读取当前里程碑**。

2. 从 `production/sprints/` **读取上一个迭代**（如有），以
   了解速率和结转工作。

3. **扫描 `design/gdd/` 中的设计文档**，查找标记为可供
   实现的功能。

4. **检查 `production/risk-register/` 中的风险登记册**。

---

## 阶段 2：生成输出

对于 `new`：

按照以下格式**生成迭代计划**并向用户展示。暂时不要请求写入，因为制作人可行性关卡（阶段 4）会先运行，并可能要求在写入文件前进行修订。

```markdown
# 迭代 [N] — [Start Date] 至 [End Date]

## 迭代目标
[One sentence describing what this sprint achieves toward the milestone]

## 产能
- 总天数：[X]
- 缓冲（20%）：[Y days reserved for unplanned work]
- 可用：[Z days]

## 任务

### 必须完成（关键路径）
| ID | 任务 | 代理/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

### 应该完成
| ID | 任务 | 代理/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

### 最好完成
| ID | 任务 | 代理/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

## 上一迭代的结转工作
| 任务 | 原因 | 新估算 |
|------|--------|-------------|

## 风险
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------------|--------|------------|

## 外部因素依赖
- [List any external dependencies]

## 本次迭代的完成定义
- [ ] 所有必须完成的任务均已完成
- [ ] 所有任务均通过验收标准
- [ ] QA 计划已存在（`production/qa/qa-plan-sprint-[N].md`）
- [ ] 所有逻辑/集成故事均有通过的单元/集成测试
- [ ] 冒烟检查已通过（`/smoke-check sprint`）
- [ ] QA 签核报告：APPROVED 或 APPROVED WITH CONDITIONS（`/team-qa sprint`）
- [ ] 已交付功能中没有 S1 或 S2 缺陷
- [ ] 已针对所有偏差更新设计文档
- [ ] 代码已评审并合并
```

对于 `update`：

**更新现有迭代计划**：

1. 从 `production/sprints/` 读取最新的迭代计划。
2. 根据 `production/sprint-status.yaml` 展示当前故事列表及其当前状态。
3. 询问用户要做哪些更改：添加、移除、重新确定优先级或重新估算故事。使用 `AskUserQuestion` 收集更改。
4. 应用更改，并重新展示完整的修订计划供评审。
5. 对修订后的计划重新运行制作人可行性关卡（阶段 4）。
6. 一并写入更新后的 Markdown 计划和 YAML（使用与 `new` 模式相同的审批）。

注意：`update` 模式不会重置故事状态。已标记为 `in-progress` 或 `done` 的故事保持其状态。只有 `backlog` 和 `ready-for-dev` 故事可以自由移除或重新确定优先级。

对于 `status`：

**生成状态报告**：

```markdown
# 迭代 [N] 状态 -- [Date]

## 进度：[X/Y tasks complete]（[Z%]）

### 已完成
| 任务 | 完成人 | 备注 |
|------|-------------|-------|

### 进行中
| 任务 | 负责人 | 完成百分比 | 阻塞项 |
|------|-------|--------|----------|

### 未开始
| 任务 | 负责人 | 是否存在风险？ | 备注 |
|------|-------|----------|-------|

### 已阻塞
| 任务 | 阻塞项 | 阻塞项负责人 | 预计完成时间 |
|------|---------|-----------------|-----|

## 燃尽评估
[On track / Behind / Ahead]
[If behind: What is being cut or deferred]

## 新出现的风险
- [Any new risks identified this sprint]
```

---

## 阶段 3：准备迭代状态文件

生成新的迭代计划后，还要准备 `production/sprint-status.yaml` 的内容。
这是故事状态的机器可读事实来源，供 `/sprint-status`、`/story-done`
和 `/help` 无需解析 Markdown 即可读取。

**暂时不要写入 YAML**，将其保留在上下文中。制作人可行性关卡（阶段 4）可能会修订故事列表。阶段 4 之后，通过一次写入审批同时写入两个文件。

格式：

```yaml
# 由 /sprint-plan 自动生成。由 /story-done 和 /dev-story 更新。
# 不要手动编辑，请使用 /story-done 更新故事状态。
#
# 状态值映射（YAML ↔ 故事文件的 Status 字段）：
#   backlog        ↔  Not Started
#   ready-for-dev  ↔  Ready
#   in-progress    ↔  In Progress
#   review         ↔  In Review
#   done           ↔  Complete
#   blocked        ↔  Blocked

sprint: [N]
goal: "[sprint goal]"
start: "[YYYY-MM-DD]"
end: "[YYYY-MM-DD]"
generated: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"

stories:
  - id: "[epic-story, e.g. 1-1]"
    name: "[story name]"
    file: "[production/stories/path.md]"
    priority: must-have        # must-have | should-have | nice-to-have
    status: ready-for-dev      # backlog | ready-for-dev | in-progress | review | done | blocked
    owner: ""
    estimate_days: 0
    blocker: ""
    completed: ""
```

根据迭代计划的任务表初始化每个故事：
- 必须完成的任务 → `priority: must-have`、`status: ready-for-dev`
- 应该完成的任务 → `priority: should-have`、`status: backlog`
- 最好完成的任务 → `priority: nice-to-have`、`status: backlog`

对于 `update`：读取现有的 `sprint-status.yaml`，保留未更改故事的状态，
添加新故事并移除已取消的故事。

---

## 阶段 4：制作人可行性关卡

**评审模式检查** — 在生成 PR-SPRINT 前应用：
- `solo` → 跳过。注明："PR-SPRINT 已跳过 — Solo 模式。"继续阶段 5（QA 计划关卡）。
- `lean` → 跳过（不是 PHASE-GATE）。注明："PR-SPRINT 已跳过 — Lean 模式。"继续阶段 5（QA 计划关卡）。
- `full` → 正常生成。

在最终确定迭代计划前，通过 Task 使用关卡 **PR-SPRINT**（`.claude/docs/director-gates.md`）生成 `producer`。

传入：提议的故事列表（标题、估算、依赖项）、以小时/天计的团队总产能、上一迭代的所有结转工作、里程碑约束和截止日期。

展示制作人的评估。

如果为 UNREALISTIC：修订故事选择（将故事推迟到应该完成或最好完成），并在请求写入审批前重新展示更新后的计划。

如果为 CONCERNS，使用 `AskUserQuestion`：
- 提示："制作人指出了本迭代计划中的问题。你希望如何继续？"
- 选项：
  - `[A] 按计划继续 — 我接受风险`
  - `[B] 调整范围 — 推迟部分应该完成的故事`
  - `[C] 延长迭代时间线`

如果选择 [A]：进入写入审批。
如果选择 [B]：修订故事列表，重新展示更新后的计划，然后进入写入审批。
如果选择 [C]：调整迭代日期和产能，重新展示更新后的计划，然后进入写入审批。

处理制作人的结论后，询问："可以将迭代计划写入 `production/sprints/sprint-[N].md` 和 `production/sprint-status.yaml` 吗？"如果同意，写入两个文件（按需创建目录）。结论：**COMPLETE** — 迭代计划和状态文件已创建。如果拒绝：结论：**BLOCKED** — 用户拒绝写入。

写入后，添加：

> **范围检查：** 如果本迭代包含超出原始史诗范围而添加的故事，请在实现开始前运行 `/scope-check [epic]` 检测范围蔓延。

---

## 阶段 5：QA 计划关卡

在结束迭代计划前，检查本迭代是否已有 QA 计划。

使用 `Glob` 查找 `production/qa/qa-plan-sprint-[N].md`，或 `production/qa/` 中引用本迭代编号的任何文件。

**如果找到 QA 计划**：在迭代计划输出中注明 — "QA 计划：`[path]`" — 然后继续。

**如果不存在 QA 计划**：不要静默继续。明确提示：

> "本迭代没有 QA 计划。缺少 QA 计划意味着测试要求未定义，开发人员将无法从 QA 角度判断怎样才算“完成”，并且本迭代无法在没有 QA 计划的情况下通过 Production → Polish 关卡。
>
> 请现在运行 `/qa-plan sprint`，然后再开始任何实现。该命令只需一个会话，并会生成每个故事所需的测试用例要求。"

使用 `AskUserQuestion`：
- 提示："未找到本迭代的 QA 计划。你希望如何继续？"
- 选项：
  - `[A] 现在运行 /qa-plan sprint — 我会在开始实现前执行（推荐）`
  - `[B] 暂时跳过 — 我了解 QA 签核将在 Production → Polish 关卡被阻塞`

如果选择 [A]：以"迭代计划已写入。接下来运行 `/qa-plan sprint`，然后开始实现。"结束。
如果选择 [B]：在迭代计划文档中添加警告块：

```markdown
> ⚠️ **无 QA 计划**：本迭代在没有 QA 计划的情况下启动。请在最后一个故事实现前
> 运行 `/qa-plan sprint`。Production → Polish 关卡要求提供 QA 签核报告，
> 而该报告需要 QA 计划。
```

---

## 阶段 6：后续步骤

写入迭代计划并处理好 QA 计划状态后：

- `/qa-plan sprint` — **必须在实现开始前执行** — 为每个故事定义测试用例，使开发人员依据 QA 规格而非空白起点进行实现
- `/story-readiness [story-file]` — 在开始故事前验证其是否就绪
- `/dev-story [story-file]` — 开始实现第一个故事
- `/sprint-status` — 在迭代中期检查进度
- `/scope-check [epic]` — 在实现开始前确认没有范围蔓延

**评审模式配置：** 所有总监关卡（制作人可行性、QA 评审、代码评审）均遵循项目评审模式。当文件不存在时，会在阶段 0 中设置评审模式（针对 `new` 迭代）；也可以通过参数 `--review full|lean|solo` 在每次运行时覆盖。文件 `production/review-mode.txt` 包含以下值之一：
- `lean` — 跳过自动总监关卡（文件缺失时的默认值，单人开发最快）
- `full` — 运行所有作为子代理生成的总监关卡
- `solo` — 无条件跳过所有关卡（单人开发者，无评审）

`/sprint-plan`、`/story-readiness`、`/story-done` 和其他技能会在启动时读取此文件。
