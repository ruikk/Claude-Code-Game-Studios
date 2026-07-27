# Godot — 当前最佳实践

上次验证: 2026-02-12 | 引擎: Godot 4.6

以下实践自模型训练数据（~4.3）以来**新增或发生变化**。
本文档用于补充（而非替代）代理的内置知识。

## GDScript (4.5+)

- **可变参数**: 函数可以接受任意数量的参数
  ```gdscript
  func log_values(prefix: String, values: Variant...) -> void:
      for v in values:
          print(prefix, ": ", v)
  ```

- **抽象类和方法**: 使用 `@abstract` 强制继承实现
  ```gdscript
  @abstract
  class_name BaseEnemy extends CharacterBody3D

  @abstract
  func get_attack_pattern() -> Array[Attack]:
   pass  # 子类必须重写
  ```

- **脚本回溯**: 即使在 Release 构建中也可获得详细调用栈

## Physics (4.6)

- **Jolt Physics 是新项目的默认 3D 引擎**
  - 确定性和稳定性优于 GodotPhysics3D
  - 某些 HingeJoint3D 属性（`damp`）仅在 GodotPhysics 中有效
  - 切换位置: Project Settings → Physics → 3D → Physics Engine
  - 2D 物理未变（仍为 Godot Physics 2D）

## Rendering (4.6)

- **D3D12 是 Windows 上的默认后端**（此前为 Vulkan），以获得更好的驱动兼容性
- **Glow 现在在色调映射前处理**，使用 screen 混合模式；现有辉光设置的效果可能不同
- **SSR 全面重构**，真实感、稳定性和性能均有显著提升
- **AgX tonemapper**，新增白点和对比度控制

## Rendering (4.5)

- **Shader Baker**: 预编译着色器，消除启动卡顿
- **SMAA 1x**: 新的抗锯齿选项，比 FXAA 更锐利，比 TAA 更省资源
- **Stencil buffer**: 可用于高级遮罩和传送门效果
- **Bent normal maps**: 在法线贴图纹理中编码方向性遮蔽
- **Specular occlusion**: 环境光遮蔽现在会影响反射

## Accessibility (4.5+)

- **屏幕阅读器支持**: Control 节点通过 AccessKit 接入无障碍工具
- **实时翻译预览**: 直接在编辑器中测试不同语言的 GUI 布局
- **FoldableContainer**: 用于可折叠区段的新手风琴式 UI 节点
- **递归禁用 Control**: 通过单个属性禁用整个节点层级的鼠标/焦点交互

## Animation (4.5+)

- **BoneConstraint3D**: 使用修改器将骨骼绑定到其他骨骼
  - AimModifier3D, CopyTransformModifier3D, ConvertTransformModifier3D

## Animation (4.6)

- **IK 系统完全恢复**: 为 3D 重新引入完整的反向运动学
  - 可用修改器: CCDIK、FABRIK、Jacobian IK、Spline IK、TwoBoneIK
  - Applied via `SkeletonModifier3D` nodes

## Resources (4.5+)

- **`duplicate_deep()`**: 为嵌套资源树提供显式深度复制
  - 保留旧版 `duplicate()` 行为以维持向后兼容
  - 需要为嵌套资源创建实例副本时使用 `duplicate_deep()`

## Navigation (4.5+)

- **专用 2D 导航服务器**: 不再通过 3D NavigationServer 代理
  - 减小纯 2D 游戏的导出二进制体积

## UI (4.6)

- **双焦点系统**: 鼠标/触摸焦点现在与键盘/手柄焦点分离
  - 视觉反馈会根据输入方式不同而变化
  - 设计自定义焦点行为时应考虑这一点

## 编辑器工作流（4.6）

- 灵活的停靠面板拖放和蓝色轮廓预览（包括底部面板）
- 大多数面板支持浮动窗口（Debugger 除外）
- 新键盘快捷键: Alt+O（Output）、Alt+S（Shader）
- 自动生成导出变量: 将资源从 FileSystem 拖入脚本编辑器
- 启用“Live Preview”后，Quick Open 对话框提供实时预览
- 新的“Select Mode”（v 键）可防止误变换；旧模式改名为“Transform Mode”（q 键）

## Tooling

- **ripgrep 没有 `gdscript` 类型**: `*.gd` 被注册在 `gap`（GAP 编程语言）下。
  `rg --type gdscript` 会直接报错，搜索不会执行。
  筛选 GDScript 文件时，始终使用 `rg --glob "*.gd"`（shell）或 `glob: "*.gd"`（Grep 工具）。

## Platform (4.5+)

- **visionOS 导出**: 开源以来首个新增平台（窗口化应用模式）
- **SDL3 gamepad driver**: 提供更好的跨平台手柄支持
- **Android**: 全面屏显示、摄像头画面访问、16KB 页面支持（Android 15+）
- **Linux**: 支持 Wayland 子窗口，实现多窗口能力
