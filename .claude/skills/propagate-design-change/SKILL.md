---
name: propagate-design-change
description: "当 GDD 被修订时，扫描所有 ADR 和可追溯性索引，识别哪些架构决策可能已过时。生成变更影响报告，并引导用户完成处理。"
argument-hint: "[path/to/changed-gdd.md]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, Task
model: sonnet
agent: technical-director
---

# 传播设计变更

GDD 发生变化时，基于它编写的架构决策可能不再有效。本技能会找出所有受影响的 ADR，比较 ADR 的假设与 GDD 当前的内容，并引导用户完成处理。

**用法：** `/propagate-design-change design/gdd/combat-system.md`

---

## 1. 验证参数

必须提供 GDD 路径参数。如果缺少参数，失败并显示：
> "用法：`/propagate-design-change design/gdd/[system].md`
> 请提供已变更 GDD 的路径。"

确认文件存在。如果不存在，失败并显示：
> "[path] 未找到。请检查路径后重试。"

---

## 2. 读取已变更的 GDD

完整读取当前 GDD。

---

## 3. 读取之前的版本

运行 git 获取上一次提交的版本：

```bash
git show HEAD:design/gdd/[filename].md
```

如果文件没有 git 历史，报告：
> "git 中没有之前的版本——这似乎是新的 GDD，而不是一次修订。
> 没有需要传播的变更。"

如果 git 返回之前的版本，进行概念性差异比较：
- 识别发生变化的章节（新增规则、移除规则、修改公式、变更验收标准、变更调优参数）
- 识别未发生变化的章节
- 生成变更摘要：

```
## 变更摘要：[GDD filename]
修订日期：[today]

已变更章节：
- [Section name]：[变更内容——新增规则、移除规则、公式修改等]

未变更章节：
- [Section name]

影响架构的关键变更：
- [Change 1——可能影响 ADR]
- [Change 2]
```

---

## 4. 加载架构输入

读取 `docs/architecture/` 中的所有 ADR：
- 完整读取每个 ADR 文件
- 提取 "GDD Requirements Addressed" 表格
- 记录每个 ADR 引用的 GDD 文档和需求 ID

如果存在，读取 `docs/architecture/architecture-traceability.md`。

报告："已加载 [N] 个 ADR。[M] 个 ADR 引用了 [gdd filename]."

---

## 5. 影响分析

对于每个引用已变更 GDD 的 ADR：

将 ADR 的 "GDD Requirements Addressed" 条目与 GDD 的已变更章节进行比较。对于每个被引用的需求：

1. **定位需求**：在当前 GDD 中定位该需求——它是否仍然存在？
2. **比较**：编写 ADR 时 GDD 的内容是什么，现在的内容是什么？
3. **评估 ADR 决策**：架构决策是否仍然有效？

将每个受影响的 ADR 分类为以下状态之一：

| 状态 | 含义 |
|--------|---------|
| ✅ **Still Valid** | GDD 变更不影响此 ADR 的决策 |
| ⚠️ **Needs Review** | GDD 变更可能影响此 ADR——需要人工判断 |
| 🔴 **Likely Superseded** | GDD 变更直接矛盾于此 ADR 的假设 |

对于每个受影响的 ADR，生成一条影响记录：

```
### ADR-NNNN：[title]
状态：[Still Valid / Needs Review / Likely Superseded]

ADR 对此 GDD 的假设：
  "[ADR 的 GDD Requirements Addressed 部分中的相关引文]"

GDD 当前的内容：
  "[当前 GDD 中的相关引文]"

评估：
  [说明 ADR 决策是否仍然有效，以及原因]

建议操作：
  [Keep as-is | Review and update | Mark Superseded and write new ADR]
```

---

## 6. 呈现影响报告

在请求任何操作前，先向用户呈现完整的影响报告。格式如下：

```
## 设计变更影响报告
GDD：[filename]
日期：[today]
检测到的变更：[N sections changed]
引用此 GDD 的 ADR：[M]

### 未受影响
[引用此 GDD 且决策仍然有效的 ADR]

### 需要审查（[count]）
[可能需要更新的 ADR]

### 可能已被取代（[count]）
[其假设现在已被矛盾内容推翻的 ADR]
```

---

## 6b. 总监关卡——技术影响审查

**审查模式检查**——在启动 TD-CHANGE-IMPACT 前应用：
- `solo` → 跳过。备注："已跳过 TD-CHANGE-IMPACT——Solo 模式。"进入第 7 阶段。
- `lean` → 跳过。备注："已跳过 TD-CHANGE-IMPACT——Lean 模式。"进入第 7 阶段。
- `full` → 正常启动。

使用关卡 **TD-CHANGE-IMPACT**（`.claude/docs/director-gates.md`），通过 Task 启动 `technical-director`。

传入：第 6 阶段生成的完整设计变更影响报告（变更摘要、所有受影响 ADR 及其 Still Valid / Needs Review / Likely Superseded 分类，以及建议操作）。

technical-director 审查以下内容：
- 影响分类是否正确（没有 ADR 被低估分类）
- 建议操作在架构上是否合理
- 是否遗漏了对其他 ADR 或系统的级联影响

应用裁决：
- **APPROVE** → 进入第 7 阶段处理流程
- **CONCERNS** → 展示被标记的具体 ADR 或建议；使用 `AskUserQuestion`，选项为：`Revise the impact assessment` / `Accept with noted concerns` / `Discuss further`
- **REJECT** → 不要进入处理流程；在继续之前重新分析影响

---

## 7. 处理流程

对于标记为 "Needs Review" 或 "Likely Superseded" 的每个 ADR，询问用户如何处理：

依次询问每个 ADR：
> "ADR-NNNN（[title]）——[status]。您想如何处理？"
> 选项：
> - "Mark Superseded (I'll write a new ADR)"——将 ADR 状态行更新为 `Superseded by: [pending]`
> - "Update in place (minor revision)"——打开 ADR 进行编辑；注明需要修订的内容
> - "Keep as-is (the change doesn't actually affect this decision)"
> - "Skip for now (revisit later)"

对于标记为 **Superseded** 的 ADR：
- 将 ADR 的 Status 字段更新为：`Superseded by ADR-[next number] (pending — see change-impact-[date]-[system].md)`
- 询问："可以更新 [ADR filename] 中的状态吗？"

---

## 8. 更新可追溯性索引

如果存在 `docs/architecture/architecture-traceability.md`：
- 将已变更的 GDD 需求添加到 "Superseded Requirements" 表格：

```markdown
## Superseded Requirements
| Date | GDD | Requirement | Changed To | ADRs Affected | Resolution |
|------|-----|-------------|------------|---------------|------------|
| [date] | [gdd] | [old requirement text] | [new requirement text] | ADR-NNNN | [Superseded/Updated/Valid] |
```

询问："可以更新可追溯性索引吗？"

---

## 9. 输出变更影响文档

询问："可以将变更影响报告写入 `docs/architecture/change-impact-[date]-[system-slug].md` 吗？"

文档包含：
- 第 3 步的变更摘要
- 第 5 步的完整影响分析
- 第 7 步作出的处理决定
- 需要编写或更新的 ADR 列表

如果用户批准：裁决：**COMPLETE**——变更影响报告已保存。
如果用户拒绝：裁决：**BLOCKED**——用户拒绝写入。

---

## 10. 后续操作

根据处理决定提出建议：

- **标记为 Superseded 的 ADR**："运行 `/architecture-decision [title]` 编写替代 ADR。然后重新运行 `/propagate-design-change` 验证覆盖范围。"
- **需要原位更新的 ADR**：列出每个 ADR 中需要更新的具体字段
- **受影响的 ADR 较多时**："所有 ADR 更新后运行 `/architecture-review`，验证完整的可追溯矩阵仍然一致。"

---

## 协作协议

1. **静默读取**——在展示任何内容前计算完整影响
2. **先展示完整报告**——让用户在请求操作前了解范围
3. **逐个询问 ADR**——不要批量决定；每个受影响的 ADR 可能需要不同处理
4. **写入前询问**——修改任何文件前始终确认
5. **非破坏性**——绝不删除 ADR 内容；只能添加 "Superseded by" 备注
