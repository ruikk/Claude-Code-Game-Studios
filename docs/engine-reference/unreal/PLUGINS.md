# Unreal Engine 5.7 —— 可选插件与系统

**最后验证时间：** 2026-02-13

本文档索引了 Unreal Engine 5.7 中可用的**可选插件与系统**。
这些内容**不属于核心引擎**，但在特定类型游戏中很常用。

---

## 如何使用本指南

**✅ 提供详细文档** - 参见 `plugins/` 目录中的完整指南
**🟡 仅提供简要概览** - 链接到官方文档，细节请使用 WebSearch
**⚠️ Experimental** - 未来版本中可能出现破坏性变更
**📦 需要插件** - 必须在 `Edit > Plugins` 中启用

---

## 可用于生产的系统（提供详细文档）

### ✅ Gameplay Ability System (GAS)
- **用途：** 模块化能力系统（abilities、attributes、effects、cooldowns、costs）
- **适用场景：** RPG、MOBA、带技能系统的射击游戏，以及任何基于能力的玩法
- **知识缺口：** GAS 自 UE4 起已较稳定，UE5 的改进超出知识截止时间
- **状态：** 可用于生产
- **插件：** `GameplayAbilities`（内置，在 Plugins 中启用）
- **详细文档：** [plugins/gameplay-ability-system.md](plugins/gameplay-ability-system.md)
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/gameplay-ability-system-for-unreal-engine/

---

### ✅ CommonUI
- **用途：** 跨平台 UI 框架（自动处理 gamepad/mouse/touch 输入路由）
- **适用场景：** 多平台游戏（console + PC）、与输入设备无关的 UI
- **知识缺口：** 在 UE5+ 中已可用于生产，知识截止后有较大改进
- **状态：** 可用于生产
- **插件：** `CommonUI`（内置，在 Plugins 中启用）
- **详细文档：** [plugins/common-ui.md](plugins/common-ui.md)
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/

---

### ✅ Gameplay Camera System
- **用途：** 模块化相机管理（camera modes、blending、context-aware cameras）
- **适用场景：** 需要动态相机行为的游戏（第三人称、瞄准、载具）
- **知识缺口：** UE 5.5 中新增，完全超出知识截止时间
- **状态：** ⚠️ Experimental（UE 5.5-5.7）
- **插件：** `GameplayCameras`（内置，在 Plugins 中启用）
- **详细文档：** [plugins/gameplay-camera-system.md](plugins/gameplay-camera-system.md)
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/

---

### ✅ PCG (Procedural Content Generation)
- **用途：** 基于节点的程序化世界生成（植被、道具、地形细节）
- **适用场景：** 开放世界、程序化关卡、大规模环境铺设
- **知识缺口：** 在 UE 5.0-5.6 中为 Experimental，5.7 起可用于生产
- **状态：** 可用于生产（截至 UE 5.7）
- **插件：** `PCG`（内置，在 Plugins 中启用）
- **详细文档：** [plugins/pcg.md](plugins/pcg.md)
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/

---

## 其他可用于生产的插件（简要概览）

### 🟡 Mass Entity
- **用途：** 面向大规模 AI/人群的高性能 ECS（10,000+ entities）
- **适用场景：** RTS、城市模拟、大规模人群、大规模 AI
- **状态：** 可用于生产（UE 5.1+）
- **插件：** `MassEntity`, `MassGameplay`, `MassCrowd`
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/mass-entity-in-unreal-engine/

---

### 🟡 Niagara Fluids
- **用途：** GPU 流体模拟（烟雾、火焰、液体）
- **适用场景：** 真实火焰/烟雾效果、水体模拟
- **状态：** Experimental → 可用于生产（UE 5.4+）
- **插件：** `NiagaraFluids`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/niagara-fluids-in-unreal-engine/

---

### 🟡 Water Plugin
- **用途：** 海洋、河流、湖泊渲染与浮力
- **适用场景：** 含水域、船只、游泳玩法的游戏
- **状态：** 可用于生产（UE 5.0+）
- **插件：** `Water`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/water-system-in-unreal-engine/

---

### 🟡 Landmass Plugin
- **用途：** 地形雕刻与 Landscape 编辑
- **适用场景：** 大规模地形修改、程序化地貌
- **状态：** 可用于生产
- **插件：** `Landmass`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/landmass-plugin-in-unreal-engine/

---

### 🟡 Chaos Destruction
- **用途：** 实时碎裂与破坏
- **适用场景：** 可破坏环境（墙体、建筑、物体）
- **状态：** 可用于生产（UE 5.0+）
- **插件：** `ChaosDestruction`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/destruction-in-unreal-engine/

---

### 🟡 Chaos Vehicle
- **用途：** 高级车辆物理（轮式载具、悬挂）
- **适用场景：** 赛车游戏、载具占比较高的玩法
- **状态：** 可用于生产（替代 PhysX Vehicles）
- **插件：** `ChaosVehicles`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/chaos-vehicles-overview-in-unreal-engine/

---

### 🟡 Geometry Scripting
- **用途：** 运行时程序化网格生成与编辑
- **适用场景：** 动态网格创建、程序化建模
- **状态：** 可用于生产（UE 5.1+）
- **插件：** `GeometryScripting`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/geometry-scripting-in-unreal-engine/

---

### 🟡 Motion Design Tools
- **用途：** 动态图形、程序化动画、关键帧动画
- **适用场景：** UI 动画、程序化运动、关键帧序列
- **状态：** Experimental → 可用于生产（UE 5.4+）
- **插件：** `MotionDesign`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/motion-design-mode-in-unreal-engine/

---

## Experimental 插件（谨慎使用）

### ⚠️ AI Assistant (UE 5.7+)
- **用途：** 编辑器内 AI 指导与帮助
- **状态：** Experimental
- **插件：** 在 UE 5.7 设置中启用
- **官方信息：** 于 UE 5.7 release 中公布

---

### ⚠️ OpenXR (VR/AR)
- **用途：** 跨平台 VR/AR 支持
- **适用场景：** VR/AR 游戏
- **状态：** VR 可用于生产，AR 为 Experimental
- **插件：** `OpenXR`（内置）
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/openxr-in-unreal-engine/

---

### ⚠️ Online Subsystem (EOS, Steam, etc.)
- **用途：** 平台无关的在线服务（matchmaking、friends、achievements）
- **适用场景：** 具有在线功能的多人游戏
- **状态：** 可用于生产
- **插件：** `OnlineSubsystem`, `OnlineSubsystemEOS`, `OnlineSubsystemSteam`
- **官方文档：** https://docs.unrealengine.com/5.7/en-US/online-subsystem-in-unreal-engine/

---

## 已弃用插件（新项目应避免使用）

### ❌ PhysX Vehicles
- **已弃用：** 请改用 Chaos Vehicles
- **状态：** 旧版方案，不推荐

---

### ❌ Old Replication Graph
- **已弃用：** 已被 Iris（UE 5.1+）取代
- **状态：** 现代网络同步请使用 Iris

---

## 按需使用 WebSearch 的策略

对于**上文未列出的插件**，当用户提问时请采用以下方式：

1. 使用 **WebSearch** 搜索最新文档：`"Unreal Engine 5.7 [plugin name]"`
2. 验证该插件是否：
   - 超出知识截止时间（May 2025 之后）
   - 属于 Experimental 还是可用于生产
   - 在 UE 5.7 中是否仍受支持
3. 可选：将结果缓存到 `plugins/[plugin-name].md`，便于后续参考

---

## 快速决策指南

**我需要 abilities/skills/buffs** → **Gameplay Ability System (GAS)**
**我需要跨平台 UI（console + PC）** → **CommonUI**
**我需要动态相机** → **Gameplay Camera System**
**我需要程序化世界** → **PCG**
**我需要大型人群（数千 AI）** → **Mass Entity**
**我需要可破坏环境** → **Chaos Destruction**
**我需要车辆** → **Chaos Vehicles**
**我需要水体/海洋** → **Water Plugin**
**我需要 VR/AR** → **OpenXR**

---

**最后更新时间：** 2026-02-13
**引擎版本：** Unreal Engine 5.7
**LLM 知识截止时间：** May 2025
