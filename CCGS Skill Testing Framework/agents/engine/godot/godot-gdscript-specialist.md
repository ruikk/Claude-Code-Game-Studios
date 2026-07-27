# 代理测试规范：godot-gdscript-specialist

## 代理摘要
领域：GDScript 静态类型、GDScript 设计模式、信号架构、协程/await 模式和 GDScript 性能。
不负责：着色器代码（godot-shader-specialist）、GDExtension 绑定（godot-gdextension-specialist）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段且内容针对本领域（提及 GDScript、静态类型、信号或协程）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家的默认层级）
- [ ] 代理定义未声称负责着色器代码或 GDExtension

---

## 测试用例

### 用例 1：领域内请求，输出适当
**输入：**“审查此 GDScript 文件的类型注解覆盖情况。”
**预期行为：**
- 读取提供的 GDScript 文件
- 标记缺少静态类型注解的每个变量、参数和返回类型
- 逐行列出具体发现：`var speed = 5.0` → `var speed: float = 5.0`
- 说明静态类型在 Godot 4 中带来的性能和工具支持优势
- 未经要求时不重写整个文件，而是生成发现列表供开发者应用

### 用例 2：领域外请求，正确重定向
**输入：**“编写一个顶点着色器，在世界空间中扭曲网格。”
**预期行为：**
- 不使用 GDScript 或 Godot 着色语言生成着色器代码
- 明确说明着色器编写属于 `godot-shader-specialist` 的职责
- 将请求重定向给 `godot-shader-specialist`
- 可以说明 GDScript 侧的工作（向着色器传递 uniform、设置着色器参数）属于自身领域

### 用例 3：使用协程异步加载
**输入：**“异步加载场景，等待加载完成后再实例化。”
**预期行为：**
- 为 Godot 4 生成 `await` + `ResourceLoader.load_threaded_request` 模式
- 全程使用静态类型（`var scene: PackedScene`）
- 使用 `ResourceLoader.load_threaded_get_status()` 处理完成状态检查
- 说明加载失败时的错误处理
- 不使用已弃用的 Godot 3 `yield()` 语法

### 用例 4：性能问题，建议使用类型化数组
**输入：**“实体更新循环很慢；它每帧遍历一个包含 1,000 个节点的无类型 Array。”
**预期行为：**
- 识别出无类型 `Array` 会使 GDScript 无法利用编译器优化
- 建议转换为类型化数组（`Array[Node]` 或具体类型）以启用 JIT 提示
- 说明如果这样仍然不够，应升级为将热点路径迁移到 C# 的建议
- 生成类型化数组重构作为即时修复
- 没有性能分析证据时，不建议将整个代码库迁移到 C#

### 用例 5：上下文传递，Godot 4.6 及知识截止日期后的功能
**输入：**已提供引擎版本上下文：Godot 4.6。请求：“使用 @abstract 为所有敌人类型创建一个抽象基类。”
**预期行为：**
- 识别出 `@abstract` 是 Godot 4.5+ 功能（晚于知识截止日期）
- 在输出中说明：此功能在 4.5 中引入，已依据 VERSION.md 迁移说明验证
- 使用 `@abstract` 生成 GDScript 类，语法应与迁移说明中的文档一致
- 由于此功能晚于知识截止日期，将输出标记为需要依据官方 4.5 发布说明进行验证
- 对抽象类中的所有方法签名使用静态类型

---

## 协议合规性

- [ ] 始终处于声明的领域内（GDScript 的类型、模式、信号、协程、性能）
- [ ] 将着色器请求重定向给 godot-shader-specialist
- [ ] 将 GDExtension 请求重定向给 godot-gdextension-specialist
- [ ] 返回完全使用静态类型的结构化 GDScript 输出
- [ ] 仅使用 Godot 4 API，不使用已弃用的 Godot 3 模式（yield、使用字符串的 connect 等）
- [ ] 标记知识截止日期后的功能（4.4、4.5、4.6），并注明需要查阅文档验证

---

## 覆盖说明
- 类型注解审查（用例 1）的输出适合用作代码审查清单
- 异步加载（用例 3）应生成可测试的代码，并能通过 `tests/unit/` 中的单元测试验证
- 知识截止日期后的 @abstract（用例 5）用于确认代理会标记版本不确定性，而不是直接使用未经验证的 API
