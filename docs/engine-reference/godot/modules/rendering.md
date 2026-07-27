# Godot Rendering — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **D3D12 是 Windows 上的默认渲染后端**（此前为 Vulkan）
- **Glow 在色调映射前处理**（此前在之后），使用 screen 混合模式
- **AgX tonemapper**: 新增白点和对比度控制
- **SSR 全面重构**: 真实感、视觉稳定性和性能更好

### 4.5 变更
- **Shader Baker**: 预编译着色器以减少启动时间
- **SMAA 1x**: 新的抗锯齿选项（比 FXAA 更锐利，比 TAA 更省资源）
- **Stencil buffer support**: 支持选择性几何遮罩和传送门效果
- **Bent normal maps**: 在法线贴图纹理中编码方向性遮蔽
- **Specular occlusion**: 环境光遮蔽现在会正确影响反射

### 4.4 变更
- **`RenderingDevice.draw_list_begin`**: Many parameters removed; optional `breadcrumb` added
- **Shader texture types**: Changed from `Texture2D` to `Texture` base type
- **Particles `.restart()`**: 新增可选 `keep_seed` 参数

### 4.3 变更（训练数据已覆盖）
- **Compositor node**: `Compositor` + `CompositorEffect` for post-processing chains

## 当前 API 模式

### Post-Processing (4.3+)
```gdscript
# 使用 Compositor 节点，不要使用手动视口着色器链
# 将 Compositor 添加为 WorldEnvironment 或 Camera3D 的子节点
# 为每个后处理步骤创建 CompositorEffect 资源
```

### 抗锯齿选项（4.6）
```
Project Settings → Rendering → Anti Aliasing:
- MSAA 2D/3D: Hardware MSAA (quality but expensive)
- Screen Space AA: FXAA (fast, blurry) or SMAA (sharp, moderate cost)  # SMAA new in 4.5
- TAA: Temporal (best quality, ghosting on fast motion)
```

### 渲染后端选择（4.6）
```
Project Settings → Rendering → Renderer:
- Forward+ (default): Full featured, desktop-focused
- Mobile: Optimized for mobile/low-end, limited features
- Compatibility: OpenGL 3.3 / WebGL 2, broadest hardware support

Windows default backend: D3D12 (was Vulkan pre-4.6)
```

## 常见错误
- 误以为 Vulkan 是 Windows 默认后端（4.6 起为 D3D12）
- 后处理使用手动视口链，而不是 Compositor
- 着色器 uniform 类型使用 `Texture2D`（4.4 起应使用 `Texture`）
- 着色器变体较多的项目未使用 Shader Baker
