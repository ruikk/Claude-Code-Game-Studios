---
name: bug-report
description: "根据描述创建结构化缺陷报告，或分析代码以识别潜在缺陷。确保每份缺陷报告都包含完整的复现步骤、严重程度评估和上下文。"
argument-hint: "[description] | analyze [path-to-file]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---

## 阶段 1：解析参数

根据参数确定模式：

- 无关键字 → **描述模式**：根据提供的描述生成结构化缺陷报告
- `analyze [path]` → **分析模式**：读取目标文件并识别潜在缺陷
- `verify [BUG-ID]` → **验证模式**：确认已报告的修复确实解决了缺陷
- `close [BUG-ID]` → **关闭模式**：将已验证的缺陷标记为已关闭，并记录解决情况

如果未提供参数，请先向用户询问缺陷描述，再继续操作。

---

## 阶段 2A：描述模式

1. **解析描述**中的关键信息：什么出了问题、何时发生、如何复现以及预期行为是什么。

2. **搜索代码库**：使用 Grep/Glob 查找相关文件，以补充上下文（受影响的系统、可能涉及的文件）。

3. **起草缺陷报告**：

```markdown
# 缺陷报告（Bug Report）

## 概要（Summary）
**标题**: [简洁且描述清晰的标题]
**ID**: BUG-[NNNN]
**严重程度**: [S1-Critical / S2-Major / S3-Minor / S4-Trivial]
**优先级**: [P1-Immediate / P2-Next Sprint / P3-Backlog / P4-Wishlist]
**状态**: Open
**报告日期**: [日期]
**报告人**: [姓名]

## 分类（Classification）
- **类别**: [Gameplay / UI / Audio / Visual / Performance / Crash / Network]
- **系统**: [受影响的游戏系统]
- **频率**: [Always / Often (>50%) / Sometimes (10-50%) / Rare (<10%)]
- **回归**: [Yes/No/Unknown -- 此功能之前是否正常工作？]

## 环境（Environment）
- **构建**: [版本号或提交哈希]
- **平台**: [操作系统及相关硬件信息]
- **场景/级别**: [游戏中的发生位置]
- **游戏状态**: [相关状态 -- 物品栏、任务进度等]

## 复现步骤（Reproduction Steps）
**前置条件**: [开始前所需的状态]

1. [准确步骤 1]
2. [准确步骤 2]
3. [准确步骤 3]

**预期结果**: [应发生的结果]
**实际结果**: [实际发生的结果]

## 技术背景（Technical Context）
- **可能受影响的文件**: [根据代码库搜索结果列出文件]
- **关联系统**: [可能涉及的其他系统]
- **潜在根本原因**: [如果能从描述中判断]

## 证据（Evidence）
- **日志**: [如有，请提供相关日志输出]
- **视觉证据**: [视觉证据描述]

## 相关问题（Related Issues）
- [相关缺陷或设计文档的链接]

## 备注（Notes）
[任何补充上下文或观察结果]
```

---

## 阶段 2B：分析模式

1. **读取参数中指定的目标文件**。

2. **识别潜在缺陷**：空引用、差一错误、竞态条件、未处理的边界情况、资源泄漏、错误的状态转换。

3. **针对每个潜在缺陷**，使用上述模板生成缺陷报告，并填写可能的触发场景和建议修复方案。

---

## 阶段 2C：验证模式

读取 `production/qa/bugs/[BUG-ID].md`。提取复现步骤和预期结果。

1. **重新执行复现步骤** — 使用 Grep/Glob 检查所述根因代码路径是否仍然存在。如果修复已删除或更改该路径，请记录变更。
2. **运行相关测试** — 如果缺陷所属系统在 `tests/` 中有测试文件，请通过 Bash 运行并报告通过/失败结果。
3. **检查回归** — 使用 grep 在代码库中查找导致该缺陷的模式是否出现了新的实例。

给出验证结论：

- **VERIFIED FIXED** — 复现步骤不再触发该缺陷；相关测试通过
- **STILL PRESENT** — 缺陷仍可按描述复现；修复未解决问题
- **CANNOT VERIFY** — 自动检查无法得出结论；需要手动试玩验证

询问：“可以更新 `production/qa/bugs/[BUG-ID].md`，将 Status 设置为 Verified Fixed / Still Present / Cannot Verify 吗？”

如果为 STILL PRESENT：重新打开该缺陷，将 Status 恢复为 Open，并建议重新运行 `/hotfix [BUG-ID]`。

---

## 阶段 2D：关闭模式

读取 `production/qa/bugs/[BUG-ID].md`。关闭前确认 Status 为 `Verified Fixed`。如果是其他状态，则停止：“缺陷 [ID] 必须为 Verified Fixed 才能关闭。请先运行 `/bug-report verify [BUG-ID]`。”

在缺陷文件末尾追加关闭记录：

```markdown
## 关闭记录（Closure Record）
**关闭日期**: [日期]
**解决结果**: Fixed — [用一行描述所做的更改]
**修复提交 / PR**: [如已知]
**验证人**: qa-tester
**关闭人**: [用户]
**回归测试**: [测试文件路径，或 "Manual verification"]
**状态**: Closed
```

将顶层的 `**Status**: Open` 字段更新为 `**Status**: Closed`。

询问：“可以更新 `production/qa/bugs/[BUG-ID].md`，将其标记为 Closed 吗？”

关闭后，检查 `production/qa/bug-triage-*.md` — 如果该缺陷出现在尚未关闭的分流报告中，请注明：“分流报告引用了缺陷 [ID]。请运行 `/bug-triage` 刷新 Open 缺陷数量。”

---

## 阶段 3：保存报告

向用户展示完整的缺陷报告。

询问：“可以将此内容写入 `production/qa/bugs/BUG-[NNNN].md` 吗？”

如果可以，则写入文件，并在需要时创建目录。Verdict: **COMPLETE** — 缺陷报告已归档。

如果不可以，则在此停止。Verdict: **BLOCKED** — 用户拒绝写入。

---

## 阶段 4：后续步骤

保存后，根据模式提出建议：

**归档后（描述/分析模式）：**
- 运行 `/bug-triage`，与现有 Open 缺陷一起确定优先级
- 如果是 S1 或 S2：运行 `/hotfix [BUG-ID]`，启动紧急修复工作流

**修复缺陷后（开发者确认修复已合入）：**
- 运行 `/bug-report verify [BUG-ID]` — 在关闭前确认修复确实有效
- 未经验证，绝不能将缺陷标记为关闭 — 无法通过验证的修复，其缺陷仍为 Open

**verify 返回 VERIFIED FIXED 后：**
- 运行 `/bug-report close [BUG-ID]` — 写入关闭记录并更新状态
- 运行 `/bug-triage`，刷新 Open 缺陷数量，并将该缺陷从活动列表中移除
