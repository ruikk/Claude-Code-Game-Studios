# Unity 6.3 LTS — 当前最佳实践

**最后验证时间：** 2026-02-13

这些是现代 Unity 6 的实践模式，可能尚未包含在 LLM 的训练数据中。
以下建议基于 Unity 6.3 LTS，可直接用于生产环境。

---

## 项目设置

### 生产环境使用 Unity 6.3 LTS
- **Tech Stream** (6.4+)：最新特性更多，但稳定性较弱
- **LTS** (6.3)：可用于生产环境，提供 2 年支持（至 2027 年 12 月）

### 选择合适的渲染管线
- **URP (Universal)**：适合移动端、跨平台，性能表现优秀 ✅ 推荐大多数游戏使用
- **HDRP (High Definition)**：适合高端 PC / 主机，追求照片级真实感
- **Built-in**：已弃用，新项目应避免使用

---

## 脚本

### 使用 C# 9+ 特性（Unity 6 支持 C# 9）

```csharp
// ✅ 使用 record 类型表示数据
public record PlayerData(string Name, int Level, float Health);

// ✅ 仅初始化属性
public class Config {
    public string GameMode { get; init; }
}

// ✅ 模式匹配
var result = enemy switch {
    Boss boss => boss.Enrage(),
    Minion minion => minion.Flee(),
    _ => null
};
```

### 使用 Async/Await 加载资源

```csharp
// ✅ 现代异步模式
public async Task<GameObject> LoadEnemyAsync(string key) {
    var handle = Addressables.LoadAssetAsync<GameObject>(key);
    return await handle.Task;
}
```

### 使用 Source Generators 进行序列化（Unity 6+）

```csharp
// ✅ 源代码生成的序列化（更快、减少反射）
[GenerateSerializer]
public partial struct PlayerStats : IComponentData {
    public int Health;
    public int Mana;
}
```

---

## DOTS/ECS（在 Unity 6.3 LTS 中已可用于生产）

### 使用 ISystem（不要使用 ComponentSystem）

```csharp
// ✅ 现代非托管 ISystem（兼容 Burst）
public partial struct MovementSystem : ISystem {
    public void OnCreate(ref SystemState state) { }

    public void OnUpdate(ref SystemState state) {
        foreach (var (transform, speed) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<MoveSpeed>>()) {
            transform.ValueRW.Position += speed.ValueRO.Value * SystemAPI.Time.DeltaTime;
        }
    }
}
```

### 并行任务使用 IJobEntity

```csharp
// ✅ IJobEntity（替代 IJobForEach）
[BurstCompile]
public partial struct DamageJob : IJobEntity {
    public float DeltaTime;

    void Execute(ref Health health, in DamageOverTime dot) {
        health.Value -= dot.DamagePerSecond * DeltaTime;
    }
}

// 调度任务
var job = new DamageJob { DeltaTime = SystemAPI.Time.DeltaTime };
job.ScheduleParallel();
```

---

## 输入

### 使用 Input System package（不要使用旧版 Input）

```csharp
// ✅ Input Actions（支持重绑定、跨平台）
using UnityEngine.InputSystem;

public class PlayerInput : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();
        controls.Gameplay.Jump.performed += ctx => Jump();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();
}
```

在编辑器中创建 Input Actions asset，并通过 inspector 生成 C# class。

---

## UI

### 运行时 UI 使用 UI Toolkit（Unity 6 中已可用于生产）

```csharp
// ✅ UI Toolkit（新项目中替代 UGUI）
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour {
    void OnEnable() {
        var root = GetComponent<UIDocument>().rootVisualElement;

        var playButton = root.Q<Button>("play-button");
        playButton.clicked += StartGame;

        var scoreLabel = root.Q<Label>("score");
        scoreLabel.text = $"High Score: {PlayerPrefs.GetInt("HighScore")}";
    }
}
```

**UXML**（UI 结构）+ **USS**（样式）= 类似 HTML/CSS 的工作流。

---

## 资源管理

### 使用 Addressables（不要使用 Resources）

```csharp
// ✅ Addressables（异步、内存效率更高）
using UnityEngine.AddressableAssets;

public async Task SpawnEnemyAsync(string enemyKey) {
    var handle = Addressables.InstantiateAsync(enemyKey);
    var enemy = await handle.Task;

    // 清理：对象销毁时释放
    Addressables.ReleaseInstance(enemy);
}
```

**优势：** 异步加载、远程内容分发、更好的内存控制。

---

## 渲染

### 自定义 Pass 使用 RenderGraph API（URP/HDRP）

```csharp
// ✅ RenderGraph API（Unity 6+）
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
    using (var builder = renderGraph.AddRasterRenderPass<PassData>("My Pass", out var passData)) {
        // 设置 pass
        builder.SetRenderFunc((PassData data, RasterGraphContext context) => {
            // 执行命令
        });
    }
}
```

**替代：** 旧的 `CommandBuffer.Execute()` 模式。

---

## 性能

### 使用 Burst Compiler + Jobs System

```csharp
// ✅ Burst 编译任务（性能提升非常显著）
[BurstCompile]
struct ParticleUpdateJob : IJobParallelFor {
    public NativeArray<float3> Positions;
    public NativeArray<float3> Velocities;
    public float DeltaTime;

    public void Execute(int index) {
        Positions[index] += Velocities[index] * DeltaTime;
    }
}

// 调度
var job = new ParticleUpdateJob {
    Positions = positions,
    Velocities = velocities,
    DeltaTime = Time.deltaTime
};
job.Schedule(positions.Length, 64).Complete();
```

**比等价的 C# 代码快 20-100 倍**。

---

### 对重复对象使用 GPU Instancing

```csharp
// ✅ GPU Instancing（可绘制成千上万个对象，同时减少 draw call）
Graphics.RenderMeshInstanced(
    new RenderParams(material),
    mesh,
    0,
    matrices // NativeArray<Matrix4x4>
);
```

---

## 内存管理

### 在 Jobs 中使用 NativeContainers（不要使用托管数组）

```csharp
// ✅ NativeArray（无 GC，兼容 Burst）
NativeArray<int> data = new NativeArray<int>(1000, Allocator.TempJob);
// ... 在 job 中使用
data.Dispose(); // 需要手动清理

// ✅ 或使用 using 语句
using var data = new NativeArray<int>(1000, Allocator.TempJob);
// 自动释放
```

---

## 多人游戏

### 使用 Netcode for GameObjects（官方方案）

```csharp
// ✅ Unity 官方 netcode
using Unity.Netcode;

public class Player : NetworkBehaviour {
    private NetworkVariable<int> health = new NetworkVariable<int>(100);

    [ServerRpc]
    public void TakeDamageServerRpc(int damage) {
        health.Value -= damage;
    }
}
```

**替代：** UNet（已弃用）、MLAPI（已更名为 Netcode for GameObjects）。

---

## 测试

### 使用 Unity Test Framework（基于 NUnit）

```csharp
// ✅ Play Mode Test
[UnityTest]
public IEnumerator Player_TakesDamage_HealthDecreases() {
    var player = new GameObject().AddComponent<Player>();
    player.Health = 100;

    player.TakeDamage(25);
    yield return null; // 等待一帧

    Assert.AreEqual(75, player.Health);
}
```

---

## 调试

### 使用日志最佳实践

```csharp
// ✅ 结构化日志（Unity 6+）
using UnityEngine;

Debug.Log($"Player {playerName} scored {score} points");

// ✅ 对调试代码使用条件编译
#if UNITY_EDITOR || DEVELOPMENT_BUILD
    Debug.DrawRay(transform.position, direction, Color.red);
#endif
```

---

## 总结：Unity 6 技术栈

| 功能 | 推荐使用（2026） | 避免使用（旧方案） |
|---------|------------------|----------------------|
| **Input** | Input System package | `Input` class |
| **UI** | UI Toolkit | UGUI (Canvas) |
| **ECS** | ISystem + IJobEntity | ComponentSystem |
| **Rendering** | URP + RenderGraph | Built-in pipeline |
| **Assets** | Addressables | Resources |
| **Jobs** | Burst + IJobParallelFor | Coroutines for heavy work |
| **Multiplayer** | Netcode for GameObjects | UNet |

---

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/BestPracticeGuides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
