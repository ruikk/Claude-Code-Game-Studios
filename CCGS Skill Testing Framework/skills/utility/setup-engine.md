# 技能测试规范：/setup-engine

## 技能摘要

`/setup-engine` 通过填充 `technical-preferences.md` 配置项目的引擎、语言、渲染后端、物理引擎、专家代理分配和命名约定。它接受可选的引擎参数（例如 `/setup-engine godot`）以跳过引擎选择步骤。对于 `technical-preferences.md` 的每个章节，技能都会展示草稿并询问
更新前询问“May I write to `technical-preferences.md`?”。

技能还会根据所选引擎填充专家路由表（文件扩展名 → 代理映射）。它没有主管门禁，因为配置属于技术工具任务。文件完整写入后，判定结果始终为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：COMPLETE
- [ ] 更新 technical-preferences.md 前包含“May I write”协作协议措辞
- [ ] 包含下一步交接说明（根据流程使用 `/brainstorm` 或 `/start`）

---

## 主管门禁检查

无。`/setup-engine` 是技术配置技能，不适用主管门禁。

---

## 测试用例

### 用例 1：Godot 4 + GDScript：完整引擎配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 已提供引擎参数：`godot`

**输入：** `/setup-engine godot`

**预期行为：**
1. 技能跳过引擎选择步骤（已提供参数）
2. 技能展示 Godot 的语言选项：GDScript 或 C#
3. 用户选择 GDScript
4. 技能起草所有引擎章节：引擎/语言/渲染/物理字段、命名约定（GDScript 使用 snake_case）和专家分配（godot-specialist、gdscript-specialist、godot-shader-specialist 等）
5. 技能填充路由表：`.gd` → gdscript-specialist，`.gdshader` → godot-shader-specialist，`.tscn` → godot-specialist
6. 技能询问“May I write to `technical-preferences.md`?”
7. 获得批准后写入文件；判定结果为 COMPLETE

**断言：**
- [ ] 引擎字段设置为 Godot 4（不是占位符）
- [ ] 语言字段设置为 GDScript
- [ ] 命名约定符合 GDScript（snake_case）
- [ ] 路由表包含 `.gd`、`.gdshader` 和 `.tscn` 条目
- [ ] 已分配专家（不是占位符）
- [ ] 写入前询问“May I write”
- [ ] 判定结果为 COMPLETE

---

### 用例 2：Unity + C#：Unity 专用配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 已提供引擎参数：`unity`

**输入：** `/setup-engine unity`

**预期行为：**
1. 技能将引擎设置为 Unity，语言设置为 C#
2. 命名约定符合 C#（类使用 PascalCase，字段使用 camelCase）
3. 专家分配引用 unity-specialist、csharp-specialist
4. 路由表：`.cs` → csharp-specialist，`.asmdef` → unity-specialist，`.unity`（场景）→ unity-specialist
5. 技能询问“May I write to `technical-preferences.md`?”并在获得批准后写入

**断言：**
- [ ] 引擎字段设置为 Unity（不是 Godot 或 Unreal）
- [ ] 语言字段设置为 C#
- [ ] 命名约定体现 C# 规范
- [ ] 路由表包含 `.cs` 和 `.unity` 条目
- [ ] 判定结果为 COMPLETE

---

### 用例 3：Unreal + Blueprint：Unreal 专用配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 已提供引擎参数：`unreal`

**输入：** `/setup-engine unreal`

**预期行为：**
1. 技能将引擎设置为 Unreal Engine 5，主要语言设置为 Blueprint（可视化脚本）
2. 专家分配引用 unreal-specialist、blueprint-specialist
3. 路由表：`.uasset` → blueprint-specialist 或 unreal-specialist，`.umap` → unreal-specialist
4. 性能预算预设为 Unreal 默认值（例如更高的 draw call 预算）
5. 技能询问“May I write”，并在获得批准后写入；判定结果为 COMPLETE

**断言：**
- [ ] 引擎字段设置为 Unreal Engine 5
- [ ] 路由表包含 `.uasset` 和 `.umap` 条目
- [ ] 已分配 Blueprint specialist
- [ ] 判定结果为 COMPLETE

---

### 用例 4：引擎已配置：提供特定章节的重新配置选项

**测试夹具：**
- `technical-preferences.md` 已将引擎设置为 Godot 4，且所有字段均已填充
- 未提供引擎参数

**输入：** `/setup-engine`

**预期行为：**
1. 技能读取 `technical-preferences.md`，检测到引擎已完整配置（Godot 4）
2. 技能报告：“引擎已配置为 Godot 4 + GDScript”
3. 技能提供选项：全部重新配置，或仅重新配置特定章节（引擎/语言、命名约定、专家代理、性能预算）
4. 用户选择“仅重新配置性能预算”
5. 只更新性能预算章节，其他字段保持不变
6. 技能询问“May I write to `technical-preferences.md`?”并在获得批准后写入

**断言：**
- [ ] 仅请求更新一个章节时，技能不会覆盖所有字段
- [ ] 向用户提供按章节重新配置的选项
- [ ] 写入文件中只有选定章节被修改
- [ ] 判定结果为 COMPLETE

---

### 用例 5：主管门禁检查：无门禁，setup-engine 是工具技能

**测试夹具：**
- 尚未配置引擎的新项目

**输入：** `/setup-engine godot`

**预期行为：**
1. 技能完成完整引擎配置
2. 全程不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 不经过门禁检查也能得到 COMPLETE 判定

---

## 协议合规性

- [ ] 询问写入前展示配置草稿
- [ ] 写入前询问“May I write to `technical-preferences.md`?”
- [ ] 提供引擎参数时遵守该参数（跳过选择步骤）
- [ ] 检测现有配置并提供局部重新配置选项
- [ ] 为所选引擎的所有关键文件类型填充路由表
- [ ] 文件写入后判定结果为 COMPLETE

---

## 覆盖说明

- Godot 4 + C#（而不是 GDScript）遵循与用例 1 相同的流程，但使用不同的命名约定并分配 godot-csharp-specialist。此变体未单独测试。
- 技能会呈现特定引擎版本的指导（例如 VERSION.md 中关于 Godot 4.6 知识缺口的警告），但此处不对其进行断言测试。
- 各引擎的性能预算默认值标记为引擎专用，但不对具体默认值进行断言测试。
