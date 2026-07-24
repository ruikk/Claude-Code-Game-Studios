---
name: reverse-document
description: "从现有实现生成设计或架构文档。根据代码/原型反向创建缺失的规划文档。"
argument-hint: "<type> <path>（例如：'design src/gameplay/combat' 或 'architecture src/core'）"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
model: sonnet
# 只读诊断技能——无需委派专业代理
---

# 反向文档化

此技能分析现有实现（代码、原型、系统），并生成适当的设计或架构文档。以下情况适用：
- 在未先编写设计文档的情况下构建了功能
- 接手了没有文档的代码库
- 制作了一个机制原型，需要将其正式化
- 需要记录现有代码背后的“为什么”

---

## 工作流

## 阶段 1：解析参数

**格式**：`/reverse-document <type> <path>`

**类型选项**：
- `design` → 生成游戏设计文档（GDD 章节）
- `architecture` → 生成架构决策记录（ADR）
- `concept` → 根据原型生成概念文档

**路径**：要分析的目录或文件
- `src/gameplay/combat/` → 所有与战斗相关的代码
- `src/core/event-system.cpp` → 指定文件
- `prototypes/stealth-mech/` → 原型目录

**示例**：
```bash
/reverse-document design src/gameplay/magic-system
/reverse-document architecture src/core/entity-component
/reverse-document concept prototypes/vehicle-combat
```

## 阶段 2：分析实现

**读取并理解代码/原型**：

**对于设计文档（GDD）：**
- 识别机制、规则和公式
- 提取游戏数值（伤害、冷却时间、范围）
- 查找状态机、能力系统和成长系统
- 检测代码中处理的边界情况
- 映射依赖关系（哪些系统相互作用？）

**对于架构文档（ADR）：**
- 识别模式（ECS、单例、观察者等）
- 理解技术决策（线程、序列化等）
- 映射依赖关系和耦合
- 评估性能特征
- 查找约束和权衡

**对于概念文档（原型分析）：**
- 识别核心机制
- 提取涌现式游戏模式
- 记录有效之处与无效之处
- 找出技术可行性方面的洞见
- 记录玩家幻想/体验感受

## 阶段 3：提出澄清问题

**不要**只描述代码。要**询问**设计意图：

**设计问题**：
- “我看到一个在 [activity] 期间消耗的 [resource] 系统。它的目的是什么：
  - 节奏控制（防止滥用）？
  - 资源管理（增加策略深度）？
  - 还是其他原因？”
- “[mechanic] 似乎处于核心位置。它是核心支柱，还是辅助功能？”
- “[Value] 随 [factor] 呈指数增长。这是有意的设计，还是需要重新平衡？”

**架构问题**：
- “你使用了服务定位器模式。选择它的原因是：
  - 可测试性（模拟依赖）？
  - 解耦（减少硬引用）？
  - 还是继承自现有代码？”
- “我看到这里使用手动内存管理，而不是智能指针。这是性能要求，还是历史遗留？”

**概念问题**：
- “原型更强调潜行而非战斗。这是预期的核心支柱吗？”
- “玩家似乎会利用抓钩来提速。这是功能还是漏洞？”

## 阶段 4：展示发现

起草前，展示你发现的内容：

```
我已分析 [path]/。以下是我的发现：

已实现的机制：
- 具有 [property] 的 [mechanic-a]（例如时机窗口、冷却时间）
- [mechanic-b]（例如两种状态之间的交互）
- [resource] 系统（执行 [action] 时消耗，满足 [condition] 时恢复）
- [state] 系统（逐渐积累并触发 [effect]）

发现的公式：
- [Output] = [formula using discovered variables]
- [Secondary output] = [formula]

意图不明确的部分：
1. [Resource] 系统——用于节奏控制还是资源管理？
2. [Mechanic]——核心支柱还是辅助功能？
3. [Value] 的缩放——有意为之还是需要调整？

在我起草设计文档前，可以请你澄清这些问题吗？
```

等待用户澄清意图后再起草。

## 阶段 5：使用模板起草文档

根据类型使用适当的模板：

| 类型 | 模板 | 输出路径 |
|------|----------|-------------|
| `design` | `templates/design-doc-from-implementation.md` | `design/gdd/[system-name].md` |
| `architecture` | `templates/architecture-doc-from-code.md` | `docs/architecture/[decision-name].md` |
| `concept` | `templates/concept-doc-from-prototype.md` | `prototypes/[name]/CONCEPT.md` or `design/concepts/[name].md` |

**起草结构**：
- 记录**现有内容**（机制、模式、实现）
- 记录**存在原因**（已与用户澄清的意图）
- 识别**缺失内容**（未处理的边界情况、设计缺口）
- 标记**后续工作**（平衡性调整、缺失功能）

## 阶段 6：展示草稿并请求批准

**协作协议**：
```
我已根据你的代码和澄清内容起草了 [system-name] 设计文档。

[Show key sections: Overview, Mechanics, Formulas, Design Intent]

我新增的内容：
- 根据你的澄清，将 [mechanic] 记录为“[intent]”
- 补充了代码中没有的边界情况（例如，如果 [resource] 在 [action] 过程中降至 0 会怎样？）
- 标记了平衡性问题：[scaling type] 在 [boundary condition] 时的缩放

标记为未完成的章节：
- “[System] 与 [other-system] 的交互”（尚未完全实现）
- “[Variant or feature]”（目前仅实现了 [subset]）

可以将此内容写入 design/gdd/[system-name].md 吗？
```

等待批准。用户可以在写入前要求修改。

## 阶段 7：写入带元数据的文档

获得批准后，使用特殊标记写入文件：

```markdown
---
status: reverse-documented
source: [path/]
date: [today]
verified-by: [User name]
---

# [System Name] 设计

> **注意**：本文档根据现有实现反向整理而成。
> 它记录了当前行为和已经澄清的设计意图。如果实现不完整或意图不明确，
> 部分章节可能尚未完成。

[Rest of document...]
```

## 阶段 8：标记后续工作

写入后，建议下一步：

```
✅ 已写入 design/gdd/combat-system.md

建议的后续工作：
1. 对战斗公式运行 /balance-check（关注指数缩放问题）
2. 为耐力系统架构决策创建 ADR
3. 实现缺失的边界情况：
   - 连击过程中耐力耗尽时的行为
   - 闪避期间的硬直状态
4. 实现武器多样性后扩展设计文档

你希望我现在处理其中哪一项吗？
```

---

## 模板选择逻辑

| 如果分析…… | 使用模板…… | 原因…… |
|----------------|-----------------|------------|
| `src/gameplay/*` | design-doc-from-implementation.md | 游戏机制 → GDD |
| `src/core/*`, `src/ai/*` | architecture-doc-from-code.md | 核心系统 → ADR |
| `prototypes/*` | concept-doc-from-prototype.md | 实验 → 概念文档 |
| `src/networking/*` | architecture-doc-from-code.md | 技术系统 → ADR |
| `src/ui/*` | design-doc-from-implementation.md | UI/UX → 设计规格 |

---

## 示例会话：反向记录一个系统

```
用户：/reverse-document design src/gameplay/[system]

代理：我将分析你的 [system] 实现并创建设计文档。
       [Reads code, discovers mechanics, formulas]

代理：我已分析 src/gameplay/[system]/。以下是我的发现：
       [Shows mechanics, formulas, unclear areas]

      起草前，可以请你澄清以下问题吗：
      1. [Resource] 系统的意图是什么？
      2. [mechanic] 是核心支柱吗？
      3. [Value] 的缩放是有意为之，还是需要调整？

用户：1. [Resource] 用于控制节奏，防止 [unwanted behavior]
      2. [Mechanic] 是核心机制——我希望实现 [design intent]
      3. 是的，指数增长太强了，应该改为线性增长

代理：很好，这让整体构想清晰了。我来起草设计文档。
       [Shows draft with clarified intent]

      可以将此内容写入 design/gdd/[system-name].md 吗？

用户：可以，写入吧。

代理：✅ 已写入 design/gdd/[system-name].md
      ✅ 已标记为 [REVERSE-DOCUMENTED]
      ✅ 已标记 [value] 的缩放以便重新平衡

      后续步骤：
      - 将 [formula] 更新为 [corrected scaling]
      - 运行 /balance-check 验证 [curve]
      - 在 game-pillars.md 中将 [mechanic] 记录为核心支柱
```

---

## 协作协议

此技能遵循协作设计原则：

1. **先分析**：读取代码，理解实现
2. **询问意图**：询问“为什么”，而不只是“是什么”
3. **展示发现**：展示发现内容，突出不明确的区域
4. **用户澄清**：区分设计意图与意外行为
5. **起草文档**：根据现实情况和意图创建文档
6. **展示草稿**：展示关键章节，解释新增内容
7. **获得批准**：“可以写入 [filepath] 吗？”获得批准后：判定：**COMPLETE**——文档已生成。拒绝后：判定：**BLOCKED**——用户拒绝写入。
8. **标记后续工作**：建议相关工作，不要自动执行

**绝不假设意图。在记录“为什么”之前务必先询问。**
