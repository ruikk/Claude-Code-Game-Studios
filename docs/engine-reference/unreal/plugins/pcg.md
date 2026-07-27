# Unreal Engine 5.7 — PCG（程序化内容生成）

**最后验证时间：** 2026-02-13
**状态：** 可用于生产（自 UE 5.7 起）
**插件：** `PCG`（内置，在 Plugins 中启用）

---

## 概述

**程序化内容生成（Procedural Content Generation, PCG）** 是 Unreal 基于节点的框架，用于大规模生成程序化内容。它专为在大型开放世界中铺设植被、岩石、道具、建筑以及其他环境细节而设计。

**适合将 PCG 用于：**
- 程序化植被摆放（树木、草地、岩石）
- 基于生物群系的环境生成
- 道路/路径生成
- 建筑/结构摆放
- 世界细节填充（道具、杂物）

**不要将 PCG 用于：**
- 游戏逻辑（请使用 Blueprints/C++）
- 一次性的手动摆放（请使用编辑器工具）

**⚠️ 注意：** PCG 在 UE 5.0-5.6 中属于实验性功能，从 UE 5.7 起变为可用于生产。

---

## 核心概念

### 1. **PCG Graph**
- 基于节点的图（类似 Material Editor）
- 定义生成规则

### 2. **PCG Component**
- 放置在关卡中，执行 PCG Graph
- 在定义好的体积范围内生成内容

### 3. **PCG Data**
- 点数据（位置、旋转、缩放）
- 样条数据（路径、道路、河流）
- 体积数据（密度、生物群系遮罩）

### 4. **Nodes**
- **Samplers**：生成点（Grid、Poisson、Surface）
- **Filters**：按规则移除点（Density、Tag、Bounds）
- **Modifiers**：变换点（Offset、Rotate、Scale）
- **Spawners**：在点上实例化 mesh/actor

---

## 设置

### 1. 启用插件

`Edit > Plugins > PCG > Enabled > Restart`

### 2. 创建 PCG Volume

1. Place Actors > Volumes > PCG Volume
2. 将体积缩放到目标生成区域

### 3. 创建 PCG Graph

1. Content Browser > PCG > PCG Graph
2. 打开 PCG Graph Editor

---

## 基础工作流

### 示例：森林生成

#### 1. 创建 PCG Graph

**节点设置：**
```
Input (Volume)
  ↓
Surface Sampler (采样体积表面，每 m² 点数: 0.5)
  ↓
Density Filter (使用纹理遮罩或噪声)
  ↓
Static Mesh Spawner (树木 meshes)
  ↓
Output
```

#### 2. 将 Graph 赋给 Volume

1. 选中 PCG Volume
2. Details Panel > PCG Component > Graph = 你的 PCG Graph
3. 点击 “Generate” 按钮

---

## 关键节点类型

### Samplers（点生成）

#### Grid Sampler
- 规则网格点
- 可配置：
  - **Grid Size**：点之间的距离
  - **Offset**：每个点的随机偏移

#### Poisson Disk Sampler
- 具有最小间距的随机点
- 可配置：
  - **Points Per m²**：密度
  - **Min Distance**：点之间的间距

#### Surface Sampler
- 在 mesh 表面或 landscape 上生成点
- 可配置：
  - **Points Per m²**：密度
  - **Surface Only**：仅表面，不包含体积内部

---

### Filters（点移除）

#### Density Filter
- 根据密度值移除点
- 输入：纹理或噪声
- 用途：生物群系遮罩、空地、路径

#### Tag Filter
- 按标签过滤点
- 用途：条件生成

#### Bounds Filter
- 仅保留边界范围内的点
- 用途：将生成限制在特定区域

---

### Modifiers（点变换）

#### Rotate
- 随机化点旋转
- 可配置：
  - **Min/Max Rotation**：各轴旋转范围

#### Scale
- 随机化点缩放
- 可配置：
  - **Min/Max Scale**：缩放范围

#### Project to Ground
- 将点贴合到 landscape 表面

---

### Spawners（Mesh/Actor 实例化）

#### Static Mesh Spawner
- 在点上生成静态 mesh
- 可配置：
  - **Mesh List**：mesh 数组（随机选择）
  - **Culling Distance**：LOD/剔除设置

#### Actor Spawner
- 在点上生成 Blueprint actor
- 用途：游戏 actor、可交互对象

---

## 数据源

### Landscape
- 使用 landscape 作为采样输入
- 自动投影到 landscape 高度

### Splines
- 沿样条生成内容（道路、河流、路径）
- 示例：沿路径生成树木

### Textures
- 使用纹理作为密度遮罩
- 用于绘制生物群系、空地、区域

---

## 生物群系示例（混合森林）

### Graph 设置

```
Input (Landscape)
  ↓
Surface Sampler (密度: 1.0)
  ↓
┌─────────────────┬─────────────────┐
│ Tree Biome      │ Rock Biome      │
│ (density > 0.5) │ (density < 0.5) │
├─────────────────┼─────────────────┤
│ Tree Spawner    │ Rock Spawner    │
└─────────────────┴─────────────────┘
  ↓
Merge
  ↓
Output
```

---

## 基于样条的生成（带树木的道路）

### 1. 创建 PCG Graph

```
Spline Input
  ↓
Spline Sampler (沿样条采样)
  ↓
Offset (相对样条路径偏移)
  ↓
Tree Spawner
  ↓
Output
```

### 2. 向 PCG Volume 添加 Spline Component

1. PCG Volume > Add Component > Spline
2. 绘制样条路径
3. PCG Graph 读取样条数据

---

## 运行时生成

### 从 C++ 触发生成

```cpp
#include "PCGComponent.h"

UPCGComponent* PCGComp = /* Get PCG Component */;
PCGComp->Generate(); // 执行 PCG graph
```

### 流式生成（大型世界）

- PCG 会随 World Partition 自动进行流式处理
- 仅在已加载的 cells 中生成内容

---

## 性能

### 优化建议

- 为生成的 mesh 使用 **culling distance**（LOD）
- 限制 **density**（点越少，性能越好）
- 对重复 mesh 使用 **Hierarchical Instanced Static Meshes (HISM)**
- 在大型世界中启用 **streaming**

### 调试性能

```cpp
// Console commands:
// pcg.graph.debug 1 - Show PCG debug info
// stat pcg - Show PCG performance stats
```

---

## 常见模式

### 带空地的森林

```
Surface Sampler
  ↓
Density Filter (带空地的噪声纹理)
  ↓
Tree Spawner (pine, oak, birch)
```

---

### 陡坡上的岩石

```
Landscape Input
  ↓
Surface Sampler
  ↓
Slope Filter (angle > 30°)
  ↓
Rock Spawner
```

---

### 道路沿线道具

```
Spline Input (road spline)
  ↓
Spline Sampler
  ↓
Offset (道路侧边)
  ↓
Street Light Spawner
```

---

## 调试

### PCG 调试可视化

```cpp
// Console commands:
// pcg.debug.display 1 - Show points and generation bounds
// pcg.debug.colormode points - Color-code points
```

### Graph 调试

- PCG Graph Editor > Debug > Show Debug Points
- 可视化 graph 中每个节点上的点

---

## 从 UE 5.6（实验性）迁移到 5.7（生产可用）

### API 变更

```cpp
// ❌ OLD (5.6 experimental API):
// Some nodes renamed, API unstable

// ✅ NEW (5.7 production API):
// Stable node types, documented API
```

**迁移方式：** 使用稳定的 5.7 节点重新构建 PCG graphs，并进行充分测试。

---

## 限制

- **不适用于游戏逻辑**：游戏规则请使用 Blueprints/C++
- **大型 graphs 可能较慢**：通过 filters 和降低 density 进行优化
- **运行时生成有额外开销**：条件允许时尽量预生成

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/pcg-quick-start-in-unreal-engine/
- UE 5.7 Release Notes（PCG Production-Ready 公告）
