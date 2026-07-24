---
paths:
  - "src/core/**"
---

# 引擎代码规则

- 在热路径（hot path，即更新循环、渲染、物理）中零分配（allocation）——预分配、池化、复用
- 所有引擎 API 必须线程安全，或明确文档标注为仅限单线程（single-thread-only）
- 每次优化前后都必须进行性能分析（profile）——记录实际测量数据
- 引擎代码绝不能依赖游戏逻辑代码（严格的依赖方向：引擎 <- 游戏逻辑）
- 每个公共 API 的文档注释中必须包含用法示例
- 公共接口的变更需要提供弃用期（deprecation period）和迁移指南
- 所有资源使用 RAII / 确定性清理（deterministic cleanup）
- 所有引擎系统必须支持优雅降级（graceful degradation）
- 编写引擎 API 代码前，查阅 `docs/engine-reference/` 获取当前引擎版本，并根据参考文档验证 API

## 示例

**正确**（零分配的热路径）：

```gdscript
# Pre-allocated array reused each frame
var _nearby_cache: Array[Node3D] = []

func _physics_process(delta: float) -> void:
    _nearby_cache.clear()  # Reuse, don't reallocate
    _spatial_grid.query_radius(position, radius, _nearby_cache)
```

**错误**（在热路径中分配）：

```gdscript
func _physics_process(delta: float) -> void:
    var nearby: Array[Node3D] = []  # VIOLATION: allocates every frame
    nearby = get_tree().get_nodes_in_group("enemies")  # VIOLATION: tree query every frame
```
