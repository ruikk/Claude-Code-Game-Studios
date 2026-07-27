# 技能测试规范：/gate-check

## 技能概述

`/gate-check` 验证项目是否已准备好进入下一个开发阶段。它检查必需产物、执行质量检查、
向用户询问无法验证的项目，并给出 PASS / CONCERNS / FAIL 结论。结论为 PASS 且用户确认后，
它会将新阶段名称写入 `production/stage.txt`。它管理全部 6 个阶段转换，是流程中最关键的
门禁技能。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题（编号为 Phase N 或使用 `##` 的章节）
- [ ] 包含结论关键字：PASS、CONCERNS、FAIL
- [ ] 包含 "May I write" 协作协议表述
- [ ] 末尾包含下一步移交说明（Follow-Up Actions 章节）

---

## 测试用例

### 用例 1：正常路径——所有 Concept 产物均存在，进入 Systems Design

**测试夹具：**
- `design/gdd/game-concept.md` 存在，且内容包含所有必需章节
- `design/gdd/game-pillars.md` 存在（或支柱已在概念文档中定义）
- 尚无系统索引（这符合当前阶段的要求）

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能读取 `design/gdd/game-concept.md` 并验证其中有内容
2. 技能检查游戏支柱（位于概念文档或单独文件中）
3. 技能检查质量项（已描述核心循环、已确定目标受众）
4. 技能输出所有项目均已标记的结构化检查清单
5. 技能给出 PASS / CONCERNS / FAIL 结论
6. 如果为 PASS，技能询问："May I update `production/stage.txt` to 'Systems Design'?"

**断言：**
- [ ] 技能先使用 Glob 或 Read 验证 `design/gdd/game-concept.md` 存在，再将其标记为已检查
- [ ] 输出包含 "Required Artifacts" 章节，并列出每项的检查状态
- [ ] 输出包含 "Quality Checks" 章节，并列出每项的检查状态
- [ ] 输出包含 "Verdict" 行，其值为 PASS / CONCERNS / FAIL 之一
- [ ] 技能询问无法验证的质量项（例如 "Has this been reviewed?"），而非假定为 PASS
- [ ] 技能在更新 `production/stage.txt` 前询问 "May I write"
- [ ] 未经用户明确确认，技能不写入 `production/stage.txt`

---

### 用例 2：失败路径——缺少 Concept → Systems Design 所需产物

**测试夹具：**
- `design/gdd/game-concept.md` 不存在
- 游戏支柱文档不存在
- `design/gdd/` 目录为空或不存在

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能尝试读取 `design/gdd/game-concept.md`，但未找到文件
2. 技能将必需产物标记为缺失（不存在）
3. 技能输出 FAIL 结论
4. 技能列出阻塞项："No game concept document found"
5. 技能建议补救措施：运行 `/brainstorm` 创建该文档

**断言：**
- [ ] 缺少必需产物时，结论为 FAIL（而非 PASS 或 CONCERNS）
- [ ] 输出明确指出缺少 `design/gdd/game-concept.md`
- [ ] 输出包含 "Blockers" 章节，其中至少有 1 项
- [ ] 输出建议使用 `/brainstorm` 作为补救措施
- [ ] 结论为 FAIL 时，技能不写入 `production/stage.txt`

---

### 用例 3：无参数——自动检测当前阶段

**测试夹具：**
- `production/stage.txt` 包含 `Concept`
- `design/gdd/game-concept.md` 存在且有内容
- 尚无系统索引

**输入：** `/gate-check`（无参数）

**预期行为：**
1. 技能读取 `production/stage.txt` 以确定当前阶段
2. 技能确定下一个门禁为 Concept → Systems Design
3. 技能继续执行 Systems Design 门禁检查
4. 输出明确说明正在验证哪个阶段转换

**断言：**
- [ ] 技能读取 `production/stage.txt`（或使用 project-stage-detect 启发式规则）以确定当前阶段
- [ ] 输出标题同时指出当前阶段和目标阶段（例如 "Gate Check: Concept → Systems Design"）
- [ ] 如果可以确定当前阶段，技能不询问用户要检查哪个门禁

---

### 用例 4：边界情况——正确标记手动检查项

**测试夹具：**
- Concept → Systems Design 所需的所有产物均存在
- 不存在试玩或审查记录（无法自动验证质量检查）

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能验证所有产物文件均存在
2. 技能遇到质量检查项："Game concept reviewed (not MAJOR REVISION NEEDED)"
3. 由于不存在审查记录，技能将该项标记为 MANUAL CHECK NEEDED
4. 技能询问用户："Has the game concept been reviewed for design quality?"
5. 技能等待用户输入，然后再确定最终结论

**断言：**
- [ ] 无法自动验证的项目标记为 `[?] MANUAL CHECK NEEDED`，而非假定为 PASS
- [ ] 对至少一个无法验证的质量项，技能向用户提问
- [ ] 技能默认不将无法验证的项目标记为 PASS

---

---

### 用例 5：主管门禁——`lean`、`full` 与 `solo` 模式

**测试夹具：**
- `production/session-state/review-mode.txt` 存在（或存在等效状态文件）
- 目标门禁所需的所有产物均存在
- `design/gdd/game-concept.md` 存在

**用例 5a——`full` 模式：**
- `review-mode.txt` 包含 `full`

**输入：** `/gate-check systems-design`（已启用 `full` 模式）

**预期行为：**
1. 技能读取审查模式，确定为 `full`
2. 技能并行启动全部 4 个 PHASE-GATE 主管提示：
   - CD-PHASE-GATE（creative-director）
   - TD-PHASE-GATE（technical-director）
   - PR-PHASE-GATE（producer）
   - AD-PHASE-GATE（art-director）
3. 如果一名主管返回 CONCERNS，则总体门禁结论至少为 CONCERNS
4. 收集全部 4 个结论后再生成最终输出

**断言（5a）：**
- [ ] 技能在决定启动哪些主管前读取 review-mode
- [ ] 启动全部 4 个 PHASE-GATE 主管提示（而非仅启动 1 个或 2 个）
- [ ] 并行启动主管（同时而非依次启动）
- [ ] 任一主管的 CONCERNS 结论都会传递到总体结论
- [ ] 如果任何主管返回 CONCERNS 或 REJECT，结论不会自动成为 PASS

**用例 5b——`solo` 模式：**
- `review-mode.txt` 包含 `solo`

**输入：** `/gate-check systems-design`（已启用 `solo` 模式）

**预期行为：**
1. 技能读取审查模式，确定为 `solo`
2. 每名主管均注明为已跳过："[CD-PHASE-GATE] skipped — Solo mode"
3. 门禁结论仅依据产物检查和质量检查得出
4. 不启动任何主管门禁

**断言（5b）：**
- [ ] 在 `solo` 模式下，不启动任何主管门禁
- [ ] 输出明确注明每个已跳过的门禁："[GATE-ID] skipped — Solo mode"
- [ ] 结论仅依据产物检查和质量检查

**用例 3 修正说明：**
用例 3 的断言先前写道："Skill does not ask the user which gate to check
if current stage is determinable." 此说法正确。但在运行完整检查前，技能确实会使用
AskUserQuestion 确认自动检测到的阶段转换。这是确认步骤，而非选择门禁。用例 3 的断言
不应将此确认视为失败。

---

## 协议合规性

- [ ] 更新 `production/stage.txt` 前使用 "May I write"
- [ ] 请求写入批准前展示完整的检查清单报告
- [ ] 以 "Follow-Up Actions" 章节结束，按结论列出下一步操作
- [ ] 未经用户明确确认，绝不推进阶段
- [ ] 如果 `production/stage.txt` 不存在，未经询问绝不自动创建

---

## 覆盖说明

- 此处未覆盖 Production → Polish 和 Polish → Release 门禁，因为它们需要复杂的
  多产物设置（迭代计划、试玩数据、QA 签核）；这些内容留待专门的后续规范处理。
- 此处未明确测试 CONCERNS 结论路径（存在较小缺口但不阻塞）；它介于用例 1 和
  用例 2 之间，并遵循相同模式。
- 未覆盖 Vertical Slice 验证块（Pre-Production → Production 门禁），因为它需要
  可玩构建上下文，无法用文档测试夹具表达。
