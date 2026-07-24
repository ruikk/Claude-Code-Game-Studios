---
paths:
  - "tests/**"
---

# 测试标准(Test Standards)

- 测试命名：`test_[系统]_[场景]_[预期结果]` 模式
- 每个测试必须具有清晰的 Arrange/Act/Assert(准备/执行/断言) 结构
- 单元测试(Unit Test)不得依赖外部状态（文件系统、网络、数据库）
- 集成测试(Integration Test)必须在执行后清理自身资源
- 性能测试(Performance Test)必须指定可接受的阈值，超出阈值时必须失败
- 测试数据必须在测试内部或专用 fixture(测试夹具) 中定义，不得使用共享的可变状态
- 模拟(Mock)外部依赖 — 测试应当快速且确定性(Deterministic)
- 每个缺陷修复(Bug Fix)都必须包含一个回归测试(Regression Test)，该测试应当能捕获原始缺陷

## 示例

**正确**（规范命名 + Arrange/Act/Assert）：

```gdscript
func test_health_system_take_damage_reduces_health() -> void:
    # Arrange
    var health := HealthComponent.new()
    health.max_health = 100
    health.current_health = 100

    # Act
    health.take_damage(25)

    # Assert
    assert_eq(health.current_health, 75)
```

**错误**：

```gdscript
func test1() -> void:  # 违规：缺少描述性名称
    var h := HealthComponent.new()
    h.take_damage(25)  # 违规：缺少 arrange 步骤，没有明确的断言
    assert_true(h.current_health < 100)  # 违规：断言不够精确
```
