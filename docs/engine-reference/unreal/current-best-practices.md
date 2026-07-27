# Unreal Engine 5.7 — 当前最佳实践

**最后验证时间：**2026-02-13

以下是现代 UE5 的实践模式，其中一些可能尚未包含在 LLM 的训练数据中。
这些建议截至 UE 5.7 已可用于生产环境。

---

## 项目配置

### 新项目使用 UE 5.7
- 最新特性：Megalights，以及已可用于生产环境的 Substrate 和 PCG
- 更好的性能与稳定性

### 选择合适的渲染特性
- **Lumen**：实时全局光照（推荐用于大多数项目）
- **Nanite**：面向高多边形网格的虚拟化几何体（推荐用于高细节环境）
- **Megalights**：支持数百万个动态光源（推荐用于复杂光照场景）
- **Substrate**：模块化材质系统（推荐用于新项目）

---

## C++ 编码

### 使用现代 C++ 特性（UE5.7 中为 C++20）

```cpp
// ✅ 使用 TObjectPtr<T>（UE5 类型安全指针）
UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComp;

// ✅ 结构化绑定
if (auto [bSuccess, Value] = TryGetValue(); bSuccess) {
    // 使用 Value
}

// ✅ Concepts 和约束（C++20）
template<typename T>
concept Damageable = requires(T t, float damage) {
    { t.TakeDamage(damage) } -> std::same_as<void>;
};
```

### 使用 UPROPERTY() 参与垃圾回收

```cpp
// ✅ UPROPERTY 可确保 GC 不会删除它
UPROPERTY()
TObjectPtr<AActor> MyActor;

// ❌ 裸指针可能变成悬垂指针
AActor* MyActor; // Dangerous! May be garbage collected
```

### 使用 UFUNCTION() 暴露给 Blueprint

```cpp
// ✅ 可从 Blueprint 调用
UFUNCTION(BlueprintCallable, Category="Combat")
void TakeDamage(float Damage);

// ✅ 可在 Blueprint 中实现
UFUNCTION(BlueprintImplementableEvent, Category="Combat")
void OnDeath();
```

---

## Blueprint 最佳实践

### 何时使用 Blueprint，何时使用 C++

- **C++**：核心 gameplay system（游戏玩法系统）、性能关键代码、底层引擎交互
- **Blueprint**：快速原型开发、内容创作、数据驱动逻辑、设计师工作流

### Blueprint 性能建议

```cpp
// ✅ 谨慎使用 Event Tick（开销较高）
// 优先使用定时器或事件

// ✅ 使用 Blueprint Nativization（Blueprints → C++）
// Project Settings > Packaging > Blueprint Nativization

// ✅ 缓存高频访问的组件
// 不要每一帧都调用 GetComponent
```

---

## 渲染（UE 5.7）

### 使用 Lumen 实现全局光照

```cpp
// 启用路径：Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// 实时 GI，无需烘焙 lightmap（推荐）
```

### 对高多边形网格使用 Nanite

```cpp
// 在 Static Mesh 上启用：Details > Nanite Settings > Enable Nanite Support
// 可自动为数百万三角形生成 LOD（推荐用于高细节网格）
```

### 对复杂光照使用 Megalights（UE 5.5+）

```cpp
// 启用路径：Project Settings > Engine > Rendering > Megalights = Enabled
// 以极低成本支持数百万个动态光源
```

### 使用 Substrate 材质（在 5.7 中已可用于生产环境）

```cpp
// 启用路径：Project Settings > Engine > Substrate > Enable Substrate
// 模块化、符合物理规律的材质系统（推荐用于新项目）
```

---

## Enhanced Input System

### 配置 Enhanced Input

```cpp
// 1. 创建 Input Action（IA_Jump）
// 2. 创建 Input Mapping Context（IMC_Default）
// 3. 添加映射：IA_Jump → Space Bar

// C++ Setup:
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"

void AMyCharacter::BeginPlay() {
    Super::BeginPlay();

    if (APlayerController* PC = Cast<APlayerController>(GetController())) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->AddMappingContext(DefaultMappingContext, 0);
        }
    }
}

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
}

void AMyCharacter::Move(const FInputActionValue& Value) {
    FVector2D MoveVector = Value.Get<FVector2D>();
    AddMovementInput(GetActorForwardVector(), MoveVector.Y);
    AddMovementInput(GetActorRightVector(), MoveVector.X);
}
```

---

## Gameplay Ability System (GAS)

### 复杂 gameplay 使用 GAS

```cpp
// ✅ GAS 适用于：技能、buff、伤害计算、冷却时间
// 模块化、可扩展、支持多人联机

// 安装：启用 "Gameplay Abilities" plugin

// Ability 示例：
UCLASS()
class UGA_Fireball : public UGameplayAbility {
    GENERATED_BODY()

public:
    virtual void ActivateAbility(...) override {
        // Ability logic
        SpawnFireball();
        CommitAbility(); // Commit cost/cooldown
    }
};
```

---

## World Partition（大型世界）

### 开放世界使用 World Partition

```cpp
// 启用路径：World Settings > Enable World Partition
// 根据玩家位置自动流送世界分区单元

// Data Layers：组织内容（例如 "Gameplay"、"Audio"、"Lighting"）
// Runtime Data Layers：在运行时加载/卸载
```

---

## Niagara（VFX）

### 使用 Niagara（不要用 Cascade）

```cpp
// 创建路径：Content Browser > Right Click > FX > Niagara System
// 基于节点、支持 GPU 加速的粒子系统（推荐）

// 生成粒子：
UNiagaraComponent* NiagaraComp = UNiagaraFunctionLibrary::SpawnSystemAtLocation(
    GetWorld(),
    ExplosionSystem,
    GetActorLocation()
);
```

---

## MetaSounds（音频）

### 使用 MetaSounds 实现程序化音频

```cpp
// 创建路径：Content Browser > Right Click > Sounds > MetaSound Source
// 基于节点的音频系统，可替代复杂逻辑下的 Sound Cue（推荐）

// 播放 MetaSound：
UAudioComponent* AudioComp = UGameplayStatics::SpawnSound2D(
    GetWorld(),
    MetaSoundSource
);
```

---

## Replication（多人联机）

### 服务器权威（Server-Authoritative）模式

```cpp
// ✅ 客户端发送输入，服务器进行校验并复制
UFUNCTION(Server, Reliable)
void Server_Move(FVector Direction);

void AMyCharacter::Server_Move_Implementation(FVector Direction) {
    // 服务器校验并应用移动
    AddMovementInput(Direction);
}

// ✅ 复制重要状态
UPROPERTY(Replicated)
int32 Health;

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}
```

---

## 性能优化

### 使用对象池（Object Pooling）

```cpp
// ✅ 复用对象，而不是反复 Spawn/Destroy
TArray<AActor*> ProjectilePool;

AActor* GetPooledProjectile() {
    for (AActor* Proj : ProjectilePool) {
        if (!Proj->IsActive()) {
            Proj->SetActive(true);
            return Proj;
        }
    }
    // 对象池耗尽，生成新对象
    return SpawnNewProjectile();
}
```

### 使用 Instanced Static Meshes

```cpp
// ✅ Hierarchical Instanced Static Mesh Component（HISM）
// 用一次 draw call 渲染成千上万个相同网格
UHierarchicalInstancedStaticMeshComponent* HISM = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Trees"));
for (int i = 0; i < 1000; i++) {
    HISM->AddInstance(FTransform(RandomLocation));
}
```

---

## 调试

### 使用日志

```cpp
// ✅ 结构化日志
UE_LOG(LogTemp, Warning, TEXT("Player health: %d"), Health);

// 自定义日志类别
DECLARE_LOG_CATEGORY_EXTERN(LogMyGame, Log, All);
DEFINE_LOG_CATEGORY(LogMyGame);
UE_LOG(LogMyGame, Error, TEXT("Critical error!"));
```

### 使用 Visual Logger

```cpp
// ✅ 可视化调试
#include "VisualLogger/VisualLogger.h"

UE_VLOG_SEGMENT(this, LogTemp, Log, StartPos, EndPos, FColor::Red, TEXT("Raycast"));
UE_VLOG_LOCATION(this, LogTemp, Log, TargetLocation, 50.f, FColor::Green, TEXT("Target"));
```

---

## 总结：UE 5.7 推荐技术栈

| Feature | Use This (2026) | Notes |
|---------|------------------|-------|
| **Lighting** | Lumen + Megalights | 实时 GI，支持数百万光源 |
| **Geometry** | Nanite | 高多边形网格，自动 LOD |
| **Materials** | Substrate | 模块化、符合物理规律 |
| **Input** | Enhanced Input | 支持重绑定，模块化 |
| **VFX** | Niagara | GPU 加速 |
| **Audio** | MetaSounds | 程序化音频 |
| **World Streaming** | World Partition | 大型开放世界 |
| **Gameplay** | Gameplay Ability System | 复杂技能与 buff |

---

**Sources:**
- https://docs.unrealengine.com/5.7/en-US/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
