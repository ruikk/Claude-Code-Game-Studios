---
name: story-done
description: "故事结束时的完成审查。读取故事文件，逐项对照实现验证验收标准，检查与 GDD/ADR 的偏差，提示进行代码审查，将故事状态更新为 Complete，并找出迭代中下一个就绪的故事。"
argument-hint: "[story-file-path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion, Task
model: sonnet
---

# 故事完成

此技能闭合设计与实现之间的反馈循环。任何故事实现结束时都应运行此技能。
它确保在故事标记为完成前验证每项验收标准，明确记录而非悄然引入
与 GDD 和 ADR 的偏差，提示执行代码审查以免遗漏，并让故事文件反映
实际完成状态。

**输出：** 已更新的故事文件（Status: Complete）+ 已找出的下一个故事。

---

## 阶段 1：查找故事

确定审查模式（仅确定一次，供本次运行创建的所有门禁使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该模式
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认为 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

**如果提供了文件路径**（例如 `/story-done production/epics/core/story-damage-calculator.md`）：
直接读取该文件。

**如果未提供参数：**

1. 检查 `production/session-state/active.md` 中当前活跃的故事。
2. 如果未找到，读取 `production/sprints/` 中最新的文件，查找标记为 IN PROGRESS 的故事。
3. 如果找到多个进行中的故事，使用 `AskUserQuestion`：
   - “我们要完成哪个故事？”
   - 选项：列出进行中的故事文件名。
4. 如果找不到任何故事，请用户提供路径。

---

## 阶段 2：读取故事

读取完整的故事文件。提取以下内容并保留在上下文中：

- **故事名称和 ID**
- **GDD 需求 TR-ID** 引用（例如 `TR-combat-001`）
- **清单版本**，即故事头部嵌入的 `Manifest Version`（例如 `2026-03-10`）
- **ADR 引用**
- **验收标准**，即完整列表（每个复选框条目）
- **实现文件**，即 “files to create/modify” 下列出的文件
- **故事类型**，即故事头部的 `Type:` 字段（Logic / Integration / Visual/Feel / UI / Config/Data）
- **引擎说明**，即注明的所有引擎特定约束
- **完成定义**，即故事级 DoD（如果存在）
- **估算范围与实际范围**（如果记录了估算）

还要读取：
- `docs/architecture/tr-registry.yaml`：查找故事中的每个 TR-ID。
  从注册表条目读取*当前* `requirement` 文本。这是 GDD 需求的事实来源；
  不要使用故事内可能引用的需求文本，因为它可能已经过时。
- 引用的 GDD 章节：只读取验收标准和关键规则，不读取完整文档。
  用它交叉检查注册表文本是否仍然准确。
- 引用的 ADR：只读取 Decision 和 Consequences 章节。
- `docs/architecture/control-manifest.md` 的头部：提取当前
  `Manifest Version:` 日期（用于阶段 4 的过时检查）。

---

## 阶段 3：验证验收标准

对故事中的每项验收标准，尝试使用以下三种方法之一进行验证：

### 自动验证（无需询问即可运行）

- **文件存在性检查**：用 `Glob` 查找故事声明要创建的文件。
- **测试通过检查**：如果提到测试文件路径，通过 `Bash` 运行它。
- **无硬编码数值检查**：用 `Grep` 在玩法代码路径中查找本应位于配置文件中的数字字面量。
- **无硬编码字符串检查**：用 `Grep` 在 `src/` 中查找本应位于本地化文件中的玩家可见字符串。
- **依赖检查**：如果某项标准写明“依赖 X”，检查 X 是否存在。

### 需要确认的手动验证（使用 `AskUserQuestion`）

- 关于主观质量的标准（“响应手感良好”“动画播放正确”）
- 关于玩法行为的标准（“玩家在……时受到伤害”“敌人对……作出响应”）
- 性能标准（“在 Xms 内完成”）：询问是否已进行性能分析，或接受为假定通过

在一次 `AskUserQuestion` 调用中合并最多 4 个手动验证问题：

```
question: "[criterion] 是否满足？"
options: "是 — 通过", "否 — 失败", "尚未测试"
```

### 无法验证（标记但不阻塞）

- 需要完整游戏构建才能测试的标准（端到端玩法场景）
- 标记为：`DEFERRED — requires playtest session`

### 测试与标准的可追溯性

完成上述通过/失败/延后检查后，将每项验收标准映射到覆盖它的测试：

对于故事中的每项验收标准：

1. 判断是否存在直接验证此标准的测试，包括单元测试、集成测试或已确认的手动试玩。
   - **单元测试**：在 `tests/unit/` 中检查与标准主题匹配的测试文件或函数名（使用 `Glob` 和 `Grep`）
   - **集成测试**：以相同方式检查 `tests/integration/`
   - **手动确认**：如果上述标准通过 `AskUserQuestion` 获得“是 — 通过”的回答，将其计为手动测试

2. 生成可追溯性表：

```
| 标准 | 测试 | 状态 |
|-----------|------|--------|
| AC-1: [criterion text] | tests/unit/test_foo.gd::test_bar | COVERED |
| AC-2: [criterion text] | 手动试玩确认 | COVERED |
| AC-3: [criterion text] | — | UNTESTED |
```

3. 应用以下升级规则：

   - 如果 **超过 50% 的标准为 UNTESTED**：升级为 **BLOCKING**。测试覆盖率不足以确认故事确实完成；覆盖率改善前，阶段 6 的结论不能是 COMPLETE。
   - 如果**部分（≤50%）标准为 UNTESTED**：保持 ADVISORY，不阻塞完成，但必须写入 Completion Notes。
   - 如果**所有标准均为 COVERED**：除在报告中包含此表外，无需采取其他操作。

4. 对任何 ADVISORY 级别的未测试标准，在阶段 7 的 Completion Notes 中添加：
   `"未测试标准：[AC-N list]。建议在后续故事中添加测试。"`

### 测试证据要求

根据阶段 2 提取的故事类型，检查必需证据：

| 故事类型 | 必需证据 | 门禁级别 |
|---|---|---|
| **Logic** | `tests/unit/[system]/` 中的自动化单元测试，必须存在并通过 | BLOCKING |
| **Integration** | `tests/integration/[system]/` 中的集成测试，或试玩文档 | BLOCKING |
| **Visual/Feel** | `production/qa/evidence/` 中的截图和签核 | ADVISORY |
| **UI** | `production/qa/evidence/` 中的手动走查文档或交互测试 | ADVISORY |
| **Config/Data** | `production/qa/smoke-*.md` 中的冒烟检查通过报告 | ADVISORY |

**对于 Logic 故事**：先读取故事的 **Test Evidence** 章节，提取要求的准确文件路径。
使用 `Glob` 检查该准确路径。如果未找到，再广泛搜索 `tests/unit/[system]/`
（文件可能被放在略有不同的位置）。如果两处都找不到测试文件：
- 标记为 **BLOCKING**：“Logic 故事没有单元测试文件。故事要求文件位于
  `[exact-path-from-Test-Evidence-section]`。将此故事标记为 Complete 前，请创建并运行该测试。”

**对于 Integration 故事**：读取故事的 **Test Evidence** 章节以获取要求的准确路径。
先用 `Glob` 检查该路径，再广泛搜索 `tests/integration/[system]/`，然后检查
`production/session-logs/` 中是否有引用此故事的试玩记录。
如果均未找到：标记为 **BLOCKING**（规则与 Logic 相同）。

**对于 Visual/Feel 和 UI 故事**：用 `Glob` 在 `production/qa/evidence/` 中查找引用此故事的文件。
- 如果没有：标记为 **ADVISORY**：“未找到手动测试证据。使用测试证据模板创建 `production/qa/evidence/[story-slug]-evidence.md`，并在最终关闭前取得签核。”
- 如果找到：读取文件并检查签核表中未勾选的复选框。用 Grep 查找匹配 `| .* | .* | .* | \[ \] Approved` 的行（复选框未勾选的签核行）。如果存在任何未勾选的签核行：标记为 **ADVISORY**：“在 `[path]` 找到证据文件，但仍有 [N] 项签核待完成（在签核表中显示为 `[ ] Approved`）。最终关闭前请取得必需的签核。注意：对于独立开发者，所有角色均可由同一人签核。”
- 如果所有签核行都显示 `[x] Approved` 或同等内容：记录“已找到证据文件，且所有签核均已完成 — ADVISORY 通过。”

**对于 Config/Data 故事**：检查是否存在任何 `production/qa/smoke-*.md` 文件。
如果没有：标记为 **ADVISORY**：“未找到冒烟检查报告。运行 `/smoke-check`。”

**如果未设置故事类型**：标记为 **ADVISORY**：
“未声明故事类型。请在故事头部添加 `Type: [Logic|Integration|Visual/Feel|UI|Config/Data]`，
以便在后续故事中执行测试证据门禁。”

任何 BLOCKING 级别的测试证据缺口都会阻止阶段 6 得出 COMPLETE 结论。

---

## 阶段 4：检查偏差

将实现与设计文档进行对照。

自动运行以下检查：

1. **GDD 规则检查**：使用从 `tr-registry.yaml` 中按故事 TR-ID 查得的当前需求文本，
   检查实现是否反映 GDD 当前的实际要求，而非编写故事时的要求。
   用 `Grep` 在实现文件中查找当前 GDD 章节提到的关键函数名、数据结构或类名。

2. **清单版本过时检查**：比较故事头部嵌入的 `Manifest Version:` 日期与当前
   `docs/architecture/control-manifest.md` 头部的 `Manifest Version:` 日期。
   - 如果一致 → 静默通过。
   - 如果故事版本较旧 → 标记为 ADVISORY：
     `ADVISORY: 故事依据清单 v[story-date] 编写；当前清单为 v[current-date]。
     可能适用新规则。运行 /story-readiness 进行检查。`
   - 如果 control-manifest.md 不存在 → 跳过此检查。

3. **ADR 约束检查**：读取引用 ADR 的 Decision 章节。检查
   `docs/architecture/control-manifest.md`（如果存在）中的禁止模式。
   用 `Grep` 查找 ADR 明确禁止的模式。

4. **硬编码数值检查**：用 `Grep` 在实现文件中查找玩法逻辑里本应位于数据文件中的数字字面量。

5. **范围检查**：实现是否改动了故事声明范围之外的文件？
   （未列在 “files to create/modify” 中的文件）

对发现的每项偏差进行分类：

- **BLOCKING**：实现与 GDD 或 ADR 冲突（标记完成前必须修复）
- **ADVISORY**：实现与规格略有偏离，但功能等价（记录下来，由用户决定）
- **OUT OF SCOPE**：改动了故事声明边界之外的额外文件（标记以便知悉，可能合理，也可能是范围蔓延）

---

## 阶段 4b：QA 覆盖率门禁

**审查模式检查**：在创建 QL-TEST-COVERAGE 前应用：
- `solo` → 跳过。记录：“QL-TEST-COVERAGE 已跳过 — Solo 模式。”继续阶段 5。
- `lean` → 跳过（不是 PHASE-GATE）。记录：“QL-TEST-COVERAGE 已跳过 — Lean 模式。”继续阶段 5。
- `full` → 正常创建。

完成阶段 4 的偏差检查后，通过 Task 使用门禁 **QL-TEST-COVERAGE** 创建 `qa-lead`（参见 `.claude/docs/director-gates.md`）。

传入：
- 故事文件路径和故事类型
- 阶段 3 找到的测试文件路径（准确路径，或“未找到”）
- 故事的 `## QA Test Cases` 章节（创建故事时预先编写的测试规格）
- 故事的 `## Acceptance Criteria` 列表

qa-lead 审查测试是否真正覆盖规定内容，而不只是检查文件是否存在。

应用结论：
- **ADEQUATE** → 继续阶段 5
- **GAPS** → 标记为 **ADVISORY**：“QA 负责人发现覆盖缺口：[list]。故事可以完成，但应在后续故事中处理这些缺口。”
- **INADEQUATE** → 标记为 **BLOCKING**：“QA 负责人：关键逻辑未经测试。覆盖率改善前，结论不能是 COMPLETE。具体缺口：[list]。”

Config/Data 故事跳过此阶段（无需代码测试）。

---

## 阶段 5：主程序员代码审查门禁

**审查模式检查**：在创建 LP-CODE-REVIEW 前应用：
- `solo` → 跳过。记录：“LP-CODE-REVIEW 已跳过 — Solo 模式。”继续阶段 6（完成报告）。
- `lean` → 继续前使用 `AskUserQuestion`：
  - 提示：“lean 模式会跳过代码审查。你是否已对实现文件运行 `/code-review`？”
  - 选项：
    - `是 — /code-review 已通过，或已带建议批准`
    - `否 — 跳过此故事的代码审查`
    - `否 — 我会在迭代收尾前运行 /code-review`
  - 将回答记录在完成说明（阶段 7）中。三个选项都继续阶段 6。
- `full` → 正常创建。

通过 Task 使用门禁 **LP-CODE-REVIEW** 创建 `lead-programmer`（参见 `.claude/docs/director-gates.md`）。

传入：实现文件路径、故事文件路径、相关 GDD 章节和约束该故事的 ADR。

向用户展示结论。如果为 CONCERNS，通过 `AskUserQuestion` 提出问题：
- 选项：`修改已标记问题` / `接受并继续` / `进一步讨论`
如果为 REJECT，在问题解决前不要进入阶段 6 的结论。

如果故事尚无实现文件（在编码完成前运行了此结论流程），跳过此阶段并记录：“LP-CODE-REVIEW 已跳过 — 未找到实现文件。请在实现完成后运行。”

---

## 阶段 6：展示完成报告

更新任何文件前，展示完整报告：

```markdown
## 故事完成：[Story Name]
**故事**：[file path]
**日期**：[today]

### 验收标准：[X/Y passing]
- [x] [Criterion 1] — 已自动验证（测试通过）
- [x] [Criterion 2] — 已确认
- [ ] [Criterion 3] — FAILS：[reason]
- [?] [Criterion 4] — DEFERRED：需要试玩

### 测试与标准的可追溯性
| 标准 | 测试 | 状态 |
|-----------|------|--------|
| AC-1: [text] | [test file::test name] | COVERED |
| AC-2: [text] | 手动确认 | COVERED |
| AC-3: [text] | — | UNTESTED |

### 测试证据
**故事类型**：[Logic | Integration | Visual/Feel | UI | Config/Data | Not declared]
**必需证据**：[unit test file | integration test or playtest | screenshot + sign-off | walkthrough doc | smoke check pass]
**找到的证据**：[YES — `[path]` | NO — BLOCKING | NO — ADVISORY]

### 偏差
[NONE] 或：
- BLOCKING：[description] — [GDD/ADR reference]
- ADVISORY：[description] — 用户已接受 / 已标记为技术债务

### 范围
[All changes within stated scope] 或：
- 改动的额外文件：[list] — [note whether valid or scope creep]

### 结论：COMPLETE / COMPLETE WITH NOTES / BLOCKED
```

**结论定义：**
- **COMPLETE**：所有标准均通过，且没有阻塞性偏差
- **COMPLETE WITH NOTES**：所有标准均通过，且已记录建议性偏差
- **BLOCKED**：必须先解决失败的标准或阻塞性偏差

如果结论为 **BLOCKED**：不要继续阶段 7。列出必须修复的内容，并主动提出协助修复阻塞项。

---

## 阶段 7：更新故事状态

写入任何内容前使用 `AskUserQuestion`：
- 提示：“验证已完成。你希望如何继续？”
- 选项：
  - `关闭故事 — 更新文件、标记为 Complete 并记录说明（推荐）`
  - `关闭故事，并将建议性偏差作为技术债务记录到 docs/tech-debt-register.md`
  - `我想先修复一些问题 — 暂不关闭`
  - `按现状接受偏差并仍然关闭`

如果选择“关闭故事”“关闭故事并记录技术债务”或“接受偏差”：编辑故事文件。
如果选择“关闭故事并记录技术债务”：更新故事文件后，还要将建议性偏差追加到 `docs/tech-debt-register.md`（如果文件不存在则创建）。
如果选择“先修复”：在此停止并列出用户标记的内容。不要写入任何文件。

1. 更新状态字段：`Status: Complete`
2. 将故事头部的 `Last Updated:` 字段更新为今天的日期（格式：`YYYY-MM-DD`）。如果该字段不存在，在 `Status:` 行之后添加。
3. 在底部添加 `## Completion Notes` 章节：

```markdown
## 完成说明
**完成日期**：[date]
**标准**：[X/Y passing]（[any deferred items listed]）
**偏差**：[None] 或 [list of advisory deviations]
**测试证据**：[Logic: test file at path | Visual/Feel: evidence doc at path | None required (Config/Data)]
**代码审查**：[Pending / Complete / Skipped]
```

4. 如果用户选择“关闭故事并记录技术债务”：按以下格式将每项建议性偏差追加到 `docs/tech-debt-register.md`：
   ```
    - **[date]**（[story title]）：[deviation description] — 来源：[story file path]
   ```
    如果文件不存在，创建文件并添加 `# Tech Debt Register` 标题。

5. **更新 `production/sprint-status.yaml`**（如果存在）：
   - 查找与此故事文件路径或 ID 匹配的条目
   - 设置 `status: done` 和 `completed: [today's date]`
   - 更新顶层 `updated` 字段
   - 这是静默更新，无需额外批准（已在上一步获得批准）

6. **建议 git 提交**：输出可直接使用的提交命令，涵盖 dev-story 摘要中的实现文件和已更新的故事文件：

```
建议的提交：
git add [src/ and tests/ files changed during implementation] [story-file-path]
git commit -m "feat: [story title] ([TR-ID])"
```

`validate-commit.sh` 钩子会自动验证设计文档引用并检查硬编码数值。

### 更新会话状态

更新故事文件后，静默追加到 `production/session-state/active.md`：

    ## 会话摘要 — /story-done [date]
    - 结论：[COMPLETE / COMPLETE WITH NOTES / BLOCKED]
    - 故事：[story file path] — [story title]
    - 已记录技术债务：[N items, or "None"]
    - 下一项建议：[next ready story title and path, or "None identified"]

如果 `active.md` 不存在，创建该文件并将此块作为初始内容。
在对话中确认：“会话状态已更新。”

---

## 阶段 8：找出下一个故事

完成后，帮助开发者保持推进节奏：

1. 从 `production/sprints/` 读取当前迭代计划。
2. 查找符合以下条件的故事：
   - Status 为 READY 或 NOT STARTED
   - 未被其他未完成故事阻塞
   - 位于 Must Have 或 Should Have 层级

展示：

```
### 下一项
以下故事已准备好领取：
1. [Story name] — [1-line description] — 估算：[X hrs]
2. [Story name] — [1-line description] — 估算：[X hrs]

开始前运行 `/story-readiness [path]`，确认故事已可实施。
```

如果本次迭代中不再有剩余的 Must Have 故事（全部为 Complete 或 Blocked）：

```
### 迭代收尾顺序

所有 Must Have 故事均已完成。推进前必须获得 QA 签核。
按顺序运行：

1. `/smoke-check sprint` — 验证关键路径仍可端到端运行
2. `/team-qa sprint` — 完整 QA 周期：执行测试用例、缺陷分诊、生成签核报告
3. `/retrospective` — 记录做得好的方面、做得不好的方面及下一迭代的行动项
4. `/gate-check` — QA 批准后推进到下一阶段（仅在确实要推进阶段时运行）
5. `/sprint-plan new` — 结合速率数据和回顾行动项规划下一迭代

在 `/team-qa` 返回 APPROVED 或 APPROVED WITH CONDITIONS 前，不要运行 `/gate-check`。
```

如果仍有未开始的 Should Have 故事，将它们与收尾顺序一并展示，让用户选择立即结束迭代，还是先纳入更多工作。

如果没有更多就绪故事，但仍有 Must Have 故事处于 In Progress（尚未 Complete）：
“没有更多可开始的故事 — 仍有 [N] 个 Must Have 故事进行中。请先继续实现这些故事，再进行迭代收尾。”

---

## 协作协议

- **未经用户批准，绝不将故事标记为完成**：阶段 7 要求在编辑任何文件前获得明确的“是”。
- **绝不自动修复失败的标准**：报告问题并询问如何处理。
- **偏差是事实，而非判断**：中立地展示，由用户决定是否可以接受。
- **BLOCKED 结论是建议性的**：用户可以覆盖该结论并仍然标记完成；如果这样做，明确记录风险。
- 使用 `AskUserQuestion` 提示代码审查，并批量确认手动标准。

---

## 建议的后续步骤

- 开始实现前运行 `/story-readiness [next-story-path]` 验证下一个故事
- 如果所有 Must Have 故事均已完成：运行 `/smoke-check sprint` → `/team-qa sprint` → `/gate-check`
- 如果记录了技术债务：通过 `/tech-debt` 跟踪，保持登记表最新
