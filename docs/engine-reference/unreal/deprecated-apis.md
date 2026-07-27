# Unreal Engine 5.7 — 已弃用 API

**最后验证时间：** 2026-02-13

用于快速查阅已弃用 API 及其替代方案的对照表。
格式：**不要使用 X** → **请改用 Y**

---

## 输入 (Input)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `InputComponent->BindAction()` | Enhanced Input `BindAction()` | 新输入系统 |
| `InputComponent->BindAxis()` | Enhanced Input `BindAxis()` | 新输入系统 |
| `PlayerController->GetInputAxisValue()` | Enhanced Input Action Values | 新输入系统 |

**迁移方式：** 安装 Enhanced Input 插件，创建 Input Actions 和 Input Mapping Contexts。

---

## 渲染 (Rendering)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| 旧版材质节点 | Substrate 材质节点 | Substrate 在 5.7 中已可用于生产环境 |
| 前向着色（默认） | Deferred + Lumen | Lumen 是 UE5 默认方案 |
| 旧版光照工作流 | Lumen Global Illumination | 实时全局光照 |

---

## 世界构建 (World Building)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| UE4 World Composition | World Partition (UE5) | 用于大世界流式加载 |
| Level Streaming Volumes | World Partition Data Layers | 更好的关卡流式加载方式 |

---

## 动画 (Animation)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| 旧版动画重定向 | IK Rig + IK Retargeter | UE5 重定向系统 |
| 旧版 Control Rig | Control Rig 2.0 | 已可用于生产环境的绑定方案 |

---

## Gameplay

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `UGameplayStatics::LoadStreamLevel()` | World Partition streaming | 使用 Data Layers |
| 硬编码输入绑定 | Enhanced Input system | 支持重绑定、模块化输入 |

---

## Niagara（VFX）

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| Cascade 粒子系统 | Niagara | Cascade 已被完全弃用 |

---

## 音频 (Audio)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| 旧版音频混音器 | MetaSounds | 程序化音频系统 |
| Sound Cue（用于复杂逻辑时） | MetaSounds | 更强大，基于节点 |

---

## 网络 (Networking)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `DOREPLIFETIME()`（基础用法） | `DOREPLIFETIME_CONDITION()` | 通过条件复制进行优化 |

---

## C++ 脚本 (C++ Scripting)

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| 将 `TSharedPtr<T>` 用于 UObjects | `TObjectPtr<T>` | UE5 类型安全指针 |
| 手动 RTTI 检查 | `Cast<T>()` / `IsA<T>()` | 类型安全转换 |

---

## 快速迁移模式 (Quick Migration Patterns)

### 输入示例
```cpp
// ❌ 已弃用
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
}

// ✅ Enhanced Input
#include "EnhancedInputComponent.h"

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    if (EIC) {
        EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    }
}
```

### 材质示例
```cpp
// ❌ 已弃用：旧版材质
// 使用标准材质图（仍可运行，但不推荐）

// ✅ Substrate Material
// 启用方式：Project Settings > Engine > Substrate > Enable Substrate
// 在材质编辑器中使用 Substrate 节点
```

### World Partition 示例
```cpp
// ❌ 已弃用：Level streaming volumes
// 手动加载/卸载关卡

// ✅ World Partition
// 启用方式：World Settings > Enable World Partition
// 使用 Data Layers 进行流式加载
```

### 粒子系统示例
```cpp
// ❌ 已弃用：Cascade
UParticleSystemComponent* PSC = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("Particles"));

// ✅ Niagara
UNiagaraComponent* NiagaraComp = CreateDefaultSubobject<UNiagaraComponent>(TEXT("Niagara"));
```

### 音频示例
```cpp
// ❌ 已弃用：用 Sound Cue 处理复杂逻辑
// 使用 Sound Cue 编辑器节点

// ✅ MetaSounds
// 创建 MetaSound Source 资源，使用基于节点的音频工作流
```

---

## 总结：UE 5.7 技术栈

| 功能 | 请使用（2026） | 避免使用（旧方案） |
|---------|------------------|----------------------|
| **Input** | Enhanced Input | Legacy Input Bindings |
| **Materials** | Substrate | Legacy Material System |
| **Lighting** | Lumen + Megalights | Lightmaps + Limited Lights |
| **Particles** | Niagara | Cascade |
| **Audio** | MetaSounds | Sound Cue（用于逻辑） |
| **World Streaming** | World Partition | World Composition |
| **Animation Retarget** | IK Rig + Retargeter | Old Retargeting |
| **Geometry** | Nanite（高模） | Standard Static Mesh LODs |

---

**来源：**
- https://docs.unrealengine.com/5.7/en-US/deprecated-and-removed-features/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
