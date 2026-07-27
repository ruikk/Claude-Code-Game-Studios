# 技能测试规范：/test-helpers

## 技能摘要

`/test-helpers` 为项目测试套件生成引擎专用的测试辅助工具。辅助工具包括工厂函数（用于创建具有已知状态的测试实体）、测试夹具加载器、断言辅助函数以及外部依赖的模拟存根。生成的辅助工具遵循 `coding-standards.md` 中的命名和结构约定，并写入 `tests/helpers/`。

每个辅助工具文件都必须先询问“May I write”。如果辅助工具文件已存在，技能会提供扩展而不是替换的选项。不适用任何 director 门禁。辅助工具文件写入后，判定为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：COMPLETE
- [ ] 在写入辅助工具前包含“May I write”协作协议措辞
- [ ] 包含后续步骤交接（例如使用生成的辅助工具编写测试）

---

## Director 门禁检查

无。`/test-helpers` 是脚手架工具，不适用任何 director 门禁。

---

## 测试用例

### 用例 1：成功路径——为 Godot/GDScript 生成玩家工厂辅助工具

**测试夹具：**
- `technical-preferences.md` 中的引擎为 Godot 4，语言为 GDScript
- `tests/` 目录存在（已运行 test-setup）
- `design/gdd/player.md` 存在并定义了玩家属性
- `tests/helpers/` 中没有现有辅助工具

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能读取引擎（Godot 4 / GDScript）和玩家 GDD，获取属性上下文
2. 技能用 GDScript 生成确定性的 `PlayerFactory` 辅助工具：
   - `create_player(health: int = 100, speed: float = 200.0)` 函数
   - 返回预先配置为已知状态的玩家节点
   - 使用依赖注入（不使用单例）
3. 技能询问“可以写入 `tests/helpers/player_factory.gd` 吗？”
4. 获得批准后写入文件，判定为 COMPLETE

**断言：**
- [ ] 生成的辅助工具使用 GDScript（不是 C# 或 Blueprint）
- [ ] 工厂函数参数使用与 GDD 值匹配的默认值
- [ ] 辅助工具使用依赖注入（不引用 Autoload/单例）
- [ ] 文件名遵循 GDScript 的 snake_case 约定
- [ ] 判定为 COMPLETE

---

### 用例 2：不存在测试设置——转到 /test-setup

**测试夹具：**
- `tests/` 目录不存在

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能检查 `tests/` 目录，未找到
2. 技能报告：“未找到测试目录，必须先设置测试框架”
3. 技能建议在生成辅助工具前运行 `/test-setup`
4. 不创建辅助工具文件

**断言：**
- [ ] 错误消息指出缺失的 tests/ 目录
- [ ] 建议 `/test-setup` 作为前置步骤
- [ ] 不调用写入工具
- [ ] 判定不是 COMPLETE（阻塞状态）

---

### 用例 3：辅助工具已存在——提供扩展而不是替换选项

**测试夹具：**
- `tests/helpers/player_factory.gd` 已存在并包含 `create_player()` 函数
- 用户请求向工厂添加新的 `create_enemy()` 函数

**输入：** `/test-helpers enemy-factory`

**预期行为：**
1. 技能找到现有的 `player_factory.gd`，检查它是否适合扩展（或是否应创建单独的 `enemy_factory.gd`）
2. 技能提供选项：向现有工厂添加 `create_enemy()`，或创建 `tests/helpers/enemy_factory.gd`
3. 用户选择扩展，技能起草 `create_enemy()` 函数
4. 技能询问“可以扩展 `tests/helpers/player_factory.gd` 吗？”
5. 获得批准后添加函数，判定为 COMPLETE

**断言：**
- [ ] 检测并显示现有辅助工具
- [ ] 向用户提供扩展或新建文件的选择
- [ ] 使用扩展许可措辞（`May I extend`），而不是针对替换使用写入许可措辞（`May I write`）
- [ ] 扩展后的文件保留现有的 `create_player()`
- [ ] 判定为 COMPLETE

---

### 用例 4：系统没有 GDD——在辅助工具中记录缺失的设计上下文

**测试夹具：**
- `technical-preferences.md` 中为 Godot 4 / GDScript
- `tests/` 存在
- 用户请求“库存系统”的辅助工具，但不存在 `design/gdd/inventory.md`

**输入：** `/test-helpers inventory-factory`

**预期行为：**
1. 技能查找 `design/gdd/inventory.md`，未找到
2. 技能记录：“未找到库存系统的 GDD，将使用占位默认值生成辅助工具”
3. 技能使用通用占位值生成 `inventory_factory.gd`（item_count = 0、max_capacity = 20），并添加注释：“# TODO: 编写库存 GDD 后使默认值保持一致”
4. 技能询问“可以写入 `tests/helpers/inventory_factory.gd` 吗？”
5. 写入文件，判定为 COMPLETE，并附带提示

**断言：**
- [ ] 没有 GDD 时技能继续执行，而不是阻塞
- [ ] 生成的辅助工具包含带 TODO 注释的占位默认值
- [ ] 输出中记录缺失的 GDD（提示性警告）
- [ ] 判定为 COMPLETE

---

### 用例 5：Director 门禁检查——无门禁；test-helpers 是脚手架工具

**测试夹具：**
- 引擎已配置，tests/ 存在

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能生成并写入辅助工具文件
2. 不生成任何 director 代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用 director 门禁
- [ ] 不出现跳过门禁的消息
- [ ] 不经过任何门禁检查并判定为 COMPLETE

---

## 协议合规性

- [ ] 生成任何辅助工具前读取引擎（辅助工具与引擎相关）
- [ ] 有 GDD 时读取其中的默认值
- [ ] 记录缺失的 GDD 上下文，而不是阻塞
- [ ] 检测现有辅助工具文件，并提供扩展而不是替换选项
- [ ] 进行任何文件操作前询问写入许可（`May I write`）或扩展许可（`May I extend`）
- [ ] 辅助工具写入后判定为 COMPLETE

---

## 覆盖说明

- 模拟/存根辅助工具生成（用于存档系统或音频总线等依赖）遵循与工厂辅助工具相同的模式，这里没有单独测试。
- Unity C# 辅助工具生成（使用 NSubstitute 或自定义模拟）遵循用例 1 的相同逻辑，并输出适合该语言的内容。
- 请求的辅助工具类型无法识别的情况没有测试；技能会要求用户澄清辅助工具类型。
