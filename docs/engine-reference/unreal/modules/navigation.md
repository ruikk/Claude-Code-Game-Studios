# Unreal Engine 5.7 — 导航模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** UE 5.7 导航改进

---

## 概览

UE 5.7 的导航系统包括：
- **Nav Mesh**：供 AI 使用的自动寻路网格
- **AI Controller**：控制 AI 的移动与行为
- **Behavior Trees**：AI 决策系统（详见 AI 模块）

---

## Nav Mesh 设置

### 添加 Nav Mesh Bounds Volume

1. 放置 Actors > Volumes > Nav Mesh Bounds Volume
2. 缩放到覆盖可行走区域
3. 按 `P` 切换 Nav Mesh 可视化（绿色覆盖层）

### Nav Mesh 设置项

```cpp
// Project Settings > Engine > Navigation System
// - Generate Navigation Only Around Navigation Invokers: 性能优化
// - Auto Update Enabled: 几何体变化时重新构建 NavMesh
```

---

## AI Controller 与移动

### 创建 AI Controller

```cpp
UCLASS()
class AEnemyAIController : public AAIController {
    GENERATED_BODY()

public:
    void BeginPlay() override {
        Super::BeginPlay();

        // 移动到指定位置
        FVector TargetLocation = FVector(1000, 0, 0);
        MoveToLocation(TargetLocation);
    }
};
```

### 将 AI Controller 分配给 Pawn

```cpp
UCLASS()
class AEnemyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AEnemyCharacter() {
        // ✅ 分配 AI Controller 类
        AIControllerClass = AEnemyAIController::StaticClass();
        AutoPossessAI = EAutoPossessAI::PlacedInWorldOrSpawned;
    }
};
```

---

## 基础 AI 移动

### 移动到位置

```cpp
AAIController* AIController = Cast<AAIController>(GetController());
if (AIController) {
    FVector TargetLocation = FVector(1000, 0, 0);
    EPathFollowingRequestResult::Type Result = AIController->MoveToLocation(TargetLocation);

    if (Result == EPathFollowingRequestResult::RequestSuccessful) {
        UE_LOG(LogTemp, Warning, TEXT("Moving to location"));
    }
}
```

### 移动到 Actor

```cpp
AActor* Target = /* Get target actor */;
AIController->MoveToActor(Target, 100.0f); // 在距离目标 100 单位处停止
```

### 停止移动

```cpp
AIController->StopMovement();
```

---

## 路径跟随事件

### On Move Completed

```cpp
UCLASS()
class AEnemyAIController : public AAIController {
    GENERATED_BODY()

public:
    void BeginPlay() override {
        Super::BeginPlay();

        // 绑定移动完成事件
        ReceiveMoveCompleted.AddDynamic(this, &AEnemyAIController::OnMoveCompleted);
    }

    UFUNCTION()
    void OnMoveCompleted(FAIRequestID RequestID, EPathFollowingResult::Type Result) {
        if (Result == EPathFollowingResult::Success) {
            UE_LOG(LogTemp, Warning, TEXT("Reached destination"));
        } else {
            UE_LOG(LogTemp, Warning, TEXT("Failed to reach destination"));
        }
    }
};
```

---

## 寻路查询

### 查找通往目标位置的路径

```cpp
#include "NavigationSystem.h"
#include "NavigationPath.h"

UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
if (NavSys) {
    FVector Start = GetActorLocation();
    FVector End = TargetLocation;

    FPathFindingQuery Query;
    Query.StartLocation = Start;
    Query.EndLocation = End;
    Query.NavData = NavSys->GetDefaultNavDataInstance();

    FPathFindingResult Result = NavSys->FindPathSync(Query);

    if (Result.IsSuccessful()) {
        UNavigationPath* NavPath = Result.Path.Get();
        // 使用路径点：NavPath->GetPathPoints()
    }
}
```

### 检查位置是否可达

```cpp
UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
FNavLocation OutLocation;
bool bReachable = NavSys->ProjectPointToNavigation(TargetLocation, OutLocation);

if (bReachable) {
    UE_LOG(LogTemp, Warning, TEXT("Location is reachable"));
}
```

---

## Nav Mesh 修改器

### Nav Modifier Volume（阻挡/允许区域）

1. 放置 Actors > Volumes > Nav Modifier Volume
2. 配置 Area Class（例如用 NavArea_Null 阻挡，用 NavArea_LowHeight 表示需蹲伏通过）

---

## 自定义 Nav Area

### 创建自定义 Nav Area

```cpp
UCLASS()
class UNavArea_Jump : public UNavArea {
    GENERATED_BODY()

public:
    UNavArea_Jump() {
        DefaultCost = 10.0f; // 更高的代价 = AI 会尽量避开，除非必要
        FixedAreaEnteringCost = 100.0f; // 进入时的一次性代价
    }
};
```

### 使用自定义 Nav Area

```cpp
// 分配给 Nav Modifier Volume 或几何体
```

---

## Nav Mesh 生成

### 在运行时重建 Nav Mesh

```cpp
UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
NavSys->Build(); // 重建整个 NavMesh
```

### 动态 Nav Mesh（移动障碍物）

```cpp
// 启用：Project Settings > Navigation System > Runtime Generation = Dynamic

// 将 actor 标记为动态障碍物：
UStaticMeshComponent* Mesh = /* Get mesh */;
Mesh->SetCanEverAffectNavigation(true);
Mesh->bDynamicObstacle = true;
```

---

## Nav Links（离网格连接）

### Nav Link Proxy（跳跃、传送）

1. 放置 Actors > Navigation > Nav Link Proxy
2. 设置起点和终点
3. 配置：
   - **Direction**：单向或双向
   - **Smart Link**：在穿越期间播放角色动画

---

## 人群管理

### Detour Crowd（避免重叠）

```cpp
// 启用：Character Movement Component > Avoidance Enabled = true

// 配置避让组和标记
UCharacterMovementComponent* MoveComp = GetCharacterMovement();
MoveComp->SetAvoidanceGroup(1);
MoveComp->SetGroupsToAvoid(1);
MoveComp->SetAvoidanceEnabled(true);
```

---

## 性能提示

### Nav Mesh 优化

```cpp
// 对于大型世界，减小 tile 大小：
// Project Settings > Navigation System > Cell Size = 19 (default)

// 对动态生成使用 Navigation Invokers：
// 仅在玩家/重要 actor 周围生成 NavMesh
```

---

## 调试

### 可视化 Nav Mesh

```cpp
// 控制台命令：
// show navigation - 切换 NavMesh 可视化
// p - 切换 NavMesh（编辑器视口）

// 绘制调试路径：
if (NavPath) {
    for (int i = 0; i < NavPath->GetPathPoints().Num() - 1; i++) {
        DrawDebugLine(GetWorld(), NavPath->GetPathPoints()[i], NavPath->GetPathPoints()[i + 1], FColor::Green, false, 5.0f, 0, 5.0f);
    }
}
```

---

## 常见模式

### 在路点之间巡逻

```cpp
UPROPERTY(EditAnywhere, Category = "AI")
TArray<AActor*> PatrolPoints;

int32 CurrentPatrolIndex = 0;

void OnMoveCompleted(FAIRequestID RequestID, EPathFollowingResult::Type Result) {
    if (Result == EPathFollowingResult::Success) {
        // 移动到下一个路点
        CurrentPatrolIndex = (CurrentPatrolIndex + 1) % PatrolPoints.Num();
        MoveToActor(PatrolPoints[CurrentPatrolIndex]);
    }
}
```

### 追击玩家

```cpp
void Tick(float DeltaTime) {
    Super::Tick(DeltaTime);

    AAIController* AIController = Cast<AAIController>(GetController());
    APawn* PlayerPawn = GetWorld()->GetFirstPlayerController()->GetPawn();

    if (AIController && PlayerPawn) {
        float Distance = FVector::Dist(GetActorLocation(), PlayerPawn->GetActorLocation());

        if (Distance < 1000.0f) {
            // 追击玩家
            AIController->MoveToActor(PlayerPawn, 100.0f);
        } else {
            // 停止追击
            AIController->StopMovement();
        }
    }
}
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/navigation-system-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/ai-in-unreal-engine/
