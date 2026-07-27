# Godot Animation — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **IK 系统完全恢复**: 为 3D 骨骼提供完整的反向运动学
  - CCDIK, FABRIK, Jacobian IK, Spline IK, TwoBoneIK
  - 通过 `SkeletonModifier3D` 节点应用（不是旧版 IK 方式）
- **动画编辑器体验改进**: Bezier 节点组支持独奏/隐藏/锁定/删除；时间线可拖动

### 4.5 变更
- **BoneConstraint3D**: 使用修改器将骨骼绑定到其他骨骼
  - `AimModifier3D`, `CopyTransformModifier3D`, `ConvertTransformModifier3D`

### 4.3 变更（训练数据已覆盖）
- **AnimationMixer**: AnimationPlayer 和 AnimationTree 的基类
  - `method_call_mode` → `callback_mode_method`
  - `playback_active` → `active`
  - `bone_pose_updated` signal → `skeleton_updated`
- **`Skeleton3D.add_bone()`**: Now returns `int32` (was `void`)

## 当前 API 模式

### AnimationPlayer（API 未变，基类已更新）
```gdscript
@onready var anim_player: AnimationPlayer = %AnimationPlayer

func play_attack() -> void:
    anim_player.play(&"attack")
    await anim_player.animation_finished
```

### IK 设置（4.6 — 新增）
```gdscript
# 将基于 SkeletonModifier3D 的 IK 节点添加为 Skeleton3D 的子节点
# 可用类型:
# - SkeletonModifier3D（基类）
# - TwoBoneIK（手臂、腿）
# - FABRIK（链条、触手）
# - CCDIK（尾巴、脊柱）
# - Jacobian IK（复杂多关节）
# - Spline IK（沿曲线）

# 在编辑器或代码中配置:
# 1. 将 IK 修改器节点添加为 Skeleton3D 的子节点
# 2. 设置目标骨骼和末端骨骼
# 3. 添加 Marker3D 作为 IK 目标
# 4. IK 求解器每帧自动运行
```

### BoneConstraint3D（4.5 — 新增）
```gdscript
# 添加为 Skeleton3D 的子节点
# 类型:
# - AimModifier3D: 使骨骼指向目标
# - CopyTransformModifier3D: 镜像另一根骨骼的变换
# - ConvertTransformModifier3D: 重新映射变换值
```

### AnimationTree（基类在 4.3 中变更）
```gdscript
# AnimationTree 现在继承 AnimationMixer（不再直接继承 Node）
# 使用 AnimationMixer 属性:
@onready var anim_tree: AnimationTree = %AnimationTree

func _ready() -> void:
    anim_tree.active = true  # 不是 playback_active（4.3 起弃用）
```

## 常见错误
- 使用 `playback_active` 而不是 `active`（4.3 起弃用）
- 使用 `bone_pose_updated` 信号而不是 `skeleton_updated`（4.3 中重命名）
- 使用旧版 IK 方式而不是 SkeletonModifier3D 系统（4.6 恢复）
- 对动画节点进行类型检查时未检查 `is AnimationMixer`
