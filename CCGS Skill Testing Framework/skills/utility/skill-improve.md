# 技能测试规范：/skill-improve

## 技能摘要

`/skill-improve` 对技能文件运行自动化的“测试-修复-重测”改进循环。它调用 `/skill-test static`（也可调用 `/skill-test category`）建立基线分数，诊断失败检查，针对 SKILL.md 文件提出修复方案，询问“May I write the improvements to [skill path]?”，应用修复后重新运行测试确认改进效果。

如果建议的修复使技能变差（回归），则在获得用户确认后还原修复，而不是保留它。如果技能已经完美（0 个失败），技能立即退出且不做修改。不适用主管门禁。判定结果：IMPROVED（分数提高）、NO CHANGE（无法改进或用户拒绝）或 REVERTED（修复导致回归并已还原）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：IMPROVED、NO CHANGE、REVERTED
- [ ] 应用修复前包含“May I write”协作协议措辞
- [ ] 包含下一步交接说明（例如运行 `/skill-test spec` 验证行为合规性）

---

## 主管门禁检查

无。`/skill-improve` 是元工具技能，不适用主管门禁。

---

## 测试用例

### 用例 1：正常路径：技能有 2 个静态失败，均已修复并得到 IMPROVED

**测试夹具：**
- `.claude/skills/some-skill/SKILL.md` 有 2 个静态检查失败：
  - 检查 4：虽然 `allowed-tools` 中包含 Write，但没有“May I write”措辞
  - 检查 5：末尾没有下一步交接说明

**输入：** `/skill-improve some-skill`

**预期行为：**
1. 技能运行 `/skill-test static some-skill`，基线为：5/7 项检查通过
2. 技能诊断 2 个失败检查（4 和 5）
3. 技能提出修复方案：
    - 在适当阶段添加“May I write”措辞
    - 在末尾添加下一步交接章节
4. 技能询问“May I write improvements to `.claude/skills/some-skill/SKILL.md`?”
5. 应用修复后重新运行 `/skill-test static some-skill`，现在 7/7 项检查通过
6. 判定结果为 IMPROVED（5→7）

**断言：**
- [ ] 在任何修改前建立基线分数（5/7）
- [ ] 诊断两个失败检查，并在拟议修复中处理
- [ ] 应用修复前询问“May I write”
- [ ] 重测确认改进（7/7）
- [ ] 判定结果为 IMPROVED，并显示修改前后的分数

---

### 用例 2：修复导致回归：分数比较显示回归并得到 REVERTED

**测试夹具：**
- `.claude/skills/some-skill/SKILL.md` 有 1 个静态失败（缺少交接说明）
- 拟议修复意外删除判定关键词章节（引入新的失败）

**输入：** `/skill-improve some-skill`

**预期行为：**
1. 基线为：6/7 项检查通过（1 个失败：缺少交接说明）
2. 技能提出修复并询问“May I write improvements?”
3. 应用修复并运行重测
4. 重测结果：5/7（修复了交接说明，但破坏了判定关键词）
5. 技能检测到回归：分数下降
6. 技能询问用户：“修复导致回归（6→5）。May I revert the changes?”
7. 用户确认后还原修改；判定结果为 REVERTED

**断言：**
- [ ] 最终确定前将重测分数与基线比较
- [ ] 分数下降时检测到回归
- [ ] 询问用户确认还原（不是自动还原）
- [ ] 用户确认后还原文件
- [ ] 判定结果为 REVERTED

---

### 用例 3：技能带有类别分配：基线记录两类分数

**测试夹具：**
- `.claude/skills/gate-check/SKILL.md` 是一个有 1 个静态检查失败和 2 个类别（G-criteria）失败的门禁技能
- `tests/skills/quality-rubric.md` 包含 Gate Skills 章节

**输入：** `/skill-improve gate-check`

**预期行为：**
1. 技能运行静态测试和类别测试以建立基线：
   - Static：6/7 项检查通过
   - Category: 3/5 G-criteria pass
2. 合并基线：9/12
3. 技能诊断全部 3 个失败并提出修复方案
4. 询问“May I write improvements to `.claude/skills/gate-check/SKILL.md`?”
5. 应用修复后重新运行两类测试
6. 重测结果：静态 7/7，类别 5/5 = 12/12
7. 判定结果为 IMPROVED（9→12）

**断言：**
- [ ] 基线同时记录静态分数和类别分数
- [ ] 使用合并分数进行比较（而不是只比较一种类型）
- [ ] 拟议修复处理全部 3 个失败
- [ ] 重测确认两类分数均有改进
- [ ] 判定结果为 IMPROVED，并显示合并后的前后分数

---

### 用例 4：技能已经完美：无需改进

**测试夹具：**
- `.claude/skills/brainstorm/SKILL.md` 没有静态失败
- 类别分数也是 5/5（如适用）

**输入：** `/skill-improve brainstorm`

**预期行为：**
1. 技能运行 `/skill-test static brainstorm`，7/7 项检查通过
2. 如适用类别测试：5/5 项标准通过
3. 技能输出：“无需改进，brainstorm 已完全合规”
4. 技能退出，不提出任何修改
5. 不询问“May I write”，也不修改文件
6. 判定结果为 NO CHANGE

**断言：**
- [ ] 确认 0 个失败后技能立即退出
- [ ] 显示“无需改进”消息
- [ ] 不提出修改
- [ ] 不询问“May I write”
- [ ] 判定结果为 NO CHANGE

---

### 用例 5：主管门禁检查：无门禁，skill-improve 是元工具

**测试夹具：**
- 至少有 1 个静态失败的技能

**输入：** `/skill-improve some-skill`

**预期行为：**
1. 技能运行测试-修复-重测循环
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定结果为 IMPROVED、NO CHANGE 或 REVERTED，不是门禁判定

---

## 协议合规性

- [ ] 提出任何修改前始终建立基线分数
- [ ] 在输出中显示修改前后的分数比较
- [ ] 应用任何修复前询问“May I write”
- [ ] 通过比较重测分数与基线检测回归
- [ ] 还原前询问用户确认（不是自动还原）
- [ ] 以 IMPROVED、NO CHANGE 或 REVERTED 判定结果结束

---

## 覆盖说明

- 改进循环设计为每次调用只运行一个修复-重测周期；运行多轮需要重新调用 `/skill-improve`。
- 改进循环不包含行为合规性（spec-mode 测试结果），只自动处理结构（静态）分数和类别分数。
- 未测试技能文件无法读取（权限错误或文件缺失）的情况；这会在建立基线前产生错误。
