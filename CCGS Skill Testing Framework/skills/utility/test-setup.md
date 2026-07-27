# 技能测试规范：/test-setup

## 技能摘要

`/test-setup` 根据已配置的引擎为项目搭建测试框架。它创建 `coding-standards.md` 定义的 `tests/` 目录结构（unit/、integration/、performance/、playtest/），并为检测到的引擎生成适当的测试 runner 配置：Godot 使用 GdUnit4 配置，Unity 使用 Unity Test Runner asmdef，Unreal Engine 使用 Unreal headless runner。

每个要创建的文件或目录都必须先询问“May I write”。如果测试框架已经存在，技能会验证配置，而不是重新初始化。不适用任何 director 门禁。脚手架就绪后，判定为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：COMPLETE
- [ ] 在创建文件前包含“May I write”协作协议措辞
- [ ] 包含后续步骤交接（例如使用 `/test-helpers` 生成辅助工具）

---

## Director 门禁检查

无。`/test-setup` 是脚手架工具，不适用任何 director 门禁。

---

## 测试用例

### 用例 1：成功路径——Godot 项目，搭建 GdUnit4 测试结构

**测试夹具：**
- `technical-preferences.md` 中的引擎为 Godot 4，语言为 GDScript
- `tests/` 目录尚不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能从 `technical-preferences.md` 读取引擎 → Godot 4 + GDScript
2. 技能起草测试目录结构：tests/unit/、tests/integration/、tests/performance/、tests/playtest/，以及 GdUnit4 runner 配置文件
3. 技能询问“可以写入 tests/ 目录结构吗？”
4. 获得批准后创建目录和 GdUnit4 runner 脚本
5. 技能确认 runner 脚本与 coding-standards.md 中的 CI 命令一致：`godot --headless --script tests/gdunit4_runner.gd`
6. 判定为 COMPLETE

**断言：**
- [ ] 创建全部 4 个子目录（unit/、integration/、performance/、playtest/）
- [ ] 生成 GdUnit4 runner 配置
- [ ] runner 脚本路径与 coding-standards.md CI 命令一致
- [ ] 创建任何文件前询问写入许可（`May I write`）
- [ ] 判定为 COMPLETE

---

### 用例 2：Unity 项目——使用 asmdef 搭建 Unity Test Runner

**测试夹具：**
- `technical-preferences.md` 中的引擎为 Unity，语言为 C#
- `tests/` 目录不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能读取引擎 → Unity + C#
2. 技能按照 Unity 约定创建大写的 `Tests/` 目录
3. 技能生成 `Tests/Tests.asmdef` 和 `Tests/Editor/EditorTests.asmdef`
4. 配置 EditMode 和 PlayMode 测试 runner 模式
5. 技能询问“可以写入 Tests/ 目录结构吗？”
6. 判定为 COMPLETE

**断言：**
- [ ] 创建 Unity 专用的 `Tests/` 结构，而不是 Godot 结构
- [ ] 生成 `.asmdef` 文件
- [ ] 存在 EditMode 和 PlayMode runner 配置
- [ ] 判定为 COMPLETE

---

### 用例 3：测试框架已存在——验证配置，而不是重新初始化

**测试夹具：**
- `tests/unit/`、`tests/integration/` 存在
- GdUnit4 runner 脚本存在（Godot 项目）

**输入：** `/test-setup`

**预期行为：**
1. 技能检测现有的 tests/ 结构
2. 技能报告：“测试框架已存在，正在验证配置”
3. 技能检查 runner 脚本路径、目录完整性和 CI 命令一致性
4. 如果所有检查通过，报告“配置已验证，无需更改”
5. 如果检查失败（例如缺少 tests/performance/），报告具体缺口并询问“可以添加缺失的目录吗？”

**断言：**
- [ ] 框架存在时技能不会重新初始化
- [ ] 对现有结构执行验证检查
- [ ] 只有缺失部分才触发写入许可（`May I write`）询问
- [ ] 无论原本正常还是修复了缺口，判定均为 COMPLETE

---

### 用例 4：没有配置引擎——转到 /setup-engine

**测试夹具：**
- `technical-preferences.md` 只包含占位符（未设置引擎）

**输入：** `/test-setup`

**预期行为：**
1. 技能读取 `technical-preferences.md` 并发现引擎占位符
2. 技能报告：“引擎未配置，无法搭建引擎专用测试框架”
3. 技能建议先运行 `/setup-engine`
4. 不创建目录或文件

**断言：**
- [ ] 错误消息明确说明引擎未配置
- [ ] 建议 `/setup-engine` 作为下一步
- [ ] 不调用写入工具
- [ ] 判定不是 COMPLETE（阻塞状态）

---

### 用例 5：Director 门禁检查——无门禁；test-setup 是脚手架工具

**测试夹具：**
- 引擎已配置，tests/ 不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能搭建并写入所有测试框架文件
2. 不生成任何 director 代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用 director 门禁
- [ ] 不出现跳过门禁的消息
- [ ] 不经过任何门禁检查并判定为 COMPLETE

---

## 协议合规性

- [ ] 生成任何脚手架前从 `technical-preferences.md` 读取引擎
- [ ] 生成适合引擎的测试 runner 配置，而不是通用配置
- [ ] 创建 coding-standards.md 中的全部 4 个子目录
- [ ] 创建文件前询问写入许可（`May I write`）
- [ ] 检测现有框架并提供验证，而不是重新初始化
- [ ] 脚手架就绪后判定为 COMPLETE

---

## 覆盖说明

- Unreal Engine 测试脚手架（带 `-nullrhi` 的 headless runner）遵循用例 1 和用例 2 的相同模式，这里没有单独设置测试夹具。
- CI 集成文件生成（例如 `.github/workflows/test.yml`）虽被引用，但这里没有通过断言测试；它可能属于其他技能的范围。
- tests/ 存在但来自不同引擎的情况（例如现在是 Godot 项目却有 Unity 测试）没有测试；技能会检测不匹配并提供协调选项。
