# Unity 6.3 — Navigation 模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** Unity 6 NavMesh 改进

---

## 概览

Unity 6 的导航系统包括：
- **NavMesh**：用于 AI 代理的内置路径寻找系统
- **NavMeshComponents**：用于在运行时构建 NavMesh 的包

---

## NavMesh 基础

### 烘焙导航网格

1. 标记可行走表面：
   - 选择 GameObject（地面/地形）
   - Inspector > Navigation > Object tab
   - 勾选 "Navigation Static"

2. 烘焙 NavMesh：
   - `Window > AI > Navigation`
   - Bake tab
   - 点击 "Bake"

3. 配置设置：
   - **Agent Radius**：代理的宽度（默认 0.5m）
   - **Agent Height**：代理的高度（默认 2m）
   - **Max Slope**：可行走的最大坡度（默认 45°）
   - **Step Height**：可攀爬的最大台阶高度（默认 0.4m）

---

## NavMeshAgent（AI 移动）

### 基础代理设置

```csharp
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour {
    private NavMeshAgent agent;
    public Transform target;

    void Start() {
        agent = GetComponent<NavMeshAgent>();
    }

    void Update() {
        // ✅ Move to target
        agent.SetDestination(target.position);
    }
}
```

---

### NavMeshAgent 属性

```csharp
NavMeshAgent agent = GetComponent<NavMeshAgent>();

// Speed
agent.speed = 3.5f;

// Acceleration
agent.acceleration = 8f;

// Stopping distance
agent.stoppingDistance = 2f; // Stop 2m before destination

// Auto-braking (slow down at destination)
agent.autoBraking = true;

// Rotation speed
agent.angularSpeed = 120f; // Degrees per second

// Obstacle avoidance
agent.obstacleAvoidanceType = ObstacleAvoidanceType.HighQualityObstacleAvoidance;
```

---

### 检查路径状态

```csharp
void Update() {
    agent.SetDestination(target.position);

    // Check if agent has a path
    if (agent.hasPath) {
        // Check if path is complete
        if (agent.pathStatus == NavMeshPathStatus.PathComplete) {
            Debug.Log("Valid path");
        } else if (agent.pathStatus == NavMeshPathStatus.PathPartial) {
            Debug.Log("Partial path (destination unreachable)");
        } else {
            Debug.Log("Invalid path");
        }
    }

    // Check if agent reached destination
    if (!agent.pathPending && agent.remainingDistance <= agent.stoppingDistance) {
        Debug.Log("Reached destination");
    }
}
```

---

### 计算路径（暂不移动）

```csharp
NavMeshPath path = new NavMeshPath();
agent.CalculatePath(targetPosition, path);

if (path.status == NavMeshPathStatus.PathComplete) {
    // Valid path exists
    agent.SetPath(path); // Apply the path
}
```

---

## NavMesh 区域（可行走代价）

### 定义区域
`Window > AI > Navigation > Areas tab`
- **Walkable**：代价 1（默认）
- **Not Walkable**：不可行走
- **Jump**：代价 2（优先选择其他路线）
- **Custom**：自定义区域

### 指定区域代价

```csharp
// Prefer shorter paths over low-cost paths
agent.areaMask = NavMesh.AllAreas; // Walk on all areas

// Only walk on "Walkable" area (avoid "Jump")
agent.areaMask = 1 << NavMesh.GetAreaFromName("Walkable");
```

---

## NavMesh 障碍物（动态障碍）

### NavMeshObstacle 组件

```csharp
// Add: GameObject > Add Component > NavMesh Obstacle

// Carve: Create hole in NavMesh (agents avoid)
// Don't Carve: Agent pushes through (local avoidance)
```

### 动态切割（移动障碍物）

```csharp
NavMeshObstacle obstacle = GetComponent<NavMeshObstacle>();
obstacle.carving = true; // Create dynamic hole in NavMesh
```

---

## Off-Mesh Links（跳跃、传送）

### 创建 Off-Mesh Link

1. `GameObject > Create Empty`（放在跳跃起点）
2. 添加 `Off Mesh Link` 组件
3. 设置 Start/End transforms
4. 配置：
   - **Bi-Directional**：可双向通行
   - **Cost Override**：该链接的路径代价

### 检测 Off-Mesh Link 穿越

```csharp
void Update() {
    // Check if agent is on an off-mesh link
    if (agent.isOnOffMeshLink) {
        // Manually traverse (e.g., play jump animation)
        StartCoroutine(TraverseOffMeshLink());
    }
}

IEnumerator TraverseOffMeshLink() {
    OffMeshLinkData data = agent.currentOffMeshLinkData;
    Vector3 startPos = agent.transform.position;
    Vector3 endPos = data.endPos;

    float duration = 0.5f;
    float elapsed = 0f;

    while (elapsed < duration) {
        agent.transform.position = Vector3.Lerp(startPos, endPos, elapsed / duration);
        elapsed += Time.deltaTime;
        yield return null;
    }

    agent.CompleteOffMeshLink(); // Resume normal pathfinding
}
```

---

## NavMeshComponents 包（运行时烘焙）

### 安装
1. `Window > Package Manager`
2. 通过 Git URL 添加：`com.unity.ai.navigation`

### 运行时 NavMesh 烘焙

```csharp
using Unity.AI.Navigation;

public class NavMeshBuilder : MonoBehaviour {
    public NavMeshSurface surface;

    void Start() {
        // Bake NavMesh at runtime
        surface.BuildNavMesh();
    }

    void UpdateNavMesh() {
        // Update NavMesh after terrain changes
        surface.UpdateNavMesh(surface.navMeshData);
    }
}
```

---

## 常见模式

### 在路点之间巡逻

```csharp
public Transform[] waypoints;
private int currentWaypoint = 0;

void Update() {
    if (!agent.pathPending && agent.remainingDistance < 0.5f) {
        // Reached waypoint, move to next
        currentWaypoint = (currentWaypoint + 1) % waypoints.Length;
        agent.SetDestination(waypoints[currentWaypoint].position);
    }
}
```

### 追逐玩家

```csharp
public Transform player;
public float chaseRange = 10f;

void Update() {
    float distance = Vector3.Distance(transform.position, player.position);

    if (distance <= chaseRange) {
        agent.SetDestination(player.position);
    } else {
        agent.ResetPath(); // Stop moving
    }
}
```

### 逃离玩家

```csharp
public Transform player;
public float fleeRange = 5f;

void Update() {
    float distance = Vector3.Distance(transform.position, player.position);

    if (distance <= fleeRange) {
        // Run away from player
        Vector3 fleeDirection = transform.position - player.position;
        Vector3 fleeTarget = transform.position + fleeDirection.normalized * 10f;

        agent.SetDestination(fleeTarget);
    }
}
```

---

## 调试

### NavMesh 可视化
- `Window > AI > Navigation > Bake tab`
- 勾选 "Show NavMesh" 以可视化可行走区域

### 代理路径 Gizmos

```csharp
void OnDrawGizmos() {
    if (agent != null && agent.hasPath) {
        Gizmos.color = Color.green;
        Vector3[] corners = agent.path.corners;

        for (int i = 0; i < corners.Length - 1; i++) {
            Gizmos.DrawLine(corners[i], corners[i + 1]);
        }
    }
}
```

---

## 性能建议

- **限制障碍物规避质量**：对远处代理使用 `LowQualityObstacleAvoidance`
- **更新频率**：如果目标没有移动，不要每帧都调用 `SetDestination()`
- **Area Masks**：限制可行走区域以缩小路径搜索空间
- **NavMesh Tiles**：大型世界使用分块 NavMesh（NavMeshComponents 包）

---

## 来源
- https://docs.unity3d.com/6000.0/Documentation/Manual/Navigation.html
- https://docs.unity3d.com/Packages/com.unity.ai.navigation@2.0/manual/index.html
manual/index.html
