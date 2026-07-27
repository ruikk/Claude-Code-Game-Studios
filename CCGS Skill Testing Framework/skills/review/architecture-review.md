# 技能测试规范：/architecture-review

## 技能摘要

`/architecture-review` 是 Opus 级技能，用于依据项目要求的八个架构章节验证技术架构文档，
并检查文档内部是否一致、是否与现有 ADR 冲突，以及目标引擎版本是否正确。
它给出 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 结论。

在 `full` 评审模式下，该技能并行生成两个主管门禁代理：
TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。
在 `lean` 或 `solo` 模式下，两个门禁均会跳过并予以注明。该技能为只读技能，不写入文件。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键字：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不要求使用 "May I write" 措辞（只读技能）
- [ ] 末尾包含下一步交接
- [ ] 说明门禁行为：`full` 模式下运行 TD-ARCHITECTURE + LP-FEASIBILITY；`lean`/`solo` 模式下跳过

---

## 主管门禁检查

在 `full` 模式下：技能读取架构文档后，并行生成 TD-ARCHITECTURE（technical-director）
和 LP-FEASIBILITY（lead-programmer）。

在 `lean` 模式下：跳过两个门禁。输出注明：
"TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：跳过两个门禁，并输出对应说明。

---

## 测试用例

### 用例 1：正常路径 - `full` 模式下的完整架构文档

**测试夹具：**
- `docs/architecture/architecture.md` 存在，且八个必需章节均有内容
- 所有章节均引用 `docs/engine-reference/` 中正确的引擎版本
- 与 `docs/architecture/` 中状态为 Accepted 的现有 ADR 没有冲突
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取架构文档
2. 技能读取现有 ADR 以进行交叉核对
3. 技能读取引擎版本参考资料
4. 并行生成 TD-ARCHITECTURE 和 LP-FEASIBILITY 门禁代理
5. 两个门禁均返回 APPROVED
6. 技能按章节输出完整性检查（已有 8/8 个章节）
7. 结论：APPROVED

**断言：**
- [ ] 检查并报告全部八个必需章节
- [ ] 并行生成 TD-ARCHITECTURE 和 LP-FEASIBILITY（而非依次生成）
- [ ] 所有章节齐全且不存在冲突时，结论为 APPROVED
- [ ] 技能不写入任何文件
- [ ] 包含交接到 `/create-control-manifest` 或 `/create-epics` 的下一步

---

### 用例 2：失败路径 - 缺少必需章节

**测试夹具：**
- `docs/architecture/architecture.md` 存在，但至少缺少 2 个必需章节
  （例如没有数据模型章节、没有错误处理章节）
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取文档并识别缺失章节
2. 章节完整性显示已有章节少于 8/8 个
3. 按名称列出缺失章节，并提供明确的补救指导
4. 结论：MAJOR REVISION NEEDED（缺少不少于 2 个章节）

**断言：**
- [ ] 缺少不少于 2 个章节时，结论为 MAJOR REVISION NEEDED（而非 APPROVED 或 NEEDS REVISION）
- [ ] 输出明确指出每个缺失章节的名称
- [ ] 补救指导具体明确（说明要添加什么，而非仅称“添加缺失章节”）
- [ ] 技能不会让缺少必需章节的文档通过

---

### 用例 3：部分路径 - 架构与现有 ADR 冲突

**测试夹具：**
- `docs/architecture/architecture.md` 存在且八个章节齐全
- `docs/architecture/` 中一个状态为 Accepted 的 ADR 规定了一项约束，而架构文档与之冲突
  （例如 ADR-001 要求采用 ECS 模式；architecture.md 却为同一系统描述了另一种模式）

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取架构文档和所有现有 ADR
2. 检测出架构文档与指定 ADR 之间的冲突
3. 冲突条目指出 ADR 编号/标题、相互冲突的章节和影响
4. 结论：NEEDS REVISION（存在冲突，但结构在其他方面完好）

**断言：**
- [ ] 单个冲突的结论为 NEEDS REVISION（而非 MAJOR REVISION NEEDED）
- [ ] 冲突条目中指出具体 ADR 编号和标题
- [ ] 识别出两份文档中相互冲突的章节
- [ ] 技能不自动解决冲突

---

### 用例 4：边界情况 - 找不到文件

**测试夹具：**
- 提供的路径在项目中不存在

**输入：** `/architecture-review docs/architecture/nonexistent.md`

**预期行为：**
1. 技能尝试读取文件
2. 找不到文件
3. 技能输出清晰的错误消息，并指出缺失的文件
4. 技能建议检查 `docs/architecture/` 或运行 `/create-architecture`
5. 技能不产生结论

**断言：**
- [ ] 找不到文件时，技能输出清晰的错误消息
- [ ] 不产生结论（APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED）
- [ ] 技能建议纠正措施
- [ ] 技能不会崩溃或产生不完整报告

---

### 用例 5：主管门禁 - `full` 模式生成两个门禁；`solo` 模式跳过两个门禁

**测试夹具（`full` 模式）：**
- `docs/architecture/architecture.md` 存在且八个章节齐全
- `production/session-state/review-mode.txt` 包含 `full`

**`full` 模式预期行为：**
1. 生成 TD-ARCHITECTURE 门禁
2. LP-FEASIBILITY 门禁与 TD-ARCHITECTURE 并行生成
3. 两个门禁均在给出结论前完成

**断言（`full` 模式）：**
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 均作为已完成门禁出现在输出中
- [ ] 两个门禁并行生成（而非一前一后）
- [ ] 结论反映门禁反馈

**测试夹具（`solo` 模式）：**
- 使用同一架构文档
- `production/session-state/review-mode.txt` 包含 `solo`

**`solo` 模式预期行为：**
1. 技能读取架构文档
2. 不生成门禁
3. 输出注明："TD-ARCHITECTURE skipped — solo mode" 和 "LP-FEASIBILITY skipped — solo mode"
4. 结论仅基于结构检查

**断言（`solo` 模式）：**
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 均不作为活动门禁出现
- [ ] 输出注明两个被跳过的门禁
- [ ] 仍根据单独的结构检查产生结论

---

## 协议合规性

- [ ] 不写入任何文件（只读技能）
- [ ] 给出结论前呈现章节完整性检查
- [ ] 在 `full` 模式下并行生成 TD-ARCHITECTURE 和 LP-FEASIBILITY
- [ ] 在 `lean`/`solo` 输出中按名称和模式注明被跳过的门禁
- [ ] 结论必须是以下三项之一：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 以适合该结论的下一步交接结束

---

## 覆盖说明

- 八个必需架构章节由项目决定；测试采用技能正文中定义的章节列表，此处不再重复列举。
- 引擎版本兼容性检查（与 `docs/engine-reference/` 交叉核对）属于用例 1 的正常路径，
  但没有使用独立测试夹具进行测试。
- RTM（需求可追溯性矩阵）模式属于另一事项，由 `/architecture-review` 技能自身的 `rtm`
  参数模式覆盖，此处不测试。
