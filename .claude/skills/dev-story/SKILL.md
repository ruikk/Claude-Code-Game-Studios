---
name: dev-story
description: "读取故事文件并实现它。加载完整上下文（故事、GDD 需求、ADR 指南、控制清单），为系统和引擎路由到正确的程序员代理，实现代码和测试，并确认每条验收标准。核心实现技能——在 /story-readiness 之后、/code-review 和 /story-done 之前运行。"
argument-hint: "[story-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion
model: sonnet
---

# 开发故事

此技能连接规划与代码。它完整读取故事文件，组装程序员所需的全部上下文，
将任务路由给正确的专家代理，并推动实现完成，包括编写测试。

**每个故事都遵循此循环：**
```
/qa-plan sprint           ← 在迭代开始前定义测试要求
/story-readiness [path]   ← 开始前进行验证
/dev-story [path]         ← 实现它（此技能）
/code-review [files]      ← 审查它
/story-done [path]        ← 验证并关闭它
```

**所有迭代故事完成后：**运行 `/team-qa sprint` 执行完整 QA 周期，并在推进项目阶段前获得签核结论。

**输出：**项目 `src/` 和 `tests/` 目录中的源代码与测试文件。

---

## 阶段 1：查找故事

**如果提供了路径**：直接读取该文件。

**如果没有参数**：检查 `production/session-state/active.md` 中的当前故事。如果找到，确认：“正在继续处理 [story title]——这样正确吗？”
如果未找到，询问：“我们要实现哪个故事？”使用 Glob 搜索
`production/epics/**/*.md`，并列出 `Status: Ready` 的故事。

---

## 阶段 2：加载完整上下文

**加载任何上下文之前，验证必需文件存在。**从故事的 `ADR Governing Implementation` 字段提取 ADR 路径，然后检查：

| 文件 | 路径 | 缺失时 |
|------|------|--------|
| TR 注册表 | `docs/architecture/tr-registry.yaml` | **停止**——“未在 `docs/architecture/tr-registry.yaml` 找到 TR 注册表。请运行 `/architecture-review`，根据 GDD 和 ADR 初始化注册表。” |
| 主管 ADR | 故事 ADR 字段中的路径 | **停止**——“未找到 ADR 文件 [path]。请运行 `/architecture-decision` 创建该文件，或修正故事 ADR 字段中的文件名。” |
| 控制清单 | `docs/architecture/control-manifest.md` | **警告并继续**——“未找到控制清单，无法检查层级规则。请运行 `/create-control-manifest`。” |

同时读取以下所有内容——它们彼此独立。所有上下文加载完成前，不得开始实现：

### 故事文件
提取并保留：
- **故事标题、ID、层级和类型**（Logic / Integration / Visual/Feel / UI / Config/Data）
- **TR-ID**——GDD 需求标识符
- **主管 ADR** 引用
- 故事头部嵌入的 **`Manifest Version`**
- **`Acceptance Criteria`**——逐字保留每个复选框项目
- **`Implementation Notes`**——故事中的 ADR 指导章节
- **`Out of Scope`** 边界
- **`Test Evidence`**——所需测试文件路径
- **`Dependencies`**——此故事完成前必须完成的内容

### TR 注册表
读取 `docs/architecture/tr-registry.yaml`。查找故事的 TR-ID。
读取当前的 `requirement` 文本——这是当前 GDD 要求的事实来源。不要依赖故事文件中的内联文本（它可能已过时）。

### 主管 ADR
读取 `docs/architecture/[adr-file].md`。提取：
- 完整的 `Decision` 章节
- `Implementation Guidelines` 章节（程序员必须遵循的内容）
- `Engine Compatibility` 章节（知识截止日期之后的 API、已知风险）
- `ADR Dependencies` 章节

### 控制清单
读取 `docs/architecture/control-manifest.md`。提取适用于该故事层级的规则：
- 必需模式
- 禁止模式
- 性能护栏

检查：故事中嵌入的 `Manifest Version` 是否与当前清单头部日期匹配。
如果不同，使用 `AskUserQuestion` 后再继续：
- 提示：“故事基于清单 v[story-date] 编写，当前清单为 v[current-date]，可能有新规则适用。你希望如何继续？”
- 选项：
  - `[A] 更新故事的清单版本，并按当前规则实现（推荐）`
  - `[B] 按旧规则实现，我接受不合规风险`
  - `[C] 在此停止，我想先审查清单差异`

如果选择 [A]：在生成程序员代理前，将故事文件的 `Manifest Version:` 字段编辑为当前清单日期。然后仔细阅读清单中的新规则。
如果选择 [B]：将故事文件的 `Manifest Version:` 字段编辑为当前清单日期，并在故事头部添加 `Manifest-Note: [date] 按旧版清单规则继续，已接受不合规风险。` 行。仍然阅读清单中的新规则。在阶段 6 总结的“偏差”下记录此决定。`/story-done` 会在其偏差章节中包含 `Manifest-Note`，而不会再次检查过期状态。
如果选择 [C]：停止。不要生成任何代理。让用户审查后重新运行 `/dev-story`。

### 依赖验证
从故事文件提取 **`Dependencies`** 列表后，逐项验证：

1. 使用 Glob 搜索 `production/epics/**/*.md`，查找每个依赖故事文件。
2. 读取其 `Status:` 字段。
3. 如果任何依赖的 `Status` 不是 `Complete` 或 `Done`：
   - 使用 `AskUserQuestion`：
     - 提示：“故事 '[current story]' 依赖 '[dependency title]'，其当前状态为 [status]，并非 `Complete`。你希望如何继续？”
     - 选项：
       - `[A] 仍然继续，我接受依赖风险`
       - `[B] 停止，我会先完成依赖项`
       - `[C] 依赖项已完成但状态尚未更新，将其标记为 Complete 后继续`
    - 如果选择 [B]：在会话状态中将故事状态设置为 **BLOCKED** 并停止。不要生成任何程序员代理。
     - 如果选择 [C]：继续前询问“可以将 [dependency path] 的 `Status` 更新为 `Complete` 吗？”
     - 如果选择 [A]：在阶段 6 总结的“偏差”下记录：“在依赖项未完成的情况下实现：[dependency title]，状态为 [status]。”

如果找不到依赖文件：警告“未找到依赖故事：[path]。请验证路径或创建故事文件。”

---

### 引擎参考
读取 `.claude/docs/technical-preferences.md`：
- `Engine:` 值——决定使用哪些程序员代理
- 命名约定（类名、文件名、信号/事件名称）
- 性能预算（帧预算、内存上限）
- 禁止模式

### 将故事标记为进行中

在生成任何代理前，静默更新两项内容：

1. **`production/sprint-status.yaml`**（如果存在）：找到与此故事文件路径匹配的条目，将其设为 `status: in_progress`。将顶层 `updated` 字段更新为今天的日期。如果文件不存在，静默跳过。

2. **故事文件本身**：将故事头部的 `Last Updated:` 字段编辑为今天的日期（格式为 `YYYY-MM-DD`）。如果故事头部没有该字段，则将其添加到 `Status:` 行之后。这使 sprint-status 能检测该故事是否过期。

---

## 阶段 3：路由到正确的程序员

根据故事的 **Layer**、**Type** 和**系统名称**，确定要通过 Task 生成的专家。

**Config/Data 故事——完全跳过代理生成：**
如果故事的 `Type` 是 `Config/Data`，不需要程序员代理或引擎专家。直接跳到阶段 4（Config/Data 说明）。不评估路由表，也不需要引擎专家。

### 主代理路由表

| 故事上下文 | 主代理 |
|---|---|
| Foundation 层——任意类型 | `engine-programmer` |
| 任意层——`Type: UI` | `ui-programmer` |
| 任意层——`Type: Visual/Feel` | `gameplay-programmer`（负责实现） |
| Core 或 Feature——游戏玩法机制 | `gameplay-programmer` |
| Core 或 Feature——AI 行为、寻路 | `ai-programmer` |
| Core 或 Feature——网络、复制 | `network-programmer` |
| Config/Data——无代码 | 不需要代理（见阶段 4 的 Config/Data 说明） |

### 引擎专家——代码故事始终作为次级代理生成

读取 `.claude/docs/technical-preferences.md` 的 `Engine Specialists` 章节，获取已配置的主专家。故事涉及引擎特定 API、模式，或 ADR 具有 HIGH 引擎风险时，与主代理同时生成该专家。

| 引擎 | 可用专家代理 |
|--------|----------------------------|
| Godot 4 | `godot-specialist`, `godot-gdscript-specialist`, `godot-shader-specialist` |
| Unity | `unity-specialist`, `unity-ui-specialist`, `unity-shader-specialist` |
| Unreal Engine | `unreal-specialist`, `ue-gas-specialist`, `ue-blueprint-specialist`, `ue-umg-specialist`, `ue-replication-specialist` |

**当引擎风险为 HIGH 时**（来自 ADR 或 VERSION.md）：即使故事不面向引擎，也始终生成引擎专家。HIGH 风险表示 ADR 记录了关于截止日期之后的引擎 API 的假设，需要专家验证。

---

## 阶段 4：实现

通过 Task 使用完整上下文包生成选定的程序员代理：

向代理提供文件路径和定向读取说明——不要将文档内容序列化到 Task 提示中。代理直接读取所需内容：

1. **故事文件**：`[story-path]`——完整读取
2. **GDD 需求**：在 `docs/architecture/tr-registry.yaml` 中查找 TR-ID `[TR-XXX-NNN]`——使用 `requirement` 字段作为事实来源
3. **ADR**：`docs/architecture/[adr-file].md`——仅读取 **`Decision`** 和 **`Implementation Guidelines`** 章节
4. **控制清单**：`docs/architecture/control-manifest.md`——仅读取 **[layer]** 层的规则
5. **引擎偏好**：`.claude/docs/technical-preferences.md`——读取命名约定和性能预算
6. **测试文件路径**：`[path from story's Test Evidence section]`——此文件必须作为实现的一部分创建
7. **测试要求**（仅 Logic 和 Integration 故事）：测试文件必须创建在 `[path from the story's Test Evidence section]`。测试应与实现同时编写，不得推迟。没有此文件，故事无法通过 `/story-done` 关闭。每条验收标准至少需要一个测试函数覆盖。测试文件命名：`[system]_[feature]_test.[ext]`。函数命名：`test_[scenario]_[expected_outcome]`。不得使用随机种子、依赖时间的断言或外部 I/O。
8. **明确指令**：按照 ADR 指南实现此故事，遵守清单规则，保持在故事的 `Out of Scope` 边界内。为公开 API 编写清晰的文档注释。

代理应当：
- 按照 ADR 指南在 `src/` 中创建或修改文件
- 遵守控制清单中的所有必需和禁止模式
- 保持在故事的 `Out of Scope` 边界内（不要触及无关文件）
- 为公开 API 编写清晰的文档注释

### Config/Data 故事（不需要代理）

对于 `Type: Config/Data` 故事，不需要程序员代理。实现就是编辑数据文件。读取故事的验收标准，并直接对数据文件执行指定更改。记录修改了哪些值，以及它们从什么值变为什么值。

### Visual/Feel 故事

生成 `gameplay-programmer` 来实现代码/动画调用。注意，Visual/Feel 验收标准无法自动验证——“感觉是否正确”的检查会在 `/story-done` 中通过人工确认完成。

---

## 阶段 5：测试证据要求

测试要求已包含在阶段 4 的程序员代理说明中（第 7 项）。本阶段总结每种故事类型所需的证据——收集阶段 6 总结时使用。

| 故事类型 | 所需证据 | 说明 |
|---|---|---|
| **Logic** | 故事 `Test Evidence` 章节指定路径的自动化单元测试 | 阻塞性——已包含在阶段 4 代理说明中 |
| **Integration** | 集成测试或有记录的试玩记录 | 阻塞性——已包含在阶段 4 代理说明中 |
| **Visual/Feel** | `production/qa/evidence/[slug]-evidence.md` 中的证据文档 | 建议性——在阶段 6 总结中注明 |
| **UI** | 手动演练文档或交互测试 | 建议性——在阶段 6 总结中注明 |
| **Config/Data** | 无——冒烟检查作为证据 | 不适用 |

对于 Visual/Feel 和 UI 故事，在阶段 6 总结中包含：“完全关闭此故事前，需要在 `production/qa/evidence/[slug]-evidence.md` 提供手动测试证据。”

---

## 阶段 6：收集并总结

程序员代理完成后，收集：

- 创建或修改的文件（含路径）
- 创建的测试文件（路径及编写的测试函数数量）
- 是否有偏离故事 `Out of Scope` 边界的内容（标记这些偏离）
- 代理提出的任何问题或阻塞项
- 专家标记的任何引擎特定风险

呈现简洁的实现总结：

```
## 实现完成：[Story Title]

**已更改文件**：
- `src/[path]` — 已创建 / 已修改（[brief description]）
- `tests/[path]` — 测试文件（[N] 个测试函数）

**已覆盖的验收标准**：
- [x] [criterion] — 已在 [file:function] 中实现
- [x] [criterion] — 已由测试 [test_name] 覆盖
- [ ] [criterion] — DEFERRED：需要试玩（Visual/Feel）

**范围偏差**：[None] 或 [list files touched outside story boundary]
**已标记的引擎风险**：[None] 或 [specialist finding]
**阻塞项**：[None] 或 [describe]

**运行 `/story-done` 前：**在本地运行测试套件并确认新编写的测试通过。`/story-done` 会自动重新运行这些测试，但如果届时发现测试失败，就必须返回实现阶段。

下一步：先运行 `/code-review [file1] [file2]`，再运行 `/story-done [story-path]`
```

---

## 阶段 7：更新会话状态

静默追加到 `production/session-state/active.md`：

```
## 会话摘要 — /dev-story [date]
- 故事：[story-path] — [story title]
- 已更改文件：[comma-separated list]
- 已编写测试：[path, or "None — Visual/Feel/Config story"]
- 阻塞项：[None, or description]
- 下一步：先运行 /code-review [files]，再运行 /story-done [story-path]
```

如果不存在，创建 `active.md`。确认：“会话状态已更新。”

---

## 错误恢复协议

如果任何生成的代理（通过 Task）返回 BLOCKED、出错或无法完成：

1. **立即暴露**：在继续依赖阶段前向用户报告“[AgentName]：BLOCKED — [reason]”
2. **评估依赖**：检查被阻塞代理的输出是否是后续阶段所需。如果是，在获得用户输入前不要越过该依赖点继续。
3. **通过 AskUserQuestion 提供选项**：
   - 跳过此代理，并在最终报告中记录缺口
   - 使用更窄的范围重试
   - 在此停止，先解决阻塞项
4. **始终生成部分报告**——报告已完成的所有内容。一个代理阻塞时，不得丢弃已有工作。

常见阻塞项：
- 输入文件缺失（找不到故事、缺少 GDD）→ 转到创建它的技能
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事之间存在冲突 → 暴露冲突，不要猜测
- 清单版本不匹配 → 向用户展示差异，询问是使用旧规则继续还是先更新故事

## 协作协议

- **文件写入由代理负责**——所有源代码、测试文件和证据文档都由通过 Task 生成的子代理写入。每个子代理单独执行“可以将内容写入 [path] 吗？”协议。此编排器不直接写入文件。
- **实现前先加载**——所有上下文（故事、TR-ID、ADR、清单、引擎偏好）加载完成前，不要开始编码。不完整的上下文会导致代码偏离设计。
- **ADR 就是法律**——实现必须遵循 ADR 的 `Implementation Guidelines`。如果指南与看似“更好”的方案冲突，在总结中标记偏差，而不是静默偏离。
- **保持在范围内**——`Out of Scope` 章节是一份契约。如果实现故事需要触及范围外文件，停止并提出：“实现 [criterion] 需要修改范围外的 [file]。是继续修改，还是另建一个故事？”
- **Logic/Integration 的测试不是可选项**——没有测试文件存在时，不要将实现标记为完成
- **Visual/Feel 标准是延期而非跳过**——在总结中将其标记为 DEFERRED；它们将在 `/story-done` 中手动验证
- **大型结构性决策前先询问**——如果故事需要 ADR 未覆盖的架构模式，在实现前说明：“ADR 没有规定如何处理 [case]。我的计划是 [X]，是否继续？”

---

## 建议的后续步骤

- 运行 `/code-review [file1] [file2]`，在关闭故事前审查实现
- 运行 `/story-done [story-path]`，验证验收标准并将故事标记为完成
- 所有迭代故事完成后：运行 `/team-qa sprint` 执行完整 QA 周期，然后再推进项目阶段
