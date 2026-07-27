# 技能测试规范：/skill-test

## 技能摘要

`/skill-test` 用于验证技能文件的结构正确性、行为合规性以及类别评分标准得分。它支持三种模式：

- **static**：无需测试夹具，检查单个技能文件是否满足结构要求（front matter 字段、阶段标题、判定关键词、“May I write”措辞和后续步骤交接），并生成逐项 PASS/FAIL 表。
- **spec**：读取 `tests/skills/` 中的测试规范文件，根据每个测试用例的断言评估技能，并逐用例生成判定结果。
- **audit**：生成 `.claude/skills/` 中所有技能和 `.claude/agents/` 中所有代理的覆盖表，显示哪些具有规范文件、哪些没有。

另外，**category** 模式会读取技能类别的质量评分标准（例如 gate 技能），并根据评分标准评估技能。不同模式使用不同的判定系统。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定词：COMPLIANT、NON-COMPLIANT、WARNINGS（static 模式）；PASS、FAIL、PARTIAL（spec 模式）；COMPLETE（audit 模式）
- [ ] 不包含“May I write”措辞（所有模式下技能均为只读）
- [ ] 包含后续步骤交接（例如使用 `/skill-improve` 修复发现的问题）

---

## Director 门禁检查

无。`/skill-test` 是元工具技能，不适用任何 director 门禁。

---

## 测试用例

### 用例 1：Static 模式——格式正确的技能，7 项检查全部通过，COMPLIANT

**测试夹具：**
- `.claude/skills/brainstorm/SKILL.md` 存在且格式正确：
  - 包含所有必需的 front matter 字段
  - 至少包含 2 个阶段标题
  - 包含判定关键词
  - 包含 `May I write` 协议措辞
  - 包含后续步骤交接
  - 记录 Director 门禁
  - 记录门禁模式行为（lean/solo 跳过）

**输入：** `/skill-test static brainstorm`

**预期行为：**
1. 技能读取 `.claude/skills/brainstorm/SKILL.md`
2. 技能执行全部 7 项结构检查
3. 7 项检查全部通过
4. 技能输出 PASS/FAIL 表，并将 7 项检查全部标记为 PASS
5. 判定为 COMPLIANT

**断言：**
- [ ] 恰好报告 7 项结构检查
- [ ] 7 项全部标记为 PASS
- [ ] 判定为 COMPLIANT
- [ ] 不写入任何文件

---

### 用例 2：Static 模式——`allowed-tools` 中有 Write 工具，但技能缺少 `May I write` 协议措辞

**测试夹具：**
- `.claude/skills/some-skill/SKILL.md` 的 `allowed-tools` front matter 中包含 `Write`
- 技能正文没有“May I write”或“May I update”措辞

**输入：** `/skill-test static some-skill`

**预期行为：**
1. 技能读取 `some-skill/SKILL.md`
2. 检查 4（协作写入协议）失败：`allowed-tools` 中有 `Write`，但未找到“May I write”措辞
3. 其他检查可以通过
4. 判定为 NON-COMPLIANT，失败断言为检查 4
5. 输出将检查 4 列为 FAIL，并给出解释

**断言：**
- [ ] 检查 4 标记为 FAIL
- [ ] 解释指出具体不匹配（有 Write 工具但没有“May I write”措辞）
- [ ] 判定为 NON-COMPLIANT
- [ ] 显示其他通过的检查，而不只是失败项

---

### 用例 3：Spec 模式——根据规范评估 gate-check 技能

**测试夹具：**
- `tests/skills/gate-check.md` 存在且包含 5 个测试用例
- `.claude/skills/gate-check/SKILL.md` 存在

**输入：** `/skill-test spec gate-check`

**预期行为：**
1. 技能同时读取技能文件和规范文件
2. 技能根据技能行为评估 5 个测试用例的每项断言
3. 每个用例：技能行为符合规范断言时为 PASS，否则为 FAIL
4. 技能生成逐用例结果表
5. 总体判定：全部 5 个通过时为 PASS，部分通过时为 PARTIAL，多数失败时为 FAIL

**断言：**
- [ ] 评估规范中的全部 5 个测试用例
- [ ] 每个用例都有独立的 PASS/FAIL 结果
- [ ] 总体判定根据用例结果为 PASS、PARTIAL 或 FAIL
- [ ] 不写入任何文件

---

### 用例 4：Audit 模式——所有技能和代理的覆盖表

**测试夹具：**
- `.claude/skills/` 包含 72 个以上技能目录
- `.claude/agents/` 包含 49 个以上代理文件
- `tests/skills/` 包含部分技能的规范文件

**输入：** `/skill-test audit`

**预期行为：**
1. 技能枚举 `.claude/skills/` 中的所有技能和 `.claude/agents/` 中的所有代理
2. 技能在 `tests/skills/` 中检查每个条目对应的规范文件
3. 技能生成覆盖表：
   - 列出每个技能/代理
   - “有规范”列：YES 或 NO
   - 摘要：“Y 个技能中有 X 个具备规范；B 个代理中有 A 个具备规范”
4. 判定为 COMPLETE

**断言：**
- [ ] 枚举所有技能目录，而不只是抽样
- [ ] 每个条目的“有规范”列准确
- [ ] 摘要计数正确
- [ ] 判定为 COMPLETE

---

### 用例 5：Category 模式——根据质量评分标准评估 Gate 技能

**测试夹具：**
- `tests/skills/quality-rubric.md` 存在，其中的“Gate 技能”章节定义 G1-G5 标准（例如 G1：包含模式守卫，G2：包含判定表等）
- `.claude/skills/gate-check/SKILL.md` 是 gate 技能

**输入：** `/skill-test category gate-check`

**预期行为：**
1. 技能读取 `quality-rubric.md` 并识别 Gate 技能章节
2. 技能根据 G1-G5 标准评估 `gate-check/SKILL.md`
3. 每项标准评分为 PASS、PARTIAL 或 FAIL
4. 计算类别总分（例如 5 项标准中 4 项通过）
5. 判定为 COMPLIANT（全部通过）、WARNINGS（部分为 PARTIAL）或 NON-COMPLIANT（存在失败）

**断言：**
- [ ] 评估 quality-rubric.md 中的所有门禁标准（G1-G5）
- [ ] 每项标准都有独立评分
- [ ] 总体判定反映评分分布
- [ ] 不写入任何文件

---

## 协议合规性

- [ ] Static 模式恰好检查 7 项结构断言
- [ ] Spec 模式逐项评估规范文件中的每个测试用例
- [ ] Audit 模式覆盖所有技能和代理，而不只是一个类别
- [ ] Category 模式读取 quality-rubric.md 获取标准，而不是硬编码
- [ ] 任何模式都不写入文件
- [ ] 发现问题时建议将 `/skill-improve` 作为下一步

---

## 覆盖说明

- skill-test 技能是自引用的（可以测试自身）。为避免测试设计中的无限递归，没有为 skill-test 自身 SKILL.md 的 static 模式用例单独设置测试夹具。
- 具体的 7 项结构检查定义在技能正文中；这里只单独测试检查 4（May I write），因为它的逻辑最复杂。
- Audit 模式的数量是近似值：随着系统增长，技能和代理的确切数量会变化；断言使用“全部”而不是固定数量。
