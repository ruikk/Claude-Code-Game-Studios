# 技能测试规范：/story-readiness

## 技能概述

`/story-readiness` 验证故事文件是否已准备好供开发人员接手实施。它检查四个维度：
设计（嵌入的 GDD 需求）、架构（ADR 引用和状态）、范围（明确的边界和 DoD）以及
完成定义（可测试的标准）。它会给出 READY / NEEDS WORK / BLOCKED 结论。
该技能为只读技能，在任何开发人员接手故事前运行。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题或编号检查章节
- [ ] 包含结论关键字：READY、NEEDS WORK、BLOCKED
- [ ] 不要求使用 "May I write" 表述（只读技能）
- [ ] 包含下一步移交说明（得出结论后应做什么）

---

## 测试用例

### 用例 1：正常路径——故事已完全就绪

**测试夹具：**
- 故事文件位于 `production/epics/core/story-light-pickup.md`
- 故事包含：
  - `TR-ID: TR-light-001`（GDD 需求引用）
  - `ADR: docs/architecture/adr-003-inventory.md`
  - 引用的 ADR 存在且状态为 `Accepted`
  - 引用的 TR-ID 存在于 `docs/architecture/tr-registry.yaml`
  - 故事包含 `## Acceptance Criteria`，其中至少有 3 个可测试项
  - 故事包含 `## Definition of Done` 章节
  - 故事包含 `Status: Ready for Dev`
  - 故事头部的清单版本与当前 `docs/architecture/control-manifest.md` 一致

**输入：** `/story-readiness production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取故事文件
2. 技能读取引用的 ADR，验证其状态为 `Accepted`
3. 技能读取 `docs/architecture/tr-registry.yaml`，验证 TR-ID 存在
4. 技能读取 `docs/architecture/control-manifest.md`，验证清单版本一致
5. 技能评估全部 4 个维度（设计、架构、范围、DoD）
6. 所有检查通过时，技能输出 READY 结论

**断言：**
- [ ] 技能读取引用的 ADR 文件（而不只是故事）
- [ ] 技能验证 ADR 状态为 `Accepted`（而非 `Proposed`）
- [ ] 技能读取 `tr-registry.yaml` 以验证 TR-ID 存在
- [ ] 输出包含全部 4 个维度的检查结果
- [ ] 所有检查通过时，结论为 READY
- [ ] 技能不写入任何文件

---

### 用例 2：阻塞路径——引用的 ADR 为 Proposed（而非 Accepted）

**测试夹具：**
- 故事文件存在，并包含 `ADR: docs/architecture/adr-005-light-system.md`
- `adr-005-light-system.md` 存在，但包含 `Status: Proposed`
- 故事的其他内容均完整

**输入：** `/story-readiness production/epics/core/story-light-system.md`

**预期行为：**
1. 技能读取故事
2. 技能读取 `adr-005-light-system.md`，发现 `Status: Proposed`
3. 技能将其标记为阻塞问题（不能依据尚未接受的 ADR 实施）
4. 技能输出 BLOCKED 结论
5. 技能建议：接手故事前接受或拒绝该 ADR

**断言：**
- [ ] ADR 为 Proposed 时，结论为 BLOCKED（而非 NEEDS WORK 或 READY）
- [ ] 输出明确指出处于 Proposed 状态的 ADR 是阻塞项
- [ ] 输出建议先解决 ADR 状态再继续
- [ ] 无论其他检查是否通过，技能都不输出 READY

---

### 用例 3：需要完善——缺少验收标准

**测试夹具：**
- 故事文件存在，但没有 `## Acceptance Criteria` 章节
- ADR 引用存在且状态为 `Accepted`
- TR-ID 存在于注册表中
- 清单版本一致

**输入：** `/story-readiness production/epics/core/story-oxygen-drain.md`

**预期行为：**
1. 技能读取故事
2. 技能发现没有 Acceptance Criteria 章节
3. 技能将其标记为 NEEDS WORK 问题（故事不完整，但未被阻塞）
4. 技能输出 NEEDS WORK 结论
5. 技能指出缺少的章节，并建议添加可衡量的标准

**断言：**
- [ ] 缺少 Acceptance Criteria 章节时，结论为 NEEDS WORK（而非 BLOCKED 或 READY）
- [ ] 输出明确指出缺少 Acceptance Criteria 章节
- [ ] 输出建议添加可测试、可衡量的标准
- [ ] 技能区分 NEEDS WORK（无需外部依赖即可修复）与 BLOCKED（需要外部操作）

---

### 用例 4：边界情况——清单版本过期

**测试夹具：**
- 故事文件头部包含 `Manifest Version: 2026-01-15`
- `docs/architecture/control-manifest.md` 包含 `Manifest Version: 2026-03-10`
- 版本不一致（故事创建于清单更新之前）

**输入：** `/story-readiness production/epics/core/story-mirror-rotation.md`

**预期行为：**
1. 技能读取故事并提取清单版本 `2026-01-15`
2. 技能读取控制清单头部并提取当前版本 `2026-03-10`
3. 技能检测到版本不一致
4. 技能将其标记为提示性问题（不阻塞，但值得注意）
5. 结论为 NEEDS WORK，并注明清单已过期

**断言：**
- [ ] 技能读取 `docs/architecture/control-manifest.md` 以获取当前版本
- [ ] 技能将故事中嵌入的清单版本与当前清单版本进行比较
- [ ] 清单版本过期时得出 NEEDS WORK（而非 BLOCKED 或 READY）
- [ ] 输出说明故事中嵌入的指导可能已过时

---

---

### 用例 5：主管门禁——QL-STORY-READY 在不同审查模式下的行为

**测试夹具：**
- 故事文件存在且为 READY（全部 4 个维度通过、ADR 为 Accepted、标准齐全）
- `production/session-state/review-mode.txt` 存在

**用例 5a——`full` 模式：**
- `review-mode.txt` 包含 `full`

**输入：** `/story-readiness production/epics/core/story-light-pickup.md`（`full` 模式）

**预期行为：**
1. 技能读取审查模式，确定为 `full`
2. 完成自身的四维检查后，技能调用 QL-STORY-READY 门禁
3. qa-lead 审查故事的就绪情况
4. 如果 qa-lead 的结论为 INADEQUATE，则无论四维检查结果如何，故事结论均为 BLOCKED
5. 如果 qa-lead 的结论为 ADEQUATE，则按正常流程得出结论

**断言（5a）：**
- [ ] 技能在决定是否调用 QL-STORY-READY 前读取审查模式
- [ ] 在 `full` 模式下，四维检查完成后调用 QL-STORY-READY 门禁
- [ ] qa-lead 的 INADEQUATE 结论覆盖四维检查的 READY 结果，最终结论为 BLOCKED
- [ ] 输出中注明门禁调用："Gate: QL-STORY-READY — [result]"

**用例 5b——`lean` 或 `solo` 模式：**
- `review-mode.txt` 包含 `lean` 或 `solo`

**预期行为：**
1. 技能读取审查模式，确定为 `lean` 或 `solo`
2. 跳过 QL-STORY-READY 门禁
3. 输出注明跳过："[QL-STORY-READY] skipped — Lean/Solo mode"
4. 结论仅依据四维检查

**断言（5b）：**
- [ ] 在 `lean` 或 `solo` 模式下，不启动 QL-STORY-READY 门禁
- [ ] 输出明确注明已跳过
- [ ] 结论仅依据四维检查

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在给出结论前展示完整的检查结果
- [ ] 不请求批准（不写入文件）
- [ ] 以建议的下一步结束（修复问题或继续实施）
- [ ] 清晰区分三个结论级别（READY、NEEDS WORK、BLOCKED）

---

## 覆盖说明

- 此处未明确测试 TR-ID 完全不在注册表中的情况；它遵循与用例 3 相同的
  NEEDS WORK 模式。
- 未测试“无参数”路径（技能自动检测当前故事），因为它依赖
  `production/session-state/active.md` 的内容，难以可靠地构造测试夹具。
- 未测试引用多个 ADR 的故事；假定其行为为累加式（所有 ADR 都必须为
  Accepted 才能得出 READY 结论）。
