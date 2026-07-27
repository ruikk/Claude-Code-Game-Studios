# Unity 6.3 LTS — 已弃用 API

**最后验证时间：** 2026-02-13

用于快速查阅已弃用 API 及其替代方案的对照表。
格式：**不要使用 X** → **请改用 Y**

---

## Input

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `Input.GetKey()` | `Keyboard.current[Key.X].isPressed` | 新 Input System |
| `Input.GetKeyDown()` | `Keyboard.current[Key.X].wasPressedThisFrame` | 新 Input System |
| `Input.GetMouseButton()` | `Mouse.current.leftButton.isPressed` | 新 Input System |
| `Input.GetAxis()` | `InputAction` callbacks | 新 Input System |
| `Input.mousePosition` | `Mouse.current.position.ReadValue()` | 新 Input System |

**迁移说明：** 安装 `com.unity.inputsystem` package。

---

## UI

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `Canvas` (UGUI) | `UIDocument` (UI Toolkit) | UI Toolkit 现已可用于生产环境 |
| `Text` component | `TextMeshPro` 或 UI Toolkit 的 `Label` | 渲染效果更好，draw call 更少 |
| `Image` component | 使用带背景的 UI Toolkit `VisualElement` | 样式更灵活 |

**迁移说明：** UGUI 仍然可用，但新项目推荐使用 UI Toolkit。

---

## DOTS/Entities

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `ComponentSystem` | `ISystem` (unmanaged) | Entities 1.0+ 完全重写 |
| `JobComponentSystem` | 搭配 `IJobEntity` 的 `ISystem` | 兼容 Burst |
| `GameObjectEntity` | 纯 ECS 工作流 | 不再进行 GameObject 转换 |
| `EntityManager.CreateEntity()` (old signature) | `EntityManager.CreateEntity(EntityArchetype)` | 显式指定 archetype |
| `ComponentDataFromEntity<T>` | `ComponentLookup<T>` | Entities 1.0+ 中重命名 |

**迁移说明：** 请参阅 Entities package migration guide。需要进行较大规模的重构。

---

## Rendering

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `CommandBuffer.DrawMesh()` | RenderGraph API | 用于 URP/HDRP 渲染通道 |
| `OnPreRender()` / `OnPostRender()` | `RenderPipelineManager` callbacks | 兼容 SRP |
| `Camera.SetReplacementShader()` | 自定义 render pass | SRP 中不支持 |

---

## Physics

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `Physics.RaycastAll()` | `Physics.RaycastNonAlloc()` | 避免 GC 分配 |
| `Rigidbody.velocity` (direct write) | `Rigidbody.AddForce()` | 物理稳定性更好 |

---

## Asset Loading

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `Resources.Load()` | Addressables | 更好的内存控制与异步加载 |
| 同步资源加载 | `Addressables.LoadAssetAsync()` | 非阻塞 |

---

## Animation

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| Legacy Animation component | Animator Controller | Mecanim 系统 |
| `Animation.Play()` | `Animator.Play()` | 状态机控制 |

---

## Particles

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| Legacy Particle System | Visual Effect Graph | GPU 加速，性能更高 |

---

## Scripting

| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| `WWW` class | `UnityWebRequest` | 现代异步网络请求 |
| `Application.LoadLevel()` | `SceneManager.LoadScene()` | 场景管理 |

---

## Platform-Specific

### WebGL
| 已弃用 | 替代方案 | 说明 |
|------------|-------------|-------|
| WebGL 1.0 | WebGL 2.0 或 WebGPU | Unity 6+ 默认使用 WebGPU |

---

## 快速迁移模式

### Input 示例
```csharp
// ❌ 已弃用
if (Input.GetKeyDown(KeyCode.Space)) {
    Jump();
}

// ✅ 新 Input System
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) {
    Jump();
}
```

### Asset Loading 示例
```csharp
// ❌ 已弃用
var prefab = Resources.Load<GameObject>("Enemies/Goblin");

// ✅ Addressables
var handle = Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin");
await handle.Task;
var prefab = handle.Result;
```

### UI 示例
```csharp
// ❌ 已弃用 (UGUI)
GetComponent<Text>().text = "Score: 100";

// ✅ TextMeshPro
GetComponent<TextMeshProUGUI>().text = "Score: 100";

// ✅ UI Toolkit
rootVisualElement.Q<Label>("score-label").text = "Score: 100";
```

---

**来源：**
- https://docs.unity3d.com/6000.0/Documentation/Manual/deprecated-features.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/Migration.html
