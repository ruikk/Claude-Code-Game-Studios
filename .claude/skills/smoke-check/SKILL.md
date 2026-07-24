---
name: smoke-check
description: "在移交 QA 前运行关键路径冒烟测试门禁。执行自动化测试套件、验证核心功能并生成 PASS/FAIL 报告。在迭代故事实现完成后、手动 QA 开始前使用。冒烟检查失败意味着构建尚未准备好进入 QA。"
argument-hint: "[sprint | quick | --platform pc|console|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
model: sonnet
---

# 冒烟检查

此技能是“实现完成”和“准备移交 QA”之间的门禁。它运行自动化测试套件、
检查测试覆盖缺口、与开发者批量验证关键路径，并生成 PASS/FAIL 报告。

规则很简单：**未通过冒烟检查的构建不得进入 QA。**
将损坏的构建交给 QA 会浪费他们的时间并打击团队士气。

**输出：** `production/qa/smoke-[date].md`

---

## 解析参数

参数可以组合使用：`/smoke-check sprint --platform console`

**基础模式**（第一个参数，默认：`sprint`）：
- `sprint` — 针对当前迭代故事执行完整冒烟检查
- `quick` — 跳过覆盖率扫描（阶段 3）和批次 3；用于快速复查

**平台标志**（`--platform`，默认：无）：
- `--platform pc` — 添加 PC 专项检查（键盘、鼠标、窗口模式）
- `--platform console` — 添加主机专项检查（手柄、电视安全区、
  平台认证要求）
- `--platform mobile` — 添加移动端专项检查（触控、横竖屏、
  电池/温控表现）
- `--platform all` — 添加所有平台变体；输出各平台判定表

如果提供了 `--platform`，阶段 4 会添加平台专项批次，
阶段 5 除总体判定外还会输出各平台判定表。

---

## 阶段 1：检测测试配置

在运行任何内容前，先了解环境：

1. **测试框架检查**：确认 `tests/` 目录存在。
   如果不存在：“在 `tests/` 未找到测试目录。运行 `/test-setup`
   搭建测试基础设施；如果测试位于其他位置，也可以手动创建目录。”然后停止。

2. **CI 检查**：检查 `.github/workflows/` 是否包含引用测试的工作流文件。
   在报告中注明是否已配置 CI。

3. **引擎检测**：读取 `.claude/docs/technical-preferences.md` 并
   提取 `Engine:` 值。保存该值，以便在阶段 2 中选择测试命令。

4. **冒烟测试列表**：检查 `production/qa/smoke-tests.md` 或
   `tests/smoke/` 是否存在。如果找到冒烟测试列表，加载它供阶段 4 使用。
   如果两者都不存在，则从当前 QA 计划中获取冒烟测试（阶段 4 的回退方案）。

5. **QA 计划检查**：glob `production/qa/qa-plan-*.md` 并选择最近修改的文件。
   如果找到，记录路径，它将在阶段 3 和阶段 4 中使用。
   如果未找到，注明：“未找到 QA 计划。为获得最佳结果，请在冒烟检查前运行
   `/qa-plan sprint`。”

继续前报告检查结果：“环境：[engine]。测试目录：
[found / not found]。已配置 CI：[yes / no]。QA 计划：[path / not found]。”

---

## 阶段 2：运行自动化测试

尝试通过 Bash 运行测试套件。根据阶段 1 检测到的引擎选择命令：

**Godot 4：**
```bash
godot --headless --script tests/gdunit4_runner.gd 2>&1
```
如果该路径下不存在 GDUnit4 运行器脚本，尝试：
```bash
godot --headless -s addons/gdunit4/GdUnitRunner.gd 2>&1
```
如果两个路径都不存在，注明：“未找到 GDUnit4 运行器，请确认测试框架的运行器路径。”

**Unity：**
在大多数环境中，Unity 测试需要编辑器，无法通过 shell 无头运行。
检查最近的测试结果产物：
```bash
# 列出最近的测试结果（bash）；在 Windows PowerShell 上使用下方回退命令
ls -t test-results/ 2>/dev/null | head -5 \
  || powershell -Command "Get-ChildItem test-results/ -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5 -ExpandProperty Name"
```
如果存在测试结果文件（XML 或 JSON），读取最新文件并解析 PASS/FAIL 数量。
如果不存在产物：“Unity 测试必须通过编辑器或 CI 管线运行。
请在继续前手动确认测试状态。”

**Unreal Engine：**
```bash
# 列出最近的 Unreal 自动化日志（bash）；在 Windows PowerShell 上使用下方回退命令
ls -t Saved/Logs/ 2>/dev/null | grep -i "test\|automation" | head -5 \
  || powershell -Command "Get-ChildItem Saved/Logs/ -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'test|automation' } | Sort-Object LastWriteTime -Descending | Select-Object -First 5 -ExpandProperty Name"
```
如果未找到匹配日志：“UE 自动化测试必须通过 Session Frontend 或 CI 管线运行。
请手动确认测试状态。”

**未知引擎/未配置：**
“`.claude/docs/technical-preferences.md` 中未配置引擎。运行
`/setup-engine` 指定引擎，然后重新运行 `/smoke-check`。”

**如果当前环境中无法使用测试运行器**（引擎二进制文件不在 PATH、
未找到运行器脚本等），请明确报告：

“无法执行自动化测试，因为在 PATH 中未找到引擎二进制文件。
状态将记录为 NOT RUN。请确认本地 IDE 或 CI 管线中的测试结果。
未经确认的 NOT RUN 视为 PASS WITH WARNINGS，而非 FAIL；
开发者必须手动确认结果。”

不要将 NOT RUN 自动视为 FAIL。将其记录为警告。
开发者在阶段 4 中的手动确认可以解决该问题。

解析运行器输出并提取：
- 运行的测试总数
- 通过数量
- 失败数量
- 所有失败测试的名称（最多 10 个；如果更多，注明数量）
- 运行器本身的所有崩溃或错误输出

---

## 阶段 3：检查测试覆盖率

按以下优先顺序获取故事列表：
1. 阶段 1 中找到的 QA 计划（其测试摘要表列出每个故事的预期测试文件路径）
2. `production/sprints/` 中的当前迭代计划（最近修改的文件）
3. 如果传入了 `quick` 参数，则完全跳过此阶段并注明：
   “已跳过覆盖率扫描；运行 `/smoke-check sprint` 进行完整覆盖率分析。”

对范围内的每个故事：

1. 从故事文件路径中提取系统 slug
   （例如 `production/epics/combat/story-001.md` → `combat`）
2. 在 `tests/unit/[system]/` 和 `tests/integration/[system]/` 中 glob
   文件名包含故事 slug 或紧密相关术语的文件
3. 检查故事文件本身是否包含 `Test file:` 头字段或“测试证据”章节

为每个故事分配覆盖状态：

| 状态 | 含义 |
|--------|---------|
| **COVERED** | 找到与该故事的系统和范围匹配的测试文件 |
| **MANUAL** | 故事类型为 Visual/Feel 或 UI；找到了测试证据文档 |
| **MISSING** | Logic 或 Integration 故事没有匹配的测试文件 |
| **EXPECTED** | Config/Data 故事不需要测试文件；抽查即可 |
| **UNKNOWN** | 故事文件缺失或无法读取 |

MISSING 条目是建议性缺口。它们不会导致 FAIL 判定，但必须在报告中醒目标出，
并且必须先解决，`/story-done` 才能完全关闭这些故事。

---

## 阶段 4：运行手动冒烟检查

按以下优先顺序获取冒烟测试清单：
1. QA 计划的“冒烟测试范围”章节（如果阶段 1 找到了 QA 计划）
2. `production/qa/smoke-tests.md`（如果存在）
3. `tests/smoke/` 目录内容（如果存在）
4. 下方标准回退列表（仅在以上内容均不存在时使用）

根据迭代或 QA 计划中识别出的实际系统调整批次 2 和批次 3。
将方括号占位符替换为当前迭代故事中的真实机制名称。

使用 `AskUserQuestion` 批量验证。最多调用 3 次。

**批次 1 — 核心稳定性（始终运行）：**
```
question: "核心稳定性——选择所有 FAILED 项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "游戏无法启动，或在进入主菜单前崩溃"
  - "新游戏/会话无法开始"
  - "主菜单不响应输入"
  - "基础导航过程中出现崩溃或卡死"
```

对于任何选中项，在生成报告前请用户简要描述失败情况。

**批次 2 — 迭代变更与回归（始终运行）：**
```
question: "迭代变更与回归——选择所有 FAILED 项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "[Primary mechanic this sprint] — FAILED"
  - "[Second notable change this sprint, if any] — FAILED"
  - "之前迭代的功能发生回归 — FAILED"
  - "观察到其他意外故障 — FAILED"
```

对于任何选中项，在生成报告前请用户简要描述故障内容。

**批次 3 — 数据完整性与性能（除非使用 `quick` 参数，否则运行）：**
```
question: "数据完整性与性能——选择所有 FAILED 或跳过的项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "保存/加载 — FAILED（观察到数据丢失或损坏）"
  - "保存/加载 — N/A（尚未实现存档系统）"
  - "观察到帧率下降或卡顿 — FAILED"
  - "本次会话未检查性能"
```

对于任何选中的 FAILED 项，在生成报告前请用户描述故障内容。

在阶段 5 报告中逐字记录每条回复。

**平台批次**（仅在提供 `--platform` 参数时运行）：

**PC 平台**（`--platform pc` 或 `--platform all`）：
```
question: "PC 平台——选择所有 FAILED 项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "键盘控制 — FAILED（随后描述问题）"
  - "鼠标输入或光标可见性 — FAILED（随后描述问题）"
  - "窗口/全屏模式 — FAILED（随后描述问题）"
  - "分辨率切换 — FAILED（随后描述问题）"
```

对于任何选中项，在生成报告前请用户简要描述失败情况。

**主机平台**（`--platform console` 或 `--platform all`）：
```
question: "主机平台——选择所有 FAILED 项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "手柄输入 — FAILED（随后描述问题）"
  - "UI 超出电视安全区/文本被裁切 — FAILED（随后描述被裁切内容）"
  - "向手柄用户显示键盘/鼠标回退提示 — FAILED（随后描述）"
  - "冷启动（无既有存档）— FAILED（随后描述问题）"
```

对于任何选中项，在生成报告前请用户简要描述失败情况。

**移动平台**（`--platform mobile` 或 `--platform all`）：
```
question: "移动平台——选择所有 FAILED 项（如果全部通过，则全部不选）："
multiSelect: true
options:
  - "触控操作 — FAILED（随后描述问题）"
  - "方向切换（竖屏 ↔ 横屏）— FAILED（随后描述故障内容）"
  - "后台/前台切换（主页按钮）— FAILED（随后描述问题）"
  - "目标设备上的性能/温控降频 — FAILED（随后描述）"
```

对于任何选中项，在生成报告前请用户简要描述失败情况。

---

## 阶段 5：生成报告

组装完整的冒烟检查报告：

````markdown
## 冒烟检查报告
**日期**：[date]
**迭代**：[sprint name / number, or "Not identified"]
**引擎**：[engine]
**QA 计划**：[path, or "Not found — run /qa-plan first"]
**参数**：[sprint | quick | blank]

---

### 自动化测试

**状态**：[PASS ([N] tests, [N] passing) | FAIL ([N] failures) |
NOT RUN ([reason])]

[If FAIL, list failing tests:]
- `[test name]` — [brief failure description from runner output]

[If NOT RUN:]
“需要手动确认：测试是否在本地 IDE 或 CI 中通过？
这将决定自动化测试行是否会导致 FAIL 判定。”

---

### 测试覆盖率

| 故事 | 类型 | 测试文件 | 覆盖状态 |
|-------|------|-----------|----------------|
| [title] | Logic | `tests/unit/[system]/[slug]_test.[ext]` | COVERED |
| [title] | Visual/Feel | `tests/evidence/[slug]-screenshots.md` | MANUAL |
| [title] | Logic | — | MISSING ⚠ |
| [title] | Config/Data | — | EXPECTED |

**摘要**：[N] 个 COVERED，[N] 个 MANUAL，[N] 个 MISSING，[N] 个 EXPECTED。

---

### 手动冒烟检查

- [x] 游戏启动且未崩溃 — PASS
- [x] 新游戏开始 — PASS
- [x] [Core mechanic] — PASS
- [ ] [Other check] — FAIL：[user's description]
- [x] 保存/加载 — PASS
- [-] 性能 — 本次会话未检查

---

### 缺失测试证据

以下故事必须具有测试证据，才能通过 `/story-done` 标记为 COMPLETE：

- **[story title]**（`[path]`）— Logic 故事没有测试文件。
  预期位置：`tests/unit/[system]/[story-slug]_test.[ext]`

[If none:] “所有 Logic 和 Integration 故事均有测试覆盖。”

---

### 平台专项结果（仅在提供 `--platform` 时）

| 平台 | 运行检查数 | 通过 | 失败 | 平台判定 |
|----------|-----------|--------|--------|-----------------|
| PC | [N] | [N] | [N] | PASS / FAIL |
| Console | [N] | [N] | [N] | PASS / FAIL |
| Mobile | [N] | [N] | [N] | PASS / FAIL |

**平台备注**：[any platform-specific observations not captured in pass/fail]

任何平台出现一个或多个 FAIL 检查都会导致总体 FAIL 判定。

---

### 判定：[PASS | PASS WITH WARNINGS | FAIL]

[Verdict rules — first matching rule wins:]

以下任一情况为 **FAIL**：
- 自动化测试套件已运行，并报告一个或多个测试失败
- 任一批次 1（核心稳定性）检查返回 FAIL
- 任一批次 2（主要迭代机制或回归检查）检查返回 FAIL

同时满足以下所有条件为 **PASS WITH WARNINGS**：
- 自动化测试为 PASS 或 NOT RUN（开发者尚未确认）
- 所有批次 1 和批次 2 冒烟检查均为 PASS
- 一个或多个 Logic/Integration 故事存在 MISSING 测试证据

同时满足以下所有条件为 **PASS**：
- 自动化测试为 PASS
- 所有批次中的冒烟检查均为 PASS 或 N/A
- 没有 MISSING 测试证据条目
````

---

## 阶段 6：写入并执行门禁

在对话中展示完整报告，然后询问：

“可以将此冒烟检查报告写入 `production/qa/smoke-[date].md` 吗？”

仅在获得批准后写入。

写入后，给出门禁判定：

**如果判定为 FAIL：**

“冒烟检查失败。在解决以下失败前，请勿移交 QA：

[List each failing automated test or smoke check with a one-line description]

修复失败项并再次运行 `/smoke-check`，通过门禁后再移交 QA。”

**如果判定为 PASS WITH WARNINGS：**

“冒烟检查通过，但有警告。该构建已准备好进行手动 QA。

在受影响故事上运行 `/story-done` 前需要解决的建议项：
[list MISSING test evidence entries]

QA 移交：与 qa-tester 代理共享 `production/qa/qa-plan-[sprint].md`，
以开始手动验证。”

**如果判定为 PASS：**

“冒烟检查完全通过。该构建已准备好进行手动 QA。

QA 移交：与 qa-tester 代理共享 `production/qa/qa-plan-[sprint].md`，
以开始手动验证。”

---

## 协作协议

- **绝不将 NOT RUN 自动视为 FAIL** — 将其记录为 NOT RUN，并让开发者手动确认状态。
  未确认的 NOT RUN 会导致 PASS WITH WARNINGS，而非 FAIL。
- **绝不自动修复失败项** — 报告失败项并说明必须解决的内容。
  不要尝试编辑源代码或测试文件。
- **PASS WITH WARNINGS 不会阻止 QA 移交** — 它会记录建议性缺口，
  供 `/story-done` 后续处理。
- **`quick` 参数**会跳过阶段 3（覆盖率扫描）和阶段 4 的批次 3。
  修复特定失败后，可用它快速复查。
- 所有手动冒烟检查验证均使用 `AskUserQuestion`。
- **未经询问绝不写入报告** — 阶段 6 要求在创建任何文件前获得明确批准。
