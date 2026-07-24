---
name: help
description: "分析已完成的工作和用户的问题，并建议下一步该做什么。当用户说‘我接下来该做什么’、‘我现在该做什么’、‘我卡住了’或‘我不知道该做什么’时使用。"
argument-hint: "[可选：刚完成的事项，例如 '已完成 design-review' 或 '卡在 ADR 上']"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: |
  !echo "=== Live Project State ===" && echo "Stage: $(cat production/stage.txt 2>/dev/null | tr -d '[:space:]' || echo 'not set')" && echo "Latest sprint: $(ls -t production/sprints/*.md 2>/dev/null | head -1 || echo 'none')" && echo "Session state: $(head -5 production/session-state/active.md 2>/dev/null || echo 'none')"
model: haiku
---

# 工作室帮助 —— 接下来该做什么？

此技能为只读技能，只报告发现，不写入文件。

此技能会准确判断你在游戏开发流程中的位置，并告诉你下一步该做什么。它是**轻量级**的，不是完整审计。要进行完整的差距分析，请使用 `/project-stage-detect`。

---

## 第 1 步：读取目录

读取 `.claude/docs/workflow-catalog.yaml`。这是所有阶段及其步骤（按顺序排列）的权威列表，同时说明每个步骤是必需还是可选，以及表示完成状态的产物 glob。

---

## 第 1b 步：查找目录中未列出的技能

读取目录后，对 `.claude/skills/*/SKILL.md` 使用 Glob，获取已安装技能的完整列表。对每个文件，从其 frontmatter 中提取 `name:` 字段。

将其与目录中的 `command:` 值进行比较。名称未作为目录命令出现的技能属于**未编入目录的技能**，仍然可以使用，但不属于阶段门禁流程。

收集这些技能，并在第 7 步的输出中作为页脚区块显示：

```
### 其他已安装技能（不在工作流中）
- `/skill-name` —— [description from SKILL.md frontmatter]
- `/skill-name` —— [description]
```

仅当至少存在一个未编入目录的技能时显示此区块。根据用户当前阶段限制为最相关的 10 个技能（例如生产阶段的 QA 技能、生产/打磨阶段的团队技能等）。

---

## 第 2 步：确定当前阶段

按以下顺序检查：

1. **读取 `production/stage.txt`** —— 如果文件存在且有内容，则以其作为权威阶段名称。将其映射到目录阶段键：
   - "Concept" → `concept`
   - "Systems Design" → `systems-design`
   - "Technical Setup" → `technical-setup`
   - "Pre-Production" → `pre-production`
   - "Production" → `production`
   - "Polish" → `polish`
   - "Release" → `release`

2. **如果缺少 stage.txt**，根据产物推断阶段（匹配最先进阶段的规则优先）：
   - `src/` 中有 10 个以上源文件 → `production`
   - `production/stories/*.md` 存在 → `pre-production`
   - `docs/architecture/adr-*.md` 存在 → `technical-setup`
   - `design/gdd/systems-index.md` 存在 → `systems-design`
   - `design/gdd/game-concept.md` 存在 → `concept`
   - 什么都没有 → `concept`（全新项目）

---

## 第 3 步：读取会话上下文

如果 `production/session-state/active.md` 存在，则读取它并提取：
- 最近处理的工作
- 任何进行中的任务或开放问题
- STATUS 区块中的当前史诗/功能/任务（如果存在）

这些信息能说明用户刚完成了什么或卡在哪里，用它来个性化输出。

---

## 第 4 步：检查当前阶段的步骤完成情况

针对当前阶段中的每个步骤（来自目录）：

### 基于产物的检查

如果步骤有 `artifact.glob`：
- 使用 Glob 检查是否存在匹配该模式的文件
- 如果指定了 `min_count`，确认至少有这么多文件匹配
- 如果指定了 `artifact.pattern`，使用 Grep 确认匹配文件中存在该模式
- **Complete** = 满足产物条件
- **Incomplete** = 产物缺失或未找到模式

如果步骤有 `artifact.note`（没有 glob）：
- 标记为 **MANUAL** —— 无法自动检测，将询问用户

如果步骤没有 `artifact` 字段：
- 标记为 **UNKNOWN** —— 无法追踪完成状态（例如可重复的实现工作）

### 特殊情况：production 阶段 —— 读取 `sprint-status.yaml`

当当前阶段为 `production` 时，在进行任何基于 glob 的故事检查前，先检查 `production/sprint-status.yaml`。如果存在，直接读取：

- `status: in-progress` 的故事 → 显示为“当前进行中”
- `status: ready-for-dev` 的故事 → 显示为“下一项"
- `status: done` 的故事 → 计为已完成
- `status: blocked` 的故事 → 使用 `blocker` 字段显示为阻塞项

这样无需扫描 markdown 就能获得每个故事的准确状态。跳过 `implement` 和 `story-done` 步骤的 glob 产物检查，YAML 才是权威来源。

### 特殊情况：`repeatable: true`（非 production）

对于 production 之外的可重复步骤（例如“系统 GDD”），产物检查只能告诉你是否做过*任何*工作，而不能说明是否已经完成。应使用不同的标签，显示已检测到的内容，并注明它可能仍在进行中。

---

## 第 5 步：定位并识别下一步

根据完成数据，确定：

1. **最后一个确认完成的步骤** —— 已完成的最远必需步骤
2. **当前阻塞项** —— 第一个未完成的*必需*步骤（这是用户下一步必须做的事）
3. **可选机会** —— 可以在阻塞项之前或同时完成的未完成*可选*步骤
4. **即将到来的必需步骤** —— 当前阻塞项之后的必需步骤（显示为“接下来”，方便用户提前规划）

如果用户提供了参数（例如“刚完成 design-review”），即使产物检查结果不明确，也应据此将位置推进到该步骤之后。

---

## 第 6 步：检查进行中的工作

如果 `active.md` 显示有进行中的任务或史诗：
- 在顶部醒目显示：“看起来你之前正在处理 [X]”
- 建议继续处理，或确认它是否已经完成

---

## 第 7 步：呈现输出

保持**简短直接**。这是快速定位，不是报告。

```
## 你当前所处阶段：[Phase Label]

**进行中：** [from active.md, if any]

### ✓ 已完成
- [completed step name]
- [completed step name]

### → 下一步（REQUIRED）
**[Step name]** — [description]
命令：`[/command]`

### ~ 其他可用步骤（OPTIONAL）
- **[Step name]** — [description] → `/command`
- **[Step name]** — [description] → `/command`

### 后续步骤
- [Next required step name] (`/command`)
- [Next required step name] (`/command`)

---
即将进入 **[next phase]** 门禁 → 准备好后运行 `/gate-check`。
```

**格式规则：**
- `✓` 表示确认完成
- `→` 表示当前必需的下一步（只显示一个，即第一个阻塞项）
- `~` 表示当前可执行的可选步骤
- 命令使用反引号作为行内代码显示
- 如果步骤没有命令（例如“实现故事”），说明该做什么，而不是显示斜杠命令
- 对于 MANUAL 步骤，询问用户：“我无法判断 [step] 是否完成，它已经完成了吗？”

结论：**COMPLETE** —— 已确定后续步骤。

---

## 第 8 步：门禁警告（如果接近门禁）

检查当前阶段的步骤后，判断用户是否可能接近门禁：
- 如果当前阶段的所有必需步骤都已完成（或几乎完成），添加：“你已接近 **[Current] → [Next]** 门禁。准备好后运行 `/gate-check`。”
- 如果还剩多个必需步骤，跳过门禁警告，因为现在还不相关。

---

## 第 9 步：升级路径

在建议之后，如果用户看起来卡住或困惑，则添加：

```
---
需要更多细节？
- `/project-stage-detect` —— 完整的差距分析，并列出所有缺失产物
- `/gate-check` —— 正式检查进入下一阶段的就绪情况
- `/start` —— 从头重新定位
```

仅当用户的输入表现出困惑（例如“我不知道”“卡住了”“迷路了”“不确定”）时显示。对于简单的“下一步是什么？”查询不要显示。

---

## 协作协议

- **绝不自动运行下一项技能。** 只提出建议，让用户自行调用。
- **询问 MANUAL 步骤**，不要擅自假设已完成或未完成。
- **匹配用户语气** —— 如果用户听起来很焦虑（“我完全迷路了”），应给予安抚并提供一个行动，而不是列出六项任务。
- **只给一个主要建议** —— 用户离开时应明确知道下一步该做的一件事。可选步骤和“接下来”仅作为辅助上下文。
