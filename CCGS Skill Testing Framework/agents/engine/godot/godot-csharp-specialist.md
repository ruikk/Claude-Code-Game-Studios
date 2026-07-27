# 代理测试规范：godot-csharp-specialist

## 代理摘要
领域：Godot 4 中的 C# 模式、应用于 Godot 的 .NET 惯用法、[Export] 特性用法、信号委托和 async/await 模式。
不负责：GDScript 代码（gdscript-specialist）、GDExtension C/C++ 绑定（gdextension-specialist）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段且内容针对本领域（提及 Godot 4 中的 C#、.NET 模式或信号委托）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家的默认层级）
- [ ] 代理定义未声称负责 GDScript 或 GDExtension 代码

---

## 测试用例

### 用例 1：领域内请求，输出适当
**输入：**“为敌人生命值创建一个导出属性，通过验证将其限制在 1 到 1000 之间。”
**预期行为：**
- 生成带 `[Export]` 特性的 C# 属性
- 使用后备字段以及属性 getter/setter，并在 setter 中限制值的范围
- 不使用没有验证的原始 `[Export]` 公共字段
- 遵循 Godot 4 C# 命名约定（属性使用 PascalCase，字段为以下划线开头的私有成员）
- 根据编码标准为属性添加 XML 文档注释

### 用例 2：领域外请求，正确重定向
**输入：**“使用 GDScript 重写这个敌人生命值系统。”
**预期行为：**
- 不生成 GDScript 代码
- 明确说明 GDScript 编写属于 `godot-gdscript-specialist` 的职责
- 将请求重定向给 `godot-gdscript-specialist`
- 可以说明可描述 C# 接口，以便 gdscript-specialist 了解预期的 API 形式

### 用例 3：异步等待信号
**输入：**“使用 C# async 等待动画结束后再转换游戏状态。”
**预期行为：**
- 生成正确的 `async Task` 模式，使用 `ToSignal()` 等待 Godot 信号
- 使用 `await ToSignal(animationPlayer, AnimationPlayer.SignalName.AnimationFinished)`
- 不使用 `Thread.Sleep()` 或 `Task.Delay()` 代替轮询
- 说明调用方法必须为 `async`，且即发即弃的 `async void` 仅适用于事件处理程序
- 如果动画可能无法触发信号，则处理取消或超时

### 用例 4：线程模型冲突
**输入：**“这段 C# 代码从后台 Task 线程访问 Godot Node 并更新其位置。”
**预期行为：**
- 将其标记为竞态条件风险：Godot 节点并非线程安全，只能从主线程访问
- 不批准或实现多线程节点访问模式
- 提供正确模式：使用 `CallDeferred()`、`Callable.From().CallDeferred()`，或通过线程安全队列封送回主线程
- 解释 Godot 的主线程要求与 .NET 线程无关类型之间的区别

### 用例 5：上下文传递，Godot 4.6 API 正确性
**输入：**引擎版本上下文：Godot 4.6。请求：“使用新的类型化信号委托模式连接信号。”
**预期行为：**
- 使用 Godot 4 C# 中引入的类型化委托模式生成 C# 信号连接（对类型化信号使用 `+=` 运算符）
- 检查 4.6 上下文，确认信号委托 API 在 4.4、4.5 或 4.6 中没有破坏性变更
- 不使用旧的基于字符串的 `Connect("signal_name", callable)` 模式（已在 Godot 4 C# 中弃用）
- 根据 VERSION.md 中的文档，生成与项目锁定的 4.6 版本兼容的代码

---

## 协议合规性

- [ ] 始终处于声明的领域内（Godot 4 中 C# 的模式、导出、信号、异步）
- [ ] 将 GDScript 请求重定向给 godot-gdscript-specialist
- [ ] 将 GDExtension 请求重定向给 godot-gdextension-specialist
- [ ] 返回遵循 Godot 4 约定的 C# 代码（而不是 Unity MonoBehaviour 模式）
- [ ] 将多线程访问 Godot 节点标记为不安全，并提供正确模式
- [ ] 使用类型化信号委托，而不是已弃用的基于字符串的 Connect() 调用
- [ ] 生成代码前检查引擎版本参考中的 API 变更

---

## 覆盖说明
- 带验证的导出属性（用例 1）应有单元测试验证范围限制行为
- 线程冲突（用例 4）涉及安全关键问题：代理必须在无需提示的情况下识别并修复它
- 异步信号（用例 3）用于验证代理在 Godot 单线程约束下正确应用 .NET 惯用法
