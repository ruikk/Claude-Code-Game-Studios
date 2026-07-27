# Godot UI — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **双焦点系统**: 鼠标/触摸焦点现在与键盘/手柄焦点分离
  - 视觉反馈因输入方式而异
  - 可能需要更新自定义焦点实现
- **TabContainer**: 可直接在 Inspector 中编辑选项卡属性
- **TileMapLayer 场景瓦片旋转**: 场景瓦片可以像图集瓦片一样旋转

### 4.5 变更
- **FoldableContainer**: 用于可折叠区段的新手风琴式 UI 节点
- **递归 Control 行为**: 通过单个属性禁用整个节点层级的鼠标/焦点
- **屏幕阅读器支持**: Control 节点可与 AccessKit 协同工作
- **实时翻译预览**: 在编辑器中测试不同区域设置
- **`RichTextLabel.push_meta`**: 新增可选 `tooltip` 参数（来自 4.4）

### 4.4 变更
- **`GraphEdit.connect_node`**: 新增可选 `keep_alive` 参数

## 当前 API 模式

### 主题与样式（4.6）
```gdscript
# 编辑器默认使用新的“Modern”主题
# 游戏 UI 仍按以前的方式使用自定义主题:
var theme := Theme.new()
theme.set_color(&"font_color", &"Label", Color.WHITE)
theme.set_font_size(&"font_size", &"Label", 24)
```

### 焦点管理（4.6 — 已变更）
```gdscript
# 键盘/手柄焦点（grab_focus 仍然有效）
func _ready() -> void:
    %StartButton.grab_focus()

# 重要: 在 4.6 中，鼠标悬停与键盘焦点分离
# 两者可以同时作用于不同控件
# 使用鼠标和键盘/手柄分别测试 UI

# 焦点邻居（未变）
%Button1.focus_neighbor_bottom = %Button2.get_path()
%Button1.focus_neighbor_right = %Button3.get_path()
```

### FoldableContainer（4.5 — 新增）
```gdscript
# 手风琴式可折叠容器
# 作为要折叠的内容的父节点添加
# 点击标题时显示/隐藏子节点
# 通过编辑器属性或代码配置
```

### 递归禁用（4.5 — 新增）
```gdscript
# 禁用整个节点层级的鼠标/焦点交互
# 适合禁用整个菜单区段
%SettingsPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
# 在 4.5+ 中可以递归传播到子节点
```

### 支持本地化的 UI（最佳实践）
```gdscript
# 所有可见字符串都使用 tr()
label.text = tr("MENU_START_GAME")

# 标签使用自动换行（不同语言的文本长度不同）
label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

# 在编辑器中使用实时翻译预览测试（4.5+）
```

## 常见错误
- 误以为 `grab_focus()` 会影响鼠标焦点（4.6 中仅影响键盘/手柄）
- 升级到 4.6 后未同时使用鼠标和手柄测试 UI
- 硬编码字符串，而不是使用 `tr()` 进行本地化
- 可折叠 UI 不使用 `FoldableContainer`（4.5 新增，比自定义实现更简洁）
