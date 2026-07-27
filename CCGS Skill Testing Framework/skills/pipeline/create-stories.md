# 技能测试规范：/create-stories

## 技能摘要

`/create-stories` 将单个史诗拆分为可供开发者直接处理的故事文件。它读取 EPIC.md、对应 GDD、主管 ADR、控制清单和 TR 注册表。每个故事都获得结构化 frontmatter，包括：Title、Epic、Layer、Priority、Status、TR-ID、ADR 引用、Acceptance Criteria 和 Definition of Done。故事按类型分类（Logic / Integration / Visual/Feel / UI / Config/Data），类型决定所需测试证据路径。

在 `full` 评审模式下，每个故事创建后运行 QL-STORY-READY 检查。在 `lean` 或 `solo` 模式下跳过 QL-STORY-READY。写入每个故事文件前，技能会询问 "May I write"。故事写入 `production/epics/[layer]/story-[name].md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、BLOCKED、NEEDS WORK
- [ ] 包含 "May I write" 协作协议用语（逐故事审批）
- [ ] 末尾包含下一步交接（`/story-readiness`、`/dev-story`）
- [ ] 说明主管 ADR 为 Proposed 时故事使用 `Status: Blocked`
- [ ] 说明 QL-STORY-READY 门禁：full 模式启用，lean/solo 模式跳过

---

## 主管门禁检查

在 `full` 模式下：每个故事创建后运行 QL-STORY-READY 检查。检查失败的故事会在 "May I write" 询问前标记为 NEEDS WORK。

在 `lean` 模式下：跳过 QL-STORY-READY。每个故事的输出注明："QL-STORY-READY skipped — lean mode"。

在 `solo` 模式下：跳过 QL-STORY-READY，并提供等效说明。

---

## 测试用例

### 用例 1：正常路径——史诗包含 3 个故事，所有 ADR 均为 Accepted

**测试夹具：**
- `production/epics/[layer]/EPIC-[name].md` 存在，且包含 3 项 GDD 需求
- 对应 GDD 存在且包含匹配的验收标准
- 所有主管 ADR 均带有 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `docs/architecture/tr-registry.yaml` 包含全部 3 项需求的 TR-ID
- `production/session-state/review-mode.txt` 内容为 `lean`

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 技能读取 EPIC.md、GDD、主管 ADR、控制清单和 TR 注册表
2. 将每项需求归类为故事类型（Logic / Integration / Visual/Feel / UI / Config/Data）
3. 使用正确的 frontmatter 结构起草 3 个故事文件
4. 跳过 QL-STORY-READY（lean 模式），并在输出中注明
5. 写入每个故事文件前询问 "May I write"
6. 获批后写入全部 3 个故事文件

**断言：**
- [ ] 每个故事的 frontmatter 包含：Title、Epic、Layer、Priority、Status、TR-ID、ADR 引用、Acceptance Criteria、DoD
- [ ] 正确归类故事类型（夹具中至少有一个 Logic 类型）
- [ ] 对每个故事分别询问 "May I write"，而非一次询问整个批次
- [ ] 输出注明跳过 QL-STORY-READY
- [ ] 全部 3 个故事文件均按正确命名 `story-[name].md` 写入
- [ ] 技能不会开始实现

---

### 用例 2：失败路径——未找到史诗文件

**测试夹具：**
- 提供的史诗路径在 `production/epics/` 中不存在

**输入：** `/create-stories nonexistent-epic`

**预期行为：**
1. 技能尝试读取 EPIC.md 文件
2. 未找到文件
3. 技能输出清晰错误并指出搜索路径
4. 技能建议检查 `production/epics/` 或先运行 `/create-epics`
5. 不创建故事文件

**断言：**
- [ ] 技能输出清晰错误并指出缺失文件路径
- [ ] 不写入故事文件
- [ ] 技能建议正确的下一步（`/create-epics`）
- [ ] 没有有效 EPIC.md 时，技能不会创建故事

---

### 用例 3：受阻故事——ADR 为 Proposed

**测试夹具：**
- EPIC.md 存在且包含 2 项需求
- 需求 1 由 Accepted ADR 覆盖
- 需求 2 由带有 `Status: Proposed` 的 ADR 覆盖

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 技能读取需求 2 的 ADR，发现 Status: Proposed
2. 需求 2 对应故事以 `Status: Blocked` 起草
3. 阻塞说明引用具体 ADR："BLOCKED: ADR-NNN is Proposed"
4. 需求 1 对应故事正常以 `Status: Ready` 起草
5. 草稿中显示两个故事，并分别询问用户 "May I write"

**断言：**
- [ ] 故事 2 的 frontmatter 中包含 `Status: Blocked`
- [ ] 阻塞说明指出具体 ADR 编号并建议 `/architecture-decision`
- [ ] 故事 1 包含 `Status: Ready`，受阻状态不影响未受阻故事
- [ ] 写入前在草稿预览中显示受阻状态
- [ ] 写入两个故事文件（受阻故事仍会写入，只是带有标记）

---

### 用例 4：边界情况——未提供参数

**测试夹具：**
- `production/epics/` 目录存在且包含至少 2 个史诗子目录

**输入：** `/create-stories`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法错误："No epic specified. Usage: /create-stories [epic-name]"
3. 技能列出 `production/epics/` 中可用的史诗
4. 不创建故事文件

**断言：**
- [ ] 未提供参数时输出用法错误
- [ ] 列出可用史诗以帮助用户选择
- [ ] 不写入故事文件
- [ ] 技能不会在没有用户输入时擅自选择史诗

---

### 用例 5：主管门禁——Full 模式运行 QL-STORY-READY；失败故事标记为 NEEDS WORK

**测试夹具：**
- EPIC.md 存在且包含 2 项需求
- 两个主管 ADR 均为 Accepted
- `production/session-state/review-mode.txt` 内容为 `full`
- QL-STORY-READY 检查发现一个故事的验收标准含糊

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 起草两个故事
2. 对每个故事运行 QL-STORY-READY 检查
3. 故事 1 通过 QL-STORY-READY
4. 故事 2 未通过 QL-STORY-READY，标记为 NEEDS WORK 并附具体反馈
5. 在 "May I write" 前，向用户显示两个故事及通过/失败状态
6. 用户可继续（故事按原样写入并带 NEEDS WORK 说明）或先修改

**断言：**
- [ ] 输出按故事显示 QL-STORY-READY 结果
- [ ] 故事 2 标记为 NEEDS WORK，并指出具体失败标准
- [ ] 故事 1 显示为通过 QL-STORY-READY
- [ ] 写入前向用户提供继续或修改的选择
- [ ] 对未通过 QL-STORY-READY 的故事，技能不会在没有用户输入时自动阻止写入

---

## 协议合规性

- [ ] 起草故事前加载所有上下文（EPIC、GDD、ADR、清单、TR 注册表）
- [ ] 在任何 "May I write" 询问前完整显示故事草稿
- [ ] 对每个故事分别询问 "May I write"，而非一次询问整个批次
- [ ] 写入审批前标记受阻故事，而非写入后才发现
- [ ] TR-ID 引用注册表，不在故事文件中内联嵌入需求文本
- [ ] 每个故事的控制清单规则引用自清单，而非凭空编造
- [ ] 以下一步交接结束：`/story-readiness` → `/dev-story`

---

## 覆盖说明

- Integration 故事的测试证据（试玩文档替代方案）与 Logic 故事遵循相同审批模式，未单独使用夹具测试。
- 故事顺序（基础内容优先，UI 最后）通过用例 1 的多故事夹具隐式验证。
- 此处未测试故事规模规则（拆分大型需求组），该规则由 `/create-stories` 技能的内部逻辑处理。
