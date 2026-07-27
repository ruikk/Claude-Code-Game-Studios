# 技能测试规范：/create-epics

## 技能摘要

`/create-epics` 读取所有已批准的 GDD，并将其转换为 EPIC.md 文件，每个系统对应一个。史诗按层级组织（Foundation → Core → Feature → Presentation），并在每个层级内按优先级处理。每个 EPIC.md 包含范围、主管 ADR、GDD 需求、引擎风险等级和 Definition of Done。创建每个 EPIC 文件前，技能会询问 "May I write"。

在 `full` 评审模式下，起草史诗后、写入任何文件前运行 PR-EPIC 门禁。在 `lean` 或 `solo` 模式下跳过并注明 PR-EPIC。史诗写入 `production/epics/[layer]/EPIC-[name].md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：CREATED、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（逐史诗审批）
- [ ] 末尾包含下一步交接（`/create-stories`）
- [ ] 说明 PR-EPIC 门禁行为：full 模式运行，lean/solo 模式跳过

---

## 主管门禁检查

在 `full` 模式下：起草史诗后、写入任何史诗文件前，运行 PR-EPIC（producer）门禁。如果 PR-EPIC 返回 CONCERNS，则在询问 "May I write" 前修订史诗。

在 `lean` 模式下：跳过 PR-EPIC。输出注明："PR-EPIC skipped — lean mode"。

在 `solo` 模式下：跳过 PR-EPIC。输出注明："PR-EPIC skipped — solo mode"。

---

## 测试用例

### 用例 1：正常路径——两个已批准的 GDD 创建两个 EPIC 文件

**测试夹具：**
- `design/gdd/systems-index.md` 存在且列出 2 个系统
- 两个系统在 `design/gdd/` 中都有已批准的 GDD
- `docs/architecture/architecture.md` 存在且包含匹配模块
- 每个系统至少有一个 Accepted ADR
- `production/session-state/review-mode.txt` 内容为 `lean`

**输入：** `/create-epics`

**预期行为：**
1. 技能读取系统索引和两个 GDD
2. 起草 2 个 EPIC 定义（层级、GDD 路径、ADR、需求、引擎风险）
3. 跳过 PR-EPIC 门禁（lean 模式），并在输出中注明
4. 对每个史诗询问 "May I write `production/epics/[layer]/EPIC-[name].md`?"
5. 获批后写入两个 EPIC 文件
6. 创建或更新 `production/epics/index.md`

**断言：**
- [ ] 在任何写入询问前显示史诗摘要
- [ ] 对每个史诗分别询问 "May I write"，而非一次询问所有史诗
- [ ] 每个 EPIC.md 包含：层级、GDD 路径、主管 ADR、需求表、Definition of Done
- [ ] 输出注明跳过 PR-EPIC
- [ ] 写入后更新 `production/epics/index.md`
- [ ] 未经逐史诗批准，技能不会写入 EPIC 文件

---

### 用例 2：失败路径——未找到已批准的 GDD

**测试夹具：**
- `design/gdd/systems-index.md` 存在
- `design/gdd/` 中没有状态为 approved 的 GDD（全部为 Draft 或 In Progress）

**输入：** `/create-epics`

**预期行为：**
1. 技能读取系统索引并尝试查找已批准的 GDD
2. 未找到已批准的 GDD
3. 技能输出："No approved GDDs to convert. GDDs must be Approved before creating epics."
4. 技能建议运行 `/design-system` 并先完成 GDD 审批
5. 技能退出，不创建任何 EPIC 文件

**断言：**
- [ ] 没有已批准 GDD 时，技能以清晰消息正常停止
- [ ] 不写入 EPIC 文件
- [ ] 技能建议正确的下一步
- [ ] 结论为 BLOCKED

---

### 用例 3：主管门禁——Full 模式在写入前生成 PR-EPIC

**测试夹具：**
- 存在 2 个已批准的 GDD
- `production/session-state/review-mode.txt` 内容为 `full`

**Full 模式预期行为：**
1. 技能起草两个史诗
2. 生成 PR-EPIC 门禁并评审史诗草稿
3. 如果 PR-EPIC 返回 APPROVED，正常进行 "May I write" 询问
4. 获批后写入史诗文件

**断言（full 模式）：**
- [ ] 输出显示 PR-EPIC 为活动门禁
- [ ] PR-EPIC 在任何 "May I write" 询问前运行
- [ ] PR-EPIC 完成前不写入史诗文件

**测试夹具（lean 模式）：**
- 相同 GDD
- `production/session-state/review-mode.txt` 内容为 `lean`

**Lean 模式预期行为：**
1. 起草史诗
2. 跳过 PR-EPIC，并在输出中注明
3. 直接进行 "May I write" 询问

**断言（lean 模式）：**
- [ ] 输出中出现 "PR-EPIC skipped — lean mode"
- [ ] 无需等待 PR-EPIC，技能即可进行 "May I write" 询问

---

### 用例 4：边界情况——某个 GDD 对应的史诗已存在

**测试夹具：**
- 某个已批准 GDD 对应的 `production/epics/[layer]/EPIC-[name].md` 已存在
- 另一个 GDD 没有现有 EPIC 文件

**输入：** `/create-epics`

**预期行为：**
1. 技能检测到第一个系统已有 EPIC 文件
2. 技能提供更新而非覆盖选项："EPIC-[name].md already exists. Update it, or skip?"
3. 对第二个系统（没有现有文件）正常进行 "May I write"

**断言：**
- [ ] 写入前检测已有 EPIC 文件
- [ ] 向用户提供更新或跳过选项，不自动覆盖
- [ ] 新系统的 EPIC 正常创建且无冲突

---

### 用例 5：主管门禁——PR-EPIC 返回 CONCERNS

**测试夹具：**
- 存在 2 个已批准的 GDD
- `production/session-state/review-mode.txt` 内容为 `full`
- PR-EPIC 门禁返回 CONCERNS（例如某个史诗的范围过大）

**输入：** `/create-epics`

**预期行为：**
1. PR-EPIC 门禁生成并返回 CONCERNS，同时提供具体反馈
2. 技能在任何写入询问前向用户呈现关注项
3. 向用户提供修改史诗、接受关注项并继续、或停止的选项
4. 用户修改时，在 "May I write" 询问前显示更新后的史诗草稿
5. CONCERNS 未处理时，技能不会写入史诗

**断言：**
- [ ] PR-EPIC 的 CONCERNS 在写入前向用户显示
- [ ] 返回 CONCERNS 时，技能不会自动写入史诗
- [ ] 向用户提供明确的修改、继续或停止选择
- [ ] 修改后、最终审批前重新显示史诗草稿

---

## 协议合规性

- [ ] 在任何 "May I write" 询问前向用户显示史诗草稿
- [ ] 对每个史诗分别询问 "May I write"，而非一次询问整个批次
- [ ] 活动门禁（如有）在写入询问前运行，而不是之后
- [ ] 在输出中按名称和模式注明跳过的门禁
- [ ] EPIC.md 内容只能来自 GDD、ADR 和架构文档，不得编造
- [ ] 以每个已创建史诗的下一步交接结束：`/create-stories [epic-slug]`

---

## 覆盖说明

- Core、Feature 和 Presentation 层的处理与 Foundation 遵循相同的逐史诗模式，未单独测试各层顺序。
- 根据主管 ADR 分配引擎风险等级（LOW/MEDIUM/HIGH）通过用例 1 的夹具结构隐式验证。
- `layer: [name]` 和 `[system-name]` 参数模式与默认的全部系统模式遵循相同审批模式。
