---
name: architecture-decision
description: "创建架构决策记录（Architecture Decision Record, ADR），记录重大技术决策及其背景、备选方案和影响后果。每个重大技术选择都应有对应的 ADR。"
argument-hint: "[标题] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

当此技能被调用时：

## 0. 解析参数 — 检测补录模式

确定评审模式（仅确定一次，并存储供本次运行的所有门禁子代理使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用其中的值
3. 否则 → 默认为 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

**如果参数以 `retrofit` 开头，后跟文件路径**
（例如 `/architecture-decision retrofit docs/architecture/adr-0001-event-system.md`）：

进入**补录模式**：

1. 完整读取现有 ADR 文件。
2. 通过扫描标题识别已有的模板章节：
   - `## 状态` — 缺失时为**阻断项**：`/story-readiness` 无法检查 ADR 是否已接受
   - `## ADR 依赖关系` — 缺失时为高风险：依赖顺序会失效
   - `## 引擎兼容性` — 缺失时为高风险：训练截止日期后的风险未知
   - `## 已处理的 GDD 需求` — 缺失时为中风险：失去可追溯性
3. 向用户展示：
   ```
   ## 补录：[ADR 标题]
   文件：[路径]

   已存在的章节（不会改动）：
   ✓ 状态：[当前值，或“缺失 — 将添加”]
   ✓ [章节]

   待添加的缺失章节：
   ✗ 状态 — 阻断项（没有此项，故事无法验证 ADR 是否已接受）
   ✗ ADR 依赖关系 — 高风险
   ✗ 引擎兼容性 — 高风险
   ```
4. 询问：“是否添加这 [N] 个缺失章节？我不会修改任何现有内容。”
5. 如果同意：
   - 对于**状态**：询问用户 — “此决策当前的状态是什么？”
     选项：`Proposed`、`Accepted`、`Deprecated`、`Superseded by ADR-XXXX`
   - 对于 **ADR 依赖关系**：询问 — “此决策是否依赖其他 ADR？
     它是否启用或阻塞其他 ADR 或 Epic？”每个字段都接受 `None`。
   - 对于**引擎兼容性**：读取引擎参考文档（与下方步骤 1 相同），
     并请用户确认领域。然后使用已验证的数据生成表格。
   - 对于**已处理的 GDD 需求**：询问 — “哪些 GDD 系统促成了此决策？
     此 ADR 处理了各 GDD 中的哪些具体需求？”
   - 使用 Edit 工具将每个缺失章节追加到 ADR 文件。
   - **绝不修改任何现有章节。**只追加或填充缺失章节。
6. 添加所有缺失章节后，如果 ADR 缺少 `## 日期` 字段，则添加该字段。
7. 建议：“现在此 ADR 已有状态和依赖关系字段，请运行 `/architecture-review` 重新验证覆盖情况。”

如果不是补录模式，则继续执行下方步骤 1（正常编写 ADR）。

**无参数防护**：如果未提供参数（标题为空），请在运行阶段 0 前询问：

> “您要记录哪项技术决策？请提供一个简短标题
> （例如 `event-system-architecture`、`physics-engine-choice`）。”

将用户的回答作为标题，然后继续执行步骤 1。

---

## 1. 加载引擎上下文（始终最先执行）

在执行其他任何操作前，先确定引擎环境：

1. 读取 `docs/engine-reference/[engine]/VERSION.md` 以获取：
   - 引擎名称和版本
   - LLM 知识截止日期
   - 截止日期后版本的风险等级（LOW / MEDIUM / HIGH）

2. 根据标题或用户描述，识别此架构决策的**领域**。
   常见领域：Physics、Rendering、UI、Audio、Navigation、Animation、Networking、Core、Input、Scripting。

3. 如果存在对应的模块参考文档，则读取：
   `docs/engine-reference/[engine]/modules/[domain].md`

4. 读取 `docs/engine-reference/[engine]/breaking-changes.md` — 标记相关领域中
   晚于 LLM 训练截止日期的所有变更。

5. 读取 `docs/engine-reference/[engine]/deprecated-apis.md` — 标记相关领域中
   不应使用的所有 API。

6. 如果该领域的风险为 MEDIUM 或 HIGH，继续前必须**显示知识缺口警告**：

   ```
   ⚠️  引擎知识缺口警告
   引擎：[名称 + 版本]
   领域：[领域]
   风险等级：HIGH — 此版本晚于 LLM 知识截止日期。

   已根据引擎参考文档验证的关键变更：
   - [与此领域相关的变更 1]
   - [变更 2]

   此 ADR 将与引擎参考库进行交叉核对。
   仅使用已验证的信息继续 — 不得仅依赖训练数据。
   ```

   如果尚未配置引擎，则提示：“尚未配置引擎。
   请先运行 `/setup-engine`，或告诉我您正在使用哪个引擎。”

---

## 2. 确定下一个 ADR 编号

扫描 `docs/architecture/` 中的现有 ADR，以找到下一个编号。

---

## 3. 收集上下文

读取相关代码、现有 ADR 以及 `design/gdd/` 中的相关 GDD。

### 3a：架构注册表检查（阻断门禁）

读取 `docs/registry/architecture.yaml`。提取与此 ADR 的领域和决策相关的条目
（按系统名称、领域关键词或正在触及的状态进行 grep）。

在协作设计开始**之前**，将所有相关立场作为锁定约束呈现给用户：

```
## 现有架构立场（不得冲突）

状态所有权：
  player_health → 由 health-system 所有（ADR-0001）
  接口：HealthComponent.current_health（只读 float）
  → 如果此 ADR 读取或写入玩家生命值，必须使用此接口。

接口契约：
  damage_delivery → signal 模式（ADR-0003）
  Signal：damage_dealt(amount, target, is_crit)
  → 如果此 ADR 发送或接收伤害事件，必须使用此 signal。

禁用模式：
  ✗ autoload_singleton_coupling（ADR-0001）
  ✗ direct_cross_system_state_write（ADR-0000）
  → 提议的方案不得使用这些模式。
```

如果用户提议的决策会与任何已注册立场冲突，立即指出冲突：

> “⚠️ 冲突：此 ADR 提议 [X]，但 ADR-[NNNN] 已确定 [Y] 是
> 此用途的已接受模式。若不解决冲突就继续，将产生相互矛盾的 ADR 和不一致的故事。
> 选项：(1) 与现有立场保持一致，(2) 使用明确替代方案取代 ADR-[NNNN]，
> (3) 说明为何此情况属于例外。”

在冲突得到解决或被明确接受为有意例外前，不得继续执行步骤 4（协作设计）。

---

## 4. 协作引导决策

提出任何问题前，根据已收集的上下文（已读取的 GDD、已加载的引擎参考文档、
已扫描的现有 ADR）推导此技能的最佳推测。然后使用 `AskUserQuestion` 呈现
**确认/调整**提示，而不是开放式问题。

**先推导假设：**
- **问题**：根据标题 + GDD 上下文推断需要作出什么决策
- **备选方案**：根据引擎参考文档 + GDD 需求提出 2-3 个具体选项
- **依赖关系**：扫描现有 ADR 以查找上游依赖；如果不明确，则假设为 `None`
- **GDD 关联**：提取标题直接关联的 GDD 系统
- **状态**：新 ADR 始终为 `Proposed` — 绝不询问用户状态是什么

**假设选项卡的范围**：假设仅涵盖：问题界定、备选方案、上游依赖关系、GDD 关联和状态。Schema 设计问题（例如“生成时机应如何运作？”、“数据应内联还是外置？”）不属于假设，而是应在假设确认后单独步骤中处理的设计决策。不要在假设的 `AskUserQuestion` 控件中包含 Schema 设计问题。

**假设确认后**，如果 ADR 涉及 Schema 或数据设计选择，请使用单独的多选项卡 `AskUserQuestion`，在起草前分别询问每个设计问题。

**使用 `AskUserQuestion` 呈现假设：**

```
这是我在起草前所作的假设：

问题：[根据上下文推导的一句话问题陈述]
我将考虑的备选方案：
  A) [根据引擎参考文档推导的选项]
  B) [根据 GDD 需求推导的选项]
  C) [来自常见模式的选项]
促成此决策的 GDD 系统：[根据上下文推导的列表]
依赖关系：[上游 ADR（如有），否则为 `None`]
状态：Proposed

[A] 继续 — 使用这些假设起草
[B] 更改备选方案列表
[C] 调整 GDD 关联
[D] 添加性能预算约束
[E] 还有其他内容需要先更改
```

在用户确认假设或提供修正前，不得生成 ADR。

**引擎专家和 TD 评审返回后**（步骤 5.5/5.6），如果仍有未解决的决策，
请使用单独的 `AskUserQuestion` 呈现每项决策，将提议选项作为选择，并提供自由文本退路：

```
决策：[具体的未解决事项]
[A] [来自专家评审的选项]
[B] [备选选项]
[C] 其他方案 — 我来描述
```

**ADR 依赖关系** — 从现有 ADR 推导，然后确认：
- 此决策是否依赖任何尚未 `Accepted` 的其他 ADR？
- 它是否会解锁或解除对其他 ADR 或 Epic 的阻塞？
- 它是否会阻止某个特定 Epic 开始？

将回答记录在 **ADR 依赖关系**章节中。如果没有适用的约束，每个字段均写入 `None`。

---

## 5. 生成 ADR

遵循以下格式：

```markdown
# ADR-[NNNN]：[标题]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date
[决策日期]

## Engine Compatibility

| 字段 | 值 |
|------|----|
| **引擎** | [例如 Godot 4.6] |
| **领域** | [Physics / Rendering / UI / Audio / Navigation / Animation / Networking / Core / Input] |
| **知识风险** | [LOW / MEDIUM / HIGH — 来自 VERSION.md] |
| **已查阅的参考文档** | [读取过的引擎参考文档列表，例如 `docs/engine-reference/godot/modules/physics.md`] |
| **使用的截止日期后 API** | [此决策依赖的、来自 LLM 知识截止日期后版本的所有 API，或 `None`] |
| **需要验证** | [发布前要测试的具体行为，或 `None`] |

## ADR Dependencies

| 字段 | 值 |
|------|----|
| **依赖于** | [ADR-NNNN（必须在实现此决策前为 `Accepted`），或 `None`] |
| **启用** | [ADR-NNNN（此 ADR 解锁该决策），或 `None`] |
| **阻塞** | [Epic/故事名称 — 在此 ADR 为 `Accepted` 前无法开始，或 `None`] |
| **顺序说明** | [上方未涵盖的任何顺序约束] |

## Context

### 问题陈述
[我们要解决什么问题？为何现在需要作出此决策？]

### 约束
- [技术约束]
- [时间线约束]
- [资源约束]
- [兼容性要求]

### 需求
- [必须支持 X]
- [必须在 Y 预算内运行]
- [必须与 Z 集成]

## Decision

[具体作出的技术决策，其描述应足够详细，使他人能够实现。]

### 架构图
[此决策所创建系统架构的 ASCII 图或描述]

### 关键接口
[此决策所创建的 API 契约或接口定义]

## Alternatives Considered

### 备选方案 1：[名称]
- **描述**：[此方案如何运作]
- **优点**：[优势]
- **缺点**：[劣势]
- **拒绝原因**：[未选择此方案的原因]

### 备选方案 2：[名称]
- **描述**：[此方案如何运作]
- **优点**：[优势]
- **缺点**：[劣势]
- **拒绝原因**：[未选择此方案的原因]

## Consequences

### 正面
- [此决策带来的良好结果]

### 负面
- [接受的权衡和成本]

### 风险
- [可能出错的事项]
- [每项风险的缓解措施]

## GDD Requirements Addressed

| GDD 系统 | 需求 | 此 ADR 如何处理该需求 |
|----------|------|-----------------------|
| [system-name].md | [该 GDD 中的具体规则、公式或性能约束] | [此决策如何满足该需求] |

## Performance Implications
- **CPU**：[预期影响]
- **内存**：[预期影响]
- **加载时间**：[预期影响]
- **网络**：[预期影响（如适用）]

## Migration Plan
[如果此决策会更改现有代码，如何从当前状态迁移到目标状态？]

## Validation Criteria
[如何判断此决策是正确的？使用哪些指标或测试？]

## Related Decisions
- [相关 ADR 的链接]
- [相关设计文档的链接]
```

5.5. **引擎专家验证** — 保存前，通过 Task 启动**主要引擎专家**来验证 ADR 草稿：
   - 读取 `.claude/docs/technical-preferences.md` 的 `引擎专家` 章节，以获取主要专家
   - 如果未配置引擎（值以 `[待配置` 开头），则跳过此步骤
   - 使用以下内容启动 `subagent_type: [primary specialist]`：ADR 的引擎兼容性章节、决策章节、关键接口以及引擎参考文档路径。要求其：
     1. 确认提议的方案符合已固定引擎版本的惯用做法
     2. 标记训练截止日期后已弃用或发生变化的任何 API 或模式
     3. 识别当前 ADR 草稿中未涵盖的引擎特定风险或易错点
   - 如果专家发现**阻断问题**（错误 API、已弃用方案、引擎版本不兼容）：相应修订决策和引擎兼容性章节，然后在继续前与用户确认更改
   - 如果专家仅发现**次要说明**：将其纳入 ADR 的风险子章节

**评审模式检查** — 启动 TD-ADR 前应用：
- `solo` → 跳过。注明：“已跳过 TD-ADR — Solo 模式。”继续执行步骤 5.7（GDD 同步检查）。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“已跳过 TD-ADR — Lean 模式。”继续执行步骤 5.7（GDD 同步检查）。
- `full` → 正常启动。

5.6. **技术总监战略评审** — 引擎专家验证后，通过 Task 使用门禁 **TD-ADR**（`.claude/docs/director-gates.md`）启动 `technical-director`：
   - 传入：ADR 文件路径（或草稿内容）、引擎版本、领域，以及同一领域中的所有现有 ADR
   - TD 验证架构一致性（此决策是否与整个系统一致？）— 这与引擎专家的 API 层检查不同
   - 如果结果为 CONCERNS 或 REJECT：继续前相应修订决策或备选方案章节

5.7. **GDD 同步检查** — 呈现写入审批前，扫描“已处理的 GDD 需求”章节中
引用的所有 GDD，检查其与 ADR 的关键接口和决策章节是否存在命名不一致
（重命名的 signal、API 方法或数据类型）。如果发现任何不一致，立即在写入审批前
以**醒目的警告块**呈现，而不是作为脚注：

```
⚠️ 需要同步 GDD
[gdd-filename].md 使用了此 ADR 已重命名的名称：
  [old_name] → [new_name_from_adr]
  [old_name_2] → [new_name_2_from_adr]
必须在写入此 ADR 前或同时更新 GDD，以防开发者阅读 GDD 后实现错误接口。
```

如果没有不一致，则静默跳过此块。

5. **写入审批** — 使用 `AskUserQuestion`：

如果发现 GDD 同步问题：
- “ADR 草稿已完成。您希望如何继续？”
  - [A] 在同一轮操作中写入 ADR + 更新 GDD
  - [B] 仅写入 ADR — 我会手动更新 GDD
  - [C] 暂不写入 — 我需要进一步审阅

如果没有 GDD 同步问题：
- “ADR 草稿已完成。可以写入吗？”
  - [A] 将 ADR 写入 `docs/architecture/adr-[NNNN]-[slug].md`
  - [B] 暂不写入 — 我需要进一步审阅

如果用户同意任一写入选项，则写入文件，并在需要时创建目录。
对于包含 GDD 更新的选项 [A]：还要更新 GDD 文件以使用新名称。

6. **更新架构注册表**

扫描已写入的 ADR，查找应注册的新架构立场：
- 它声明所有权的状态
- 它定义的接口契约（signal 签名、方法 API）
- 它声明的性能预算
- 它明确作出的 API 选择
- 它禁用的模式（后果 → 负面，或明确的“不得使用 X”）

呈现候选项：
```
此 ADR 中的注册表候选项：
  新状态所有权：      player_stamina → stamina-system
  新接口契约：        stamina_depleted signal
  新性能预算：        stamina-system: 0.5ms/frame
  新禁用模式：        每帧轮询 stamina（改用 signal）
  已存在（仅更新 referenced_by）：player_health → 已注册 ✅
```

**注册表追加逻辑**：写入 `docs/registry/architecture.yaml` 时，不得假设章节为空。该文件可能已有本次会话先前写入的 ADR 条目。每次调用 Edit 前：
1. 读取 `docs/registry/architecture.yaml` 的当前状态
2. 找到正确章节（state_ownership、interfaces、forbidden_patterns、api_decisions）
3. 将新条目追加到该章节最后一个现有条目之后 — 不要尝试替换可能已不存在的 `[]` 占位符
4. 如果该章节已有条目，使用最后一个条目的结尾内容作为 `old_string` 锚点，并在其后追加新条目

**阻断项 — 未经用户明确批准，不得写入 `docs/registry/architecture.yaml`。**

使用 `AskUserQuestion` 询问：
- “可以使用这 [N] 个新立场更新 `docs/registry/architecture.yaml` 吗？”
  - 选项：“是 — 更新注册表”、“暂不更新 — 我想审阅候选项”、“跳过注册表更新”

仅当用户选择“是”时继续。如果同意：追加新条目。绝不修改现有条目 — 如果某项立场正在更改，
则将旧条目设置为 `status: superseded_by: ADR-[NNNN]`，并添加新条目。

---

## 6. 结束时的后续步骤

写入 ADR（并可选更新注册表）后，使用 `AskUserQuestion` 结束。

生成控件前：
1. 读取 `docs/registry/architecture.yaml` — 检查是否仍有尚未编写的优先 ADR（查找 technical-preferences.md 或 systems-index.md 中标记为前置条件的 ADR）
2. 检查是否已编写所有前置 ADR。如果是，则包含“开始编写 GDD”选项。
3. 将所有剩余优先 ADR 分别列为独立选项 — 不得只列下一个或两个。

控件格式：
```
ADR-[NNNN] 已写入，注册表已更新。您接下来想做什么？
[1] 编写 [next-priority-adr-name] — [来自前置条件列表的简短描述]
[2] 编写 [another-priority-adr] — [简短描述]（包括所有剩余项）
[N] 开始编写 GDD — 运行 `/design-system [first-undesigned-system]`（仅当已编写所有前置 ADR 时显示）
[N+1] 本次会话到此结束
```

如果没有剩余优先 ADR，也没有尚未设计的 GDD 系统，则仅提供“到此结束”，并建议在新会话中运行 `/architecture-review`。

**结束输出中始终包含以下固定通知（不得省略）：**

> 要根据 GDD 验证 ADR 覆盖情况，请打开一个**全新的 Claude Code 会话**
> 并运行 `/architecture-review`。
>
> **绝不要在运行 `/architecture-decision` 的同一会话中运行 `/architecture-review`。**
> 评审代理必须独立于编写上下文，才能给出无偏见的评估。
> 在此处运行会使评审失效。

将所有因等待此 ADR 而处于 `Status: Blocked` 的故事更新为 `Status: Ready`。
