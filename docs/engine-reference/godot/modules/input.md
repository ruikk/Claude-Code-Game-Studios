# Godot Input — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **双焦点系统**: 鼠标/触摸焦点现在与键盘/手柄焦点分离
  - 视觉反馈因输入方式而异
  - 可能需要更新自定义焦点实现
- **Select Mode 快捷键变更**: “Select Mode” 现在使用 `v` 键；旧模式改名为“Transform Mode”（`q` 键）

### 4.5 变更
- **SDL3 gamepad driver**: 手柄处理交由 SDL 库负责，以提供更好的跨平台支持
- **递归禁用 Control**: 单个属性即可禁用整个节点层级的鼠标/焦点

### 4.3 变更（训练数据已覆盖）
- **InputEventShortcut**: 专用于菜单快捷键的事件类型（可选）

## 当前 API 模式

### 输入动作（未变）
```gdscript
func _physics_process(delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector(
        &"move_left", &"move_right", &"move_forward", &"move_back"
    )
    if Input.is_action_just_pressed(&"jump"):
        jump()
```

### 输入事件（未变）
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_click(event.position)
    elif event is InputEventKey:
        if event.keycode == KEY_ESCAPE and event.pressed:
            toggle_pause()
```

### 焦点管理（4.6 — 已变更）
```gdscript
# 鼠标/触摸焦点现在与键盘/手柄焦点分离
# 视觉样式可能因当前输入方式而异
# 如果有自定义焦点绘制，请使用两种输入方式测试

# 标准方式仍然有效:
func _ready() -> void:
    %StartButton.grab_focus()  # 键盘/手柄焦点

# 但请注意: 4.6 中鼠标悬停焦点 != 键盘焦点
```

### 手柄（4.5+ — SDL3 后端）
```gdscript
# API 未变，但 SDL3 提供:
# - 更好的跨平台设备检测
# - 改进的震动支持
# - 更一致的按键映射

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        if event.button_index == JOY_BUTTON_A and event.pressed:
            confirm_selection()
```

## 常见错误
- 未测试鼠标和键盘两条焦点路径（4.6 使用双焦点）
- 误以为 `grab_focus()` 会影响鼠标焦点（4.6 中仅影响键盘/手柄）
- 热路径中的动作名称使用字符串字面量，而不是 `StringName`（`&"action"`）
