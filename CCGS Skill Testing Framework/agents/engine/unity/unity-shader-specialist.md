# 代理测试规范：unity-shader-specialist

## 代理摘要
领域：Unity Shader Graph、自定义 HLSL、VFX Graph、URP/HDRP 渲染管线定制及后处理效果。
不负责：游戏逻辑代码、美术风格指导。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对该领域（提及 Shader Graph / HLSL / VFX Graph / URP / HDRP）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] 模型层级为 Sonnet（专家代理的默认值）
- [ ] 代理定义未声称拥有游戏逻辑代码或美术指导的权限

---

## 测试用例

### 用例 1：领域内请求——输出适当
**输入：**“在 URP 中使用 Shader Graph 为角色创建描边效果。”
**预期行为：**
- 生成 Shader Graph 节点设置说明：
  - 反向外壳方法：Scale Normal → 在顶点阶段进行 Vertex offset，并设置 Cull Front
  - 或者使用基于深度/法线边缘检测的屏幕空间后处理描边
- 根据 URP 能力建议适当的方法（反向外壳兼容 URP，后处理适合 HDRP）
- 说明 URP 限制：不支持几何着色器（因此排除基于几何着色器的描边方案）
- 未确认渲染管线前，不生成 HDRP 特定节点

### 用例 2：领域外请求重定向
**输入：**“用代码实现角色生命条 UI。”
**预期行为：**
- 不生成 UI 实现代码
- 明确说明 UI 实现属于 `ui-programmer`（或 `unity-ui-specialist`）的职责
- 适当地重定向请求
- 可以说明：如果生命条的填充效果（例如溶解/填充渐变）由着色器驱动，则该视觉效果属于其职责范围

### 用例 3：用于描边的 HDRP 自定义通道
**输入：**“我们使用 HDRP，并希望以后处理效果实现描边。”
**预期行为：**
- 生成 HDRP `CustomPassVolume` 模式：
  - 继承 `CustomPass` 的 C# 类
  - `Execute()` 方法使用 `CoreUtils.SetRenderTarget()` 和全屏着色器 Blit
  - 对深度/法线缓冲区采样以检测边缘
- 说明 CustomPass 需要 HDRP 包，且不适用于 URP
- 提供 HDRP 特定代码前，确认项目使用 HDRP

### 用例 4：VFX Graph 性能——GPU 事件批处理
**输入：**“爆炸 VFX Graph 每次事件生成 10,000 个粒子，同时生成 20 次爆炸会导致 GPU 帧耗时尖峰。”
**预期行为：**
- 识别 GPU 粒子生成为主要开销来源（同时存在 200,000 个粒子）
- 提议 GPU 事件批处理：将生成事件延迟分散到多帧，并错开初始化
- 建议限制每个活动爆炸的粒子预算（例如每次爆炸 3,000 个，超额部分排队）
- 说明 VFX Graph Event Batcher 模式和用于跨帧分配的 Output Event API
- 不更改游戏逻辑事件系统，而是提出 VFX 侧的预算方案

### 用例 5：上下文传递——渲染管线（URP 或 HDRP）
**输入：**项目上下文：URP 渲染管线，Unity 2022.3。请求：“添加景深后处理。”
**预期行为：**
- 使用 URP Volume 框架：`DepthOfField` Volume Override 组件
- 不使用 HDRP Volume 组件（例如参数名不同的 HDRP `DepthOfField`）
- 说明 URP 相比 HDRP 的特定景深限制（例如散景质量差异）
- 生成与 Unity 2022.3 URP 包版本兼容的 C# Volume 配置代码

---

## 协议合规性

- [ ] 保持在声明的领域内（Shader Graph、HLSL、VFX Graph、URP/HDRP 定制）
- [ ] 将游戏逻辑和 UI 代码重定向到适当的代理
- [ ] 返回结构化输出（节点图说明、HLSL 代码、CustomPass 模式）
- [ ] 区分 URP 和 HDRP 方案，不混用特定于不同管线的 API
- [ ] 在相关情况下，将几何着色器方案标记为与 URP 不兼容
- [ ] 生成不改变游戏逻辑行为的 VFX 优化方案

---

## 覆盖说明
- 描边效果（用例 1）应在 `production/qa/evidence/` 中配套视觉截图测试
- HDRP CustomPass（用例 3）用于确认代理生成正确的 Unity 模式，而非通用后处理方案
- 管线隔离（用例 5）用于验证代理不会在缺少上下文时假定渲染管线
