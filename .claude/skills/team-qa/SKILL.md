---
name: team-qa
description: "编排 QA 团队完成完整测试周期。协调 qa-lead（策略 + 测试计划）和 qa-tester（测试用例编写 + 缺陷报告），为迭代或功能生成完整的 QA 交付包。涵盖：测试计划生成、测试用例编写、冒烟检查门禁、手动 QA 执行和签核报告。"
argument-hint: "[sprint | feature: system-name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
agent: qa-lead
---

调用此技能时，编排 QA 团队完成结构化测试周期。

**决策点：** 每次阶段转换时，使用 `AskUserQuestion` 将子代理的提案作为可选项呈现给用户。先在对话中写出代理的完整分析，再用简洁的标签记录决定。进入下一阶段前必须获得用户批准。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中指定的模式。
3. 如果仍未指定，默认使用 `lean`。

模式：
- `full`：按说明生成所有总监和主管门禁
- `lean`：跳过总监门禁，除非其类型为 PHASE-GATE（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo`：完全不生成任何总监门禁；运行技能时不使用任何代理门禁

保存确定后的模式，供后续所有阶段使用。

## 团队构成

- **qa-lead**：QA 策略、测试计划生成、故事分类、签核报告
- **qa-tester**：测试用例编写、缺陷报告编写、手动 QA 文档

## 委派方式

使用 Task 工具将每位团队成员生成为子代理：
- `subagent_type: qa-lead`：策略、规划、分类、签核
- `subagent_type: qa-tester`：测试用例和缺陷报告编写

始终在每个代理的提示词中提供完整上下文（故事文件路径、QA 计划路径、范围约束）。尽可能并行启动相互独立的 qa-tester 任务（例如，可以同时为阶段 5 中的多个故事搭建测试内容）。

## 流程

### 阶段 1：加载上下文

执行其他操作前，先收集完整范围：

1. 根据参数确定当前迭代或功能范围：
   - 如果参数是迭代标识符（例如 `sprint-03`）：使用 Glob 在 `production/sprints/` 中查找匹配 `*[sprint-identifier]*.md` 的文件。读取匹配文件；如果匹配多个文件，使用最近修改的文件。
   - 如果参数是 `feature: [system-name]`：查找标记为该系统的故事文件
   - 如果没有参数：读取 `production/session-state/active.md` 和 `production/sprint-status.yaml`（如存在），推断当前迭代

2. 读取 `production/stage.txt`，确认当前项目阶段。

3. 统计找到的故事数量并向用户报告：
   > "即将为 [sprint/feature] 启动 QA 周期。找到 [N] 个故事。当前阶段：[stage]。准备开始制定 QA 策略吗？"

### 阶段 2：QA 策略（qa-lead）

通过 Task 生成 `qa-lead`，审查范围内的所有故事并制定 QA 策略。

要求 qa-lead：
- 读取每个故事文件
- 按类型对每个故事分类：**Logic** / **Integration** / **Visual/Feel** / **UI** / **Config/Data**
- 确定哪些故事需要自动化测试证据，哪些需要手动 QA
- 标记会因缺少验收标准或测试证据而阻塞 QA 的故事
- 估算手动 QA 工作量（所需测试会话数）
- **评估冒烟状态前，检查是否已有冒烟检查报告**：使用 Glob 查找 `production/qa/smoke-*.md`，并读取最近修改的文件（如找到）。如果报告存在，直接使用其结论和发现，不要再次询问用户。如果报告不存在，注明："未找到之前的冒烟检查报告，请先运行 `/smoke-check sprint` 再继续。"，并将冒烟检查状态设为 UNKNOWN（为继续流程，将其视为 PASS WITH WARNINGS）。生成冒烟检查结论：**PASS** / **PASS WITH WARNINGS [list]** / **FAIL [list of failures]** / **UNKNOWN (no report found)**
- 生成策略汇总表和冒烟检查结果：

  | 故事 | 类型 | 需要自动化测试 | 需要手动测试 | 是否阻塞？ |
  |------|------|----------------|--------------|-----------|

  **冒烟检查**：[PASS / PASS WITH WARNINGS / FAIL / UNKNOWN] - [来源：`production/qa/smoke-[date].md` 或 "未找到报告"] - [非 PASS 时的详细信息]

如果冒烟检查结果为 **FAIL**，qa-lead 必须醒目列出失败项。冒烟检查失败时，QA 不得越过策略阶段继续执行。

向用户展示 qa-lead 的完整策略，然后使用 `AskUserQuestion`：

```
question: "QA 策略审查"
options:
  - "策略符合预期，继续制定测试计划"
  - "先调整故事类型，再继续"
  - "跳过被阻塞的故事，继续处理其余故事"
  - "冒烟检查失败，修复问题后重新运行 /team-qa"
  - "取消，先解决阻塞项"
```

如果冒烟检查为 **FAIL**：不要进入阶段 3。展示冒烟检查报告中的失败项并停止。用户必须修复这些问题，重新运行 `/smoke-check sprint`，然后重新运行 `/team-qa`。
如果冒烟检查为 **UNKNOWN**：显示警告："未找到冒烟检查报告。建议在 QA 前运行 `/smoke-check sprint`。当前将谨慎继续。"
如果冒烟检查为 **PASS WITH WARNINGS**：记录警告以供签核报告使用，然后继续。
如果存在阻塞项：明确列出。用户可以选择跳过被阻塞的故事或取消此周期。

### 阶段 3：生成测试计划

使用阶段 2 的策略生成结构化测试计划文档。

测试计划应涵盖：
- **范围**：迭代/功能名称、故事数量、日期
- **故事分类表**：来自阶段 2 的策略
- **自动化测试要求**：哪些故事需要测试文件，以及 `tests/` 中的预期路径
- **手动 QA 范围**：哪些故事需要手动走查，以及要验证的内容
- **范围外事项**：本周期明确不测试的内容及原因
- **准入标准**：开始 QA 前必须满足的条件。始终包括：(1) `production/qa/smoke-*.md` 中存在结论为 PASS 或 PASS WITH WARNINGS 的冒烟检查报告；(2) 构建稳定（启动时不崩溃）；(3) `production/sprint-status.yaml` 中所有 Must Have 故事的 Status 均为 in-progress 或 done。在此基础上添加迭代特有的标准。
- **退出标准**：QA 周期视为完成的条件（所有故事均为 PASS，或为 FAIL 且已提交缺陷）

询问："可以将 QA 计划写入 `production/qa/qa-plan-[sprint]-[date].md` 吗？"

仅在获得批准后写入。

### 阶段 4：编写测试用例（qa-tester）

> **冒烟检查**在阶段 2（QA 策略）中执行。如果阶段 2 的冒烟检查返回 FAIL，周期已在该阶段停止。仅当阶段 2 的冒烟检查结果为 PASS、PASS WITH WARNINGS 或 UNKNOWN 时才运行此阶段。

对于每个需要手动 QA 的故事（Visual/Feel、UI、没有自动化测试的 Integration）：

通过 Task 为每个故事生成 `qa-tester`（尽可能并行运行），并提供：
- 故事文件路径
- QA 计划中与该故事相关的章节
- 被测系统的 GDD 验收标准（如有）
- 编写覆盖所有验收标准的详细测试用例的指令

每组测试用例应包括：
- **前置条件**：开始测试前所需的游戏状态
- **步骤**：编号清晰、无歧义的操作
- **预期结果**：应发生的结果
- **实际结果**：留空，供测试人员填写
- **通过/失败**：留空

执行前将测试用例按故事分组，提交用户审查。

对每组故事使用 `AskUserQuestion`（每批 3 至 4 个）：

```
question: "[Story Group] 的测试用例已准备好。开始手动 QA 前是否审查？"
options:
  - "批准，开始对这些故事执行手动 QA"
  - "修改 [story name] 的测试用例"
  - "跳过 [story name] 的手动 QA，该故事尚未就绪"
```

### 阶段 5：执行手动 QA

逐一测试已批准的手动 QA 列表中的故事。

将故事分为每组 3 至 4 个，并对每个故事使用 `AskUserQuestion`：

```
question: "手动 QA - [Story Title]\n[brief description of what to test]"
options:
  - "PASS - 已验证所有验收标准"
  - "PASS WITH NOTES - 发现轻微问题（随后说明）"
  - "FAIL - 未满足标准（随后说明）"
  - "BLOCKED - 暂时无法测试（说明原因）"
```

每次得到 FAIL 结果后：使用 `AskUserQuestion` 收集失败说明，然后通过 Task 生成 `qa-tester`，在 `production/qa/bugs/` 中编写正式缺陷报告。

缺陷报告命名：`BUG-[NNN]-[short-slug].md`（在目录中现有缺陷编号的基础上递增 NNN）。

收集所有结果后，汇总：
- PASS 故事：[count]
- PASS WITH NOTES 故事：[count]
- FAIL 故事：[count] - 已提交缺陷：[IDs]
- BLOCKED 故事：[count]

### 阶段 6：QA 签核报告

通过 Task 生成 `qa-lead`，使用阶段 4 至 6 的所有结果生成签核报告。

签核报告格式：

```markdown
## QA 签核报告：[Sprint/Feature]
**日期**：[date]

### 测试覆盖汇总
| 故事 | 类型 | 自动化测试 | 手动 QA | 结果 |
|------|------|-----------|---------|------|
| [title] | Logic | PASS | — | PASS |
| [title] | Visual | — | PASS | PASS |

### 发现的缺陷
| ID | 故事 | 严重程度 | Status |
|----|------|----------|--------|
| BUG-001 | [story] | S2 | Open |

### 结论：APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED

**条件**（如有）：[list what must be fixed before the build advances]

### 下一步
[guidance based on verdict]
```

结论规则：
- **APPROVED**：所有故事均为 PASS 或 PASS WITH NOTES；没有处于 Open 状态的 S1/S2 缺陷
- **APPROVED WITH CONDITIONS**：存在处于 Open 状态的 S3/S4 缺陷，或已记录 PASS WITH NOTES 问题；没有 S1/S2 缺陷
- **NOT APPROVED**：存在任何处于 Open 状态的 S1/S2 缺陷；或故事为 FAIL 且没有记录解决办法

按结论给出下一步指引：
- APPROVED："构建已准备好进入下一阶段。运行 `/gate-check` 验证是否可以推进。"
- APPROVED WITH CONDITIONS："推进前先满足相关条件。S3/S4 缺陷可以推迟到打磨阶段处理。"
- NOT APPROVED："解决 S1/S2 缺陷，并重新运行 `/team-qa` 或有针对性的手动 QA，然后再推进。"

询问："可以将此 QA 签核报告写入 `production/qa/qa-signoff-[sprint]-[date].md` 吗？"

仅在获得批准后写入。

## 错误恢复协议

如果通过 Task 生成的任何代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即呈现**：进入依赖该结果的阶段前，向用户报告 "[AgentName]: BLOCKED - [reason]"
2. **评估依赖关系**：检查后续阶段是否需要被阻塞代理的输出。如果需要，在获得用户输入前不得越过该依赖点继续执行。
3. **提供选项**：通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止，先解决阻塞项
4. **始终生成部分报告**：输出已经完成的内容。绝不要因为一个代理被阻塞而丢弃已有工作。

常见阻塞项：
- 缺少输入文件（找不到故事、缺少 GDD）→ 转至创建该文件的技能
- ADR 状态为 Proposed → 不要实施；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事中的指令冲突 → 呈现冲突，不要猜测

## 输出

生成汇总，涵盖：范围内的故事、冒烟检查结果、手动 QA 结果、已提交的缺陷（含 ID 和严重程度），以及最终的 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 结论。

结论：**COMPLETE** - QA 周期已完成。
结论：**BLOCKED** - 冒烟检查失败或关键阻塞项导致周期无法完成；已生成部分报告。

## 更新会话状态

最终阶段完成后（签核报告已写入或结论为 BLOCKED），静默追加以下内容到 `production/session-state/active.md`：

```
<!-- QA RUN: [date] | Sprint: [sprint identifier or "ad-hoc"] | Verdict: [PASS/FAIL/CONCERNS] | Report: production/qa/qa-[date].md -->
```
