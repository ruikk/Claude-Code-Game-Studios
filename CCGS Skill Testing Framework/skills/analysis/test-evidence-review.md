# 技能测试规范：/test-evidence-review

## 技能摘要

`/test-evidence-review` 会对 `tests/` 中的测试文件进行质量审查，检查测试命名规范、确定性、隔离性以及不使用硬编码魔法数字，
所有检查均依据项目在 `coding-standards.md` 中定义的测试标准执行。检查结果可能会提交给 qa-lead 审查。不会触发任何 director
门禁。未经用户批准不会写入文件。审查结果包括：PASS、WARNINGS 或 FAIL。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：PASS、WARNINGS、FAIL
- [ ] 不要求使用 "May I write"（只读；可选报告需获得批准）
- [ ] 包含下一步交接（审查结果后应执行的操作）

---

## 总监门禁检查

无。测试证据审查是建议性的质量技能；QL-TEST-COVERAGE 门禁由独立调用处理，不在此触发。

---

## 测试用例

### 用例 1：正常路径——测试遵循所有标准

**测试夹具：**
- `tests/unit/combat/health_system_take_damage_test.gd` 存在，并包含：
  - 命名：`test_health_system_take_damage_reduces_health()`（遵循 `test_[system]_[scenario]_[expected]`）
  - 采用 Arrange/Act/Assert 结构
  - 不包含 `sleep()`、带时间值的 `await` 或随机种子
  - 不调用外部 API，也不进行文件 I/O
  - 不包含内联魔法数字（使用 `tests/unit/combat/fixtures/` 中的常量）

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能从 `coding-standards.md` 读取测试标准
2. 技能读取测试文件，检查全部 5 项标准
3. 命名、结构、确定性、隔离和无硬编码数据检查全部通过
4. 结论为 PASS

**断言：**
- [ ] 检查并报告全部 5 项测试标准
- [ ] 符合标准时所有检查均显示 PASS
- [ ] 结论为 PASS
- [ ] 不写入任何文件

---

### 用例 2：失败——检测到时间依赖

**测试夹具：**
- `tests/unit/ui/hud_update_test.gd` 包含：
  ```gdscript
  await get_tree().create_timer(1.0).timeout
  assert_eq(label.text, "Ready")
  ```
- 使用 1 秒实时等待，而不是模拟对象或基于信号的断言

**输入：** `/test-evidence-review tests/unit/ui/hud_update_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测实时等待（`create_timer(1.0)`），即非确定性的时间依赖
3. 技能将其标记为 FAIL 级别的问题
4. 结论为 FAIL
5. 技能建议将计时器替换为基于信号的断言或模拟对象

**断言：**
- [ ] 检测到实时等待，并将其识别为非确定性的时间依赖
- [ ] 问题分类为 FAIL 严重级别（阻塞性问题，违反确定性标准）
- [ ] 结论为 FAIL
- [ ] 修复建议提到基于信号或基于模拟对象的方法
- [ ] 技能不编辑测试文件

---

### 用例 3：失败——测试直接调用外部 API

**测试夹具：**
- `tests/unit/networking/auth_test.gd` 包含：
  ```gdscript
  var result = HTTPRequest.new().request("https://api.example.com/auth")
  ```
- 直接调用外部 API，没有使用模拟对象

**输入：** `/test-evidence-review tests/unit/networking/auth_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测直接调用外部 API（向真实 URL 发起 HTTPRequest）
3. 技能将其标记为 FAIL 级别的问题，违反隔离标准
4. 结论为 FAIL
5. 技能建议注入模拟 HTTP 客户端

**断言：**
- [ ] 检测并标记直接调用外部 API
- [ ] 问题分类为 FAIL 严重级别（违反隔离标准）
- [ ] 结论为 FAIL
- [ ] 修复建议涉及依赖注入和模拟 HTTP 客户端
- [ ] 技能不修改测试文件

---

### 用例 4：边界情况——未找到测试文件

**测试夹具：**
- 用户调用 `/test-evidence-review tests/unit/audio/`
- `tests/unit/audio/` 目录不存在

**输入：** `/test-evidence-review tests/unit/audio/`

**预期行为：**
1. 技能尝试读取 `tests/unit/audio/` 中的文件，但找不到文件
2. 技能输出：“在 `tests/unit/audio/` 中未找到测试文件，请运行 `/test-setup` 创建测试目录”
3. 不输出结论

**断言：**
- [ ] 路径不存在时技能不崩溃
- [ ] 输出信息包含尝试访问的路径
- [ ] 输出建议运行 `/test-setup` 创建目录
- [ ] 没有可审查内容时不输出结论

---

### 用例 5：门禁合规——不调用门禁；QL-TEST-COVERAGE 独立处理

**测试夹具：**
- 测试文件包含 1 个 WARNINGS 级别的问题（非边界测试中的魔法数字）
- `review-mode.txt` 包含 `full`

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能审查测试，发现 1 个 WARNINGS 级别的问题
2. 不调用总监门禁（QL-TEST-COVERAGE 单独调用，不在此处调用）
3. 结论为 WARNINGS
4. 输出说明：“如需完整测试覆盖率门禁，请运行会调用 QL-TEST-COVERAGE 的 `/gate-check`”
5. 技能提供可选的报告写入；如果用户选择写入，则询问 "May I write"

**断言：**
- [ ] 任何审查模式下都不调用总监门禁
- [ ] 输出区分本技能与 QL-TEST-COVERAGE 门禁调用
- [ ] 可选报告必须在写入前询问 "May I write"
- [ ] 对建议级测试质量问题，结论为 WARNINGS

---

## 协议合规性

- [ ] 审查测试文件前读取 `coding-standards.md` 中的测试标准
- [ ] 检查命名、Arrange/Act/Assert 结构、确定性、隔离和无硬编码数据
- [ ] 不编辑任何测试文件（只读技能）
- [ ] 不调用总监门禁
- [ ] 结论为以下之一：PASS、WARNINGS、FAIL

---

## 覆盖说明

- 未明确测试审查 `tests/` 中的全部文件；假定按文件执行相同检查并汇总结论。
- QL-TEST-COVERAGE 总监门禁负责检查测试覆盖率百分比，属于独立职责，明确不由此技能调用。
