# Godot — 破坏性变更

上次验证: 2026-02-12

Godot 各版本之间的变化，重点关注 LLM 知识截止时间之后的变更（4.4+）。

## 4.5 → 4.6（2026 年 1 月 — 截止时间后，高风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Physics | Jolt 现在是默认 3D 物理引擎 | 新项目自动使用 Jolt。现有项目保留原设置。某些 HingeJoint3D 属性（如 `damp`）仅在 GodotPhysics 中有效。 |
| Rendering | Glow 在色调映射前处理 | 此前在色调映射后处理。带辉光的场景外观会不同。请在 WorldEnvironment 中调整强度/混合。 |
| Rendering | Windows 默认使用 D3D12 | 此前为 Vulkan，以获得更好的驱动兼容性。 |
| Rendering | AgX tonemapper 新增控制项 | 新增白点和对比度参数。 |
| Core | Quaternion 初始化为单位四元数 | 此前为零。通常不会影响大多数代码，但属于技术上的破坏性变更。 |
| UI | 双焦点系统 | 鼠标/触摸焦点现在与键盘/手柄焦点分离。视觉反馈因输入方式而异。 |
| Animation | IK 系统完全恢复 | 通过 SkeletonModifier3D 节点提供 CCDIK、FABRIK、Jacobian IK、Spline IK、TwoBoneIK。 |
| Editor | 新的“Modern”主题为默认主题 | 灰度取代蓝色调。恢复方式: Editor Settings → Interface → Theme → Style: Classic |
| Editor | “Select Mode”快捷键变更 | 新的“Select Mode”（v 键）可防止误变换。旧模式改名为“Transform Mode”（q 键）。 |
| 2D | TileMapLayer 场景瓦片旋转 | 场景瓦片现在可以像图集瓦片一样旋转。 |
| Localization | 支持 CSV 复数形式 | 复数不再需要 Gettext。新增上下文列。 |
| C# | 自动提取字符串 | 自动从 C# 代码中提取翻译字符串。 |
| Plugins | 新增 EditorDock 类 | 为插件停靠面板提供布局控制的专用容器。 |

## 4.4 → 4.5（2025 年末 — 截止时间后，高风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| GDScript | 新增可变参数 | 函数可以接受 `...` 任意参数，这是新的语言特性 |
| GDScript | `@abstract` 装饰器 | 现在可以强制使用抽象类和方法 |
| GDScript | 脚本回溯 | 即使在 Release 构建中也可获得详细调用栈 |
| Rendering | 支持 Stencil buffer | 为高级视觉效果提供新能力 |
| Rendering | SMAA 1x 抗锯齿 | 新的后处理 AA 选项 |
| Rendering | Shader Baker | Pre-compiles shaders — reportedly 20x faster startup on some demos |
| Rendering | Bent normal maps、specular occlusion | 新的材质特性 |
| Accessibility | 支持屏幕阅读器 | Control 节点可通过 AccessKit 与无障碍工具协同工作 |
| Editor | Live translation preview | Test GUI layouts in different languages in-editor |
| Physics | 3D 插值重新设计 | 从 RenderingServer 移至 SceneTree。API 未变，但内部实现不同。 |
| Animation | BoneConstraint3D | New: AimModifier3D, CopyTransformModifier3D, ConvertTransformModifier3D |
| Resources | 新增 `duplicate_deep()` | 用于嵌套资源深度复制的新显式方法 |
| Navigation | 专用 2D 导航服务器 | 不再代理 3D 导航；减小 2D 游戏的导出体积 |
| UI | FoldableContainer 节点 | 用于可折叠 UI 区段的新手风琴式容器 |
| UI | Recursive Control behavior | Disable mouse/focus interactions across entire node hierarchies |
| Platform | visionOS 导出支持 | 新的平台目标 |
| Platform | SDL3 gamepad driver | Delegated gamepad handling to SDL library |
| Platform | Android 16KB 页面支持 | 面向 Android 15+ 的 Google Play 发布所需 |

## 4.3 → 4.4（2025 年中 — 接近截止时间，请验证）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Core | `FileAccess.store_*` return `bool` | Was `void`. Methods: `store_8`, `store_16`, `store_32`, `store_64`, `store_buffer`, `store_csv_line`, `store_double`, `store_float`, `store_half`, `store_line`, `store_pascal_string`, `store_real`, `store_string`, `store_var` |
| Core | `OS.execute_with_pipe` | 新增可选 `blocking` 参数 |
| Core | `RegEx.compile/create_from_string` | 新增可选 `show_error` 参数 |
| Rendering | `RenderingDevice.draw_list_begin` | Many parameters removed; `breadcrumb` parameter added |
| Rendering | 着色器纹理类型 | 参数/返回类型从 `Texture2D` 改为 `Texture` |
| Particles | `.restart()` 方法 | 新增可选 `keep_seed` 参数（CPU/GPU 2D/3D） |
| GUI | `RichTextLabel.push_meta` | 新增可选 `tooltip` 参数 |
| GUI | `GraphEdit.connect_node` | 新增可选 `keep_alive` 参数 |

## 4.2 → 4.3（训练数据已覆盖 — 低风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Animation | `Skeleton3D.add_bone` returns `int32` | Was `void` |
| Animation | `bone_pose_updated` signal | Replaced by `skeleton_updated` |
| TileMap | `TileMapLayer` replaces `TileMap` | One node per layer instead of multi-layer single node |
| Navigation | `NavigationRegion2D` | 移除 `avoidance_layers`、`constrain_avoidance` 属性 |
| Editor | `EditorSceneFormatImporterFBX` | 重命名为 `EditorSceneFormatImporterFBX2GLTF` |
| Animation | AnimationMixer 基类 | AnimationPlayer 和 AnimationTree 现在继承 AnimationMixer |
