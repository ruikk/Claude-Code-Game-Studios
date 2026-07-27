# 技能测试规范：/create-control-manifest

## 技能摘要

`/create-control-manifest` 读取 `docs/architecture/` 中所有 Accepted ADR，并生成控制清单，即集中记录全部架构约束、必需模式和禁止模式的摘要文档。控制清单是故事作者编写故事文件时使用的参考文档，确保故事继承正确的架构规则，而无需逐一阅读所有 ADR。

该技能只包含 Accepted ADR；Proposed ADR 会被排除并注明。它没有主管门禁。写入 `docs/architecture/control-manifest.md` 前，技能会询问 "May I write"。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：CREATED、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（用于 control-manifest.md）
- [ ] 末尾包含下一步交接（`/create-epics` 或 `/create-stories`）
- [ ] 说明只包含 Accepted ADR，不包含 Proposed ADR

---

## 主管门禁检查

没有主管门禁。该技能不会生成任何主管门禁代理。控制清单是从 Accepted ADR 中机械提取的文档，不需要创意或技术评审门禁。

---

## 测试用例

### 用例 1：正常路径——4 个 Accepted ADR 创建正确的清单

**测试夹具：**
- `docs/architecture/` 包含 4 个 ADR 文件，且全部带有 `Status: Accepted`
- 每个 ADR 都有 "Required Patterns" 和/或 "Forbidden Patterns" 章节
- `docs/architecture/control-manifest.md` 不存在

**输入：** `/create-control-manifest`

**预期行为：**
1. 技能读取 `docs/architecture/` 中的所有 ADR 文件
2. 从每个文件提取 Required Patterns、Forbidden Patterns 和关键约束
3. 按正确章节结构起草清单
4. 向用户显示清单草稿
5. 询问 "May I write `docs/architecture/control-manifest.md`?"
6. 获批后写入清单

**断言：**
- [ ] 清单体现全部 4 个 Accepted ADR
- [ ] 清单分别包含 Required Patterns 和 Forbidden Patterns 章节
- [ ] 每项约束包含来源 ADR 编号
- [ ] 写入前询问 "May I write"
- [ ] 未经批准，技能不会写入
- [ ] 写入后结论为 CREATED

---

### 用例 2：失败路径——未找到 ADR

**测试夹具：**
- `docs/architecture/` 目录存在，但不包含 ADR 文件

**输入：** `/create-control-manifest`

**预期行为：**
1. 技能读取 `docs/architecture/`，发现没有 ADR 文件
2. 技能输出："No ADRs found. Run `/architecture-decision` to create ADRs before generating the control manifest."
3. 技能退出，不创建任何文件
4. 结论为 BLOCKED

**断言：**
- [ ] 未找到 ADR 时技能输出清晰错误
- [ ] 不写入控制清单文件
- [ ] 技能建议 `/architecture-decision` 作为下一步
- [ ] 结论为 BLOCKED，而不是错误崩溃

---

### 用例 3：ADR 状态混合——只包含 Accepted ADR

**测试夹具：**
- `docs/architecture/` 包含 3 个 Accepted ADR 和 2 个 Proposed ADR

**输入：** `/create-control-manifest`

**预期行为：**
1. 技能读取所有 ADR 文件，并按 Status: Accepted 过滤
2. 清单仅根据 3 个 Accepted ADR 起草
3. 输出注明："2 Proposed ADRs were excluded: [adr-NNN-name, adr-NNN-name]"
4. 用户在批准写入前看到被排除的 ADR
5. 询问 "May I write `docs/architecture/control-manifest.md`?"

**断言：**
- [ ] 清单内容只出现 3 个 Accepted ADR
- [ ] 输出按名称列出被排除的 Proposed ADR
- [ ] 用户在批准写入前看到排除列表
- [ ] 技能不会不作说明就静默忽略 Proposed ADR

---

### 用例 4：边界情况——清单已存在

**测试夹具：**
- `docs/architecture/control-manifest.md` 已存在（版本 1，日期为上周）
- `docs/architecture/` 包含 Accepted ADR，其中有一些是在上次清单后新增的

**输入：** `/create-control-manifest`

**预期行为：**
1. 技能检测现有清单，并读取其版本号/日期
2. 技能提供重新生成选项："control-manifest.md already exists (v1, [date]). Regenerate with current ADRs?"
3. 用户确认后，技能起草更新后的清单并递增版本号
4. 询问 "May I write `docs/architecture/control-manifest.md`?"（覆盖）
5. 获批后写入更新后的清单

**断言：**
- [ ] 提供重新生成选项前读取并报告现有清单版本
- [ ] 向用户提供重新生成/跳过选择，不自动覆盖
- [ ] 更新后的清单版本号递增
- [ ] 覆盖现有文件前询问 "May I write"

---

### 用例 5：主管门禁——不生成门禁；不读取 review-mode.txt

**测试夹具：**
- 存在 4 个 Accepted ADR
- `production/session-state/review-mode.txt` 存在且内容为 `full`

**输入：** `/create-control-manifest`

**预期行为：**
1. 技能读取 ADR 并起草清单
2. 技能不读取 `production/session-state/review-mode.txt`
3. 任何阶段都不生成主管门禁代理
4. 起草完成后直接进行 "May I write" 询问
5. 评审模式设置不影响该技能行为

**断言：**
- [ ] 不生成主管门禁代理（没有带 CD-、TD-、PR-、AD- 前缀的门禁）
- [ ] 技能不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含 "Gate: [GATE-ID]" 或跳过门禁条目
- [ ] 清单只根据 ADR 生成，不经过外部门禁评审

---

## 协议合规性

- [ ] 起草清单前读取所有 ADR 文件
- [ ] 只包含 Accepted ADR，并注明被排除的 Proposed ADR
- [ ] 在询问 "May I write" 前向用户显示清单草稿
- [ ] 写入前询问 "May I write `docs/architecture/control-manifest.md`?"
- [ ] 没有主管门禁，不读取 review-mode.txt
- [ ] 以下一步交接结束：`/create-epics` 或 `/create-stories`

---

## 覆盖说明

- 生成清单的具体章节结构（约束表、模式列表）由技能正文定义，测试断言不再逐项列举。
- 版本字段递增逻辑（v1 → v2）通过用例 4 测试，但未锁定确切版本编号格式。
- ADR 解析（提取 Required/Forbidden Patterns）依赖一致的 ADR 结构，并通过用例 1 隐式测试。
