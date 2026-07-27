# 代理测试规范：unity-ui-specialist

## 代理摘要
领域：Unity UI Toolkit（UXML/USS）、UGUI（Canvas）、数据绑定、运行时 UI 性能及 UI 输入事件处理。
不负责：UX 流程设计（ux-designer）、视觉美术风格（art-director）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对该领域（提及 UI Toolkit / UGUI / Canvas / 数据绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家代理的默认值）
- [ ] 代理定义未声称拥有 UX 流程设计或视觉美术指导的权限

---

## 测试用例

### 用例 1：领域内请求——输出适当
**输入：**“使用 Unity UI Toolkit 实现一个物品栏 UI 界面。”
**预期行为：**
- 生成定义物品栏面板结构的 UXML 文档（ListView、物品模板、详情面板）
- 生成用于物品栏布局和物品状态（默认、悬停、选中）的 USS 样式
- 提供通过 `INotifyValueChanged` 或 `IBindable` 将物品栏数据模型绑定到 UI 的 C# 代码
- 对可滚动物品列表使用带有 `makeItem` / `bindItem` 回调的 `ListView`
- 不生成 UX 流程设计，而是依据提供的规范进行实现

### 用例 2：领域外请求重定向
**输入：**“设计物品栏的 UX 流程：玩家装备物品与丢弃物品时分别会发生什么。”
**预期行为：**
- 不生成 UX 流程设计
- 明确说明交互流程设计属于 `ux-designer` 的职责
- 将请求重定向到 `ux-designer`
- 说明自己会实现 ux-designer 指定的任何流程

### 用例 3：动态列表的 UI Toolkit 数据绑定
**输入：**“当玩家的背包中添加或移除物品时，物品栏列表需要实时更新。”
**预期行为：**
- 生成绑定 `ObservableList<T>` 的 `ListView` 模式，或采用事件驱动的刷新方式
- 在后端集合变更事件中使用 `ListView.Rebuild()` 或 `ListView.RefreshItems()`
- 说明大型列表的性能注意事项（通过 `makeItem`/`bindItem` 模式实现虚拟化）
- 不使用 `QuerySelector` 循环逐个更新元素作为列表刷新策略，并将其标记为性能反模式

### 用例 4：Canvas 性能——过度绘制
**输入：**“主菜单 Canvas 触发了 GPU 过度绘制警告，其中有许多相互重叠的面板。”
**预期行为：**
- 识别过度绘制的原因：多个堆叠的 Canvas、停用时未被剔除的全屏覆盖面板
- 建议：
  - 为世界空间、屏幕空间覆盖和屏幕空间摄像机图层使用独立的 Canvas
  - 禁用或停用面板，而不是将 alpha 设为 0（不可见的 alpha-0 面板仍会绘制）
  - 淡入淡出效果使用 Canvas Group + alpha，而不是单独设置 Image alpha
- 如果项目具备迁移条件，说明可选用 UI Toolkit

### 用例 5：上下文传递——Unity 版本
**输入：**项目上下文：Unity 2022.3 LTS。请求：“使用数据绑定实现设置面板。”
**预期行为：**
- 使用 UI Toolkit 及 2022.3 LTS 版本的运行时绑定系统
- 说明 Unity 2022.3 引入了运行时数据绑定（早期版本仅支持编辑器内绑定）
- 如果 Unity 6 增强绑定 API 的功能在 2022.3 中不可用，则不使用这些功能
- 生成与指定 Unity 版本兼容的代码，并注明版本特定的 API

---

## 协议合规性

- [ ] 保持在声明的领域内（UI Toolkit、UGUI、数据绑定、UI 性能）
- [ ] 将 UX 流程设计重定向到 ux-designer
- [ ] 返回结构化输出（UXML、USS、C# 绑定代码）
- [ ] 根据项目的 Unity 版本使用正确版本的 Unity UI 框架
- [ ] 将 Canvas 过度绘制标记为性能反模式，并提供具体的修复措施
- [ ] 不使用 alpha-0 作为显示/隐藏模式，而是使用 SetActive() 或 VisualElement.style.display

---

## 覆盖说明
- 物品栏 UI（用例 1）应在 `production/qa/evidence/` 中提供手动演练文档
- 动态列表绑定（用例 3）应提供集成测试或自动化交互测试
- Canvas 过度绘制（用例 4）用于验证代理掌握正确的 Unity UI 性能模式
