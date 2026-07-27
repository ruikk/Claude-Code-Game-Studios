# Unreal Engine 5.7 — 破坏性变更

**最后验证时间：** 2026-02-13

本文档追踪 Unreal Engine 5.3（很可能包含在模型训练数据中）与 Unreal Engine 5.7（当前版本）之间会导致兼容性中断的 API 变化和行为差异，并按风险等级组织。

## HIGH RISK — 会破坏现有代码

### Substrate Material System（在 5.7 中达到生产可用）
**版本：** UE 5.5+（实验性），5.7（生产可用）

Substrate 以模块化、具备物理准确性的框架取代了旧版材质系统。

```cpp
// ❌ 旧：传统材质节点（仍可使用，但已弃用）
// Standard material graph with Base Color, Metallic, Roughness, etc.

// ✅ 新：Substrate 材质层
// Use Substrate nodes: Substrate Slab, Substrate Blend, etc.
// Modular material authoring with true physical accuracy
```

**迁移：** 在 `Project Settings > Engine > Substrate` 中启用 Substrate，并使用 Substrate 节点重建材质。

---

### PCG（Procedural Content Generation）API 大改
**版本：** UE 5.7（生产可用）

PCG 框架已达到生产可用状态，同时伴随了较大的 API 变更。

```cpp
// ❌ 旧：实验性 PCG API（5.7 之前）
// Old node types, unstable API

// ✅ 新：生产级 PCG API（5.7+）
// Use FPCGContext, IPCGElement, new node types
// Stable API, production-ready workflow
```

**迁移：** 参考 5.7 文档中的 PCG migration guide。若项目使用了实验性 PCG 代码，预计需要进行较大规模的重构。

---

### Megalights 渲染系统
**版本：** UE 5.5+

新的光照系统支持数百万个动态光源。

```cpp
// ❌ 旧：受限的动态光数量（clustered forward shading）
// Max ~100-200 dynamic lights before performance degrades

// ✅ 新：Megalights（5.5+）
// Millions of dynamic lights with minimal performance cost
// Enable: Project Settings > Engine > Rendering > Megalights
```

**迁移：** 无需修改代码，但光照表现可能会发生变化。启用后请重新测试场景。

---

## MEDIUM RISK — 行为变化

### Enhanced Input System（现已成为默认方案）
**版本：** UE 5.1+（推荐），5.7（默认）

Enhanced Input 现已成为默认输入系统。

```cpp
// ❌ 旧：传统输入绑定（已弃用）
InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

// ✅ 新：Enhanced Input
SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
}
```

**迁移：** 将旧版输入绑定替换为 Enhanced Input actions。

---

### Nanite 默认启用趋势
**版本：** UE 5.0+（可选），5.7（鼓励采用）

Nanite 虚拟化几何体现已成为静态网格的推荐工作流。

```cpp
// 在静态网格上启用 Nanite：
// Static Mesh Editor > Details > Nanite Settings > Enable Nanite Support
```

**迁移：** 将高面数网格转换为 Nanite，并在目标平台上测试性能。

---

## LOW RISK — 弃用项（仍可运行）

### 旧版材质系统
**状态：** 已弃用，但仍受支持
**替代方案：** Substrate Material System

旧版材质仍可使用，但新项目建议采用 Substrate。

---

### 旧版 World Partition（UE4 风格）
**状态：** 已弃用
**替代方案：** World Partition（UE5+）

大型世界请使用 UE5 的 World Partition 系统。

---

## 平台相关的破坏性变更

### Windows
- **UE 5.7**：DirectX 12 现已成为默认选项（旧版本通常为 DX11）
- 需要更新 shader 以兼容 DX12

### macOS
- **UE 5.5+**：要求使用 Metal 3（最低 macOS 13）

### Mobile
- **UE 5.7**：最低 Android API level 提升至 26（Android 8.0）
- 最低 iOS 部署目标提升至 iOS 14

---

## 迁移检查清单

从 UE 5.3 升级到 UE 5.7 时：

- [ ] 检查 Substrate 材质（若准备切换到新系统则进行转换）
- [ ] 审核 PCG 使用情况（若使用实验性版本则升级到生产级 API）
- [ ] 测试 Megalights 性能（启用并做基准测试）
- [ ] 将旧版输入迁移到 Enhanced Input
- [ ] 将高面数网格转换为 Nanite
- [ ] 针对 DX12（Windows）或 Metal 3（macOS）更新 shader
- [ ] 验证最低平台版本要求（Android 8.0、iOS 14）
- [ ] 在目标硬件上测试 Lumen 和 Nanite 性能

---

**来源：**
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
