# Unity 6.3 — Input 模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** Unity 6 使用新的 Input System（旧版 Input 已弃用）

---

## 概览

Unity 6 的输入系统：
- **Input System Package**（推荐）：跨平台、支持重绑定、现代化
- **Legacy Input Manager**：已弃用，新项目应避免使用

---

## 相比 2022 LTS 的关键变化

### Unity 6 中 Legacy Input 已弃用

```csharp
// ❌ 已弃用：Input class
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ 新方式：Input System package
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**需要迁移：** 安装 `com.unity.inputsystem` package。

---

## Input System Package 设置

### 安装
1. `Window > Package Manager`
2. 搜索 “Input System”
3. 安装 package
4. 根据提示重启 Unity

### 启用新的 Input System
`Edit > Project Settings > Player > Active Input Handling`：
- **Input System Package (New)** ✅ 推荐
- **Both**（用于迁移阶段）

---

## Input Actions（推荐模式）

### 创建 Input Actions Asset

1. `Assets > Create > Input Actions`
2. 命名（例如 `"PlayerControls"`）
3. 打开 asset，定义 actions：

```
Action Maps:
  Gameplay
    Actions:
      - Move (Value, Vector2)
      - Jump (Button)
      - Fire (Button)
      - Look (Value, Vector2)
```

4. **生成 C# Class**：在 Inspector 中勾选 “Generate C# Class”
5. 点击 “Apply”

### 使用生成的输入类

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();

        // 订阅 actions
        controls.Gameplay.Jump.performed += ctx => Jump();
        controls.Gameplay.Fire.performed += ctx => Fire();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();

    void Update() {
        // 读取持续输入
        Vector2 move = controls.Gameplay.Move.ReadValue<Vector2>();
        transform.Translate(new Vector3(move.x, 0, move.y) * Time.deltaTime);

        Vector2 look = controls.Gameplay.Look.ReadValue<Vector2>();
        // 应用相机旋转
    }

    void Jump() {
        Debug.Log("Jump!");
    }

    void Fire() {
        Debug.Log("Fire!");
    }
}
```

---

## 直接访问设备（快速但较粗放）

### Keyboard

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 当前状态
    if (Keyboard.current.spaceKey.isPressed) { }

    // 本帧刚按下
    if (Keyboard.current.spaceKey.wasPressedThisFrame) { }

    // 本帧刚松开
    if (Keyboard.current.spaceKey.wasReleasedThisFrame) { }
}
```

### Mouse

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 鼠标位置
    Vector2 mousePos = Mouse.current.position.ReadValue();

    // 鼠标位移（移动量）
    Vector2 mouseDelta = Mouse.current.delta.ReadValue();

    // 鼠标按键
    if (Mouse.current.leftButton.wasPressedThisFrame) { }
    if (Mouse.current.rightButton.isPressed) { }

    // 滚轮
    Vector2 scroll = Mouse.current.scroll.ReadValue();
}
```

### Gamepad

```csharp
using UnityEngine.InputSystem;

void Update() {
    Gamepad gamepad = Gamepad.current;
    if (gamepad == null) return; // 没有连接手柄

    // 按钮
    if (gamepad.buttonSouth.wasPressedThisFrame) { } // A/Cross
    if (gamepad.buttonWest.wasPressedThisFrame) { }  // X/Square

    // 摇杆
    Vector2 leftStick = gamepad.leftStick.ReadValue();
    Vector2 rightStick = gamepad.rightStick.ReadValue();

    // 扳机
    float leftTrigger = gamepad.leftTrigger.ReadValue();
    float rightTrigger = gamepad.rightTrigger.ReadValue();

    // D-Pad
    Vector2 dpad = gamepad.dpad.ReadValue();
}
```

### Touch（移动端）

```csharp
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;

void OnEnable() {
    EnhancedTouchSupport.Enable();
}

void Update() {
    foreach (var touch in UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches) {
        Debug.Log($"Touch at {touch.screenPosition}");
    }
}
```

---

## Input Action 回调

### Action 回调（事件驱动）

```csharp
// started：输入开始（例如扳机轻微按下）
controls.Gameplay.Fire.started += ctx => Debug.Log("Fire started");

// performed：输入动作被触发（例如按钮完全按下）
controls.Gameplay.Fire.performed += ctx => Debug.Log("Fire performed");

// canceled：输入被释放或中断
controls.Gameplay.Fire.canceled += ctx => Debug.Log("Fire canceled");
```

### Context 数据

```csharp
controls.Gameplay.Move.performed += ctx => {
    Vector2 value = ctx.ReadValue<Vector2>();
    float duration = ctx.duration; // 输入持续了多久
    InputControl control = ctx.control; // 由哪个设备/控件触发
};
```

---

## Control Schemes 与设备切换

### 在 Input Actions Asset 中定义 Control Schemes

```
Control Schemes:
  - Keyboard&Mouse (Keyboard, Mouse)
  - Gamepad (Gamepad)
  - Touch (Touchscreen)
```

### 在设备切换时自动识别

```csharp
controls.Gameplay.Move.performed += ctx => {
    if (ctx.control.device is Keyboard) {
        Debug.Log("Using keyboard");
    } else if (ctx.control.device is Gamepad) {
        Debug.Log("Using gamepad");
    }
};
```

---

## 重绑定（运行时按键映射）

### 交互式重绑定

```csharp
using UnityEngine.InputSystem;

public void RebindJumpKey() {
    var rebindOperation = controls.Gameplay.Jump.PerformInteractiveRebinding()
        .WithControlsExcluding("Mouse") // 排除鼠标绑定
        .OnComplete(operation => {
            Debug.Log("Rebind complete");
            operation.Dispose();
        })
        .Start();
}
```

### 保存/加载绑定

```csharp
// 保存
string rebinds = controls.SaveBindingOverridesAsJson();
PlayerPrefs.SetString("InputBindings", rebinds);

// 加载
string rebinds = PlayerPrefs.GetString("InputBindings");
controls.LoadBindingOverridesFromJson(rebinds);
```

---

## Action 类型

### Button（按下/松开）
- 单次按下/松开
- 示例：Jump、Fire

### Value（连续值）
- 连续数值（float、Vector2）
- 示例：Move、Look、Aim

### Pass-Through（即时透传）
- 不做处理，直接传递原始值
- 示例：鼠标位置

---

## Processors（输入修饰器）

### Scale

```csharp
// 在 Input Actions asset 中：Action > Properties > Processors > Add > Scale
// 将输入乘以指定值（例如反转 Y 轴）
```

### Invert

```csharp
// 在 Input Actions asset 中：Action > Properties > Processors > Add > Invert
// 反转输入符号
```

### Dead Zone

```csharp
// 在 Input Actions asset 中：Action > Properties > Processors > Add > Stick Deadzone
// 忽略摇杆的小幅移动
```

---

## PlayerInput Component（简化配置）

### 自动输入设置

```csharp
// Add Component: Player Input
// 分配 Input Actions asset
// Behavior: Send Messages / Invoke Unity Events / Invoke C# Events

// Send Messages 示例：
public class Player : MonoBehaviour {
    public void OnMove(InputValue value) {
        Vector2 move = value.Get<Vector2>();
        // 处理移动
    }

    public void OnJump(InputValue value) {
        if (value.isPressed) {
            Jump();
        }
    }
}
```

---

## 调试

### Input Debugger
- `Window > Analysis > Input Debugger`
- 可查看当前活跃设备、输入值和 action 状态

---

## Sources
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/QuickStartGuide.html
