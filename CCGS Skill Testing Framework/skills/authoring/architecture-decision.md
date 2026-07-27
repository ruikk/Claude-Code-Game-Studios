# 技能测试规范：/architecture-decision

## 技能摘要

`/architecture-decision` 引导用户按章节编写新的架构决策记录（ADR）。必需章节包括：状态、背景、决策、后果、备选方案和相关 ADR。该技能还会将 `docs/engine-reference/` 中的引擎版本引用写入 ADR，以便追溯。

在 `full` 审查模式下，草稿完成后生成 TD-ADR（technical-director）和 LP-FEASIBILITY（lead-programmer）门禁代理。如果两个门禁都返回 APPROVED，ADR 状态将设为 Accepted。在 `lean` 或 `solo` 模式下，两个门禁都会跳过，ADR 写入时的 Status 为 Proposed。编写期间，该技能会逐章节询问 "May I write"。ADR 写入 `docs/architecture/adr-NNN-[name].md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：ACCEPTED、PROPOSED、CONCERNS
- [ ] 包含 "May I write" 协作协议措辞（逐章节批准）
- [ ] 结尾包含下一步移交
- [ ] 记录门禁行为：`full` 模式下运行 TD-ADR 和 LP-FEASIBILITY；`lean`/`solo` 模式下跳过
- [ ] 记录 ADR 状态：`full` 模式且门禁通过时为 Accepted，否则为 Proposed
- [ ] 提及来自 `docs/engine-reference/` 的引擎版本标记

---

## 主管门禁检查

在 `full` 模式下：ADR 草稿完成后生成 TD-ADR（technical-director）和 LP-FEASIBILITY（lead-programmer）。如果两者都返回 APPROVED，ADR Status 设为 Accepted；如果任一返回 CONCERNS 或 FAIL，ADR 保持 Proposed。

在 `lean` 模式下：两个门禁都会跳过，ADR 写入时的 Status 为 Proposed。

输出说明："TD-ADR skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：两个门禁都会跳过，ADR 写入时的 Status 为 Proposed。

---

## 测试用例

### 用例 1：正常路径，为渲染方案创建新 ADR，full 模式且门禁通过

**夹具：**
- `docs/architecture/` 存在，且没有关于渲染的现有 ADR
- `docs/engine-reference/[engine]/VERSION.md` 存在
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-decision rendering-approach`

**预期行为：**
1. 技能引导用户完成每个必需章节（状态、背景、决策、后果、备选方案、相关 ADR）
2. 技能从 `docs/engine-reference/` 将引擎版本写入 ADR
3. 每个章节都显示草稿，询问 "May I write this section?"，并在获批后写入
4. 所有章节完成后，并行生成 TD-ADR 和 LP-FEASIBILITY 门禁
5. 两个门禁都返回 APPROVED
6. ADR Status 设为 Accepted
7. 技能写入 `docs/architecture/adr-NNN-rendering-approach.md`
8. 如果定义了新的 TR-ID，则更新 `docs/architecture/tr-registry.yaml`

**断言：**
- [ ] 全部 6 个必需章节均已编写并写入
- [ ] ADR 中包含引擎版本引用
- [ ] TD-ADR 和 LP-FEASIBILITY 并行生成，而非依次生成
- [ ] `full` 模式下两个门禁都返回 APPROVED 时，ADR Status 为 Accepted
- [ ] 编写期间逐章节询问 "May I write"
- [ ] 文件写入 `docs/architecture/adr-NNN-[name].md`

---

### 用例 2：失败路径，TD-ADR 返回 CONCERNS

**夹具：**
- ADR 草稿已完成（所有章节均已填写）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ADR 门禁返回 CONCERNS："该决策未处理[具体疑虑]"

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. TD-ADR 门禁生成并返回包含具体反馈的 CONCERNS
2. 技能向用户展示这些疑虑
3. ADR Status 保持 Proposed（不设为 Accepted）
4. 技能询问用户：修订决策以处理疑虑，还是接受为 Proposed
5. 如果疑虑未解决，ADR 以 Status: Proposed 写入

**断言：**
- [ ] TD-ADR 的疑虑原样展示给用户
- [ ] TD-ADR 返回 CONCERNS 时，ADR Status 为 Proposed（不为 Accepted）
- [ ] 疑虑未解决时，技能不会将 Status 设为 Accepted
- [ ] 用户可以选择修订并重新运行门禁

---

### 用例 3：Lean 模式，跳过两个门禁；ADR 以 Proposed 写入

**夹具：**
- `production/session-state/review-mode.txt` 包含 `lean`
- 已为新的技术决策编写 ADR 草稿

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. 技能引导用户完成全部 6 个章节
2. 草稿完成后，跳过 TD-ADR 和 LP-FEASIBILITY
3. 输出说明："TD-ADR skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"
4. ADR 以 Status: Proposed 写入（门禁未批准，因此不为 Accepted）
5. 最终写入文件前仍询问 "May I write"

**断言：**
- [ ] 输出中出现两个门禁跳过说明
- [ ] `lean` 模式下 ADR Status 为 Proposed（不为 Accepted）
- [ ] 写入文件前仍询问 "May I write"
- [ ] 用户批准后技能写入 ADR

---

### 用例 4：边界情况，该主题已有 ADR

**夹具：**
- `docs/architecture/` 中已有涵盖相同主题的 ADR
- 现有 ADR 的 Status 为 Accepted

**输入：** `/architecture-decision [same-topic]`

**预期行为：**
1. 技能检测到已有涵盖该主题的 ADR
2. 技能询问："[topic] 已有 ADR（[filename]）。要更新它，还是创建新的取代性 ADR？"
3. 用户选择更新或取代
4. 技能不会静默创建重复 ADR

**断言：**
- [ ] 技能在开始编写前检测现有 ADR
- [ ] 向用户提供更新或取代选项，不静默创建重复项
- [ ] 如果选择更新，技能打开现有 ADR 进行逐章节修订
- [ ] 如果选择取代，新 ADR 在相关 ADR 章节中引用被取代的 ADR

---

### 用例 5：主管门禁，根据模式和门禁结果正确设置状态

**夹具：**
- ADR 草稿已完成
- 两种场景：(a) `full` 模式，两个门禁返回 APPROVED；(b) `full` 模式，一个门禁返回 CONCERNS

**Full 模式，两个门禁均 APPROVED：**
- ADR Status 设为 Accepted

**断言（均批准）：**
- [ ] ADR frontmatter/标题显示 `Status: Accepted`
- [ ] 输出中 TD-ADR 和 LP-FEASIBILITY 均显示 APPROVED

**Full 模式，一个门禁返回 CONCERNS：**
- ADR Status 保持 Proposed

**断言（CONCERNS）：**
- [ ] ADR frontmatter/标题显示 `Status: Proposed`
- [ ] 输出中列出疑虑
- [ ] 任一门禁返回 CONCERNS 时，技能不会将 Status 设为 Accepted

**Lean/solo 模式：**
- 无论内容质量如何，ADR Status 始终为 Proposed

**断言（lean/solo）：**
- [ ] `lean` 模式下 ADR Status 为 Proposed
- [ ] `solo` 模式下 ADR Status 为 Proposed
- [ ] `lean` 或 `solo` 模式下不出现门禁输出

---

## 协议合规性

- [ ] 所有 6 个必需章节均在门禁审查前完成编写
- [ ] ADR 从 `docs/engine-reference/` 获取并写入引擎版本标记
- [ ] 编写期间逐章节询问 "May I write"
- [ ] `full` 模式下 TD-ADR 和 LP-FEASIBILITY 并行生成
- [ ] `lean`/`solo` 输出按名称和模式注明跳过的门禁
- [ ] 仅在 `full` 模式且两个门禁都返回 APPROVED 时将 ADR Status 设为 Accepted
- [ ] 结尾移交给 `/architecture-review` 或 `/create-control-manifest`

---

## 覆盖说明

- ADR 编号（自动递增的 NNN）未单独进行夹具测试；技能读取现有 ADR 文件名以分配下一个编号。
- 相关 ADR 章节的链接（supersedes / related-to）通过用例 4 进行结构测试，但未逐一验证所有链接类型。
- 当 ADR 定义新的 TR-ID 时，TR 注册表更新属于写入阶段；用例 1 会隐式测试该行为。
