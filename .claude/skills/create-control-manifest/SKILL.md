---
name: create-control-manifest
description: "架构完成后，为程序员生成一份扁平、可执行的规则表，按系统和层级说明必须做什么、绝不能做什么。规则提取自所有 Accepted ADR、技术偏好和引擎参考文档。相比解释原因的 ADR，它更便于直接执行。"
argument-hint: "[update — 根据当前 ADR 重新生成]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
agent: technical-director
---

# 创建控制清单

控制清单是一份面向程序员的扁平、可执行规则表。它回答“我该做什么？”和
“我绝不能做什么？”，按架构层级组织，并从所有 Accepted ADR、技术偏好和
引擎参考文档中提取。ADR 解释*为什么*，清单则说明*做什么*。

**输出：** `docs/architecture/control-manifest.md`

**运行时机：** `/architecture-review` 通过且 ADR 处于 Accepted 状态后。每当有新 ADR
被接受或现有 ADR 被修订时，重新运行。

---

## 1. 加载所有输入

### ADR
- 使用 Glob 匹配 `docs/architecture/adr-*.md` 并读取每个文件
- 仅筛选 Accepted ADR（Status: Accepted），跳过 Proposed、Deprecated、
  Superseded
- 记录每条规则来源的 ADR 编号和标题

### 技术偏好
- 读取 `.claude/docs/technical-preferences.md`
- 提取：命名约定、性能预算、已批准的库/插件、
  禁止模式

### 引擎参考
- 从 `docs/engine-reference/[engine]/VERSION.md` 读取引擎和版本
- 读取 `docs/engine-reference/[engine]/deprecated-apis.md`，将其中内容转为
  禁止 API 条目
- 如果存在，读取 `docs/engine-reference/[engine]/current-best-practices.md`

报告：“已加载 [N] 个 Accepted ADR，引擎：[name + version]。”

---

## 2. 从每个 ADR 中提取规则

对每个 Accepted ADR，提取：

### 必需模式（来自 "Implementation Guidelines" 章节）
- 每条包含 "must"、"should"、"required to"、"always" 的陈述
- 每个明确要求的具体模式或方法

### 禁止方法（来自 "Alternatives Considered" 章节）
- 每个被明确否决的备选方案，其被否决的*原因*将成为
  规则（“绝不使用 X，因为 Y”）
- 所有被明确指出的反模式

### 性能护栏（来自 "Performance Implications" 章节）
- 预算约束：“此系统每帧最多 N ms”
- 内存限制：“此系统不得超过 N MB”

### 引擎 API 约束（来自 "Engine Compatibility" 章节）
- 需要验证的知识截止日期之后的 API
- 与 LLM 默认假设不同、且已经验证的行为
- 在锁定引擎版本中行为不同的 API 字段或方法

### 层级分类
按规则所约束系统的架构层级对每条规则分类：
- **Foundation**：场景管理、事件架构、保存/加载、引擎初始化
- **Core**：核心玩法循环、主要玩家系统、物理/碰撞
- **Feature**：次要系统、次要机制、AI
- **Presentation**：渲染、音频、UI、VFX、着色器

如果某个 ADR 跨越多个层级，则将规则复制到每个相关层级中。

---

## 3. 添加全局规则

合并适用于所有层级的规则：

### 来自 technical-preferences.md：
- 命名约定（类、变量、信号/事件、文件、常量）
- 性能预算（目标帧率、帧预算、绘制调用限制、内存上限）

### 来自 deprecated-apis.md：
- 所有弃用 API → 禁止 API 条目

### 来自 current-best-practices.md（如果可用）：
- 引擎推荐模式 → 必需条目

### 来自 technical-preferences.md 的禁止模式：
- 直接复制所有 "Forbidden Patterns" 条目

---

## 4. 写入前展示规则摘要

写入清单前，向用户展示摘要：

```
## Control Manifest Preview
引擎：[name + version]
涵盖的 ADR：[list ADR numbers]
提取的规则总数：
  - Foundation 层：[N] 条必需规则，[M] 条禁止规则，[P] 条护栏
  - Core 层：[N] 条必需规则，[M] 条禁止规则，[P] 条护栏
  - Feature 层：...
  - Presentation 层：...
  - 全局：[N] 条命名约定，[M] 个禁止 API，[P] 个已批准库
```

使用 `AskUserQuestion`：
- 提示：“这份规则摘要是否完整？”
- 选项：
  - `[A] 是 — 看起来不错，执行总监评审并写入清单`
  - `[B] 添加规则 — 写入前我还有其他规则需要加入`
  - `[C] 删除规则 — 应移除部分已提取规则`
  - `[D] 到此为止 — 我需要先评审 ADR`

---

## 4b. 总监门禁 — 技术评审

**评审模式检查** — 在启动 TD-MANIFEST 前应用：
- `solo` → 跳过。注明：“TD-MANIFEST 已跳过 — Solo 模式。”继续阶段 5。
- `lean` → 跳过。注明：“TD-MANIFEST 已跳过 — Lean 模式。”继续阶段 5。
- `full` → 正常启动。

通过 Task 启动 `technical-director`，使用门禁 **TD-MANIFEST**（`.claude/docs/director-gates.md`）。

传入：阶段 4 的 Control Manifest Preview（各层规则数量、提取出的完整规则列表）、涵盖的 ADR 列表、引擎版本，以及来自 technical-preferences.md 或引擎参考文档的所有规则。

technical-director 评审以下内容：
- 是否捕获并准确表述了所有强制 ADR 模式
- 禁止方法是否完整且来源归属正确
- 是否没有添加缺少来源 ADR 或偏好文档的规则
- 性能护栏是否与 ADR 约束一致

应用裁决：
- **APPROVE** → 继续阶段 5
- **CONCERNS** → 通过 `AskUserQuestion` 呈现，选项：`修订标记的规则` / `接受并继续` / `进一步讨论`
- **REJECT** → 不写入清单；修正标记的规则并重新展示摘要

---

## 5. 写入控制清单

使用 `AskUserQuestion`：
- 提示：“可以写入控制清单吗？”
- 选项：
  - `[A] 是 — 写入 docs/architecture/control-manifest.md`
  - `[B] 先向我展示完整草稿，然后再次询问`
  - `[C] 暂时不要 — 我还想做更多修改`

格式：

```markdown
# 控制清单

> **引擎**：[名称 + 版本]
> **最后更新**：[日期]
> **清单版本**：[日期]
> **涵盖的 ADR**：[ADR-NNNN、ADR-MMMM、...]
> **状态**：[生效中 — ADR 变更时使用 `/create-control-manifest update` 重新生成]

`清单版本` 是生成此清单的日期。故事文件创建时会嵌入
此日期。`/story-readiness` 将故事中嵌入的版本与此字段比较，
以检测依据过时规则编写的故事。它始终与 `最后更新` 一致，
二者是同一日期，但服务于不同消费者。

此清单是面向程序员的快速参考，提取自所有已接受的 ADR、
技术偏好和引擎参考文档。每条规则背后的理由
请参阅其引用的 ADR。

---

## 基础层规则

*适用于：场景管理、事件架构、保存/加载、引擎初始化*

### 必需模式
- **[规则]** — 来源：[ADR-NNNN]
- **[规则]** — 来源：[ADR-NNNN]

### 禁止方法
- **绝不 [反模式]** — [简要原因] — 来源：[ADR-NNNN]

### 性能约束
- **[系统]**：每帧最多 [N] 毫秒 — 来源：[ADR-NNNN]

---

## 核心层规则

*适用于：核心玩法循环、主要玩家系统、物理、碰撞*

### 必需模式
...

### 禁止方法
...

### 性能约束
...

---

## 功能层规则

*适用于：次要机制、AI 系统、次要功能*

### 必需模式
...

### 禁止方法
...

---

## 表现层规则

*适用于：渲染、音频、UI、VFX、着色器、动画*

### 必需模式
...

### 禁止方法
...

---

## 全局规则（所有层）

### 命名约定
| 元素 | 约定 | 示例 |
|---------|-----------|---------|
| 类 | [来自技术偏好] | [示例] |
| 变量 | [来自技术偏好] | [示例] |
| 信号/事件 | [来自技术偏好] | [示例] |
| 文件 | [来自技术偏好] | [示例] |
| 常量 | [来自技术偏好] | [示例] |

### 性能预算
| 指标 | 数值 |
|--------|-------|
| 帧率 | [来自技术偏好] |
| 帧时间预算 | [来自技术偏好] |
| 绘制调用次数 | [来自技术偏好] |
| 内存上限 | [来自技术偏好] |

### 批准使用的库/插件
- [库] — 批准用于 [用途]

### 禁用的 API（[引擎版本]）
这些 API 对 [引擎 + 版本] 而言已弃用或未经验证：
- `[API 名称]` — 自 [版本] 起弃用 / 知识截止日期后未经验证
- 来源：`docs/engine-reference/[engine]/deprecated-apis.md`

### 跨领域约束
- [适用于所有位置、不受层级影响的约束]
```

---

## 6. 建议后续步骤

写入清单后：

- 如果史诗/故事尚不存在：“运行 `/create-epics layer: foundation`，然后运行 `/create-stories [epic-slug]`，程序员
  现在可以在编写故事实现说明时使用此清单。”
- 如果这是重新生成（清单已经存在）：“已更新。建议
  将规则变更通知团队，尤其是新增的禁止条目。”

---

## 协作协议

1. **静默加载** — 展示任何内容前读取所有输入
2. **先展示摘要** — 写入前让用户查看范围
3. **写入前询问** — 创建或覆盖清单前始终确认。写入时：结论：**COMPLETE** — 控制清单已写入。拒绝时：结论：**BLOCKED** — 用户拒绝写入。
4. **标注每条规则的来源** — 绝不添加无法追溯到 ADR、
   技术偏好或引擎参考文档的规则
5. **不作解释性改写** — 按 ADR 中的表述提取规则；不要以
   改变含义的方式转述
