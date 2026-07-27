# 技能测试规范：/story-done

## 技能概述

`/story-done` 闭合设计与实施之间的循环。它在故事实施结束时运行，读取故事文件，
并对照实现验证每项验收标准。它检查 GDD 和 ADR 偏差、提示进行代码审查、将故事状态
更新为 `Complete`、记录所有技术债务，并显示迭代中下一个已就绪的故事。它会给出
COMPLETE / COMPLETE WITH NOTES / BLOCKED 结论，并写入故事文件，也可选择写入
`docs/tech-debt-register.md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 5 个阶段标题（复杂技能适用时应使用 `context: fork`）
- [ ] 包含结论关键字：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议表述（写入故事文件和技术债务登记表）
- [ ] 包含下一步移交说明（显示迭代中的下一个故事）

---

## 测试用例

### 用例 1：正常路径——所有验收标准均满足且无偏差

**测试夹具：**
- `production/epics/core/story-light-pickup.md` 中的故事文件包含：
  - 3 项验收标准，均按描述实施
  - 引用 GDD 需求的 `TR-ID: TR-light-001`
  - `ADR: docs/architecture/adr-003-inventory.md`（Accepted）
  - `Status: In Progress`
- 故事中列出的实现文件存在于 `src/`
- TR-light-001 的 GDD 需求文本与功能实现方式一致
- 已遵循 ADR 指导（无偏差）

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取故事文件并提取所有关键字段
2. 技能从 `tr-registry.yaml` 重新读取 GDD 需求（而非使用故事中引用的文本）
3. 技能读取引用的 ADR 以了解实施约束
4. 技能评估每项验收标准（可以自动验证时自动验证，否则提示手动验证）
5. 技能检查 GDD 需求偏差
6. 技能检查 ADR 指导偏差
7. 技能提示用户："Please provide the code review outcome for this story"
8. 技能给出 COMPLETE 结论
9. 技能询问："May I update story Status to Complete and add Completion Notes?"
10. 如果用户同意，技能更新故事文件
11. 技能显示迭代中下一个 `Ready for Dev` 故事

**断言：**
- [ ] 技能读取 `docs/architecture/tr-registry.yaml` 以获取 TR-ID 需求文本（而不只是读取故事）
- [ ] 技能读取引用的 ADR 文件（而不只是故事中的引用）
- [ ] 每项验收标准均列出 VERIFIED / DEFERRED / FAILED 状态
- [ ] 技能提示用户提供代码审查结果（不跳过此步骤）
- [ ] 所有标准均已验证且不存在偏差时，结论为 COMPLETE
- [ ] 技能在更新故事文件前询问 "May I write"
- [ ] 未经用户确认，技能不自动更新故事状态
- [ ] 完成后，技能显示 `production/sprints/` 中下一个已就绪的故事

---

### 用例 2：阻塞路径——无法验证验收标准

**测试夹具：**
- 故事文件包含一项验收标准："Player sees correct animation on pickup"
- 该标准没有自动化测试
- 尚未执行手动验证
- 所有其他标准均已满足

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能处理所有验收标准
2. 处理到动画标准时，发现无法自动验证
3. 技能询问用户："Acceptance criterion 'Player sees correct animation on
   pickup' cannot be auto-verified. Has this been manually tested?"
4. 如果用户回答 No，则将该标准标记为 DEFERRED，结论变为 COMPLETE WITH NOTES
5. 技能在完成说明中记录延期标准
6. 询问："May I write updated story with deferred criterion noted?"

**断言：**
- [ ] 对于无法验证的标准，技能询问用户，而非假定为 PASS
- [ ] 延期标准使结论为 COMPLETE WITH NOTES（而非 COMPLETE 或 BLOCKED）
- [ ] 完成说明中明确指出延期标准
- [ ] 技能在更新故事文件前仍询问 "May I write"

---

### 用例 3：阻塞路径——检测到 GDD 偏差

**测试夹具：**
- 故事的 TR-ID 指向需求："Player can carry max 3 light sources"
- `src/` 中的实现使用变量 `MAX_CARRIED_LIGHTS = 5`
- 这是对 GDD 的有意偏离

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取 GDD 需求文本（最多 3 个）
2. 技能检测到需求与实现值（5）之间的差异
3. 技能将其标记为 GDD 偏差，并要求用户分类：
   - INTENTIONAL：记录偏差及原因
   - ERROR：必须修复实现，才能将故事标记为 Complete
   - OUT OF SCOPE：需求已更改，需要更新 GDD
4. 如果为 INTENTIONAL，技能在完成说明中记录偏差，结论为 COMPLETE WITH NOTES
5. 如果为 ERROR，结论为 BLOCKED，直至实现得到修正

**断言：**
- [ ] 技能检测到 GDD 需求与实现值不匹配
- [ ] 技能要求用户对偏差进行分类（不自动作出任何假定）
- [ ] INTENTIONAL 偏差 → COMPLETE WITH NOTES（而非 BLOCKED）
- [ ] ERROR 偏差 → 修复前结论为 BLOCKED
- [ ] 检测到的偏差记录在完成说明或技术债务登记表中

---

### 用例 4：边界情况——无参数，自动检测当前故事

**测试夹具：**
- `production/session-state/active.md` 包含对
  `production/epics/core/story-oxygen-drain.md` 的引用，并将其作为当前故事
- 该故事文件存在，且包含 `Status: In Progress`

**输入：** `/story-done`（无参数）

**预期行为：**
1. 技能读取 `production/session-state/active.md`
2. 技能找到当前故事引用
3. 技能读取该故事文件并按正常流程继续
4. 输出确认自动检测到的故事

**断言：**
- [ ] 未提供参数时，技能读取 `production/session-state/active.md`
- [ ] 技能在继续前识别并确认自动检测到的故事
- [ ] 如果会话状态中未找到故事，技能要求用户提供路径

---

---

### 用例 5：主管门禁——LP-CODE-REVIEW 在不同审查模式下的行为

**测试夹具：**
- 故事文件位于 `production/epics/core/story-light-pickup.md`
- 所有验收标准均已验证，且无 GDD 偏差
- `production/session-state/review-mode.txt` 存在

**用例 5a——`full` 模式：**
- `review-mode.txt` 包含 `full`

**输入：** `/story-done production/epics/core/story-light-pickup.md`（`full` 模式）

**预期行为：**
1. 技能读取审查模式，确定为 `full`
2. 实现验证完成后，技能调用 LP-CODE-REVIEW 门禁
3. lead-programmer 审查实现
4. 如果 LP 结论为 NEEDS CHANGES，则不能将故事标记为 Complete
5. 如果 LP 结论为 APPROVED，则技能继续将故事标记为 Complete

**断言（5a）：**
- [ ] 技能在决定是否调用 LP-CODE-REVIEW 前读取审查模式
- [ ] 在 `full` 模式下，实现检查完成后调用 LP-CODE-REVIEW 门禁
- [ ] LP 的 NEEDS CHANGES 结论会阻止故事被标记为 Complete
- [ ] 输出中注明门禁结果："Gate: LP-CODE-REVIEW — [result]"
- [ ] 即使 LP 已批准，技能在更新故事状态前仍询问 "May I write"

**用例 5b——`lean` 或 `solo` 模式：**
- `review-mode.txt` 包含 `lean` 或 `solo`

**预期行为：**
1. 技能读取审查模式，确定为 `lean` 或 `solo`
2. 跳过 LP-CODE-REVIEW 门禁
3. 输出注明跳过："[LP-CODE-REVIEW] skipped — Lean/Solo mode"
4. 仅依据验收标准检查继续完成故事

**断言（5b）：**
- [ ] 在 `lean` 或 `solo` 模式下，不启动 LP-CODE-REVIEW 门禁
- [ ] 输出明确注明已跳过
- [ ] 将故事标记为 Complete 前，技能仍要求取得 "May I write" 批准

---

## 协议合规性

- [ ] 更新故事文件前使用 "May I write"
- [ ] 向 `docs/tech-debt-register.md` 添加条目前使用 "May I write"
- [ ] 请求批准前展示完整发现（标准检查、偏差检查）
- [ ] 以显示迭代计划中下一个已就绪的故事结束
- [ ] 如果任何标准处于 ERROR 状态，不将故事标记为 Complete
- [ ] 不跳过代码审查提示

---

## 覆盖说明

- 用例 1 至 3 覆盖了技能完整的 8 阶段流程，但未覆盖每个阶段中的所有边界情况。
- 用例 2 提到了技术债务记录（将延期项写入 `docs/tech-debt-register.md`），
  但它不是主要断言重点；专项覆盖暂缓。
- 用例 1 隐含了 `sprint-status.yaml` 更新（技能的 Phase 7），但它不是主要断言；
  假定其遵循相同的 "May I write" 模式。
- 未明确测试包含多个 TR-ID 或多个 ADR 的故事。
