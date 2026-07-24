---
name: skill-improve
description: "使用测试-修复-重测循环改进技能。运行静态检查，提出针对性修复，重写技能，重新测试，并根据分数变化保留或还原。"
argument-hint: "[skill-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
model: sonnet
---

# 改进技能

对单个技能运行改进循环：
测试 → 修复 → 重测 → 保留或还原。

---

## 阶段 1：解析参数

从第一个参数读取技能名称。如果缺少参数，输出用法并停止：

```
Usage: /skill-improve [skill-name]
Example: /skill-improve tech-debt
```

验证 `.claude/skills/[name]/SKILL.md` 是否存在。如果不存在，停止并显示：
"Skill '[name]' not found."

---

## 阶段 2：基线测试

运行 `/skill-test static [name]` 并记录基线分数：
- FAIL 的数量
- WARN 的数量
- 哪些具体检查失败（检查 1–7）

向用户显示：
```
Static baseline:   [N] failures, [M] warnings
Failing: Check 4 (no ask-before-write), Check 5 (no handoff)
```

如果基线为 0 个 FAIL 和 0 个 WARN，注明这一点并继续阶段 2b。

### 阶段 2b：类别基线

在 `CCGS Skill Testing Framework/catalog.yaml` 中查找技能的 `category:` 字段。

如果找不到 `category:` 字段，显示：
"Category: not yet assigned — skipping category checks."
并跳至阶段 3。

如果找到类别，运行 `/skill-test category [name]` 并记录类别基线：
- FAIL 的数量
- WARN 的数量
- 哪些具体类别评估指标失败

向用户显示：
```
Category baseline: [N] failures, [M] warnings  ([category] rubric)
```

如果静态基线和类别基线均为 0 个 FAIL 和 0 个 WARN，停止并显示：
"This skill already passes all static and category checks. No improvements needed."

---

## 阶段 3：诊断

读取 `.claude/skills/[name]/SKILL.md` 中的完整技能文件。

对于每个失败或警告的**静态**检查，找出确切缺口：

- **检查 1 失败** → 缺少哪个 frontmatter 字段
- **检查 2 失败** → 找到的阶段数与最低要求分别是多少
- **检查 3 失败** → 技能正文中任何位置都没有结论关键词
- **检查 4 失败** → allowed-tools 中有 Write 或 Edit，但没有写入前询问的措辞
- **检查 5 警告** → 末尾没有后续或下一步章节
- **检查 6 警告** → 已设置 `context: fork`，但找到的阶段少于 5 个
- **检查 7 警告** → argument-hint 为空，或与记录的模式不匹配

对于每个失败或警告的**类别**检查（如果阶段 2b 已分配类别），找出技能文本中的确切缺口。例如：
- 如果 G2 失败（gate 模式，未生成完整 director）：技能正文从未引用全部 4 个
  PHASE-GATE director prompts
- 如果 A2 失败（authoring，没有逐章节 May-I-write）：技能只在末尾询问一次，而不是
  在每个章节写入前询问
- 如果 T3 失败（team，没有显示 BLOCKED）：技能没有暂停依赖于被阻塞代理的工作

在提出任何更改之前，向用户显示完整的合并诊断。

---

## 阶段 4：提出修复方案

为每个失败和警告编写针对性修复。以清晰标记的修改前/修改后区块显示拟议更改。只更改失败的内容，不要重写已通过的章节。

询问：“可以将此改进版本写入 `.claude/skills/[name]/SKILL.md` 吗？”

如果用户拒绝，在此停止。

---

## 阶段 5：写入并重测

记录技能文件的当前内容（必要时用于还原）。

将改进后的技能写入 `.claude/skills/[name]/SKILL.md`。

重新运行 `/skill-test static [name]` 并记录新的静态分数。
如果已分配类别，也重新运行 `/skill-test category [name]` 并记录新的类别分数。

显示比较结果：
```
Static:   Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings
Category: Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings  (if applicable)
Combined change: improved / no change / worse
```

---

## 阶段 6：结论

计算合并失败总数：静态 FAIL + 类别 FAIL + 静态 WARN + 类别 WARN。

**如果合并分数提高（合并失败数低于基线）：**
报告：“分数提高。保留更改。”
显示各个维度中已修复内容的摘要。

**如果合并分数相同或更差：**
报告：“合并分数没有提高。”
显示更改内容及其可能未起作用的原因。
询问：“可以使用 git checkout 还原 `.claude/skills/[name]/SKILL.md` 吗？”
如果同意：运行 `git checkout -- .claude/skills/[name]/SKILL.md`

---

## 阶段 7：后续步骤

- 运行 `/skill-test static all` 查找下一个存在失败的技能。
- 运行 `/skill-improve [next-name]` 在另一个技能上继续循环。
- 运行 `/skill-test audit` 查看总体覆盖进度。
