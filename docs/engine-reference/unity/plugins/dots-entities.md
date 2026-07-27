# Unity 6.3 — DOTS / Entities (ECS)

**最后验证时间：** 2026-02-13
**状态：** 生产可用 (Production-Ready，Entities 1.3+，Unity 6.3 LTS)
**包：** `com.unity.entities` (Package Manager)

---

## 概述

**DOTS (Data-Oriented Technology Stack，数据导向技术栈)** 是 Unity 的高性能 ECS (Entity Component System，实体组件系统)
框架，适用于超大规模游戏（数千到数万个实体）。

**适合使用 DOTS 的场景：**
- RTS 游戏（数千单位）
- 模拟类系统（人群、交通、物理）
- 程序化内容生成
- 对性能要求极高的系统

**不建议使用 DOTS 的场景：**
- 小型游戏（引入成本不划算）
- 需要频繁进行结构性变更的玩法
- 大量依赖 UnityEngine API 的场景（MonoBehaviour 更简单）

**⚠️ 知识断层提示：** Entities 1.0+（Unity 6）相较于 0.x 是一次彻底重写。
许多面向 Entities 0.x 的教程现在已经过时。

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 "Entities"
3. 安装：
   - `Entities`（ECS 核心）
   - `Burst`（LLVM 编译器）
   - `Jobs`（自动安装）
   - `Mathematics`（SIMD 数学库）

---

## 核心概念

### 1. **Entity**
- 轻量级 ID（int）
- 不包含行为，只是一个标识符

### 2. **Component**
- 仅包含数据（无方法）
- 实现 `IComponentData` 的 struct

### 3. **System**
- 对组件进行操作的逻辑
- 实现 `ISystem` 的 struct

### 4. **Archetype**
- 组件类型的唯一组合
- 拥有相同组件的实体共享同一种 archetype

---

## 基础 ECS 模式

### 定义 Component

```csharp
using Unity.Entities;
using Unity.Mathematics;

// ✅ Component: Data only, no methods
public struct Position : IComponentData {
    public float3 Value;
}

public struct Velocity : IComponentData {
    public float3 Value;
}
```

---

### 定义 System

```csharp
using Unity.Entities;
using Unity.Burst;

// ✅ System: Logic that processes entities
[BurstCompile]
public partial struct MovementSystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        float deltaTime = SystemAPI.Time.DeltaTime;

        // Query all entities with Position + Velocity
        foreach (var (transform, velocity) in
            SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

            transform.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
        }
    }
}
```

---

### 创建 Entities

```csharp
using Unity.Entities;
using Unity.Mathematics;

public partial class EntitySpawner : SystemBase {
    protected override void OnUpdate() {
        var em = EntityManager;

        // Create entity
        Entity entity = em.CreateEntity();

        // Add components
        em.AddComponentData(entity, new Position { Value = float3.zero });
        em.AddComponentData(entity, new Velocity { Value = new float3(1, 0, 0) });
    }
}
```

---

## 混合 ECS（MonoBehaviour + ECS）

### Baker（将 GameObject 转换为 Entity）

```csharp
using Unity.Entities;
using UnityEngine;

public class PlayerAuthoring : MonoBehaviour {
    public float speed;
}

public class PlayerBaker : Baker<PlayerAuthoring> {
    public override void Bake(PlayerAuthoring authoring) {
        var entity = GetEntity(TransformUsageFlags.Dynamic);

        AddComponent(entity, new Position { Value = authoring.transform.position });
        AddComponent(entity, new Velocity { Value = new float3(authoring.speed, 0, 0) });
    }
}
```

**工作方式：**
1. 在编辑器中将 `PlayerAuthoring` 添加到 GameObject
2. Baker 会在运行时自动将其转换为 Entity
3. 该 Entity 会拥有 Position + Velocity 组件

---

## Queries

### 查询拥有指定组件的所有实体

```csharp
foreach (var (position, velocity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

    position.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
}
```

---

### 查询时同时获取 Entity

```csharp
foreach (var (position, velocity, entity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>().WithEntityAccess()) {

    // Access entity ID
    Debug.Log($"Entity: {entity}");
}
```

---

### 带过滤条件的查询

```csharp
// Only entities with "Enemy" tag
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // Process enemies only
}
```

---

## Jobs（并行执行）

### IJobEntity（并行 Foreach）

```csharp
using Unity.Entities;
using Unity.Burst;

[BurstCompile]
public partial struct MovementJob : IJobEntity {
    public float DeltaTime;

    // Execute runs in parallel for each entity
    void Execute(ref Position position, in Velocity velocity) {
        position.Value += velocity.Value * DeltaTime;
    }
}

[BurstCompile]
public partial struct MovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var job = new MovementJob {
            DeltaTime = SystemAPI.Time.DeltaTime
        };
        job.ScheduleParallel(); // Parallel execution
    }
}
```

---

## Burst Compiler（性能优化）

### 启用 Burst

```csharp
using Unity.Burst;

[BurstCompile] // 10-100x faster than regular C#
public partial struct MySystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        // Burst-compiled code
    }
}
```

**Burst 限制：**
- 不支持托管引用（class、string 等）
- 仅支持 blittable 类型（struct、基础类型、Unity.Mathematics 类型）
- 不支持异常

---

## Entity Command Buffers（结构性变更）

### 延迟执行结构性变更

```csharp
using Unity.Entities;

public partial struct SpawnSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var ecb = new EntityCommandBuffer(Allocator.Temp);

        // Defer entity creation (don't modify during iteration)
        foreach (var spawner in SystemAPI.Query<Spawner>()) {
            Entity newEntity = ecb.CreateEntity();
            ecb.AddComponent(newEntity, new Position { Value = spawner.SpawnPos });
        }

        ecb.Playback(state.EntityManager); // Apply changes
        ecb.Dispose();
    }
}
```

---

## Dynamic Buffers（类似数组的组件）

### 定义 Dynamic Buffer

```csharp
public struct PathWaypoint : IBufferElementData {
    public float3 Position;
}
```

### 使用 Dynamic Buffer

```csharp
// Add buffer to entity
var buffer = EntityManager.AddBuffer<PathWaypoint>(entity);
buffer.Add(new PathWaypoint { Position = new float3(0, 0, 0) });
buffer.Add(new PathWaypoint { Position = new float3(10, 0, 0) });

// Query buffer
foreach (var buffer in SystemAPI.Query<DynamicBuffer<PathWaypoint>>()) {
    foreach (var waypoint in buffer) {
        Debug.Log(waypoint.Position);
    }
}
```

---

## Tags（零大小组件）

### 定义 Tag

```csharp
public struct EnemyTag : IComponentData { } // Empty component = tag
```

### 使用 Tag 进行过滤

```csharp
// Only process entities with EnemyTag
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // Enemy-specific logic
}
```

---

## System 排序

### 显式排序

```csharp
[UpdateBefore(typeof(PhysicsSystem))]
public partial struct InputSystem : ISystem { }

[UpdateAfter(typeof(PhysicsSystem))]
public partial struct RenderSystem : ISystem { }
```

---

## 性能模式

### Chunk 迭代（最高性能）

```csharp
public void OnUpdate(ref SystemState state) {
    var query = SystemAPI.QueryBuilder().WithAll<Position, Velocity>().Build();

    var chunks = query.ToArchetypeChunkArray(Allocator.Temp);
    var positionType = state.GetComponentTypeHandle<Position>();
    var velocityType = state.GetComponentTypeHandle<Velocity>(true); // Read-only

    foreach (var chunk in chunks) {
        var positions = chunk.GetNativeArray(ref positionType);
        var velocities = chunk.GetNativeArray(ref velocityType);

        for (int i = 0; i < chunk.Count; i++) {
            positions[i] = new Position {
                Value = positions[i].Value + velocities[i].Value * deltaTime
            };
        }
    }

    chunks.Dispose();
}
```

---

## 从 MonoBehaviour 迁移

```csharp
// ❌ OLD: MonoBehaviour (OOP)
public class Enemy : MonoBehaviour {
    public float speed;
    void Update() {
        transform.position += Vector3.forward * speed * Time.deltaTime;
    }
}

// ✅ NEW: DOTS (ECS)
public struct EnemyData : IComponentData {
    public float Speed;
}

[BurstCompile]
public partial struct EnemyMovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        float dt = SystemAPI.Time.DeltaTime;
        foreach (var (transform, enemy) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<EnemyData>>()) {
            transform.ValueRW.Position += new float3(0, 0, enemy.ValueRO.Speed * dt);
        }
    }
}
```

---

## 调试

### Entities Hierarchy Window

`Window > Entities > Hierarchy`

- 显示所有实体及其组件
- 可按 archetype、组件类型过滤

### Entities Profiler

`Window > Analysis > Profiler > Entities`

- System 执行耗时
- 每种 archetype 的内存使用情况

---

## Sources
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html
- https://learn.unity.com/tutorial/entity-component-system
