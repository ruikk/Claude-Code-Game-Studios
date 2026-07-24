---
paths:
  - "src/gameplay/**"
---

# 玩法代码规则(Gameplay Code Rules)

- 所有玩法数值必须来自外部配置/数据文件，禁止硬编码
- 所有时间相关的计算必须使用 delta time（帧率无关）
- 禁止直接引用 UI 代码——使用事件/信号(Signal)进行跨系统通信
- 每个玩法系统必须实现清晰的接口(Interface)
- 状态机(State Machine)必须具有明确的转换表，并记录所有状态
- 为所有玩法逻辑编写单元测试——将逻辑与表现层分离
- 在代码注释中注明每个功能对应的设计文档
- 禁止使用静态单例(Singleton)管理游戏状态——使用依赖注入(Dependency Injection)

## 示例

**正确**（数据驱动）：

```gdscript
var damage: float = config.get_value("combat", "base_damage", 10.0)
var speed: float = stats_resource.movement_speed * delta
```

**错误**（硬编码）：

```gdscript
var damage: float = 25.0   # 违规：硬编码玩法数值
var speed: float = 5.0      # 违规：未从配置读取，未使用 delta
```
