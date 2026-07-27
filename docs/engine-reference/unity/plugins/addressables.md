# Unity 6.3 — Addressables

**最后验证时间：** 2026-02-13
**状态：** 可用于生产环境
**包：** `com.unity.addressables` (Package Manager)

---

## 概览

**Addressables** 是 Unity 的高级资源管理系统，用异步加载、远程内容分发和更精细的内存控制来替代 `Resources.Load()`。

**Addressables 适合用于：**
- 异步资源加载（不阻塞）
- DLC 和远程内容
- 内存优化（按需加载/卸载）
- 资源依赖管理
- 拥有大量资源的大型项目

**不要在以下场景使用 Addressables：**
- 小型项目（额外开销不值得）
- 启动时必须立刻可用的资源（改用直接引用）

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 “Addressables”
3. 安装 `Addressables`

---

## 核心概念

### 1. **Addressable Assets**
- 被标记为 “Addressable” 的资源（分配唯一 key）
- 可在运行时通过 key 加载

### 2. **Asset Groups**
- 用于组织资源（例如 “UI”、“Weapons”、“Level1”）
- Group 决定构建设置（本地或远程）

### 3. **Async Loading**
- 所有加载都是异步的（不阻塞）
- 返回 `AsyncOperationHandle`

### 4. **Reference Counting**
- Addressables 会跟踪资源使用情况
- 使用完成后必须手动释放资源

---

## 设置

### 1. 将资源标记为 Addressable

1. 在 Project 窗口中选中资源
2. Inspector > 勾选 “Addressable”
3. 分配 key（例如 `"Enemies/Goblin"`）

**或者通过脚本：**
```csharp
#if UNITY_EDITOR
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;

AddressableAssetSettings.AddAssetEntry(guid, "MyAssetKey", "Default Local Group");
#endif
```

---

### 2. 创建 Groups

`Window > Asset Management > Addressables > Groups`

- **Default Local Group**：随构建一起打包
- **Remote Group**：托管在服务器（CDN）上

---

## 基础加载

### 异步加载资源

```csharp
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class AssetLoader : MonoBehaviour {
    async void Start() {
        // ✅ 异步加载资源
        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin");
        await handle.Task;

        if (handle.Status == AsyncOperationStatus.Succeeded) {
            GameObject prefab = handle.Result;
            Instantiate(prefab);
        } else {
            Debug.LogError("Failed to load asset");
        }

        // ⚠️ 重要：用完后释放
        Addressables.Release(handle);
    }
}
```

---

### 加载并实例化

```csharp
async void SpawnEnemy() {
    // ✅ 一步完成加载和实例化
    AsyncOperationHandle<GameObject> handle = Addressables.InstantiateAsync("Enemies/Goblin");
    await handle.Task;

    GameObject enemy = handle.Result;
    // 使用 enemy...

    // ✅ 销毁时释放
    Addressables.ReleaseInstance(enemy);
}
```

---

### 加载多个资源

```csharp
async void LoadAllWeapons() {
    // 加载带有 "Weapons" 标签的所有资源
    AsyncOperationHandle<IList<GameObject>> handle = Addressables.LoadAssetsAsync<GameObject>("Weapons", null);
    await handle.Task;

    foreach (var weapon in handle.Result) {
        Debug.Log($"Loaded: {weapon.name}");
    }

    Addressables.Release(handle);
}
```

---

## Asset Labels（标签）

### 分配标签

1. `Window > Asset Management > Addressables > Groups`
2. 选中资源 > Inspector > Labels > Add label（例如 `"Level1"`、`"UI"`）

### 按标签加载

```csharp
// 加载所有带有 "Level1" 标签的资源
Addressables.LoadAssetsAsync<GameObject>("Level1", null);
```

---

## 远程内容（DLC）

### 设置 Remote Groups

1. 创建新 group：`Window > Addressables > Groups > Create New Group > Packed Assets`
2. Group Settings：
   - **Build Path**：`ServerData/[BuildTarget]`
   - **Load Path**：`http://yourcdn.com/content/[BuildTarget]`

### 构建远程内容

1. `Window > Asset Management > Addressables > Build > New Build > Default Build Script`
2. 将 `ServerData/` 文件夹上传到 CDN
3. 游戏会从远程服务器加载资源

---

## 预加载 / 缓存

### 下载依赖

```csharp
async void PreloadLevel() {
    // 下载组内所有资源，但不加载到内存中
    AsyncOperationHandle handle = Addressables.DownloadDependenciesAsync("Level1");
    await handle.Task;

    // 现在 "Level1" 资源已缓存，可立即加载
    Addressables.Release(handle);
}
```

### 检查下载大小

```csharp
async void CheckDownloadSize() {
    AsyncOperationHandle<long> handle = Addressables.GetDownloadSizeAsync("Level1");
    await handle.Task;

    long sizeInBytes = handle.Result;
    Debug.Log($"Download size: {sizeInBytes / (1024 * 1024)} MB");

    Addressables.Release(handle);
}
```

---

## 内存管理

### 释放资源

```csharp
// ✅ 用完后始终释放
Addressables.Release(handle);

// ✅ 对已实例化对象
Addressables.ReleaseInstance(gameObject);
```

### 检查引用计数

```csharp
// Addressables 使用引用计数
// 当 refCount == 0 时，资源会被卸载
```

---

## Asset References（Inspector 分配）

### 使用 AssetReference

```csharp
using UnityEngine.AddressableAssets;

public class EnemySpawner : MonoBehaviour {
    // ✅ 在 Inspector 中分配（拖拽）
    public AssetReference enemyPrefab;

    async void SpawnEnemy() {
        AsyncOperationHandle<GameObject> handle = enemyPrefab.InstantiateAsync();
        await handle.Task;

        GameObject enemy = handle.Result;
        // 使用 enemy...

        enemyPrefab.ReleaseInstance(enemy);
    }
}
```

---

## 场景

### 加载 Addressable Scene

```csharp
using UnityEngine.SceneManagement;

async void LoadScene() {
    AsyncOperationHandle<SceneInstance> handle = Addressables.LoadSceneAsync("MainMenu", LoadSceneMode.Additive);
    await handle.Task;

    SceneInstance sceneInstance = handle.Result;
    // 场景已加载

    // 卸载场景
    await Addressables.UnloadSceneAsync(handle).Task;
}
```

---

## 常见模式

### Lazy Loading（按需加载）

```csharp
Dictionary<string, AsyncOperationHandle<GameObject>> loadedAssets = new();

async Task<GameObject> GetAsset(string key) {
    if (!loadedAssets.ContainsKey(key)) {
        var handle = Addressables.LoadAssetAsync<GameObject>(key);
        await handle.Task;
        loadedAssets[key] = handle;
    }
    return loadedAssets[key].Result;
}
```

---

### 场景卸载时清理

```csharp
void OnDestroy() {
    // 释放所有 handle
    foreach (var handle in loadedAssets.Values) {
        Addressables.Release(handle);
    }
    loadedAssets.Clear();
}
```

---

## Content Catalog 更新（在线更新）

### 检查 Catalog 更新

```csharp
async void CheckForUpdates() {
    AsyncOperationHandle<List<string>> handle = Addressables.CheckForCatalogUpdates();
    await handle.Task;

    if (handle.Result.Count > 0) {
        Debug.Log("Updates available");
        await Addressables.UpdateCatalogs(handle.Result).Task;
    }

    Addressables.Release(handle);
}
```

---

## 性能建议

- 在启动时**预加载**高频使用的资源
- 不再需要时立即**释放**资源
- 使用 **labels** 批量加载相关资源
- 对远程内容进行**缓存**，以支持离线使用

---

## 调试

### Addressables Event Viewer

`Window > Asset Management > Addressables > Event Viewer`

- 显示所有加载/释放操作
- 每个资源的内存占用
- 引用计数

### Addressables Profiler

`Window > Asset Management > Addressables > Profiler`

- 实时资源使用情况
- Bundle 加载统计

---

## 从 Resources 迁移

```csharp
// ❌ 旧方式：Resources.Load（同步，会阻塞帧）
GameObject prefab = Resources.Load<GameObject>("Enemies/Goblin");

// ✅ 新方式：Addressables（异步，不阻塞）
var handle = await Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin").Task;
GameObject prefab = handle.Result;
```

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html
- https://learn.unity.com/tutorial/addressables
