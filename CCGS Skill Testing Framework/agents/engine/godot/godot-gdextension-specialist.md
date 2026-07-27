# 代理测试规范：godot-gdextension-specialist

## 代理摘要
领域：GDExtension API、godot-cpp C++ 绑定、godot-rust 绑定、原生库集成和原生性能优化。
不负责：GDScript 代码（gdscript-specialist）、着色器代码（godot-shader-specialist）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段且内容针对本领域（提及 GDExtension、godot-cpp 或原生绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家的默认层级）
- [ ] 代理定义未声称负责 GDScript 或着色器编写

---

## 测试用例

### 用例 1：领域内请求，输出适当
**输入：**“通过 GDExtension 将 C++ 刚体物理模拟库公开给 GDScript。”
**预期行为：**
- 使用 godot-cpp 生成 GDExtension 绑定模式：
  - 类继承自 `godot::Object` 或适当的 Godot 基类
  - 使用 `GDCLASS` 宏注册
  - 实现 `_bind_methods()`，将物理 API 公开给 GDScript
  - 设置 `GDExtension` 入口点（`gdextension_init`）
- 说明所需的 `.gdextension` 清单文件格式
- 不生成 GDScript 使用代码（该职责属于 gdscript-specialist）

### 用例 2：领域外请求重定向
**输入：**“编写调用用例 1 中物理模拟的 GDScript。”
**预期行为：**
- 不生成 GDScript 代码
- 明确说明 GDScript 编写属于 `godot-gdscript-specialist` 的职责
- 重定向给 `godot-gdscript-specialist`
- 可以将 GDScript 应调用的 API 表面（方法名、参数类型）描述为交接规范

### 用例 3：ABI 兼容性风险，次版本更新
**输入：**“我们正从 Godot 4.5 升级到 4.6。现有 GDExtension 还能工作吗？”
**预期行为：**
- 标记 ABI 兼容性问题：GDExtension 二进制文件在不同次版本之间可能不兼容
- 指示查阅 4.5→4.6 迁移指南中的 GDExtension API 变更
- 建议依据 4.6 godot-cpp 头文件重新编译扩展，而不是假定二进制兼容
- 说明 `.gdextension` 清单可能需要更新 `compatibility_minimum` 版本
- 提供重新编译清单

### 用例 4：内存管理，Godot 对象的 RAII
**输入：**“应如何管理在 C++ GDExtension 代码中创建的 Godot 对象的生命周期？”
**预期行为：**
- 为 GDExtension 中的 Godot 对象生成基于 RAII 的生命周期模式：
  - 对引用计数对象使用 `Ref<T>`（Ref 离开作用域时自动释放）
  - 对非引用计数对象使用 `memnew()` / `memdelete()`
  - 警告：不要对 Godot 对象使用 `new`/`delete`，否则会产生未定义行为
- 说明对象所有权规则：谁负责释放已添加到场景树的节点
- 提供管理在 C++ 中创建的 `CollisionShape3D` 的具体示例

### 用例 5：上下文传递，Godot 4.6 GDExtension API 检查
**输入：**引擎版本上下文：Godot 4.6（从 4.5 升级）。请求：“检查 GDExtension API 从 4.5 到 4.6 是否发生变化。”
**预期行为：**
- 引用 VERSION.md 已验证来源列表中的 4.5→4.6 迁移指南
- 报告 4.6 版本中记录的所有 GDExtension API 变更
- 如果文档未记录 GDExtension 在 4.6 中存在破坏性变更，应明确说明，同时提醒依据官方变更日志进行验证
- 标记 Windows 默认使用 D3D12（4.6 变更）可能与 GDExtension 渲染代码有关
- 提供升级后的验证清单

---

## 协议合规性

- [ ] 始终处于声明的领域内（GDExtension、godot-cpp、godot-rust、原生绑定）
- [ ] 将 GDScript 编写重定向给 godot-gdscript-specialist
- [ ] 将着色器编写重定向给 godot-shader-specialist
- [ ] 返回结构化输出（绑定模式、RAII 示例、ABI 清单）
- [ ] 标记次版本升级时的 ABI 兼容性风险，绝不假定二进制兼容
- [ ] 使用 Godot 专用内存管理（`memnew`/`memdelete`、`Ref<T>`），而不是原始 C++ new/delete
- [ ] 在确认兼容性之前，检查引擎版本参考中的 GDExtension API 变更

---

## 覆盖说明
- 绑定模式（用例 1）应包含冒烟测试，以验证扩展可以加载且方法可从 GDScript 调用
- ABI 风险（用例 3）是关键升级路径，代理不得批准发布未经验证的扩展二进制文件
- 内存管理（用例 4）用于验证代理采用 Godot 专用模式，而不是通用 C++ RAII
