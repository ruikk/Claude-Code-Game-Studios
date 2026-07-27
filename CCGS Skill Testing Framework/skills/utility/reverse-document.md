# 技能测试规范：/reverse-document

## 技能摘要

`/reverse-document` 从现有源代码生成设计或架构文档。它读取指定的源文件，根据类结构、方法名、常量和注释推断设计意图，并生成 GDD 骨架（用于玩法系统）或架构概览（用于技术系统）。输出是尽力而为的推断，魔法数字和未记录的逻辑可能导致 PARTIAL 判定。

技能在创建文档前询问“May I write to [inferred path]?”。
不适用主管门禁。判定结果：COMPLETE（推断清晰）、PARTIAL（部分字段存在歧义，需要人工复核）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：COMPLETE、PARTIAL
- [ ] 写入文档前包含“May I write”协作协议措辞
- [ ] 包含下一步交接说明（例如使用 `/design-review` 验证生成的文档）

---

## 主管门禁检查

无。`/reverse-document` 是文档工具，不适用主管门禁。

---

## 测试用例

### 用例 1：结构良好的源代码：生成准确的设计文档骨架

**测试夹具：**
- `src/gameplay/health_system.gd` 存在并包含：
  - `@export var max_health: int = 100`
  - `func take_damage(amount: int)` 及其限制逻辑
  - `signal health_changed(new_value: int)`
   - 所有公共方法均有文档字符串

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. 技能读取源文件并识别生命值系统
2. 技能推断设计意图：最大生命值、take_damage 行为、生命值信号
3. 技能为生命值系统生成包含 8 个必需章节的 GDD 骨架：
   Overview, Player Fantasy, Detailed Rules, Formulas, Edge Cases, Dependencies,
   Tuning Knobs, Acceptance Criteria
4. Formulas 章节包含推断出的限制公式
5. Tuning Knobs 章节将 `max_health = 100` 标记为可配置值
6. 技能询问“May I write to `design/gdd/health-system.md`?”
7. 写入文件；判定结果为 COMPLETE

**断言：**
- [ ] 输出包含全部 8 个必需的 GDD 章节
- [ ] `max_health = 100` 作为 Tuning Knob 出现
- [ ] Formulas 章节记录限制公式
- [ ] 使用推断路径询问“May I write”
- [ ] 判定结果为 COMPLETE

---

### 用例 2：源代码存在歧义：魔法数字导致 PARTIAL 判定

**测试夹具：**
- `src/gameplay/enemy_ai.gd` 存在并包含：
  - 内联魔法数字：`if distance < 150:`、`speed = 3.5`
  - 没有注释或 docstring
  - 不易自解释的复杂状态机逻辑

**输入：** `/reverse-document src/gameplay/enemy_ai.gd`

**预期行为：**
1. 技能读取文件并检测没有上下文的魔法数字
2. 技能生成带有以下注释的 GDD 骨架：“AMBIGUOUS VALUE: 150（单位未知，是像素、世界单位还是瓦片？）”
3. 技能将 Formulas 和 Tuning Knobs 章节标记为需要人工复核
4. 技能带着 PARTIAL 提示询问“May I write to `design/gdd/enemy-ai.md`?”
5. 写入带有 PARTIAL 标记的文件；判定结果为 PARTIAL

**断言：**
- [ ] 魔法数字出现 AMBIGUOUS VALUE 注释
- [ ] 明确标记需要人工复核的章节
- [ ] 判定结果为 PARTIAL（不是 COMPLETE）
- [ ] 仍然写入文件，PARTIAL 不是阻塞性失败

---

### 用例 3：多个相互依赖的文件：生成跨系统概览

**测试夹具：**
- 用户提供 2 个源文件：`combat_system.gd` 和 `damage_resolver.gd`
- 两个文件相互引用（combat 调用 damage_resolver）

**输入：** `/reverse-document src/gameplay/combat_system.gd src/gameplay/damage_resolver.gd`

**预期行为：**
1. 技能读取两个文件并检测依赖关系
2. 技能生成跨系统架构概览（不是分别生成 GDD）
3. 概览描述 Combat System → Damage Resolver 的交互、共享接口以及二者之间的数据流
4. 技能询问“May I write to `docs/architecture/combat-damage-overview.md`?”
5. 获得批准后写入概览；判定结果为 COMPLETE（存在歧义时为 PARTIAL）

**断言：**
- [ ] 两个文件作为整体分析（不是分别生成两个文档）
- [ ] 输出记录跨系统依赖
- [ ] 输出文件写入 `docs/architecture/`（不是 `design/gdd/`）
- [ ] 判定结果为 COMPLETE 或 PARTIAL

---

### 用例 4：找不到源文件：错误

**测试夹具：**
- `src/gameplay/inventory_system.gd` 不存在

**输入：** `/reverse-document src/gameplay/inventory_system.gd`

**预期行为：**
1. 技能尝试读取指定文件，但文件不存在
2. 技能输出：“找不到源文件：src/gameplay/inventory_system.gd”
3. 技能建议检查路径，或运行 `/map-systems` 来识别正确的源文件
4. 不创建文档

**断言：**
- [ ] 错误消息使用完整路径指出缺失文件
- [ ] 提供替代建议（检查路径或使用 `/map-systems`）
- [ ] 不调用写入工具
- [ ] 不给出判定结果（错误状态）

---

### 用例 5：主管门禁检查：无门禁，reverse-document 是工具

**测试夹具：**
- 存在结构良好的源文件

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. 技能生成并写入设计文档
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定结果为 COMPLETE 或 PARTIAL，不涉及门禁判定

---

## 协议合规性

- [ ] 生成任何内容前读取源文件
- [ ] 目标为玩法系统时生成全部 8 个必需的 GDD 章节
- [ ] 使用 AMBIGUOUS VALUE 标记注释有歧义的值
- [ ] 多文件输入时生成跨系统概览（不是分别生成 GDD）
- [ ] 创建任何输出文件前询问“May I write”
- [ ] 判定结果为 COMPLETE（推断清晰）或 PARTIAL（字段有歧义）

---

## 覆盖说明

- 架构概览格式（用于技术/基础设施系统）不同于 GDD 格式；推断出的输出类型由源文件性质决定（玩法逻辑 → GDD；引擎/基础设施代码 → 架构文档）。
- 未测试源文件可读但只有自动生成样板、没有有意义逻辑的情况；技能可能生成近乎空白的骨架，并给出 PARTIAL 判定。
- C# 和 Blueprint 源文件遵循与 GDScript 相同的推断模式；语言差异由技能正文处理。
