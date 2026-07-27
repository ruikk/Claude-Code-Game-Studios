# 技能测试规范：/regression-suite

## 技能摘要

`/regression-suite` 将测试覆盖映射到 GDD 需求：读取当前迭代（或指定 epic）故事文件中的验收标准，
然后扫描 `tests/` 中对应的测试文件，检查每个 AC 是否有匹配断言。它生成覆盖报告，标明哪些 AC 已完整覆盖、部分覆盖或未测试，以及哪些测试文件没有匹配的 AC（孤立测试）。

该技能可以在询问“May I write”后将覆盖报告写入 `production/qa/`。不适用主管门禁。判定结果：FULL COVERAGE（所有 AC 都有测试）、GAPS FOUND（部分 AC 未测试）或 CRITICAL GAPS（关键优先级 AC 没有测试）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：FULL COVERAGE、GAPS FOUND、CRITICAL GAPS
- [ ] 包含“May I write”措辞（技能可能写入覆盖报告）
- [ ] 包含下一步交接说明（例如缺少测试框架时使用 `/test-setup`，缺少计划时使用 `/qa-plan`）

---

## 主管门禁检查

无。`/regression-suite` 是 QA 分析工具。不适用主管门禁。

---

## 测试用例

### 用例 1：完整覆盖：迭代中的所有 AC 都有对应测试

**测试夹具：**
- `production/sprints/sprint-004.md` 列出 3 个故事，每个故事有 2 条 AC（共 6 条）
- `tests/unit/` 和 `tests/integration/` 包含与全部 6 条 AC 匹配的测试文件
  （依据系统名称和场景描述）

**输入：** `/regression-suite sprint-004`

**预期行为：**
1. 技能从 sprint-004 故事中读取全部 6 条 AC
2. 技能扫描测试文件，将每条 AC 与至少一条测试断言匹配
3. 全部 6 条 AC 都有覆盖
4. 技能生成覆盖报告：“6/6 条 AC 已覆盖”
5. 技能询问“May I write to `production/qa/regression-sprint-004.md`?”
6. 获得批准后写入文件；判定结果为 FULL COVERAGE

**断言：**
- [ ] 覆盖报告包含全部 6 条 AC
- [ ] 每条 AC 均标记为已覆盖，并引用匹配的测试文件
- [ ] 判定结果为 FULL COVERAGE
- [ ] 写入报告前询问“May I write”

---

### 用例 2：发现缺口：3 个 AC 没有测试

**测试夹具：**
- 迭代包含 5 个故事，共 8 条 AC
- 8 条 AC 中有 5 条存在测试；3 条没有对应的测试文件或断言

**输入：** `/regression-suite`

**预期行为：**
1. 技能读取全部 8 条 AC
2. 技能扫描测试：5 条匹配，3 条不匹配
3. 覆盖报告按故事和 AC 文本列出 3 条未测试的 AC
4. 技能询问“May I write to `production/qa/regression-[sprint]-[date].md`?”
5. 写入报告；判定结果为 GAPS FOUND

**断言：**
- [ ] 报告按名称列出 3 条未测试的 AC
- [ ] 同时展示已匹配的 AC（不只展示缺口）
- [ ] 判定结果为 GAPS FOUND（不是 FULL COVERAGE）
- [ ] 获得“May I write”批准后写入报告

---

### 用例 3：关键 AC 未测试：突出标记并判定为 CRITICAL GAPS

**测试夹具：**
- 迭代包含 4 个故事；其中一个故事的 `Priority` 为 `Critical`，并有 2 条 AC
- 其中一条 Critical 优先级 AC 没有测试

**输入：** `/regression-suite`

**预期行为：**
1. 技能读取所有故事和 AC，记录哪些故事具有 Critical 优先级
2. 技能扫描测试：关键 AC 没有匹配项
3. 报告突出标记：“CRITICAL GAP: [AC text] — 未找到测试（Critical 优先级故事）”
4. 技能建议在添加测试前阻止故事完成
5. 判定结果为 CRITICAL GAPS

**断言：**
- [ ] 判定结果为 CRITICAL GAPS（不是 GAPS FOUND）
- [ ] Critical 优先级 AC 比普通缺口得到更醒目的标记
- [ ] 包含阻止故事完成的建议
- [ ] 同时列出非关键缺口（如有）

---

### 用例 4：孤立测试：测试文件没有匹配的 AC

**测试夹具：**
- `tests/unit/save_system_test.gd` 存在，其中包含当前任何故事 AC 列表均未涉及的场景断言
- 当前迭代故事未引用存档系统

**输入：** `/regression-suite`

**预期行为：**
1. 技能扫描测试并与 AC 交叉核对
2. `save_system_test.gd` 中的断言与任何当前 AC 均不匹配
3. 覆盖报告将该测试文件标记为 ORPHAN TEST
4. 报告注明：“孤立测试可能属于过去或未来的迭代，或者 AC 已重命名”
5. 根据总体 AC 覆盖情况，判定结果为 FULL COVERAGE 或 GAPS FOUND
   （孤立测试不影响判定结果，仅作提示）

**断言：**
- [ ] 报告中标记孤立测试
- [ ] 孤立标记包含文件名和建议（过去的迭代 / 已重命名的 AC）
- [ ] 孤立测试本身不会导致 GAPS FOUND 判定
- [ ] 总体判定仅反映 AC 覆盖情况

---

### 用例 5：主管门禁检查：无门禁，regression-suite 是 QA 工具

**测试夹具：**
- 包含故事和测试文件的迭代

**输入：** `/regression-suite`

**预期行为：**
1. 技能生成并写入覆盖报告
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定结果为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS，不是门禁判定

---

## 协议合规性

- [ ] 扫描测试前从迭代文件读取故事 AC
- [ ] 按系统名称和场景将 AC 与测试匹配（而非仅按文件名）
- [ ] 将未测试的关键优先级 AC 标记为 CRITICAL GAPS
- [ ] 标记孤立测试（存在于 `tests/` 中但没有匹配的 AC）
- [ ] 持久化覆盖报告前询问“May I write”
- [ ] 判定结果为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS

---

## 覆盖说明

- 将 AC 与测试匹配的启发式方法（依据系统名称和场景关键词）是近似的；精确匹配逻辑在技能正文中定义。
- 集成测试覆盖与单元测试覆盖采用相同的映射方式；判定结果不区分二者。
- 此技能不运行测试，只将 AC 文本映射到测试断言。测试执行由 CI 管线处理。
