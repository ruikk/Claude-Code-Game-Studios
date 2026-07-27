# Unreal Engine 5.7 — Rendering 模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** UE 5.7 包含 Megalights、可用于生产环境的 Substrate，以及对 Lumen 的改进

---

## 概览

UE 5.7 的渲染栈：
- **Lumen**：实时全局光照（默认）
- **Nanite**：面向数百万三角形的虚拟化几何体
- **Megalights**：支持数百万动态光源（5.5+ 中新增）
- **Substrate**：可用于生产环境的模块化材质系统（5.7 中新增）

---

## Lumen（全局光照）

### 启用 Lumen

```cpp
// Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// 实时 GI，无需烘焙 lightmap
```

### Lumen 质量设置

```ini
; DefaultEngine.ini
[/Script/Engine.RendererSettings]
r.Lumen.DiffuseColorBoost=1.0
r.Lumen.ScreenProbeGather.RadianceCache.NumFramesToKeepCached=2
```

### 在 C++ 中使用 Lumen

```cpp
// 检查是否启用了 Lumen
bool bIsLumenEnabled = IConsoleManager::Get().FindConsoleVariable(TEXT("r.DynamicGlobalIlluminationMethod"))->GetInt() == 1;
```

---

## Nanite（虚拟化几何体）

### 在 Static Mesh 上启用 Nanite

1. 打开 Static Mesh Editor
2. 进入 Details > Nanite Settings > Enable Nanite Support
3. 保存 mesh（会自动构建 Nanite 数据）

### 在 C++ 中使用 Nanite

```cpp
// 生成 Nanite mesh
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetStaticMesh(NaniteMesh); // 如果已启用，会自动使用 Nanite
```

### Nanite 的限制
- 不支持顶点动画（skeletal meshes）
- 材质中不支持 world position offset（WPO）
- 最适合静态的高面数几何体

---

## Megalights（UE 5.5+）

### 启用 Megalights

```cpp
// Project Settings > Engine > Rendering > Megalights = Enabled
// 以极低性能开销支持数百万动态光源
```

### Megalights 的用法

```cpp
// 像平常一样添加 point lights
UPointLightComponent* Light = CreateDefaultSubobject<UPointLightComponent>(TEXT("Light"));
Light->SetIntensity(5000.0f);
Light->SetAttenuationRadius(500.0f);

// Megalights 会自动处理成千上万/数百万个这类光源
```

---

## Substrate 材质（5.7 中可用于生产环境）

### 启用 Substrate

```cpp
// Project Settings > Engine > Substrate > Enable Substrate
// 重启编辑器
```

### Substrate 材质节点
- **Substrate Slab**：物理材质层（diffuse、specular 等）
- **Substrate Blend**：混合多个层
- **Substrate Thin Film**：虹彩效果、肥皂泡效果
- **Substrate Hair**：头发专用着色

### Substrate 材质图示例

```
Substrate Slab (Diffuse)
  └─ Base Color: Texture Sample
  └─ Roughness: Constant (0.5)
  └─ Metallic: Constant (0.0)
  └─ Connect to Material Output
```

---

## 材质（C++ API）

### 动态材质实例

```cpp
// 创建动态材质实例
UMaterialInstanceDynamic* DynMat = UMaterialInstanceDynamic::Create(BaseMaterial, this);

// 设置参数
DynMat->SetVectorParameterValue(TEXT("BaseColor"), FLinearColor::Red);
DynMat->SetScalarParameterValue(TEXT("Metallic"), 0.8f);
DynMat->SetTextureParameterValue(TEXT("DiffuseTexture"), MyTexture);

// 应用到 mesh
MeshComp->SetMaterial(0, DynMat);
```

---

## 后处理

### Post-Process Volume

```cpp
// 添加到关卡
APostProcessVolume* PPV = GetWorld()->SpawnActor<APostProcessVolume>();
PPV->bUnbound = true; // 影响整个世界

// 配置设置
PPV->Settings.bOverride_MotionBlurAmount = true;
PPV->Settings.MotionBlurAmount = 0.5f;

PPV->Settings.bOverride_BloomIntensity = true;
PPV->Settings.BloomIntensity = 1.0f;
```

### 在 C++ 中使用后处理

```cpp
// 访问相机后处理设置
APlayerController* PC = GetWorld()->GetFirstPlayerController();
if (APlayerCameraManager* CamManager = PC->PlayerCameraManager) {
    CamManager->PostProcessBlendWeight = 1.0f;
    CamManager->PostProcessSettings.BloomIntensity = 2.0f;
}
```

---

## 光照

### Directional Light（太阳光）

```cpp
ADirectionalLight* Sun = GetWorld()->SpawnActor<ADirectionalLight>();
Sun->SetActorRotation(FRotator(-45.f, 0.f, 0.f));
Sun->GetLightComponent()->SetIntensity(10.0f);
Sun->GetLightComponent()->bCastShadows = true;
```

### Point Light（点光源）

```cpp
APointLight* Light = GetWorld()->SpawnActor<APointLight>();
Light->SetActorLocation(FVector(0, 0, 200));
Light->GetPointLightComponent()->SetIntensity(5000.0f);
Light->GetPointLightComponent()->SetAttenuationRadius(1000.0f);
Light->GetPointLightComponent()->SetLightColor(FLinearColor::Red);
```

### Spot Light（聚光灯）

```cpp
ASpotLight* Spotlight = GetWorld()->SpawnActor<ASpotLight>();
Spotlight->GetSpotLightComponent()->SetInnerConeAngle(20.0f);
Spotlight->GetSpotLightComponent()->SetOuterConeAngle(40.0f);
```

---

## Render Targets（渲染到纹理）

### 创建 Render Target

```cpp
// 创建 render target 资源（2D 纹理）
UTextureRenderTarget2D* RenderTarget = NewObject<UTextureRenderTarget2D>();
RenderTarget->InitAutoFormat(512, 512); // 512x512 分辨率
RenderTarget->UpdateResourceImmediate();

// 将场景渲染到纹理
UKismetRenderingLibrary::DrawMaterialToRenderTarget(
    GetWorld(),
    RenderTarget,
    MaterialToDraw
);
```

---

## 自定义渲染 Pass（高级）

### Render Dependency Graph（RDG）

```cpp
// UE5 使用 Render Dependency Graph 进行自定义渲染
// 示例：自定义后处理 pass

#include "RenderGraphBuilder.h"

void RenderCustomPass(FRDGBuilder& GraphBuilder, const FViewInfo& View) {
    FRDGTextureRef SceneColor = /* Get scene color texture */;

    // 定义 pass 参数
    struct FPassParameters {
        FRDGTextureRef InputTexture;
    };

    FPassParameters* PassParams = GraphBuilder.AllocParameters<FPassParameters>();
    PassParams->InputTexture = SceneColor;

    // 添加 render pass
    GraphBuilder.AddPass(
        RDG_EVENT_NAME("CustomPass"),
        PassParams,
        ERDGPassFlags::Raster,
        [](FRHICommandList& RHICmdList, const FPassParameters* Params) {
            // Render commands
        }
    );
}
```

---

## 性能

### 渲染统计信息

```cpp
// 用于分析性能的控制台命令：
// stat fps - 显示 FPS
// stat unit - 显示帧时间拆分
// stat gpu - 显示 GPU 耗时
// profilegpu - 详细 GPU 性能分析
```

### 可扩展性设置

```cpp
// 获取当前可扩展性设置
UGameUserSettings* Settings = UGameUserSettings::GetGameUserSettings();
int32 ViewDistanceQuality = Settings->GetViewDistanceQuality(); // 0-4

// 设置可扩展性
Settings->SetViewDistanceQuality(3); // High
Settings->SetShadowQuality(2); // Medium
Settings->ApplySettings(false);
```

---

## 调试

### 可视化渲染特性

```
Console commands:
- r.Lumen.Visualize 1 - 显示 Lumen 调试视图
- r.Nanite.Visualize 1 - 显示 Nanite 三角形
- viewmode wireframe - 线框模式
- viewmode unlit - 禁用光照
- show collision - 显示碰撞网格
```

---

## Sources
- https://docs.unrealengine.com/5.7/en-US/lumen-global-illumination-and-reflections-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/nanite-virtualized-geometry-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/substrate-materials-in-unreal-engine/
