---
name: code-review
description: "对指定文件或文件集执行架构和代码质量审查。检查编码标准合规性、架构模式遵循情况、SOLID 原则、可测试性和性能问题。"
argument-hint: "[path-to-file-or-directory]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task, AskUserQuestion
model: sonnet
agent: lead-programmer
---

## 阶段 1：加载目标文件

完整读取目标文件。读取 CLAUDE.md 以了解项目编码标准。

---

## 阶段 2：确定引擎专家

读取 `.claude/docs/technical-preferences.md` 的 `## 引擎专家` 章节。记录：

- **Primary** 专家（用于架构和广泛的引擎问题）
- **Language/Code Specialist**（用于审查项目的主要语言文件）
- **Shader Specialist**（用于审查着色器文件）
- **UI Specialist**（用于审查 UI 代码）

如果该章节显示以 `[待配置` 开头的值，则尚未固定引擎，跳过引擎专家步骤。

---

## 阶段 3：ADR 合规性检查

**参数：** `/code-review [file(s)]` 可以选择将故事文件路径作为最后一个参数（例如 `/code-review src/combat/attack.gd production/epics/combat/story-001.md`）。如果提供了故事路径，读取该文件以提取管辖 ADR 引用。

按以下优先级顺序搜索 ADR 引用：
1. 故事文件（如果作为参数提供）
2. 实现文件顶部的头部注释
3. 引用这些文件的提交消息（`git log --oneline -- [file]`）

查找类似 `ADR-NNN` 或 `docs/architecture/ADR-` 的模式。

如果未找到 ADR 引用，注明：“未找到 ADR 引用，已跳过 ADR 合规性检查。要进行完整的 ADR 合规性审查，请提供故事路径：`/code-review [files] [story-path]`。”

对于每个引用的 ADR：读取文件，提取 **Decision** 和 **Consequences** 章节，然后对所有偏差进行分类：

- **ARCHITECTURAL VIOLATION** (BLOCKING)：使用了 ADR 明确拒绝的模式
- **ADR DRIFT** (WARNING)：在未使用禁用模式的情况下明显偏离所选方案
- **MINOR DEVIATION** (INFO)：与 ADR 指导存在细微差异，但不影响整体架构

---

## 阶段 4：标准合规性

确定系统类别（引擎、游戏玩法、AI、网络、UI、工具）并评估：

- [ ] 公共方法和类具有文档注释
- [ ] 每个方法的圈复杂度低于 10
- [ ] 方法不超过 40 行（不包括数据声明）
- [ ] 依赖通过注入提供（游戏状态不使用静态单例）
- [ ] 从数据文件加载配置值
- [ ] 系统公开接口（而非依赖具体类）

---

## 阶段 5：架构与 SOLID

**架构：**
- [ ] 依赖方向正确（engine <- gameplay，而非相反）
- [ ] 模块之间不存在循环依赖
- [ ] 正确分层（UI 不持有游戏状态）
- [ ] 使用事件/信号进行跨系统通信
- [ ] 与代码库中既有模式保持一致

**SOLID:**
- [ ] 单一职责：每个类只有一个变化原因
- [ ] 开闭原则：无需修改即可扩展
- [ ] 里氏替换：子类型可替代基类型
- [ ] 接口隔离：不存在臃肿接口
- [ ] 依赖倒置：依赖抽象，而非具体实现

---

## 阶段 6：游戏特定问题

- [ ] 帧率无关（使用 delta time）
- [ ] 热路径（更新循环）中不分配内存
- [ ] 正确处理 null/空状态
- [ ] 在需要时保证线程安全
- [ ] 清理资源（无泄漏）

---

## 阶段 7：专家审查（并行）

通过 Task 同时生成所有适用的专家，不要等待一个专家完成后再启动下一个。

### 引擎专家

如果已配置引擎，确定每个文件适用的专家并并行生成：

- 主要语言文件（`.gd`、`.cs`、`.cpp`）→ Language/Code Specialist
- 着色器文件（`.gdshader`、`.hlsl`、shader graph）→ Shader Specialist
- UI 屏幕/控件代码 → UI Specialist
- 跨领域或不明确 → Primary Specialist

对于任何涉及引擎架构（场景结构、节点层级、生命周期钩子）的文件，还要生成 **Primary Specialist**。

### QA 可测试性审查

对于 Logic 和 Integration 故事，还要通过 Task 生成 `qa-tester`，使其与引擎专家并行工作。传入：
- 正在审查的实现文件
- 故事的 `## QA Test Cases` 章节（由 qa-lead 预先编写的测试规范）
- 故事的 `## Acceptance Criteria`

要求 qa-tester 评估：
- [ ] 是否公开了所有测试钩子和接口（未隐藏在 private/internal 访问权限之后）？
- [ ] 故事 `## QA Test Cases` 章节中的 QA 测试用例是否映射到可测试的代码路径？
- [ ] 按当前实现是否存在任何无法测试的验收标准（例如硬编码值、没有可供注入的接缝）？
- [ ] 实现是否引入了现有 QA 测试用例未覆盖的新边界情况？
- [ ] 是否存在应有测试但没有测试的可观察副作用？

对于 Visual/Feel 和 UI 故事：qa-tester 审查 `## QA Test Cases` 中的手动验证步骤能否通过当前实现完成，例如“手动检查者需要进入的状态是否确实可达？”

生成输出前，收集所有专家的发现。

---

## 阶段 8：输出审查

```
## Code Review: [File/System Name]

### Engine Specialist Findings: [N/A — no engine configured / CLEAN / ISSUES FOUND]
[引擎专家的发现；如果跳过，则写“未配置引擎。”]

### Testability: [N/A — Visual/Feel or Config story / TESTABLE / GAPS / BLOCKING]
[qa-tester 的发现：测试钩子、覆盖缺口、不可测试路径、新边界情况]
[如果为 BLOCKING：实现必须公开 [X]，`## QA Test Cases` 中的测试才能运行]

### ADR Compliance: [NO ADRS FOUND / COMPLIANT / DRIFT / VIOLATION]
[列出检查的每个 ADR、结果以及所有偏差及其严重性]

### Standards Compliance: [X/6 passing]
[列出失败项及行号引用]

### Architecture: [CLEAN / MINOR ISSUES / VIOLATIONS FOUND]
[列出具体的架构问题]

### SOLID: [COMPLIANT / ISSUES FOUND]
[列出具体违规项]

### Game-Specific Concerns
[列出游戏开发特定问题]

### Positive Observations
[做得好的地方——始终包含此章节]

### Required Changes
[批准前必须修复的项目——ARCHITECTURAL VIOLATION 始终列在此处]

### Suggestions
[锦上添花的改进]

### Verdict: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

此技能为只读，不写入任何文件。

---

## 阶段 9：后续步骤

使用 `AskUserQuestion`：
- 提示：“代码审查完成——结论：[APPROVED / CHANGES REQUIRED / MAJOR REVISION]。你希望如何继续？”
- 选项（根据结论调整）：
  - 如果为 APPROVED：
    - `[A] 运行 /story-done 将故事标记为完成`
    - `[B] 到此为止`
  - 如果为 CHANGES REQUIRED 或 MAJOR REVISION：
    - `[A] 修复问题并重新运行 /code-review`
    - `[B] 仍然运行 /story-done，并注明例外情况`
    - `[C] 到此为止`

如果发现 ARCHITECTURAL VIOLATION：
- 如果违规与**现有 ADR** 冲突：修复实现，使其符合 `docs/architecture/[adr-file].md`。如果设计确实已更改，运行 `/architecture-decision` 以正式*修订*现有 ADR，不要创建相互竞争的 ADR。
- 如果被违反的模式**不存在 ADR**：先运行 `/architecture-decision` 记录正确方案，再修复代码。
