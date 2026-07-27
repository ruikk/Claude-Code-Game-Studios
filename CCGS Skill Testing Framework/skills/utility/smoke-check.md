# 技能测试规范：/smoke-check

## 技能摘要

`/smoke-check` 是实现完成与移交 QA 之间的门禁。它检测测试环境，通过 Bash 运行自动化测试套件，根据迭代故事扫描测试覆盖率，并使用 `AskUserQuestion` 与开发者分批确认手动冒烟检查。获得用户明确批准后，它将报告写入 `production/qa/smoke-[date].md`。

判定：PASS（测试通过、所有冒烟检查通过且没有缺失的测试证据）、PASS WITH WARNINGS（测试通过或 NOT RUN、所有关键检查通过，但存在测试覆盖率缺失等提示性缺口），或 FAIL（任一自动化测试失败，或 Batch 1/Batch 2 冒烟检查返回 FAIL）。

不适用任何 director 门禁。该技能不会调用任何 director 代理。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：PASS、PASS WITH WARNINGS、FAIL
- [ ] 在写入报告前包含“May I write”协作协议措辞
- [ ] 包含后续步骤交接（例如 FAIL 时使用 `/bug-report`，PASS 时提供 QA 移交指导）

---

## Director 门禁检查

无。`/smoke-check` 是 QA 前置工具技能，不适用任何 director 门禁。

---

## 测试用例

### 用例 1：成功路径——自动化测试通过、手动项目确认通过，PASS

**测试夹具：**
- `tests/` 目录存在，并包含 GDUnit4 runner 脚本
- 从 `technical-preferences.md` 检测到引擎为 Godot
- `production/qa/qa-plan-sprint-005.md` 存在
- 自动化测试 runner 报告 12 个测试，12 个通过，0 个失败
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS
- 所有迭代故事都有匹配的测试文件（没有 MISSING 覆盖）

**输入：** `/smoke-check`

**预期行为：**
1. 技能检测测试目录和引擎，并记录已找到 QA 计划
2. 通过 Bash 运行 `godot --headless --script tests/gdunit4_runner.gd`
3. 解析输出：12/12 通过
4. 扫描测试覆盖率，所有故事均为 COVERED 或 EXPECTED
5. 使用 `AskUserQuestion` 检查 Batch 1（核心稳定性）和 Batch 2（迭代机制）
6. 开发者为所有项目选择 PASS
7. 汇总报告：自动化测试 PASS、所有冒烟检查 PASS、没有 MISSING 覆盖
8. 询问“可以将此冒烟检查报告写入 `production/qa/smoke-[date].md` 吗？”
9. 获得批准后写入报告
10. 给出判定：PASS

**断言：**
- [ ] 通过 Bash 调用自动化测试 runner
- [ ] 使用 `AskUserQuestion` 进行手动冒烟检查分批确认
- [ ] 写入报告文件前询问写入许可（`May I write`）
- [ ] 报告写入 `production/qa/smoke-[date].md`
- [ ] 判定为 PASS

---

### 用例 2：失败路径——自动化测试失败，FAIL 判定

**测试夹具：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试 runner 报告运行 10 个测试：8 个通过，2 个失败
  - 失败测试：`test_health_clamp_at_zero`、`test_damage_calculation_negative`
- QA 计划存在

**输入：** `/smoke-check`

**预期行为：**
1. 技能通过 Bash 运行自动化测试
2. 解析输出，检测到 2 个失败
3. 记录失败测试名称
4. 继续执行手动冒烟检查分批确认
5. 报告将自动化测试显示为 FAIL，并列出失败测试名称
6. 询问是否写入报告，获得批准后写入
7. 给出 FAIL 判定并显示消息：“冒烟检查失败。在这些失败得到解决前，不要移交 QA。”列出失败测试，并建议修复后重新运行 `/smoke-check`

**断言：**
- [ ] 报告列出失败测试名称
- [ ] 判定为 FAIL
- [ ] 判定后的消息要求开发者在移交 QA 前修复失败
- [ ] 修复后建议重新运行 `/smoke-check`

---

### 用例 3：手动确认——使用 AskUserQuestion，PASS WITH WARNINGS

**测试夹具：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试 runner 报告所有测试通过（8/8）
- 一个 Logic 故事没有匹配的测试文件（MISSING 覆盖）
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS

**输入：** `/smoke-check`

**预期行为：**
1. 自动化测试为 PASS
2. 覆盖率扫描发现一个 Logic 故事存在 1 个 MISSING 条目
3. 使用 `AskUserQuestion` 检查 Batch 1 和 Batch 2，开发者确认全部 PASS
4. 报告显示：自动化测试 PASS、手动检查全部 PASS、1 个 MISSING 覆盖条目
5. 判定为 PASS WITH WARNINGS：构建可以交给 QA，但必须在 `/story-done` 关闭受影响故事前解决 MISSING 条目
6. 询问是否写入报告，获得批准后写入

**断言：**
- [ ] 使用 `AskUserQuestion` 进行手动冒烟检查分批确认，而不是使用行内文字提示
- [ ] 报告中出现 MISSING 测试覆盖条目
- [ ] 判定为 PASS WITH WARNINGS（不是 PASS，也不是 FAIL）
- [ ] 提示说明 MISSING 条目必须在 `/story-done` 前解决
- [ ] 报告文件写入 `production/qa/smoke-[date].md`

---

### 用例 4：没有测试目录——技能停止并给出指导

**测试夹具：**
- `tests/` 目录不存在
- 引擎配置为 Godot

**输入：** `/smoke-check`

**预期行为：**
1. 阶段 1 检查 `tests/` 目录，未找到
2. 技能输出：“在 `tests/` 未找到测试目录。运行 `/test-setup` 搭建测试基础设施；如果测试位于其他位置，也可以手动创建该目录。”
3. 技能停止，不运行自动化测试、不执行手动冒烟检查、不写入报告

**断言：**
- [ ] 错误消息指出缺失的 `tests/` 目录
- [ ] 建议使用 `/test-setup` 作为修复步骤
- [ ] 技能在此消息后停止，不运行后续阶段
- [ ] 不写入报告文件

---

### 用例 5：Director 门禁检查——无门禁；smoke-check 是 QA 前置检查工具

**测试夹具：**
- 测试设置有效，自动化测试通过，手动冒烟检查已确认

**输入：** `/smoke-check`

**预期行为：**
1. 技能运行所有阶段并生成 PASS 或 PASS WITH WARNINGS 判定
2. 执行过程中不会生成任何 director 代理
3. 输出中不出现门禁 ID（CD-*、TD-*、AD-*、PR-*）
4. 不调用 `/gate-check`

**断言：**
- [ ] 不调用 director 门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定为 PASS、PASS WITH WARNINGS 或 FAIL，不涉及门禁判定

---

## 协议合规性

- [ ] 对所有手动冒烟检查分批（Batch 1、Batch 2、Batch 3）使用 `AskUserQuestion`
- [ ] 在询问任何手动问题前通过 Bash 运行自动化测试
- [ ] 创建报告文件前询问写入许可（`May I write`），未经批准绝不写入
- [ ] 判定词严格使用 PASS / PASS WITH WARNINGS / FAIL，不使用其他判定
- [ ] 自动化测试失败或 Batch 1/Batch 2 返回 FAIL 时触发 FAIL
- [ ] 存在 MISSING 测试覆盖但没有关键失败时触发 PASS WITH WARNINGS
- [ ] NOT RUN（引擎二进制不可用）记录为警告，而不是 FAIL
- [ ] 全程不调用 director 门禁

---

## 覆盖说明

- `quick` 参数（跳过阶段 3 覆盖率扫描和 Batch 3）没有单独设置测试夹具；它遵循用例 1 的相同模式，并在输出中注明跳过覆盖率。
- `--platform` 参数会增加平台专用的 AskUserQuestion 分批确认和按平台划分的判定表；这里没有单独测试。
- 引擎二进制不在 PATH 中的情况（NOT RUN）遵循 PASS WITH WARNINGS 模式，并由上述协议合规性断言覆盖。
