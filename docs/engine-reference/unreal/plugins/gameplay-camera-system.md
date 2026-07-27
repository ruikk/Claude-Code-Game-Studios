# Unreal Engine 5.7 — Gameplay Camera System

**最后验证时间：** 2026-02-13
**状态：** ⚠️ 实验性（在 UE 5.5 中引入）
**插件：** `GameplayCameras`（内置，在 Plugins 中启用）

---

## 概述

**Gameplay Camera System** 是 UE 5.5 引入的一套模块化相机管理框架。
它用灵活的节点式系统取代了传统的相机搭建方式，可用于处理相机模式、混合，以及基于上下文的相机行为。

**适合使用 Gameplay Cameras 的场景：**
- 动态相机行为（第三人称、瞄准、载具、过场）
- 基于上下文的相机切换（战斗、探索、对话）
- 模式间平滑相机混合
- 程序化相机运动（camera shake、lag、offset）

**⚠️ 警告：** 该插件在 UE 5.5-5.7 中仍为实验性功能。未来版本预计会有 API 变动。

---

## 核心概念

### 1. **Camera Rig**
- 定义相机配置（位置、旋转、FOV 等）
- 采用模块化节点图（类似 Material Editor）

### 2. **Camera Director**
- 管理当前激活的是哪一个 camera rig
- 处理不同 camera rig 之间的混合

### 3. **Camera Nodes**
- 构成相机行为的基础模块：
  - **Position Nodes**：Orbit、Follow、Fixed Position
  - **Rotation Nodes**：Look At、Match Actor Rotation
  - **Modifiers**：Camera Shake、Lag、Offset

---

## 配置

### 1. 启用插件

`Edit > Plugins > Gameplay Cameras > Enabled > Restart`

### 2. 添加 Camera Component

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

UCLASS()
class AMyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AMyCharacter() {
        // Create camera component
        CameraComponent = CreateDefaultSubobject<UGameplayCameraComponent>(TEXT("GameplayCamera"));
        CameraComponent->SetupAttachment(RootComponent);
    }

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
    TObjectPtr<UGameplayCameraComponent> CameraComponent;
};
```

---

## 创建 Camera Rig

### 1. 创建 Camera Rig Asset

1. Content Browser > Gameplay > Gameplay Camera Rig
2. 打开 Camera Rig Editor（基于节点的图编辑器）

### 2. 搭建 Camera Rig（示例：第三人称）

**节点结构：**
```
Actor Position (Character)
  ↓
Orbit Node (Orbit around character)
  ↓
Offset Node (Shoulder offset)
  ↓
Look At Node (Look at character)
  ↓
Camera Output
```

---

## Camera Nodes

### Position Nodes

#### Orbit Node（第三人称）
- 围绕目标 Actor 进行环绕
- 可配置：
  - **Orbit Distance**：与目标的距离（例如 300 单位）
  - **Pitch Range**：俯仰角最小/最大值
  - **Yaw Range**：偏航角最小/最大值

#### Follow Node（平滑跟随）
- 带有 lag 的目标跟随
- 可配置：
  - **Lag Speed**：相机追上目标的速度
  - **Offset**：相对于目标的固定偏移

#### Fixed Position Node
- 世界空间中的静态相机位置

---

### Rotation Nodes

#### Look At Node
- 让相机朝向目标
- 可配置：
  - **Target**：要看的 Actor 或组件
  - **Offset**：Look-at 偏移（例如瞄准头部而不是脚部）

#### Match Actor Rotation
- 匹配目标 Actor 的旋转
- 适用于第一人称或载具相机

---

### Modifier Nodes

#### Camera Shake
- 添加程序化震动（例如脚步、爆炸）
- 可配置：
  - **Shake Pattern**：Perlin noise、sine wave、自定义
  - **Amplitude**：震动强度

#### Camera Lag
- 对相机运动进行平滑阻尼
- 可配置：
  - **Lag Speed**：阻尼系数（0 = 瞬时，高值 = 更明显的 lag）

#### Offset Node
- 在计算后的位置基础上添加静态偏移
- 适合用于肩后视角偏移

---

## Camera Director（在多个 Rigs 之间切换）

### 指定 Camera Rig

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

void AMyCharacter::SetCameraMode(UGameplayCameraRig* NewRig) {
    if (CameraComponent) {
        CameraComponent->SetCameraRig(NewRig);
    }
}
```

### 在 Camera Rigs 之间混合

```cpp
// Blend to aiming camera over 0.5 seconds
CameraComponent->BlendToCameraRig(AimingCameraRig, 0.5f);
```

---

## 示例：第三人称 + 瞄准

### 1. 创建两个 Camera Rigs

**Third Person Rig：**
```
Actor Position → Orbit (distance: 300) → Look At → Output
```

**Aiming Rig：**
```
Actor Position → Orbit (distance: 150) → Offset (shoulder) → Look At → Output
```

### 2. 在瞄准时切换

```cpp
UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> ThirdPersonRig;

UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> AimingRig;

void StartAiming() {
    CameraComponent->BlendToCameraRig(AimingRig, 0.3f); // Blend over 0.3s
}

void StopAiming() {
    CameraComponent->BlendToCameraRig(ThirdPersonRig, 0.3f);
}
```

---

## 常见模式

### 肩后相机（Over-the-Shoulder Camera）

```
Actor Position
  ↓
Orbit Node (distance: 250, yaw offset: 30°)
  ↓
Offset Node (X: 0, Y: 50, Z: 50) // Shoulder offset
  ↓
Look At Node (target: Character head)
  ↓
Output
```

---

### 载具相机

```
Vehicle Position
  ↓
Follow Node (lag: 0.2)
  ↓
Offset Node (behind vehicle: X: -400, Z: 150)
  ↓
Look At Node (target: Vehicle)
  ↓
Output
```

---

### 第一人称相机

```
Character Head Socket
  ↓
Match Actor Rotation
  ↓
Output
```

---

## Camera Shake

### 触发 Camera Shake

```cpp
#include "GameplayCameras/Public/GameplayCameraShake.h"

void TriggerExplosionShake() {
    if (APlayerController* PC = GetWorld()->GetFirstPlayerController()) {
        if (UGameplayCameraComponent* CameraComp = PC->FindComponentByClass<UGameplayCameraComponent>()) {
            CameraComp->PlayCameraShake(ExplosionShakeClass, 1.0f);
        }
    }
}
```

---

## 性能建议

- 限制 camera shake 的触发频率（不要每帧都触发）
- 谨慎使用 camera lag（高 lag 值开销较大）
- 缓存 camera rig 引用（不要每帧查找）

---

## 调试

### 相机调试可视化

```cpp
// Console commands:
// GameplayCameras.Debug 1 - Show active camera rig info
// showdebug camera - Show camera debug info
```

---

## 从旧版相机系统迁移

### 旧版 Spring Arm + Camera Component

```cpp
// ❌ OLD: Spring Arm Component
USpringArmComponent* SpringArm;
UCameraComponent* Camera;

// ✅ NEW: Gameplay Camera Component
UGameplayCameraComponent* CameraComponent;
// Build orbit + look-at rig in Camera Rig asset
```

---

## 限制（实验性状态）

- **API 不稳定**：预计 UE 5.8+ 会有破坏性变更
- **文档有限**：官方文档仍在持续完善
- **Blueprint 支持**：目前主要偏向 C++（Blueprint 支持正在改进）
- **生产风险**：正式发布前务必充分测试

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/
- UE 5.5+ Release Notes
- **注意：** 该系统为实验性功能。遇到 API 变化时，请始终以最新官方文档为准。
