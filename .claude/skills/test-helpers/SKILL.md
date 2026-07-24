---
name: test-helpers
description: "为项目测试套件生成引擎专用的测试辅助库。读取现有测试模式，并在 tests/helpers/ 中生成适配项目系统的断言工具、工厂函数和模拟对象。减少新测试文件中的样板代码。"
argument-hint: "[system-name | all | scaffold]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---

# 测试辅助工具

将常见的初始化、清理和断言模式抽象为辅助工具后，编写测试用例会更快、
也更一致。此技能会根据项目实际使用的引擎、语言和系统生成适配的
`tests/helpers/` 库，让每位开发者少写样板代码，多写断言。

**输出：** 包含引擎专用辅助文件的 `tests/helpers/` 目录

**何时运行：**
- `/test-setup` 首次搭建测试框架后
- 多个测试文件重复相同的初始化样板代码时
- 开始为新系统编写测试时

---

## 1. 解析参数

**模式：**
- `/test-helpers [system-name]`：为特定系统生成辅助工具
  （例如 `/test-helpers combat`）
- `/test-helpers all`：为所有已有测试文件的系统生成辅助工具
- `/test-helpers scaffold`：仅生成基础辅助库（不生成系统专用辅助工具）；
  首次运行时使用此模式
- 无参数：如果辅助工具尚不存在，则运行 `scaffold`，否则运行 `all`

---

## 2. 检测引擎和语言

读取 `.claude/docs/technical-preferences.md` 并提取：
- `Engine:` 的值
- `Language:` 的值
- Testing 章节中的 `Framework:`

如果未配置引擎："尚未配置引擎。请先运行 `/setup-engine`。"

---

## 3. 加载现有测试模式

扫描测试目录，查找已在使用的模式：

```
Glob pattern="tests/**/*_test.*"（所有测试文件）
```

读取有代表性的测试文件样本（最多 5 个），并提取：
- 初始化模式（`before_each` / `setUp` / fixture 的写法）
- 常见断言模式（最常断言的内容）
- 对象创建模式（测试中如何实例化游戏对象或场景）
- mock/stub 模式（如何替换依赖项）

这样可确保生成的辅助工具符合项目现有风格，而不是套用通用模板。

还需读取：
- `design/gdd/systems-index.md`：了解存在哪些系统
- 范围内的 GDD：了解需要测试的数据类型和值
- `docs/architecture/tr-registry.yaml`：将需求映射到受测系统

---

## 4. 生成引擎专用辅助工具

### Godot 4 (GDUnit4 / GDScript)

**基础辅助工具**（`tests/helpers/game_assertions.gd`）：

```gdscript
## 用于 [Project Name] 测试的游戏专用断言工具。
## 使用领域专用辅助方法扩展 GdUnitAssertions。
##
## 用法：
##   var assert = GameAssertions.new()
##   assert.health_in_range(entity, 0, entity.max_health)

class_name GameAssertions
extends RefCounted

## 断言值位于闭区间 [min_val, max_val] 内。
## 用于 GDD 中已定义边界的任何公式输出。
static func assert_in_range(
    value: float,
    min_val: float,
    max_val: float,
    label: String = "值"
) -> void:
    assert(
        value >= min_val and value <= max_val,
        "%s %.2f 超出预期范围 [%.2f, %.2f]" % [label, value, min_val, max_val]
    )

## 断言在可调用代码块执行期间发出了信号。
## 用法：assert_signal_emitted(entity, "health_changed", func(): entity.take_damage(10))
static func assert_signal_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    var emitted := false
    obj.connect(signal_name, func(_args): emitted = true)
    action.call()
    assert(emitted, "预期发出信号 '%s'，但并未发出。" % signal_name)

## 断言可调用对象未发出信号。
static func assert_signal_not_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    var emitted := false
    obj.connect(signal_name, func(_args): emitted = true)
    action.call()
    assert(not emitted, "预期不发出信号 '%s'，但该信号已发出。" % signal_name)

## 断言父节点内的指定路径上存在节点。
static func assert_node_exists(parent: Node, path: NodePath) -> void:
    assert(
        parent.has_node(path),
        "预期路径 '%s' 上存在节点。" % str(path)
    )
```

**工厂辅助工具**（`tests/helpers/game_factory.gd`）：

```gdscript
## 用于创建测试游戏对象的工厂函数。
## 返回为单元测试配置的最小对象（无需场景树）。
##
## 用法：var player = GameFactory.make_player(health: 100)

class_name GameFactory
extends RefCounted

## 创建用于测试的最小类玩家对象。
## 根据需要覆盖字段。
static func make_player(health: int = 100) -> Node:
    var player = Node.new()
    player.set_meta("health", health)
    player.set_meta("max_health", health)
    return player
```

**场景辅助工具**（`tests/helpers/scene_runner_helper.gd`）：

```gdscript
## 用于场景集成测试的工具。
## 封装 GdUnitSceneRunner 的常用模式。

class_name SceneRunnerHelper
extends GdUnitTestSuite

## 加载场景并等待一帧，让 _ready() 执行完毕。
func load_scene_and_wait(scene_path: String) -> Node:
    var scene = load(scene_path).instantiate()
    add_child(scene)
    await get_tree().process_frame
    return scene
```

---

### Unity (NUnit / C#)

**基础辅助工具**（`tests/helpers/GameAssertions.cs`）：

```csharp
using NUnit.Framework;
using UnityEngine;

/// <summary>
/// 用于 [Project Name] 测试的游戏专用断言工具。
/// 使用领域专用辅助方法扩展 NUnit 的 Assert。
/// </summary>
public static class GameAssertions
{
    /// <summary>
    /// 断言值位于闭区间 [min, max] 内。
    /// 用于 GDD Formulas 章节中定义的任何公式输出。
    /// </summary>
    public static void AssertInRange(float value, float min, float max, string label = "值")
    {
        Assert.That(value, Is.InRange(min, max),
            $"{label} ({value:F2}) 超出预期范围 [{min:F2}, {max:F2}]");
    }

    /// <summary>断言执行操作期间触发了 UnityEvent 或 C# 事件。</summary>
    public static void AssertEventRaised(ref bool wasCalled, System.Action action, string eventName)
    {
        wasCalled = false;
        action();
        Assert.IsTrue(wasCalled, $"预期触发事件 '{eventName}'，但并未触发。");
    }

    /// <summary>断言 GameObject 上存在组件。</summary>
    public static void AssertHasComponent<T>(GameObject obj) where T : Component
    {
        var component = obj.GetComponent<T>();
        Assert.IsNotNull(component,
            $"预期 GameObject '{obj.name}' 包含组件 {typeof(T).Name}。");
    }
}
```

**工厂辅助工具**（`tests/helpers/GameFactory.cs`）：

```csharp
using UnityEngine;

/// <summary>
/// 无需加载场景即可创建最小测试对象的工厂方法。
/// </summary>
public static class GameFactory
{
    /// <summary>创建带命名组件的最小 GameObject 用于测试。</summary>
    public static GameObject MakeGameObject(string name = "TestObject")
    {
        var go = new GameObject(name);
        return go;
    }

    /// <summary>
    /// 为数据驱动测试创建 T 类型的 ScriptableObject。
    /// 测试后使用 Object.DestroyImmediate 释放该对象。
    /// </summary>
    public static T MakeScriptableObject<T>() where T : ScriptableObject
    {
        return ScriptableObject.CreateInstance<T>();
    }
}
```

---

### Unreal Engine (C++)

**基础辅助工具**（`tests/helpers/GameTestHelpers.h`）：

```cpp
#pragma once

#include "CoreMinimal.h"
#include "Misc/AutomationTest.h"

/**
 * 用于 [Project Name] 自动化测试的游戏专用断言宏和辅助工具。
 * 在任何需要领域专用断言的测试文件中引入。
 *
 * 用法：
 *   GAME_TEST_ASSERT_IN_RANGE(TestName, DamageValue, 10.0f, 50.0f, TEXT("伤害"));
 */

// 断言浮点值位于闭区间 [Min, Max] 内
#define GAME_TEST_ASSERT_IN_RANGE(TestName, Value, Min, Max, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s (%.2f) 位于范围 [%.2f, %.2f] 内"), Label, Value, Min, Max), \
        (Value) >= (Min) && (Value) <= (Max) \
    )

// 断言 UObject 指针有效（非空且未被垃圾回收）
#define GAME_TEST_ASSERT_VALID(TestName, Ptr, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s 有效"), Label), \
        IsValid(Ptr) \
    )

// 断言 Actor 位于世界中（已成功生成）
#define GAME_TEST_ASSERT_SPAWNED(TestName, ActorPtr, ClassName) \
    TestNotNull( \
        FString::Printf(TEXT("已生成类 %s 的 Actor"), TEXT(#ClassName)), \
        ActorPtr \
    )

/**
 * 用于创建最小测试世界的辅助工具。
 * 请记得在清理阶段调用 World->DestroyWorld(false)。
 */
namespace GameTestHelpers
{
    inline UWorld* CreateTestWorld(const FString& WorldName = TEXT("TestWorld"))
    {
        UWorld* World = UWorld::CreateWorld(EWorldType::Game, false);
        FWorldContext& WorldContext = GEngine->CreateNewWorldContext(EWorldType::Game);
        WorldContext.SetCurrentWorld(World);
        return World;
    }
}
```

---

## 5. 生成系统专用辅助工具

在 `[system-name]` 或 `all` 模式下，为每个系统生成一个辅助工具：

读取系统 GDD 并提取：
- 数据类型（实体类型、组件名称）
- 公式变量及其边界
- Edge Cases 中提到的常见测试场景

生成 `tests/helpers/[system]_factory.[ext]`，其中包含该系统对象专用的工厂函数。

`combat` 系统的示例模式（Godot/GDScript）：

```gdscript
## 用于 Combat 系统测试的工厂和断言辅助工具。
## 由 /test-helpers combat 于 [date] 生成。
## 依据：design/gdd/combat.md

class_name CombatTestFactory
extends RefCounted

const DAMAGE_MIN := 0
const DAMAGE_MAX := 999  # 来自 GDD：伤害公式上限

## 创建用于伤害公式测试的最小攻击者对象。
static func make_attacker(attack: float = 10.0, crit_chance: float = 0.0) -> Node:
    var attacker = Node.new()
    attacker.set_meta("attack", attack)
    attacker.set_meta("crit_chance", crit_chance)
    return attacker

## 创建用于承伤测试的最小目标对象。
static func make_target(defense: float = 0.0, health: float = 100.0) -> Node:
    var target = Node.new()
    target.set_meta("defense", defense)
    target.set_meta("health", health)
    target.set_meta("max_health", health)
    return target

## 断言伤害输出位于 GDD 指定的边界内。
static func assert_damage_in_bounds(damage: float) -> void:
    GameAssertions.assert_in_range(damage, DAMAGE_MIN, DAMAGE_MAX, "伤害")
```

---

## 6. 写入输出

展示将要创建的内容摘要：

```
## 要创建的测试辅助工具

基础辅助工具（引擎：[engine]）：
- tests/helpers/game_assertions.[ext]
- tests/helpers/game_factory.[ext]
[engine-specific extras]

系统辅助工具（[mode]）：
- tests/helpers/[system]_factory.[ext]  ← 来自 [system] GDD
```

询问："可以将这些辅助文件写入 `tests/helpers/` 吗？"

**绝不覆盖现有文件。** 如果文件已存在，请报告：
"跳过 `[path]`：文件已存在。如需重新生成，请手动删除该文件。"

写入后：结论：**COMPLETE**：辅助文件已创建。

"辅助文件已创建。在测试中使用这些文件：
- Godot：`class_name` 会自动导入，无需显式导入
- Unity：添加 `using` 指令或引用测试程序集
- Unreal：`#include \"tests/helpers/GameTestHelpers.h\"`"

---

## 协作协议

- **绝不覆盖现有辅助工具**：其中可能包含手写的自定义内容。只生成尚不存在的新文件
- **生成的代码只是起点**：为简化实现，生成的工厂函数使用元数据模式；实际代码存在后，
  应根据真实类结构进行调整
- **辅助工具应反映 GDD**：辅助工具中的边界和常量应可追溯到 GDD Formulas 章节，
  不得使用臆造的值
- **写入前询问**：在 `tests/` 中创建文件前始终先确认

## 后续步骤

- 如果尚未搭建测试框架，请运行 `/test-setup`。
- 使用 `/dev-story` 实现故事，辅助工具可减少新测试文件中的样板代码。
- 运行 `/skill-test`，验证其他可能需要辅助工具覆盖的技能。
