# Godot Physics — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **Jolt Physics 是新项目的默认 3D 引擎**
  - 现有项目保留当前物理引擎设置
  - 确定性、稳定性和性能优于 GodotPhysics3D
  - 某些 HingeJoint3D 属性（`damp`）仅适用于 GodotPhysics3D
  - 2D 物理未变（仍为 Godot Physics 2D）

### 4.5 变更
- **3D 物理插值重新设计**: 从 RenderingServer 移至 SceneTree
  - 面向用户的 API 未变，但边缘情况下的内部行为可能不同

## 物理引擎选择（4.6）

```
Project Settings → Physics → 3D → Physics Engine:
- Jolt Physics（新项目默认）
- GodotPhysics3D（旧版，仍可用）
```

### Jolt 与 GodotPhysics3D 对比

| 特性 | Jolt（默认） | GodotPhysics3D |
|---------|---------------|----------------|
| 确定性 | 更好 | 不一致 |
| 稳定性 | 更好 | 足够 |
| 性能 | 复杂场景中更好 | 足够 |
| HingeJoint3D `damp` | 不支持 | 支持 |
| 运行时警告 | 有，针对不支持的属性 | 无 |
| 碰撞边距 | 行为可能不同 | 原有行为 |

## 当前 API 模式

### 基础物理设置（未变）
```gdscript
# CharacterBody3D 移动，各引擎的 API 相同
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
    var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()
```

### 射线检测（未变）
```gdscript
var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
var query := PhysicsRayQueryParameters3D.create(from, to)
query.collision_mask = collision_mask
var result: Dictionary = space_state.intersect_ray(query)
if result:
    var hit_point: Vector3 = result.position
    var hit_normal: Vector3 = result.normal
```

## 常见错误
- 误以为 GodotPhysics3D 是默认引擎（4.6 起为 Jolt）
- 未检查物理引擎便使用 HingeJoint3D `damp` 属性（Jolt 会忽略它）
- 切换物理引擎时未测试碰撞边缘情况
