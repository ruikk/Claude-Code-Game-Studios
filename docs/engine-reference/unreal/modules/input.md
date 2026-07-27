# Unreal Engine 5.7 — 输入模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** UE 5.7 默认使用 Enhanced Input（旧版输入系统已废弃）

---

## 概览

UE 5.7 的输入系统：
- **Enhanced Input**（推荐，UE5 默认）：模块化、可重绑定、基于上下文
- **Legacy Input**：已废弃，新项目应避免使用

---

## Enhanced Input 系统

### 设置 Enhanced Input

1. **启用插件**：`Edit > Plugins > Enhanced Input`（在 UE5 中默认启用）
2. **项目设置**：`Engine > Input > Default Classes > Default Player Input Class = EnhancedPlayerInput`

---

### 创建 Input Action

1. Content Browser > Input > Input Action
2. 命名（例如：`IA_Jump`、`IA_Move`）
3. 配置：
   - **Value Type**：Digital（bool）、Axis1D（float）、Axis2D（Vector2D）、Axis3D（Vector）

Input Action 示例：
- `IA_Jump`：Digital（bool）
- `IA_Move`：Axis2D（Vector2D）
- `IA_Look`：Axis2D（Vector2D）
- `IA_Fire`：Digital（bool）

---

### 创建 Input Mapping Context

1. Content Browser > Input > Input Mapping Context
2. 命名（例如：`IMC_Default`）
3. 添加映射：
   - `IA_Jump` → Space Bar
   - `IA_Move` → W/A/S/D 键（组合 X/Y）
   - `IA_Look` → Mouse XY
   - `IA_Fire` → Left Mouse Button

---

### 在 C++ 中绑定输入

```cpp
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"

class AMyCharacter : public ACharacter {
public:
    // Input Actions（在 Blueprint 中赋值）
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> MoveAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> LookAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> JumpAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputMappingContext> DefaultMappingContext;

protected:
    virtual void BeginPlay() override {
        Super::BeginPlay();

        // 添加 Input Mapping Context
        if (APlayerController* PC = Cast<APlayerController>(Controller)) {
            if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
                ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
                Subsystem->AddMappingContext(DefaultMappingContext, 0);
            }
        }
    }

    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override {
        Super::SetupPlayerInputComponent(PlayerInputComponent);

        UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
        if (EIC) {
            // 绑定动作
            EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
            EIC->BindAction(JumpAction, ETriggerEvent::Completed, this, &ACharacter::StopJumping);

            EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
            EIC->BindAction(LookAction, ETriggerEvent::Triggered, this, &AMyCharacter::Look);
        }
    }

    void Move(const FInputActionValue& Value) {
        FVector2D MoveVector = Value.Get<FVector2D>();

        if (Controller) {
            AddMovementInput(GetActorForwardVector(), MoveVector.Y);
            AddMovementInput(GetActorRightVector(), MoveVector.X);
        }
    }

    void Look(const FInputActionValue& Value) {
        FVector2D LookVector = Value.Get<FVector2D>();

        if (Controller) {
            AddControllerYawInput(LookVector.X);
            AddControllerPitchInput(LookVector.Y);
        }
    }
};
```

---

## Input Trigger

### Trigger 类型

Input Action 可以配置 Trigger，用来控制何时触发：
- **Pressed**：输入开始时
- **Released**：输入结束时
- **Hold**：按住一段时间后触发
- **Tap**：快速点击
- **Pulse**：按住期间重复触发

### 在编辑器中添加 Trigger

1. 打开 Input Action 资源
2. Triggers > Add > 选择 Trigger 类型（例如：`Hold`）
3. 配置参数（例如：Hold Time = 0.5s）

---

## Input Modifier

### Modifier 类型

Modifier 用于变换输入值：
- **Negate**：翻转符号（-1 ↔ 1）
- **Dead Zone**：忽略较小的输入
- **Scalar**：按数值缩放
- **Smooth**：随时间平滑处理

### 在编辑器中添加 Modifier

1. 打开 Input Action 资源
2. Modifiers > Add > 选择 Modifier（例如：`Negate`）
3. 进行配置

---

## Input Mapping Context（上下文切换）

### 多个 Context

```cpp
// 定义 Context
UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> DefaultContext;

UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> VehicleContext;

// 切换 Context
void EnterVehicle() {
    if (APlayerController* PC = Cast<APlayerController>(Controller)) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->RemoveMappingContext(DefaultContext);
            Subsystem->AddMappingContext(VehicleContext, 0);
        }
    }
}
```

---

## Legacy Input（已废弃）

### 旧版输入绑定

```cpp
// ❌ 已废弃：新项目不要使用

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    // 旧版动作绑定
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

    // 旧版轴绑定
    PlayerInputComponent->BindAxis("MoveForward", this, &AMyCharacter::MoveForward);
}

void MoveForward(float Value) {
    AddMovementInput(GetActorForwardVector(), Value);
}
```

**迁移方式：** 改用 Enhanced Input。

---

## Gamepad 输入

### 使用 Enhanced Input 处理 Gamepad

```cpp
// Input Mapping Context:
// - IA_Move → Gamepad Left Thumbstick
// - IA_Look → Gamepad Right Thumbstick
// - IA_Jump → Gamepad Face Button Bottom (A/Cross)

// 无需修改代码，只需在 Input Mapping Context 中添加 gamepad 映射
```

---

## Touch 输入（移动端）

### 使用 Enhanced Input 处理 Touch 输入

```cpp
// Input Mapping Context:
// - IA_Move → Touch（虚拟摇杆）
// - IA_Look → Touch（滑动）

// 使用 Touch Interface 资源来提供虚拟控件
```

---

## 运行时重绑定输入

### 修改按键映射

```cpp
#include "PlayerMappableInputConfig.h"

// 获取 subsystem
UEnhancedInputLocalPlayerSubsystem* Subsystem = /* Get subsystem */;

// 获取可由玩家映射的按键
FPlayerMappableKeySlot KeySlot = FPlayerMappableKeySlot(/*..*/);
FKey NewKey = EKeys::F; // 重新绑定到 F 键

// 应用新的映射
Subsystem->AddPlayerMappedKey(/*..*/);
```

---

## 输入调试

### 调试输入

```cpp
// 控制台命令：
// showdebug input - 显示输入调试信息

// 记录输入值：
UE_LOG(LogTemp, Warning, TEXT("Move Input: %s"), *MoveVector.ToString());
```

---

## 常见模式

### 检查按键是否按下（Quick & Dirty）

```cpp
// 仅用于调试（不推荐用于 gameplay）
if (GetWorld()->GetFirstPlayerController()->IsInputKeyDown(EKeys::SpaceBar)) {
    // Space bar 当前处于按下状态
}
```

---

## 参考来源
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-action-and-input-mapping-context-in-unreal-engine/
