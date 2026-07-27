# Godot — 已弃用 API

上次验证: 2026-02-12

如果代理建议使用“已弃用”列中的任何 API，必须替换为“改用”列中的 API。

## 节点与类

| 已弃用 | 改用 | 起始版本 | 说明 |
|------------|-------------|-------|-------|
| `TileMap` | `TileMapLayer` | 4.3 | One node per layer instead of multi-layer node |
| `VisibilityNotifier2D` | `VisibleOnScreenNotifier2D` | 4.0 | 为清晰起见重命名 |
| `VisibilityNotifier3D` | `VisibleOnScreenNotifier3D` | 4.0 | 为清晰起见重命名 |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 | Node2D 上的属性，不是独立节点 |
| `Navigation2D` / `Navigation3D` | `NavigationServer2D` / `NavigationServer3D` | 4.0 | 基于服务器的 API |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 | 已重命名 |

## 方法与属性

| 已弃用 | 改用 | 起始版本 | 说明 |
|------------|-------------|-------|-------|
| `yield()` | `await signal` | 4.0 | GDScript 2.0 coroutine syntax |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 | Callable-based connections |
| `instance()` | `instantiate()` | 4.0 | 已重命名 |
| `PackedScene.instance()` | `PackedScene.instantiate()` | 4.0 | 已重命名 |
| `get_world()` | `get_world_3d()` | 4.0 | Explicit 2D/3D split |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 | Time singleton preferred |
| 嵌套资源使用 `duplicate()` | `duplicate_deep()` | 4.5 | 显式控制深度复制 |
| `Skeleton3D` signal `bone_pose_updated` | `skeleton_updated` | 4.3 | 已重命名 |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 | Moved to base class |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 | Moved to base class |

## 模式（不只是 API）

| 已弃用模式 | 改用 | 原因 |
|--------------------|-------------|-----|
| 基于字符串的 `connect()` | 类型化信号连接 | 类型安全，便于重构 |
| `_process()` 中的 `$NodePath` | `@onready var` 缓存引用 | 性能：每帧都进行路径查找 |
| 无类型 `Array` / `Dictionary` | `Array[Type]`、类型化变量 | GDScript 编译器优化 |
| 着色器参数中的 `Texture2D` | `Texture` 基类类型 | 4.4 中变更 |
| 手动后处理视口链 | `Compositor` + `CompositorEffect` | 结构化后处理（4.3+） |
| 新项目使用 GodotPhysics3D | Jolt Physics 3D | 4.6 起为默认，稳定性更好 |
