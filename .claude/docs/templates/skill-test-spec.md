# Skill Test Spec（技能测试规范）: /[skill-name]

## Skill Summary（技能概述）

[一段文字：说明该技能做什么、何时使用、会产出什么。请包含主要输出工件、其使用的判定格式，以及它所属的pipeline阶段。]

---

## Static Assertions（静态断言，结构性）

由 `/skill-test static` 自动验证 —— 无需fixture。

- [ ] 包含必需的frontmatter字段：`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] 包含 ≥2 个阶段标题（## Phase N 或带编号的 ## 小节）
- [ ] 包含判定关键词：[列出期望关键词，例如 PASS, FAIL, CONCERNS]
- [ ] 包含 “May I write” 协作协议措辞（若技能会写文件）
- [ ] 末尾包含下一步交接

---

## Test Cases（测试用例）

### Case 1: Happy Path（正常路径）— [简短描述]

**Fixture（测试夹具）:** [描述假定的项目状态。哪些文件存在？内容是什么？例如：“game-concept.md 存在且包含完整的 8 个必需章节。systems-index.md 存在。所有 MVP 游戏设计文档已存在且逐一评审完成。”]

**Input（输入）:** `/[skill-name] [args]`

**Expected behavior（预期行为）:**
1. [Phase 1 动作 —— 技能应读取或检查什么]
2. [Phase 2 动作 —— 技能应评估什么]
3. [Phase N 动作 —— 技能应输出什么]

**Assertions（断言）:**
- [ ] 技能在产出输出前先读取[具体文件]
- [ ] 输出包含判定关键词[PASS/FAIL/etc.]
- [ ] 输出列出fixture中的[具体内容]
- [ ] 技能在写入任何文件前请求批准

---

### Case 2: Failure Path（失败路径）— [简短描述，例如 “缺少必需工件”]

**Fixture（测试夹具）:** [描述失败状态。例如：“game-concept.md 缺失。design/gdd/ 下无任何文件。”]

**Input（输入）:** `/[skill-name] [args]`

**Expected behavior（预期行为）:**
1. [Phase 1：技能检测到缺失文件]
2. [Phase 2：技能暴露缺口，而不是假设 OK]
3. [输出：FAIL 或 BLOCKED 判定，并明确具体阻塞项]

**Assertions（断言）:**
- [ ] 当fixture不完整时，技能不会输出 PASS
- [ ] 技能明确指出具体缺失的工件
- [ ] 技能给出修复建议（例如：“Run /[other-skill]”）
- [ ] 未经询问，技能不会创建文件来填补缺口

---

### Case 3: Edge Case（边界场景）— [简短描述，例如 “未提供参数”]

**Fixture（测试夹具）:** [该场景下的项目文件状态]

**Input（输入）:** `/[skill-name]` (no argument)

**Expected behavior（预期行为）:**
1. [技能在无参数调用时应执行的行为]

**Assertions（断言）:**
- [ ] [assertion]

---

## Protocol Compliance（协议合规）

- [ ] 在所有文件写入前使用 “May I write”
- [ ] 在请求写入批准前先展示发现结果或报告
- [ ] 以推荐下一步或后续技能结束
- [ ] 未经用户明确批准，绝不自动创建文件
- [ ] 不跳过阶段，也不在未检查前直接给出判定

---

## Coverage Notes（覆盖说明）

[记录本规范中有意“不测试”的内容及原因。示例：
- “Case 3（all-mode）未覆盖，因为其会运行过多检查，不适合在单一规范中评估 —— 请分别测试各子模式。”
- “数据库集成路径未覆盖，因为其需要实时环境。”
- “涉及损坏 YAML 文件的边界场景延后到后续规范处理。”]
