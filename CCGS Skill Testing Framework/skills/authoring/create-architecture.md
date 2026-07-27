# 技能测试规范：/create-architecture

## 技能摘要

`/create-architecture` 引导用户按章节编写技术架构文档。它采用先建骨架方法，在填写任何内容前创建包含所有必需章节标题的文件。每个章节经过讨论和起草，并在用户批准后单独写入。如果架构文档已存在，该技能会提供改造模式来更新特定章节。

在 `full` 审查模式下，完整草稿完成后会生成 TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。在 `lean` 或 `solo` 模式下，两个门禁均跳过。该技能写入 `docs/architecture/architecture.md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 包含 "May I write" 协作协议措辞（逐章批准）
- [ ] 最后包含下一步移交（`/architecture-review` 或 `/create-control-manifest`）
- [ ] 记录先建骨架方法
- [ ] 记录门禁行为：full 模式下运行 TD-ARCHITECTURE 和 LP-FEASIBILITY；lean/solo 下跳过
- [ ] 记录现有架构文档的改造模式

---

## 主管门禁检查

在 `full` 模式下：所有章节起草完成后、最终批准写入前，并行生成 TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。

在 `lean` 模式下：跳过两个门禁。输出注明："TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：跳过两个门禁，并输出对应说明。

---

## 测试用例

### 用例 1：正常路径，新架构文档、先建骨架、full 模式门禁批准

**夹具：**
- `docs/architecture/architecture.md` 不存在
- `docs/architecture/` 包含可供参考的 Accepted ADR
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/create-architecture`

**预期行为：**
1. 技能创建骨架 `docs/architecture/architecture.md`，包含所有必需章节标题
2. 对每个章节：起草内容、显示草稿、询问 "May I write [section]?"，获批后写入
3. 所有章节起草完成后，并行生成 TD-ARCHITECTURE 和 LP-FEASIBILITY
4. 两个门禁均返回 APPROVED
5. 最后询问 "May I confirm architecture is complete?"
6. 更新会话状态

**断言：**
- [ ] 写入任何内容前，创建包含所有章节标题的骨架文件
- [ ] 编写期间逐章询问 "May I write [section]?"
- [ ] 并行而非依次生成 TD-ARCHITECTURE 和 LP-FEASIBILITY
- [ ] 最终确认完成前，两个门禁均已结束
- [ ] 两个门禁均返回 APPROVED 时，结论为 APPROVED
- [ ] 包含到 `/architecture-review` 或 `/create-control-manifest` 的下一步移交

---

### 用例 2：失败路径，TD-ARCHITECTURE 返回 MAJOR REVISION

**夹具：**
- 架构文档已完整起草（所有章节）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ARCHITECTURE 门禁返回 MAJOR REVISION："[specific structural issue]"

**输入：** `/create-architecture`

**预期行为：**
1. 所有章节均已起草并写入
2. TD-ARCHITECTURE 门禁运行，并返回 MAJOR REVISION 和具体反馈
3. 技能向用户展示反馈
4. 不将架构标记为已定稿
5. 询问用户：修订标记的章节，或接受该文档作为草稿

**断言：**
- [ ] TD-ARCHITECTURE 返回 MAJOR REVISION 时，不将架构标记为已定稿
- [ ] 向用户显示包含具体问题说明的门禁反馈
- [ ] 为用户提供修订特定章节的选项
- [ ] 即使收到 MAJOR REVISION 反馈，技能也不会自动定稿

---

### 用例 3：Lean 模式，跳过两个门禁；仅凭用户批准写入架构

**夹具：**
- 没有现有架构文档
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-architecture`

**预期行为：**
1. 创建骨架文件
2. 所有章节均按章节编写，并在用户批准后写入
3. 完成后跳过 TD-ARCHITECTURE 和 LP-FEASIBILITY
4. 输出注明："TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"
5. 仅凭用户批准将架构视为完成

**断言：**
- [ ] 输出中出现两个门禁跳过说明
- [ ] lean 模式下，仅凭用户批准写入架构文档
- [ ] 技能不会因为跳过门禁而阻止完成
- [ ] 仍包含下一步移交

---

### 用例 4：改造模式，用户更新现有架构文档的一个章节

**夹具：**
- `docs/architecture/architecture.md` 已存在，且所有章节均已填写

**输入：** `/create-architecture`

**预期行为：**
1. 技能检测到现有架构文档，并读取其当前内容
2. 技能提供改造模式："架构文档已存在。要更新哪个章节？"
3. 用户选择一个章节
4. 技能只编写该章节，并询问 "May I write [section]?"
5. 只更新所选章节，其他章节不变

**断言：**
- [ ] 技能在提供改造选项前检测并读取现有架构文档
- [ ] 询问用户要更新哪个章节，而不是要求重写整个文档
- [ ] 只更新所选章节
- [ ] 改造会话期间不修改其他章节

---

### 用例 5：主管门禁，架构引用 Proposed ADR；标记为风险

**夹具：**
- 正在编写架构文档
- 某个章节引用或依赖 `Status: Proposed` 的 ADR
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/create-architecture`

**预期行为：**
1. 技能编写所有章节
2. 编写期间，技能检测到对 Proposed ADR 的引用
3. 技能标记："注意：[section] 引用了状态为 Proposed 的 ADR-NNN，在该 ADR 被接受前，这是一项风险"
4. 风险标记嵌入相关章节的内容
5. TD-ARCHITECTURE 和 LP-FEASIBILITY 仍会运行，并获知 Proposed ADR 风险

**断言：**
- [ ] 编写章节期间检测并标记 Proposed ADR 引用
- [ ] 风险说明嵌入架构文档章节
- [ ] 仍然生成 TD-ARCHITECTURE 和 LP-FEASIBILITY（该风险不会阻止门禁）
- [ ] 风险标记指出具体 ADR 编号和标题

---

## 协议合规性

- [ ] 写入任何内容前，创建包含所有章节标题的骨架文件
- [ ] 编写期间逐章询问 "May I write [section]?"
- [ ] full 模式下并行生成 TD-ARCHITECTURE 和 LP-FEASIBILITY
- [ ] lean/solo 输出按名称和模式注明跳过的门禁
- [ ] 在文档中将 Proposed ADR 引用标记为风险
- [ ] 最后移交给 `/architecture-review` 或 `/create-control-manifest`

---

## 覆盖说明

- 架构文档的必需章节列表定义在技能正文和 `/architecture-review` 技能中，此处不再枚举。
- 在架构文档中记录引擎版本（与 ADR 记录方式相同）是编写工作流的一部分，通过用例 1 间接测试。
- 在一个会话中更新多个章节的改造模式遵循相同的逐章批准模式；此处不单独测试多章节改造。
