---
name: milestone-review
description: "生成全面的项目里程碑进度评审，包含功能完整度、质量指标、风险评估和通过/不通过（go/no-go）建议。在里程碑检查点或评估里程碑截止日期就绪状态时使用。"
argument-hint: "[milestone-name|current] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
---

## 阶段 0：解析参数

提取里程碑名称（`current` 或具体名称）并解析评审模式（一次解析，本次运行所有门禁派生均复用）：
1. 如果传入 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

---

## 阶段 1：加载里程碑数据

从 `production/milestones/` 读取里程碑定义。如果参数为 `current`，使用最近修改的里程碑文件。

从 `production/sprints/` 读取该里程碑范围内所有迭代报告。

---

## 阶段 2：扫描代码库健康度

- 扫描 `TODO`、`FIXME`、`HACK` 标记，识别未完成的工作
- 检查 `production/risk-register/` 中的风险登记表

---

## 阶段 3：生成里程碑评审

```markdown
# 里程碑评审：[里程碑名称]

## 概览
- **目标日期**：[日期]
- **当前日期**：[今天]
- **剩余天数**：[N]
- **已完成迭代**：[X/Y]

## 功能完整度

### 已完全完成
| 功能 | 验收标准 | 测试状态 |
|---------|-------------------|-------------|

### 部分完成
| 功能 | 完成度 | 剩余工作 | 对里程碑的风险 |
|---------|--------|---------------|------------------|

### 尚未开始
| 功能 | 优先级 | 可否裁剪？ | 裁剪的影响 |
|---------|----------|----------|------------------|

## 质量指标
- **未关闭 S1 Bug**：[N] —— [列表]
- **未关闭 S2 Bug**：[N]
- **未关闭 S3 Bug**：[N]
- **测试覆盖率**：[X%]
- **性能**：[是否在预算内？详情]

## 代码健康度
- **TODO 数量**：[全代码库 N]
- **FIXME 数量**：[N]
- **HACK 数量**：[N]
- **技术债务条目**：[列出关键项]

## 风险评估
| 风险 | 状态 | 一旦发生的影响 | 缓解状态 |
|------|--------|-------------------|------------------|

## 速率分析
- **计划 vs 完成**（所有迭代合计）：[X/Y 任务 = Z%]
- **趋势**：[上升 / 稳定 / 下降]
- **剩余工作的修正估算**：[按当前速率所需天数]

## 范围建议
### 必须保留（必须随里程碑发布）
- [功能及原因]

### 有风险（可能需要裁剪或简化）
- [功能及风险]

### 裁剪候选（可推迟而不影响里程碑）
- [功能及裁剪影响]

## 通过/不通过评估

**建议**：[通过（GO）/ 有条件通过（CONDITIONAL GO）/ 不通过（NO-GO）]

**条件**（若有条件）：
- [必须满足的条件 1]
- [必须满足的条件 2]

**理由**：[对建议的说明]

## 行动项
| # | 行动 | 负责人 | 截止日期 |
|---|--------|-------|----------|
```

---

## 阶段 3b：制作人风险评估

**评审模式检查** —— 在派生 PR-MILESTONE 前执行：
- `solo` → 跳过。提示："PR-MILESTONE skipped — Solo mode."（PR-MILESTONE 已跳过 —— 单人模式。）直接呈现通过/不通过章节，不含制作人裁定。
- `lean` → 跳过（非 PHASE-GATE）。提示："PR-MILESTONE skipped — Lean mode."（PR-MILESTONE 已跳过 —— 精简模式。）直接呈现通过/不通过章节，不含制作人裁定。
- `full` → 正常派生。

在生成通过/不通过建议之前，通过 Task 使用门禁 **PR-MILESTONE**（`.claude/docs/director-gates.md`）派生 `producer`（制作人）。

传递：里程碑名称和目标日期、当前完成百分比、阻塞的故事数、迭代报告中的速率数据（如有）、裁剪候选列表。

将制作人的评估内联呈现在通过/不通过章节中。制作人裁定（ON TRACK 正轨 / AT RISK 有风险 / OFF TRACK 偏轨）影响整体建议。

如果为 OFF TRACK（偏轨），在生成建议前使用 `AskUserQuestion`：
- 提示："Producer verdict: OFF TRACK. The milestone is in jeopardy. This review will recommend NO-GO. How do you want to proceed?"（制作人裁定：偏轨。里程碑面临危机。本评审将建议不通过。您希望如何继续？）
- 选项：
  - `[A] Accept NO-GO — generate the full review with that recommendation`（接受不通过 —— 以该建议生成完整评审）
  - `[B] Override to CONDITIONAL GO — I'll document the accepted risks myself`（覆盖为有条件通过 —— 我将自行记录已接受的风险）
  - `[C] Stop — I want to address blockers before generating the review`（停止 —— 我想先解决阻塞项再生成评审）

如果为 AT RISK（有风险），使用 `AskUserQuestion`：
- 提示："Producer verdict: AT RISK. Milestone may slip. How should the Go/No-Go section be framed?"（制作人裁定：有风险。里程碑可能延期。通过/不通过章节应如何定调？）
- 选项：
  - `[A] CONDITIONAL GO — include producer's conditions in the review`（有条件通过 —— 在评审中包含制作人条件）
  - `[B] NO-GO — conditions cannot be met in time`（不通过 —— 条件无法按时满足）
  - `[C] GO — I accept the risk and want to proceed`（通过 —— 我接受风险并继续）

除非用户明确选择上方 [B]，否则不得在 OFF TRACK 裁定下出具通过建议。

---

## 阶段 4：保存评审

向用户呈现评审。

询问："May I write this to `production/milestones/[milestone-name]-review.md`?"（我可以将其写入 `production/milestones/[milestone-name]-review.md` 吗？）

如果同意，写入文件（按需创建目录）。裁定：**COMPLETE**（已完成）—— 里程碑评审已保存。

如果拒绝，在此停止。裁定：**BLOCKED**（阻塞）—— 用户拒绝写入。

---

## 阶段 5：后续步骤

- 如果此里程碑标志着一个开发阶段边界，运行 `/gate-check` 获取正式的阶段门禁裁定。
- 运行 `/sprint-plan`，根据上方的范围建议调整下一个迭代。
