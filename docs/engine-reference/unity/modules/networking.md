# Unity 6.3 — Networking 模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** Unity 6 使用 Netcode for GameObjects（UNet 已弃用）

---

## 概览

Unity 6 的联网选项：
- **Netcode for GameObjects**（推荐）：Unity 官方多人游戏框架
- **Mirror**：社区驱动（UNet 的后继方案）
- **Photon**：第三方服务（PUN2）
- **Custom**：底层 sockets

**UNet（旧版）**：已弃用，不要使用。

---

## Netcode for GameObjects

### 安装
1. `Window > Package Manager`
2. 搜索 “Netcode for GameObjects”
3. 安装 `com.unity.netcode.gameobjects`

---

## 基础配置

### NetworkManager

```csharp
// Add to scene: GameObject > Add Component > NetworkManager

// Or create custom NetworkManager:
using Unity.Netcode;

public class CustomNetworkManager : MonoBehaviour {
    void Start() {
        NetworkManager.Singleton.StartHost(); // Server + client
        // OR
        NetworkManager.Singleton.StartServer(); // Dedicated server
        // OR
        NetworkManager.Singleton.StartClient(); // Client only
    }
}
```

---

## NetworkObject（联网 GameObject）

### 将 GameObject 标记为可联网对象

1. 给 GameObject 添加 `NetworkObject` 组件
2. 必须位于 prefab 根节点（不能嵌套）
3. 在 `NetworkManager > NetworkPrefabs List` 中注册 prefab

### 生成网络对象

```csharp
using Unity.Netcode;

public class GameManager : NetworkBehaviour {
    public GameObject playerPrefab;

    [ServerRpc(RequireOwnership = false)]
    public void SpawnPlayerServerRpc(ulong clientId) {
        GameObject player = Instantiate(playerPrefab);
        player.GetComponent<NetworkObject>().SpawnAsPlayerObject(clientId);
    }
}
```

---

## NetworkBehaviour（联网脚本）

### NetworkBehaviour 基类

```csharp
using Unity.Netcode;

public class Player : NetworkBehaviour {
    // Called when spawned on network
    public override void OnNetworkSpawn() {
        if (IsOwner) {
            // Only run on owner's client
            GetComponent<Camera>().enabled = true;
        }
    }

    void Update() {
        if (!IsOwner) return; // Only owner can control

        // Handle input
        if (Input.GetKey(KeyCode.W)) {
            MoveServerRpc(Vector3.forward);
        }
    }

    [ServerRpc]
    void MoveServerRpc(Vector3 direction) {
        // Runs on server
        transform.position += direction * Time.deltaTime;
    }
}
```

---

## Network Variables（同步状态）

### NetworkVariable<T>

```csharp
using Unity.Netcode;

public class Player : NetworkBehaviour {
    // ✅ Auto-synced across clients
    private NetworkVariable<int> health = new NetworkVariable<int>(100);

    public override void OnNetworkSpawn() {
        // Subscribe to value changes
        health.OnValueChanged += OnHealthChanged;
    }

    void OnHealthChanged(int oldValue, int newValue) {
        Debug.Log($"Health changed: {oldValue} -> {newValue}");
        UpdateHealthUI(newValue);
    }

    [ServerRpc]
    public void TakeDamageServerRpc(int damage) {
        // Only server can modify NetworkVariable
        health.Value -= damage;
    }
}
```

### NetworkVariable 权限

```csharp
// Server can write, clients read-only (default)
private NetworkVariable<int> score = new NetworkVariable<int>();

// Owner can write
private NetworkVariable<int> ammo = new NetworkVariable<int>(
    default,
    NetworkVariableReadPermission.Everyone,
    NetworkVariableWritePermission.Owner
);
```

---

## RPC（远程过程调用）

### ServerRpc（客户端 → 服务器）

```csharp
// Client calls, server executes
[ServerRpc]
void FireWeaponServerRpc() {
    // Runs on server
    Debug.Log("Server: Weapon fired");
}

// Call from client:
if (IsOwner && Input.GetKeyDown(KeyCode.Space)) {
    FireWeaponServerRpc();
}
```

### ClientRpc（服务器 → 所有客户端）

```csharp
// Server calls, all clients execute
[ClientRpc]
void PlayExplosionClientRpc(Vector3 position) {
    // Runs on all clients
    Instantiate(explosionPrefab, position, Quaternion.identity);
}

// Call from server:
[ServerRpc]
void ExplodeServerRpc(Vector3 position) {
    // Server logic
    DealDamageToNearbyPlayers(position);

    // Notify all clients
    PlayExplosionClientRpc(position);
}
```

### RPC 参数

```csharp
// ✅ Supported: Primitives, structs, strings, arrays
[ServerRpc]
void SetNameServerRpc(string playerName) { }

[ClientRpc]
void UpdateScoresClientRpc(int[] scores) { }

// ❌ Not supported: MonoBehaviour, GameObject (use NetworkObjectReference)
```

---

## 网络所有权

### 检查所有权

```csharp
if (IsOwner) {
    // This client owns this NetworkObject
}

if (IsServer) {
    // Running on server
}

if (IsClient) {
    // Running on client
}

if (IsLocalPlayer) {
    // This is the local player object
}
```

### 转移所有权

```csharp
// Server transfers ownership
NetworkObject netObj = GetComponent<NetworkObject>();
netObj.ChangeOwnership(newOwnerClientId);
```

---

## NetworkObjectReference（在 RPC 中传递 GameObject）

```csharp
using Unity.Netcode;

[ServerRpc]
void AttackTargetServerRpc(NetworkObjectReference targetRef) {
    if (targetRef.TryGet(out NetworkObject target)) {
        // Got the target object
        target.GetComponent<Health>().TakeDamage(10);
    }
}

// Call:
NetworkObject targetNetObj = target.GetComponent<NetworkObject>();
AttackTargetServerRpc(targetNetObj);
```

---

## 客户端-服务器架构

### 服务器权威（Server-Authoritative）模式（推荐）

```csharp
public class Player : NetworkBehaviour {
    private NetworkVariable<Vector3> position = new NetworkVariable<Vector3>();

    void Update() {
        if (IsOwner) {
            // Client: Send input to server
            Vector3 input = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
            MoveServerRpc(input);
        }

        // All clients: Sync to networked position
        transform.position = position.Value;
    }

    [ServerRpc]
    void MoveServerRpc(Vector3 input) {
        // Server: Validate and apply movement
        position.Value += input * Time.deltaTime * moveSpeed;
    }
}
```

---

## 网络传输层

### Unity Transport（默认）

```csharp
// Configured in NetworkManager:
// - Transport: Unity Transport
// - Address: 127.0.0.1 (localhost) or server IP
// - Port: 7777 (default)
```

### 连接事件

```csharp
void Start() {
    NetworkManager.Singleton.OnClientConnectedCallback += OnClientConnected;
    NetworkManager.Singleton.OnClientDisconnectCallback += OnClientDisconnected;
}

void OnClientConnected(ulong clientId) {
    Debug.Log($"Client {clientId} connected");
}

void OnClientDisconnected(ulong clientId) {
    Debug.Log($"Client {clientId} disconnected");
}
```

---

## 性能建议

### 减少网络流量
- 对变更频率较低的状态使用 `NetworkVariable`
- 在同步前批量合并多次变更
- 对大体量数据使用 delta compression

### Prediction 与 Reconciliation
- 在本地运行移动逻辑以提升响应性
- 与服务器权威状态进行 reconciliation
- 使用 interpolation 实现平滑移动

---

## 调试

### Network Profiler
- `Window > Analysis > Network Profiler`
- 监控带宽、RPC 调用、变量更新

### Network Simulator（测试延迟/丢包）
- `NetworkManager > Network Simulator`
- 添加人工延迟和丢包进行测试

---

## 资料来源
- https://docs-multiplayer.unity3d.com/netcode/current/about/
- https://docs-multiplayer.unity3d.com/netcode/current/learn/bossroom/
