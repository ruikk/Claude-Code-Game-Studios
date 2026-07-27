# 技能测试规范：/test-flakiness

## 技能摘要

`/test-flakiness` 通过分析测试历史日志（如有）或扫描测试源代码中的常见波动模式，检测非确定性测试，包括未设种子的随机数、实时等待和外部 I/O。
不会调用总监门禁。未经用户批准不会写入文件。结论包括：NO FLAKINESS、SUSPECT TESTS FOUND 或 CONFIRMED FLAKY。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：NO FLAKINESS、SUSPECT TESTS FOUND、CONFIRMED FLAKY
- [ ] 不要求使用 "May I write"（只读；可选报告需获得批准）
- [ ] 包含下一步交接（发现波动问题后应执行的操作）

---

## 总监门禁检查

无。波动性检测是供 qa-lead 使用的建议性质量技能，不会调用门禁。

---

## 测试用例

### 用例 1：正常路径——干净的测试历史，无波动

**测试夹具：**
- `production/qa/test-history/` 中包含 10 次测试运行的日志
- 所有测试在全部 10 次运行中持续通过（每个测试的通过率为 100%）
- 没有测试出现失败模式

**输入：** `/test-flakiness`

**预期行为：**
1. 技能从 `production/qa/test-history/` 读取测试历史日志
2. 技能计算每个测试在 10 次运行中的通过率
3. 所有测试均在 10 次运行中通过，未检测到不一致
4. 结论为 NO FLAKINESS

**断言：**
- [ ] 有测试历史时读取测试历史日志
- [ ] 根据所有可用运行记录计算每个测试的通过率
- [ ] 所有测试持续通过时，结论为 NO FLAKINESS
- [ ] 不写入任何文件

---

### 用例 2：发现可疑测试——历史记录中存在间歇性失败

**测试夹具：**
- `production/qa/test-history/` 中包含 10 次测试运行的日志
- `test_combat_damage_applies_crit_multiplier` 通过 7 次、失败 3 次
- 失败消息不同（有时超时，有时数值错误）

**输入：** `/test-flakiness`

**预期行为：**
1. 技能读取测试历史日志并计算通过率
2. `test_combat_damage_applies_crit_multiplier` 的通过率为 70%（阈值：95%）
3. 技能将其标记为 SUSPECT，显示通过率（7/10）并记录失败模式
4. 结论为 SUSPECT TESTS FOUND
5. 技能建议调查该测试是否存在时间依赖或状态依赖

**断言：**
- [ ] 按名称标记通过率低于阈值的测试
- [ ] 为每个可疑测试显示通过率（分数和百分比）
- [ ] 如果可以识别，则记录失败模式（例如不一致的错误消息）
- [ ] 结论为 SUSPECT TESTS FOUND
- [ ] 给出调查步骤

---

### 用例 3：源码模式——使用未设种子的随机数

**测试夹具：**
- 不存在测试历史日志
- `tests/unit/loot/loot_drop_test.gd` 包含：
  ```gdscript
  var roll = randf()  # unseeded random — non-deterministic
  assert_gt(roll, 0.5, "Loot should drop above 50%")
  ```

**输入：** `/test-flakiness`

**预期行为：**
1. 技能找不到测试历史日志
2. 技能回退到源码分析
3. 技能检测到没有先调用 `seed()` 的 `randf()`
4. 技能将该测试标记为 FLAKINESS RISK（源码模式，不代表已确认）
5. 结论为 SUSPECT TESTS FOUND（检测到模式，但没有历史记录确认）
6. 技能建议在调用前设置随机种子，或模拟随机函数

**断言：**
- [ ] 没有历史日志时使用源码分析作为回退方案
- [ ] 检测未设种子的随机数使用，并将其标记为波动风险
- [ ] 结论为 SUSPECT TESTS FOUND（不是 CONFIRMED FLAKY，因为没有历史记录确认）
- [ ] 修复建议设置随机种子或使用模拟对象

---

### 用例 4：没有测试历史——仅进行源码分析并检查常见模式

**测试夹具：**
- `production/qa/test-history/` 不存在
- `tests/` 中包含 15 个测试文件
- 扫描发现 2 个测试使用 `OS.get_ticks_msec()` 进行时间断言
- 未发现其他波动模式

**输入：** `/test-flakiness`

**预期行为：**
1. 技能检查测试历史，但未找到
2. 技能说明：“没有可用的测试历史，仅分析源码中的波动模式”
3. 技能扫描所有测试文件中的已知模式：未设种子的随机数、实时等待和系统时钟使用
4. 找到 2 个使用 `OS.get_ticks_msec()` 的测试，并将其标记为 FLAKINESS RISK
5. 结论为 SUSPECT TESTS FOUND

**断言：**
- [ ] 明确说明正在进行仅源码分析（没有测试历史）
- [ ] 扫描常见波动模式：随机数、基于时间的断言和外部 I/O
- [ ] 将断言中的 `OS.get_ticks_msec()` 使用标记为波动风险
- [ ] 发现源码模式时，结论为 SUSPECT TESTS FOUND

---

### 用例 5：门禁合规——不调用门禁；波动报告仅供建议

**测试夹具：**
- 测试历史显示 1 个 CONFIRMED FLAKY 测试（10 次运行中失败 6 次）
- `review-mode.txt` 包含 `full`

**输入：** `/test-flakiness`

**预期行为：**
1. 技能分析测试历史，识别出 1 个已确认的波动测试
2. 无论审查模式为何均不调用总监门禁
3. 结论为 CONFIRMED FLAKY
4. 技能展示发现并提供可选的书面报告
5. 如果用户选择写入，询问：“May I write to `production/qa/flakiness-report-[date].md`?”

**断言：**
- [ ] 任何审查模式下都不调用总监门禁
- [ ] CONFIRMED FLAKY 结论必须有基于历史的证据（不能只依据源码模式）
- [ ] 可选报告必须在写入前询问 "May I write"
- [ ] 波动报告仅供 qa-lead 参考；技能不会自动禁用测试

---

## 协议合规性

- [ ] 有测试历史时读取日志；没有历史时回退到源码分析
- [ ] 明确说明当前使用的分析模式（历史分析或仅源码分析）
- [ ] 使用波动阈值（例如 95% 通过率）进行 SUSPECT 分类
- [ ] CONFIRMED FLAKY 需要历史证据；源码模式只能产生 SUSPECT 结论
- [ ] 不禁用或修改任何测试文件
- [ ] 不调用总监门禁
- [ ] 结论为以下之一：NO FLAKINESS、SUSPECT TESTS FOUND、CONFIRMED FLAKY

---

## 覆盖说明

- SUSPECT 分类的通过率阈值（上例建议为 95%）属于实现细节；测试验证间歇性失败会被标记，不验证确切阈值。
- 由环境问题导致的失败（缺少资产、平台错误）不属于波动性；技能会区分环境失败和测试自身的非确定性，但此项区分未在此处明确测试。
