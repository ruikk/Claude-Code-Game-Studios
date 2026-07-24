---
name: scope-check
description: "通过将当前范围与原始计划进行比较，分析功能或迭代是否发生范围蔓延。标记新增内容、量化膨胀程度并提出删减建议。当用户说‘是否有范围蔓延’、‘范围审查’或‘我们是否仍在范围内’时使用。"
argument-hint: "[feature-name or sprint-N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
model: haiku
---

# 范围检查

此技能为只读模式，只报告发现，不写入任何文件。

将原始计划范围与当前状态进行比较，以检测、量化并分级处理范围蔓延。

**参数：** `$ARGUMENTS[0]` — 功能名称、迭代编号或里程碑名称。

---

## 阶段 1：查找原始计划

根据给定参数定位范围基准文档：

- **功能名称** → 读取 `design/gdd/[feature].md` 或 `design/` 中的匹配文件
- **迭代编号**（例如 `sprint-3`）→ 读取 `production/sprints/sprint-03.md` 或类似文件
- **里程碑** → 读取 `production/milestones/[name].md`

如果找不到文档，报告缺失文件并停止。没有可供比较的基准时不要继续。

---

## 阶段 2：读取当前状态

检查实际已实现或正在进行的内容：

- 扫描代码库中与该功能/迭代相关的文件
- 读取与此工作相关的 git 提交记录（`git log --oneline --since=[start-date]`）
- 检查表示范围新增内容尚未完成的 TODO/FIXME 注释
- 如果该功能处于迭代中，检查当前迭代计划

---

## 阶段 3：比较原始范围与当前范围

生成比较报告：

```markdown
## 范围检查：[Feature/Sprint Name]
生成时间：[Date]

### 原始范围
[List of items from the original plan]

### 当前范围
[List of items currently implemented or in progress]

### 范围新增内容（不在原始计划中）
| 新增内容 | 来源 | 时间 | 是否合理？ | 工作量 |
|----------|--------|------|------------|--------|
| [item] | [commit/person] | [date] | [Yes/No/Unclear] | [S/M/L] |

### 范围删减（原计划中但已移除）
| 移除项目 | 原因 | 影响 |
|-------------|--------|--------|
| [item] | [why removed] | [what's affected] |

### 膨胀评分
- 原始项目数：[N]
- 当前项目数：[N]
- 新增项目数：[N]（+[X]%）
- 移除项目数：[N]
- 范围净变化：[+/-N]（[X]%）

### 风险评估
- **进度风险**：[Low/Medium/High] — [explanation]
- **质量风险**：[Low/Medium/High] — [explanation]
- **集成风险**：[Low/Medium/High] — [explanation]

### 建议
1. **删减**：[为按计划完成而应移除的项目]
2. **延期**：[可移至未来迭代/版本的项目]
3. **保留**：[确实必要的新增内容]
4. **标记**：[需要制片人/创意总监决策的项目]
```

---

## 阶段 4：结论

根据范围净变化指定规范结论：

| 净变化 | 结论 | 含义 |
|-----------|---------|---------|
| ≤10% | **PASS** | 按计划进行 — 在可接受偏差范围内 |
| 10–25% | **CONCERNS** | 轻微蔓延 — 通过针对性删减即可控制 |
| 25–50% | **FAIL** | 严重蔓延 — 必须删减或正式延长时间线 |
| >50% | **FAIL** | 失控 — 停止、重新规划并上报制片人 |

突出输出结论：

```
**范围结论：[PASS / CONCERNS / FAIL]**
净变化：[+X%] — [On Track / Minor Creep / Significant Creep / Out of Control]
```

---

## 阶段 5：后续步骤

呈现报告后，提供具体的后续行动：

- **PASS** → 无需采取行动。建议在下一个里程碑前重新运行。
- **CONCERNS** → 提议找出删减收益最高的 2–3 项新增内容。引用 `/sprint-plan update` 以正式重新确定范围。
- **FAIL** → 建议上报制片人。引用 `/sprint-plan update` 进行重新规划，或引用 `/estimate` 重新建立时间线基准。

始终以以下内容结尾：
> "完成删减后再次运行 `/scope-check [name]`，以验证结论是否改善。"

---

### 规则

- 范围蔓延是指没有相应删减或时间线延长的新增内容
- 并非所有新增内容都不好，有些是新发现的需求。但必须承认并计入计划
- 提出删减建议时，优先保留核心玩家体验，而不是锦上添花的内容
- 始终量化范围变化——“感觉变大了”无法指导行动，而“项目数 +35%”可以
