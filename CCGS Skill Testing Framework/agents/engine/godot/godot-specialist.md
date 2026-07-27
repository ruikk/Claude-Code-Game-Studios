# 代理测试规范：godot-specialist

## 代理摘要
领域：Godot 专用模式、节点/场景架构、信号、资源，以及 GDScript、C# 与 GDExtension 的选型决策。
不负责：使用特定语言实际编写代码（委派给语言子专家）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段且内容针对本领域（提及 Godot 架构、节点模式或引擎决策）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家的默认层级）
- [ ] 代理定义将 `docs/engine-reference/godot/VERSION.md` 引用为权威 API 来源

---

## 测试用例

### 用例 1：领域内请求，输出适当
**输入：**“在 Godot 中，什么时候应该使用信号，什么时候应该直接调用方法？”
**预期行为：**
- 给出包含理由的模式决策指南：
  - 信号：解耦通信、父级无需了解子级、事件驱动的 UI 更新、一对多通知
  - 直接调用：调用者需要返回值的紧耦合系统，或性能关键的热点路径
- 结合项目上下文提供每种模式的具体示例
- 不为两种模式都直接生成原始代码，而是将实现交给 gdscript-specialist 或 csharp-specialist
- 说明“禁止向上直接调用”的约定（子级不直接调用父级方法，而是使用信号）

### 用例 2：错误引擎重定向
**输入：**“编写一个在 Start() 时运行并订阅 UnityEvent 的 MonoBehaviour。”
**预期行为：**
- 不生成 Unity MonoBehaviour 代码
- 明确指出这是 Unity 模式，而不是 Godot 模式
- 给出 Godot 中的等效方案：Node 脚本使用 `_ready()` 代替 `Start()`，使用 Godot 信号代替 UnityEvent
- 确认项目基于 Godot，并重定向概念映射

### 用例 3：知识截止日期后的 API 风险
**输入：**“使用 Godot 4.5 新增的 @abstract 注解定义一个抽象基类。”
**预期行为：**
- 识别出 `@abstract` 是知识截止日期后的功能（在 LLM 知识截止日期之后的 Godot 4.5 中引入）
- 标记版本风险：LLM 对此注解的了解可能不完整或不正确
- 指示用户依据 `docs/engine-reference/godot/VERSION.md` 和官方 4.5 迁移指南进行验证
- 根据版本参考中的迁移说明尽力提供指导，同时明确标记为未经验证

### 用例 4：热点路径的语言选择
**输入：**“物理查询循环每帧要处理 500 个对象。这里应该使用 GDScript 还是 C#？”
**预期行为：**
- 给出均衡分析：
  - GDScript：更简单、团队熟悉，但紧密循环的执行速度较慢
  - C#：执行 CPU 密集型循环更快，但需要 .NET 运行时，团队也需要具备 C# 知识
- 不单方面作出最终决定
- 将分析作为输入，把决策交给 `lead-programmer`
- 说明 GDExtension (C++) 是极端性能场景下的第三种选择，并建议在 C# 仍不够用时升级处理

### 用例 5：上下文传递，引擎版本 4.6
**输入：**已提供引擎版本上下文：Godot 4.6，默认物理引擎为 Jolt。请求：“为玩家角色设置 RigidBody3D。”
**预期行为：**
- 读取 4.6 上下文，并应用 Jolt 为默认物理引擎的信息（来自 VERSION.md 迁移说明）
- 推荐兼容 Jolt 的 RigidBody3D 配置选项（例如说明在 Jolt 下行为不同的 GodotPhysics 专用设置）
- 引用关于 Jolt 在 4.6 中成为默认物理引擎的迁移说明，而不是仅依赖 LLM 训练数据
- 标记在 GodotPhysics 与 Jolt 之间行为发生变化的所有 RigidBody3D 属性

---

## 协议合规性

- [ ] 始终处于声明的领域内（Godot 架构决策、节点/场景模式、语言选择）
- [ ] 将特定语言的实现重定向给 godot-gdscript-specialist 或 godot-csharp-specialist
- [ ] 返回结构化发现（决策树、包含理由的模式建议）
- [ ] 将 `docs/engine-reference/godot/VERSION.md` 视为比 LLM 训练数据更权威的来源
- [ ] 标记知识截止日期后的 API 用法（4.4、4.5、4.6）及其验证要求
- [ ] 存在权衡时，将语言选型决策交给 lead-programmer

---

## 覆盖说明
- 信号与直接调用指南（用例 1）应写入 `docs/architecture/`，作为可复用的模式文档
- 知识截止日期后功能的标记（用例 3）用于确认代理不会在无法验证时确信地使用 API
- 引擎版本用例（用例 5）用于验证代理会应用版本参考中的迁移说明，而不是依赖假设
