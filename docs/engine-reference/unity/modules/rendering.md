# Unity 6.3 — Rendering 模块参考

**最后校验时间：** 2026-02-13
**知识缺口：** LLM 训练基于 Unity 2022 LTS；Unity 6 在渲染方面有重大变化

---

## 概览

Unity 6.3 LTS 使用 **Scriptable Render Pipelines (SRP)** 作为现代渲染架构：
- **URP (Universal Render Pipeline)**：跨平台，适合移动端（推荐）
- **HDRP (High Definition Render Pipeline)**：面向高端 PC/主机，追求照片级真实感
- **Built-in Pipeline**：已弃用，新项目应避免使用

---

## 相比 2022 LTS 的关键变化

### RenderGraph API (Unity 6+)
自定义渲染通道现在使用 RenderGraph，而不是 CommandBuffer：

```csharp
// ✅ Unity 6+ (RenderGraph)
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
    using var builder = renderGraph.AddRasterRenderPass<PassData>("MyPass", out var passData);
    builder.SetRenderFunc((PassData data, RasterGraphContext ctx) => {
        // Rendering commands
    });
}

// ❌ Old (CommandBuffer - still works but deprecated)
public override void Execute(ScriptableRenderContext context, ref RenderingData data) { }
```

### GPU Resident Drawer (Unity 6+)
用于大幅减少 draw call 的自动批处理机制：

```csharp
// Enable in URP Asset settings:
// Rendering > GPU Resident Drawer = Enabled
// Automatically batches thousands of objects with minimal CPU overhead
```

---

## URP 快速参考

### 创建 URP Asset
1. `Assets > Create > Rendering > URP Asset (with Universal Renderer)`
2. 分配到 `Project Settings > Graphics > Scriptable Render Pipeline Settings`

### URP Renderer Features
添加自定义渲染通道：

```csharp
using UnityEngine.Rendering.Universal;

public class OutlineRendererFeature : ScriptableRendererFeature {
    OutlineRenderPass pass;

    public override void Create() {
        pass = new OutlineRenderPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData data) {
        renderer.EnqueuePass(pass);
    }
}
```

---

## 材质与 Shader

### Shader Graph（可视化 Shader 编辑器）
Unity 6 的 Shader Graph 已可用于生产环境，适用于所有 Shader 类型：

```csharp
// Create: Assets > Create > Shader Graph > URP > Lit Shader Graph
// No code needed, visual node-based editing
```

### HLSL 自定义 Shader（URP）

```hlsl
// URP Lit shader template
Shader "Custom/URPLit" {
    Properties {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input) {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 frag(Varyings input) : SV_Target {
                return half4(1, 0, 0, 1); // Red
            }
            ENDHLSL
        }
    }
}
```

---

## 光照

### 烘焙光照（Unity 6 Progressive Lightmapper）

```csharp
// Mark objects as static: Inspector > Static > Contribute GI
// Bake: Window > Rendering > Lighting > Generate Lighting
```

### 实时光源（URP）

```csharp
// Main Light (Directional): Auto-handled by URP
// Additional Lights: Limited by "Additional Lights" setting in URP Asset

// Check light count in shader:
int lightCount = GetAdditionalLightsCount();
```

---

## 后处理

### Volume 系统（Unity 6+）

```csharp
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

// Add Volume component to GameObject
// Add Volume Profile asset
// Configure effects: Bloom, Color Grading, Depth of Field, etc.

// Script access:
Volume volume = GetComponent<Volume>();
if (volume.profile.TryGet<Bloom>(out var bloom)) {
    bloom.intensity.value = 2.5f;
}
```

---

## 性能

### SRP Batcher（自动批处理）

```csharp
// Enable: URP Asset > Advanced > SRP Batcher = Enabled
// Batches draws with same shader variant (minimal CPU overhead)
```

### GPU Instancing

```csharp
// Material: Enable "Enable GPU Instancing" checkbox
// Batches identical meshes (same material + mesh)

Graphics.RenderMeshInstanced(
    new RenderParams(material),
    mesh,
    0,
    matrices // NativeArray<Matrix4x4>
);
```

### Occlusion Culling（遮挡剔除）

```csharp
// Window > Rendering > Occlusion Culling
// Bake occlusion data for static geometry
```

---

## 常见模式

### 自定义相机渲染

```csharp
// Get URP camera data
var cameraData = frameData.Get<UniversalCameraData>();
var camera = cameraData.camera;

// Access render targets
var colorTarget = cameraData.renderer.cameraColorTargetHandle;
```

### 屏幕空间效果

```csharp
// Create ScriptableRendererFeature
// Inject pass at specific point: AfterRenderingOpaques, AfterRenderingTransparents, etc.
```

---

## 调试

### Frame Debugger
- `Window > Analysis > Frame Debugger`
- 逐步查看 draw call，并检查状态

### Rendering Debugger (Unity 6+)
- `Window > Analysis > Rendering Debugger`
- 实时查看 URP 设置、overdraw、光照等信息

---

## 参考来源
- https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/index.html
- https://docs.unity3d.com/6000.0/Documentation/Manual/render-pipelines.html
