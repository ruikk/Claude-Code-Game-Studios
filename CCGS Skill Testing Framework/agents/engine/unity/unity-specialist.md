# 代理测试规范：unity-specialist

## 代理摘要
领域：Unity 特定架构模式、MonoBehaviour 与 DOTS 的选型，以及子系统选择（Addressables、New Input System、UI Toolkit、Cinemachine 等）。
不负责：特定语言或领域的深入实现（委派给 unity-dots-specialist、unity-ui-specialist 等）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对该领域（提及 Unity 模式 / MonoBehaviour / 子系统决策）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家代理的默认值）
- [ ] 代理定义认可子专家路由表（DOTS、UI、Shader、Addressables）

---

## 测试用例

### 用例 1：领域内请求——输出适当
**输入：**“存储敌人配置数据应该使用 MonoBehaviour 还是 ScriptableObject？”
**预期行为：**
- 生成涵盖以下内容的模式决策树：
  - MonoBehaviour：用于运行时行为，需要附加到 GameObject，并具有 Update() 生命周期
  - ScriptableObject：用于纯数据/配置，以资产形式存在，可在实例间共享，不依赖场景
- 建议对敌人配置数据使用 ScriptableObject（无状态、可复用、便于设计师使用）
- 说明 MonoBehaviour 可以引用 ScriptableObject 供运行时使用
- 提供 ScriptableObject 类定义的具体示例（不生成完整代码，而是让 engine-programmer 或 gameplay-programmer 负责实现）

### 用例 2：错误引擎重定向
**输入：**“为这个敌人系统设置带信号的 Node 场景树。”
**预期行为：**
- 不生成 Godot Node/信号代码
- 识别出这是 Godot 模式
- 说明 Unity 中的对应方案是 GameObject 层级结构 + UnityEvent 或 C# 事件
- 映射概念：Godot Node → Unity MonoBehaviour，Godot Signal → C# event / UnityEvent
- 继续之前确认项目基于 Unity

### 用例 3：Unity 版本 API 标记
**输入：**“使用新的 Unity 6 GPU Resident Drawer 进行批量渲染。”
**预期行为：**
- 识别 Unity 6 功能 GPU Resident Drawer
- 标记此 API 在较早 Unity 版本中可能不可用
- 提供实现指导前，询问或检查项目的 Unity 版本
- 指示查阅 Unity 6 官方文档进行验证
- 未经确认，不假定项目使用 Unity 6

### 用例 4：DOTS 与 MonoBehaviour 冲突
**输入：**“战斗系统使用 MonoBehaviour 管理状态，但我们想添加基于 DOTS 的投射物系统。两者能否共存？”
**预期行为：**
- 识别出这是混合架构场景
- 解释混合方案：MonoBehaviour 可以通过 SystemAPI、IComponentData 和托管组件与 DOTS 交互
- 说明混用两种模式在性能和复杂度上的取舍
- 建议将架构决策升级给 `lead-programmer` 或 `technical-director`
- 将 DOTS 侧的实现细节委派给 `unity-dots-specialist`

### 用例 5：上下文传递——Unity 版本
**输入：**已提供项目上下文：Unity 2023.3 LTS。请求：“为此项目配置 New Input System。”
**预期行为：**
- 应用 Unity 2023.3 LTS 上下文：使用 New Input System（com.unity.inputsystem）包
- 不生成旧版 Input Manager 代码（`Input.GetKeyDown()`、`Input.GetAxis()`）
- 说明任何 2023.3 特定的 Input System 行为或包版本约束
- 如果 Input System 与 DOTS 交互，则引用项目版本确认 Burst/Jobs 兼容性

---

## 协议合规性

- [ ] 保持在声明的领域内（Unity 架构决策、模式选择、子系统路由）
- [ ] 将 Godot 模式重定向到适当的 Godot 专家，或将其标记为错误引擎
- [ ] 将 DOTS 实现重定向到 unity-dots-specialist
- [ ] 将 UI 实现重定向到 unity-ui-specialist
- [ ] 标记受 Unity 版本限制的 API，并要求在建议使用前确认版本
- [ ] 返回结构化的模式决策指南，而非无结构的主观意见

---

## 覆盖说明
- 如果 MonoBehaviour 与 ScriptableObject 的选择（用例 1）形成项目级决策，则应记录为 ADR
- 版本标记（用例 3）用于确认代理不会在缺少上下文时假定使用最新 Unity 版本
- DOTS 混合方案（用例 4）用于验证代理会升级架构冲突，而不是单方面解决
