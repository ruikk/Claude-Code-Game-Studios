---
name: test-flakiness
description: "通过读取 CI 运行日志或测试结果历史记录，检测非确定性（不稳定）测试。汇总每项测试的通过率，识别间歇性失败，建议隔离或修复，并维护不稳定测试登记表。最适合在 Polish 阶段或多次 CI 运行后使用。"
argument-hint: "[ci-log-path | scan | registry]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
model: sonnet
---

# 测试不稳定性检测

不稳定测试是指在代码没有任何变更的情况下，有时通过、有时失败的测试。
从某些方面看，不稳定测试比没有测试更糟糕，因为它会让团队习惯忽略失败的 CI
运行，从而掩盖真正的故障。本技能用于识别此类测试、解释可能的原因，并建议
逐项隔离或修复。

**输出：** 更新 `tests/regression-suite.md` 的隔离区段 + 可选的
`production/qa/flakiness-report-[date].md`

**何时运行：**
- Polish 阶段（测试已经运行多次，统计信号可靠）
- 当开发人员开始把 CI 失败归为“可能是不稳定测试”而不予处理时
- 在 `/regression-suite` 识别出需要诊断的已隔离测试后

---

## 1. 解析参数

**模式：**
- `/test-flakiness [ci-log-path]` — 分析指定的 CI 运行日志文件
- `/test-flakiness scan` — 扫描 `.github/` 或标准日志输出目录中的所有可用 CI 日志
- `/test-flakiness registry` — 读取现有 regression-suite.md 的隔离区段，
  并为已知的不稳定测试提供修复指导
- 无参数 — 自动检测：如果可访问 CI 日志，则运行 `scan`，否则运行
  `registry`

---

## 2. 定位 CI 日志数据

### 选项 A — GitHub Actions（首选）

检查测试结果产物：
```bash
ls -t .github/ 2>/dev/null
ls -t test-results/ 2>/dev/null
```

对于 Godot 项目：GdUnit4 输出兼容 JUnit 格式的 XML 结果。
检查 `test-results/` 中的 `.xml` 文件。

对于 Unity 项目：game-ci test runner 默认将 NUnit XML 输出到 `test-results/`。

对于 Unreal 项目：自动化日志位于 `Saved/Logs/`。使用 Grep 搜索
`Result: Success` 和 `Result: Fail` 模式。

### 选项 B — 本地日志文件

如果提供了路径参数，直接读取该文件。

### 选项 C — 没有可用的日志数据

如果未找到日志：
> “未找到 CI 日志数据。要检测不稳定测试，本技能需要多次运行的测试结果历史记录。
> 可选操作：
> 1. 至少运行测试套件 3 次，并收集输出日志
> 2. 检查 CI 流水线输出，并将日志保存到 `test-results/`
> 3. 运行 `/test-flakiness registry`，检查 `tests/regression-suite.md` 中
>    已标记为不稳定的测试”

停止并询问用户要采用哪个选项。

---

## 3. 解析测试结果

解析找到的每个 CI 日志或结果文件：

**JUnit XML 格式**（GdUnit4 / Unity）：
- 使用 Grep 搜索 `<testcase name=` 以获取测试名称
- 使用 Grep 搜索 `<failure` 或 `<error` 以识别失败
- 解析 `classname` 和 `name` 属性以获取完整测试标识符

**纯文本日志：**
- 使用 Grep 搜索通过/失败模式：
  - Godot：测试名称旁的 `PASSED` / `FAILED`
  - Unreal: `Result: Success` / `Result: Fail`
  - Unity: `Test passed` / `Test failed`

构建表格：`test_id → [run1_result, run2_result, run3_result, ...]`

---

## 4. 识别不稳定测试

如果在代码未发生变更的多次运行中，一项测试的结果历史记录同时包含 PASS 和
FAIL，则该测试属于**不稳定测试**。

不稳定性阈值：
- **高度不稳定**：超过 25% 的运行失败 — 立即隔离
- **中度不稳定**：5–25% 的运行失败 — 尽快调查并修复
- **轻度/疑似不稳定**：1–5% 的运行失败 — 持续监控；也可能是真正的罕见故障

对每项不稳定测试的可能原因进行分类：

### 原因分类

| 原因 | 表现 | 修复方向 |
|-------|----------|---------------|
| **时序/异步** | 等待信号或计时器后失败；通过率与系统负载相关 | 添加显式等待/同步；避免基于时间的延迟 |
| **顺序依赖** | 在特定其他测试之后运行时失败；单独运行时通过 | 添加正确的 setup/teardown；确保测试隔离 |
| **随机种子** | 无明显规律地间歇性失败；涉及 RNG | 传入显式种子；不要在测试中使用 `randf()` |
| **资源泄漏** | 越到测试运行后期越容易失败 | 修复 teardown 中的清理；检查孤立节点（Godot）或对象释放（Unity） |
| **外部状态** | 先前测试遗留文件、场景或全局状态时失败 | 将测试与文件系统隔离；使用内存 mock |
| **浮点数** | 在 `== 0.5` 等比较中失败 | 使用 epsilon 比较（`is_equal_approx`、`Assert.AreApproximately`） |
| **场景/prefab 加载竞态** | 场景尚未就绪时失败 | 实例化后等待一帧；使用 `await get_tree().process_frame` |

使用 Grep 检查测试文件中的时序调用、randf、全局状态访问或浮点数相等比较，
以缩小原因范围。

---

## 5. 建议操作

针对每项不稳定测试：

**隔离（高度不稳定）：**
> “立即隔离此测试。添加 `@pytest.mark.skip` / `[Ignore]` / `GdUnitSkip`
> 注解，在 CI 中禁用它。将其记录到 `tests/regression-suite.md` 的隔离区段。
> 此测试现在仅可显式选择运行。必须修复根本原因后才能解除隔离。”

**尽快调查并修复（中度不稳定）：**
> “此测试存在间歇性不可靠问题。根本原因似乎是 [cause]。
> 建议修复方式：[specific fix based on cause classification]。暂时不要隔离，
> 直接修复测试。”

**监控（轻度/疑似不稳定）：**
> “此测试疑似存在不稳定性。隔离前应收集更多运行数据。
> 在回归套件中将其标记为‘疑似’。”

---

## 6. 生成报告

### 对话内摘要

```
## 不稳定性检测结果

**已分析运行次数**：[N]
**已跟踪测试数**：[N]

### 发现的不稳定测试

| 测试 | 系统 | 失败率 | 可能原因 | 建议 |
|------|--------|-----------|--------------|----------------|
| [test_name] | [system] | [N]% | 时序 | 隔离 + 修复异步问题 |
| [test_name] | [system] | [N]% | 浮点数比较 | 修复：使用 epsilon 比较 |
| [test_name] | [system] | [N]% | 顺序依赖 | 调查 teardown |

### 稳定测试（未检测到不稳定性）

[N] 项测试在 [N] 次运行中的结果一致，未检测到不稳定性。

### 数据限制

[Note if fewer than 5 runs were available — fewer runs = less statistical confidence]
```

---

## 7. 更新回归套件 + 可选报告文件

询问：“可以用发现的不稳定测试更新 `tests/regression-suite.md` 的隔离区段吗？”

如果同意：使用 `Edit` 将条目追加到 Quarantined Tests 表格。
绝不要移除现有隔离条目，只添加新条目。

另行询问：“可以将完整的不稳定性报告写入
`production/qa/flakiness-report-[date].md` 吗？”

完整报告应包含每项测试的分析、详细原因和引擎专用修复片段。

写入后：

- 对每项已隔离测试：“添加引擎专用跳过注解，在 CI 中禁用此测试。
  修复根本原因后重新启用。”
- 对可直接修复的测试：“[test] 的修复很直接，将第 [N] 行的相等比较改为使用
  `is_equal_approx`。”
- 摘要：“应用所有隔离注解后，CI 应能通过。在发布门禁前安排修复这 [N] 项
  已隔离测试。”

---

## 协作协议

- **绝不要删除测试文件** — 隔离是添加注解并列入清单，而不是移除
- **统计置信度很重要** — 运行少于 3 次时，将发现标记为“疑似”而非“确认”；
  询问是否有更多运行数据
- **修复始终是目标** — 隔离只是临时措施；即使建议隔离，也要明确修复方向
- **写入前先询问** — 更新 regression-suite 和写入报告文件都需要明确批准。
  写入后：Verdict: **COMPLETE** — 不稳定性报告已写入。拒绝时：Verdict: **BLOCKED** — 用户拒绝写入。
- **CI 中的不稳定性是团队问题** — 清晰列出问题和建议操作；不要在团队不知情的情况下静默隔离
