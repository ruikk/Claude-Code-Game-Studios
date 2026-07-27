# Unity 6.3 LTS — 破坏性变更

**最后验证时间：** 2026-02-13

本文用于追踪 Unity 2022 LTS（很可能包含在模型训练数据中）与 Unity 6.3 LTS（当前版本）之间的 API 破坏性变更以及行为差异，并按风险等级进行整理。

## HIGH RISK — 会导致现有代码失效

### Entities/DOTS API 完全重构
**版本：** Entities 1.0+（Unity 6.0+）

```csharp
// ❌ OLD（Unity 6 之前，GameObjectEntity 模式）
public class HealthComponent : ComponentData {
    public float Value;
}

// ✅ NEW（Unity 6+，IComponentData）
public struct HealthComponent : IComponentData {
    public float Value;
}

// ❌ OLD：ComponentSystem
public class DamageSystem : ComponentSystem { }

// ✅ NEW：ISystem（非托管，可兼容 Burst）
public partial struct DamageSystem : ISystem {
    public void OnCreate(ref SystemState state) { }
    public void OnUpdate(ref SystemState state) { }
}
```

**迁移方式：** 按照 Unity 的 ECS 迁移指南处理。需要进行较大幅度的架构调整。

---

### Input System — 旧版 Input 已弃用
**版本：** Unity 6.0+

```csharp
// ❌ OLD：Input 类（已弃用）
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ NEW：Input System package
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**迁移方式：** 安装 Input System package，并将所有 `Input.*` 调用替换为新 API。

---

### URP/HDRP Renderer Feature API 变更
**版本：** Unity 6.0+

```csharp
// ❌ OLD：ScriptableRenderPass.Execute 签名
public override void Execute(ScriptableRenderContext context, ref RenderingData data)

// ✅ NEW：改用 RenderGraph API
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
```

**迁移方式：** 将自定义渲染 Pass 更新为使用 RenderGraph API。

---

## MEDIUM RISK — 行为变更

### Addressables — 资源加载返回行为变化
**版本：** Unity 6.2+

资源加载失败时，现在默认会抛出异常，而不是返回 null。
请补充合适的异常处理，或改用 `TryLoad` 变体。

```csharp
// ❌ OLD：失败时静默返回 null
var handle = Addressables.LoadAssetAsync<Sprite>("key");
var sprite = handle.Result; // 失败时为 null

// ✅ NEW：失败时抛出异常，使用 try/catch 或 TryLoad
try {
    var handle = Addressables.LoadAssetAsync<Sprite>("key");
    var sprite = await handle.Task;
} catch (Exception e) {
    Debug.LogError($"Failed to load: {e}");
}
```

---

### Physics — 默认求解器迭代次数已更改
**版本：** Unity 6.0+

为提升稳定性，默认求解器迭代次数已增加。
如果你的项目依赖旧行为，请检查 `Physics.defaultSolverIterations`。

---

## LOW RISK — 弃用项（仍可使用）

### UGUI（旧版 UI）
**状态：** 已弃用，但仍受支持
**替代方案：** UI Toolkit

UGUI 仍可继续使用，但新项目建议采用 UI Toolkit。

---

### 旧版粒子系统
**状态：** 已弃用
**替代方案：** Visual Effect Graph (VFX Graph)

---

### 旧版动画系统
**状态：** 已弃用
**替代方案：** Animator Controller (Mecanim)

---

## 平台相关破坏性变更

### WebGL
- **Unity 6.0+**：WebGPU 现已成为默认选项（仍可回退到 WebGL 2.0）
- 需要更新 shader 以兼容 WebGPU

### Android
- **Unity 6.0+**：最低 API 级别提升至 24（Android 7.0）

### iOS
- **Unity 6.0+**：最低部署目标版本提升至 iOS 13

---

## 迁移检查清单

当从 2022 LTS 升级到 Unity 6.3 LTS 时：

- [ ] 审查所有 DOTS/ECS 代码（很可能需要完全重写）
- [ ] 将 `Input` 类替换为 Input System package
- [ ] 将自定义渲染 Pass 更新到 RenderGraph API
- [ ] 为 Addressables 调用补充异常处理
- [ ] 测试 Physics 行为（求解器迭代次数已变化）
- [ ] 为新 UI 评估是否从 UGUI 迁移到 UI Toolkit
- [ ] 更新 WebGL shader 以适配 WebGPU
- [ ] 验证最低平台版本要求（Android/iOS）

---

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/upgrade-guide.html
