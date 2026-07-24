---
name: skill-test
description: "验证技能文件的结构合规性和行为正确性。三种模式：static（检查器）、spec（行为验证）、audit（覆盖率报告）。"
argument-hint: "static [skill-name | all] | spec [skill-name] | category [skill-name | all] | audit"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---

# 技能测试

验证 `.claude/skills/*/SKILL.md` 文件的结构合规性和行为正确性。不依赖外部依赖项，完全在现有的技能/钩子/模板架构中运行。

**四种模式：**

| 模式 | 命令 | 用途 | Token 成本 |
|------|---------|---------|------------|
| `static` | `/skill-test static [name\|all]` | 结构检查器：每个技能执行 7 项合规检查 | Low (~1k/skill) |
| `spec` | `/skill-test spec [name]` | 行为验证器：评估测试规范中的断言 | Medium (~5k/skill) |
| `category` | `/skill-test category [name\|all]` | 类别量规：根据技能所属类别的专属指标进行检查 | Low (~2k/skill) |
| `audit` | `/skill-test audit` | 覆盖率报告：技能、代理规范、最近测试日期 | Low (~3k total) |

---

## 阶段 1：解析参数

根据第一个参数确定模式：

- `static [name]` → 对一个技能运行 7 项结构检查
- `static all` → 对所有技能运行 7 项结构检查（Glob `.claude/skills/*/SKILL.md`）
- `spec [name]` → 读取技能和测试规范，评估断言
- `category [name]` → 根据 `CCGS Skill Testing Framework/quality-rubric.md` 运行类别专属量规
- `category all` → 对 catalog 中含有 `category:` 的每个技能运行类别量规
- `audit`（或无参数）→ 读取 catalog，列出所有技能和代理，显示覆盖率

如果缺少参数或参数无法识别，输出用法并停止。

---

## 阶段 2A：Static 模式——结构检查器

对每个待测技能完整读取其 `SKILL.md`，并运行全部 7 项检查：

### 检查 1——必需的 Frontmatter 字段
文件的 YAML frontmatter 块必须包含以下全部字段：
- `name:`
- `description:`
- `argument-hint:`
- `user-invocable:`
- `allowed-tools:`

如果缺少任何字段，则为 **FAIL**。

### 检查 2——多个阶段
技能必须有至少 2 个编号阶段标题。查找以下模式：
- `## Phase N` 或 `## Phase N:`
- `## N.`（编号的顶层章节）
- 如果阶段没有明确编号，则至少有 2 个不同的 `##` 标题

如果找到少于 2 个类似阶段的标题，则为 **FAIL**。

### 检查 3——结论关键词
技能必须至少包含以下一个关键词：`PASS`、`FAIL`、`CONCERNS`、`APPROVED`、
`BLOCKED`, `COMPLETE`, `READY`, `COMPLIANT`, `NON-COMPLIANT`

如果一个都没有，则为 **FAIL**。

### 检查 4——协作协议语言
技能必须包含写入前询问的语言。查找：
- `"May I write"`（规范形式）
- 文件写入说明附近的 `"before writing"` 或 `"approval"`
- 相邻出现的 `"ask"` + `"write"`（位于同一章节内）

如果缺少，则为 **WARN**（某些只读技能可以合理跳过此项）。
如果 `allowed-tools` 包含 `Write` 或 `Edit`，但未找到写入前询问语言，则为 **FAIL**。

### 检查 5——后续步骤交接
技能必须以建议的下一步操作或后续路径结尾。查找：
- 提及另一个技能的最后章节（例如 `/story-done`、`/gate-check`）
- "Recommended next" 或 "next step" 表述
- "Follow-Up" 或 "After this" 章节

如果缺少，则为 **WARN**。

### 检查 6——Fork 上下文复杂度
如果 frontmatter 包含 `context: fork`，技能应有至少 5 个阶段标题（`##` 级别或编号的 Phase N 标题）。Fork 上下文用于复杂的多阶段技能；简单技能不应使用它。

如果设置了 `context: fork` 但找到少于 5 个阶段，则为 **WARN**。

### 检查 7——参数提示合理性
`argument-hint` 必须非空。如果技能正文提到多种模式（例如 "Mode A | Mode B"），提示应反映这些模式。将提示与第一个阶段的 "Parse Arguments" 章节进行交叉核对。

如果提示为 `""`，或文档中的模式与提示不匹配，则为 **WARN**。

---

### Static 模式输出格式

对于单个技能：
```
=== 技能静态检查：/[name] ===

检查 1——Frontmatter 字段：    PASS
检查 2——多个阶段：       PASS (找到 7 个阶段)
检查 3——结论关键词：      PASS (PASS, FAIL, CONCERNS)
检查 4——协作协议： PASS (找到 "May I write")
检查 5——后续步骤交接：     WARN (未找到后续章节)
检查 6——Fork 上下文复杂度： PASS (8 个阶段，已设置 context: fork)
检查 7——参数提示：         PASS

结论：WARNINGS（1 个警告，0 个失败）
建议：在技能末尾添加 "Follow-Up Actions" 章节。
```

对于 `static all`，先输出汇总表，再列出所有不合规技能：
```
=== 技能静态检查：全部 52 个技能 ===

技能                  | 结果       | 问题
-----------------------|--------------|-------
gate-check             | COMPLIANT    |
design-review          | COMPLIANT    |
story-readiness        | WARNINGS     | 检查 5：无交接
...

汇总：48 COMPLIANT、3 WARNINGS、1 NON-COMPLIANT
总体结论：N WARNINGS / N FAILURES
```

---

## 阶段 2B：Spec 模式——行为验证器

### 步骤 1——定位文件

在 `.claude/skills/[name]/SKILL.md` 查找技能。
从 `CCGS Skill Testing Framework/catalog.yaml` 查找规范路径，使用匹配技能条目的 `spec:` 字段。

如果任一项缺失：
- 缺少技能："在 `.claude/skills/` 中找不到技能 '[name]'。"
- catalog 中缺少规范路径："catalog.yaml 中未设置 '[name]' 的规范路径。"
- 路径处找不到规范文件："[path] 处缺少规范文件。运行 `/skill-test audit` 查看覆盖率缺口。"

### 步骤 2——读取两个文件

完整读取技能文件和测试规范文件。

### 步骤 3——评估断言

对于规范中的每个 **Test Case**：

1. 读取 **Fixture** 描述（项目文件的假设状态）
2. 读取 **Expected behavior** 步骤
3. 读取每个 **Assertion** 复选框

对于每个断言，评估在给定 Fixture 状态下正确遵循技能书面说明是否能够满足该断言。这是由 Claude 评估的推理检查，不执行代码。

标记每个断言：
- **PASS**——技能说明明确满足该断言
- **PARTIAL**——技能说明部分涉及，但存在歧义
- **FAIL**——根据 Fixture，技能说明无法满足该断言

对于始终存在的 **Protocol Compliance** 断言：
- 检查技能是否要求在文件写入前使用 "May I write"
- 检查技能是否在请求审批前展示发现结果
- 检查技能是否以建议的下一步结尾
- 检查技能是否避免未经审批自动创建文件

### 步骤 4——构建报告

```
=== 技能规范测试：/[name] ===
日期：[date]
规范：CCGS Skill Testing Framework/skills/[category]/[name].md

案例 1：[Happy Path — name]
  Fixture：[summary]
  断言：
    [PASS] [assertion text]
    [FAIL] [assertion text]
     原因：技能的阶段 3 说“...”，但 Fixture 状态意味着“...”
   案例结论：FAIL

案例 2：[Edge Case — name]
  ...
  案例结论：PASS

协议合规性：
  [PASS] 在文件写入前使用 "May I write"
  [PASS] 在请求审批前展示发现结果
  [WARN] 末尾没有明确的后续步骤交接

总体结论：FAIL（1 个案例失败，1 个警告）
```

### 步骤 5——询问是否写入结果

"May I write"：是否将这些结果写入 `CCGS Skill Testing Framework/results/skill-test-spec-[name]-[date].md` 并更新 `CCGS Skill Testing Framework/catalog.yaml`？

如果同意：
- 将结果文件写入 `CCGS Skill Testing Framework/results/`
- 更新 `CCGS Skill Testing Framework/catalog.yaml` 中技能的条目：
  - `last_spec: [date]`
  - `last_spec_result: PASS|PARTIAL|FAIL`

---

## 阶段 2D：Category 模式——量规评估

### 步骤 1——定位技能和类别

在 `.claude/skills/[name]/SKILL.md` 查找技能。
在 `CCGS Skill Testing Framework/catalog.yaml` 查找 `category:` 字段。

如果找不到技能："找不到技能 '[name]'。"
如果没有 `category:` 字段："catalog.yaml 中没有为 '[name]' 分配类别。请先向技能条目添加 `category: [name]`。"

对于 `category all`：收集所有含有 `category:` 字段的技能并逐一处理。
`category: utility` 技能只根据 U1（静态检查通过）和 U2（如适用，gate 模式正确）进行评估，U1 直接跳转到 static 模式。

### 步骤 2——读取量规章节

读取 `CCGS Skill Testing Framework/quality-rubric.md`。
提取与技能类别匹配的章节（例如 `### gate`、`### team`）。

### 步骤 3——读取技能

完整读取技能的 `SKILL.md`。

### 步骤 4——评估量规指标

对于类别量规表中的每个指标：
1. 检查技能的书面说明是否明确满足标准
2. 标记 PASS、FAIL 或 WARN
3. 对于 FAIL/WARN，指出技能文本中的确切缺口（引用相关章节或说明其缺失）

### 步骤 5——输出报告

```
=== 技能类别检查：/[name] ([category]) ===

指标 G1——Review 模式读取：      PASS
指标 G2——Full 模式主管：   FAIL
  缺口：阶段 3 仅生成 CD-PHASE-GATE；缺少 TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE
指标 G3——Lean 模式：仅 PHASE-GATE：PASS
指标 G4——Solo 模式：无主管：    PASS
指标 G5——不自动推进：       PASS

结论：FAIL（1 个失败，0 个警告）
修复：将 TD-PHASE-GATE、PR-PHASE-GATE 和 AD-PHASE-GATE 添加到阶段 3 的 Full 模式主管面板中。
```

### 步骤 6——询问是否更新 Catalog

"是否可以更新 `CCGS Skill Testing Framework/catalog.yaml`，记录 [name] 的此次类别检查（`last_category`、`last_category_result`）？"

---

## 阶段 2C：Audit 模式——覆盖率报告

### 步骤 1——读取 Catalog

读取 `CCGS Skill Testing Framework/catalog.yaml`。如果缺失，注明 catalog 尚不存在（首次运行状态）。

### 步骤 2——枚举所有技能和代理

使用 Glob `.claude/skills/*/SKILL.md` 获取完整的技能列表。
从每个路径（目录名）提取技能名称。

同时读取 `CCGS Skill Testing Framework/catalog.yaml` 中的 `agents:` 章节，以获得完整的代理列表。

### 步骤 3——构建技能覆盖率表

对于每个技能：
- 检查规范文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/skills/*/[name].md`）
- 查找 `last_static`、`last_static_result`、`last_spec`、`last_spec_result`、
  从 catalog 查找 `last_category`、`last_category_result`、`category`（或
  如果不在 catalog 中则标记为 "never" / "—"）
- 优先级来自 catalog 的 `priority:` 字段（critical/high/medium/low）

### 步骤 3b——构建代理覆盖率表

对于 catalog 的 `agents:` 章节中的每个代理：
- 检查规范文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/agents/*/[name].md`）
- 从 catalog 查找 `last_spec`、`last_spec_result`、`category`

### 步骤 4——输出报告

```
=== 技能测试覆盖率审计 ===
日期：[date]

技能（共 72 个）
已编写规范：72（100%）| 从未进行静态测试：72 | 从未进行类别测试：72

技能                  | 类别      | 有规范 | 最近静态测试 | S.Result | 最近类别测试 | C.Result | 优先级
-----------------------|----------|----------|-------------|----------|----------|----------|----------
gate-check             | gate     | YES      | never       | —        | never    | —        | critical
design-review          | review   | YES      | never       | —        | never    | —        | critical
...

代理（共 49 个）
已编写代理规范：49（100%）

代理                  | 类别   | 有规范 | 最近规范测试   | 结果
-----------------------|------------|----------|-------------|--------
creative-director      | director   | YES      | never       | —
technical-director     | director   | YES      | never       | —
...

前 5 个优先级缺口（没有规范且优先级为 critical/high 的技能）：
（如果所有规范都已编写则为 none）

技能覆盖率：72/72 个规范（100%）
代理覆盖率：49/49 个规范（100%）
```

Audit 模式不写入文件。

询问："是否运行 `/skill-test static all` 检查所有技能的结构合规性？运行 `/skill-test category all` 执行类别量规检查？或运行 `/skill-test spec [name]` 执行特定行为测试？"

---

## 阶段 3：建议的后续步骤

任一模式完成后，提供与上下文相关的后续操作：

- `static [name]` 完成后："如果存在测试规范，运行 `/skill-test spec [name]` 验证行为正确性。"
- `static all` 出现失败后："先处理 NON-COMPLIANT 技能。逐个运行 `/skill-test static [name]` 以获得详细修复指导。"
- `spec [name]` 为 PASS 后："更新 `CCGS Skill Testing Framework/catalog.yaml` 记录通过日期。可以运行 `/skill-test audit` 查找下一个规范缺口。"
- `spec [name]` 为 FAIL 后："检查失败的断言，并更新技能或测试规范以解决不匹配。"
- `audit` 完成后："从 critical 优先级缺口开始。使用 `CCGS Skill Testing Framework/templates/skill-test-spec.md` 中的规范模板创建新规范。"
