# Unity 6.3 — UI 模块参考

**最后验证时间：** 2026-02-13
**知识缺口：** Unity 6 的 UI Toolkit 已可用于生产环境运行时 UI

---

## 概览

Unity 6 的 UI 系统：
- **UI Toolkit**（推荐）：现代化、高性能，风格类似 HTML/CSS（在 Unity 6 中已达到生产可用）
- **UGUI (Canvas)**：传统遗留系统，仍受支持，但不建议用于新项目
- **IMGUI**：仅限编辑器使用，运行时 UI 已弃用

---

## UI Toolkit（现代 UI）

### 设置 UI Document

1. 创建 UXML（UI 结构）：
   - `Assets > Create > UI Toolkit > UI Document`
2. 创建 USS（样式）：
   - `Assets > Create > UI Toolkit > StyleSheet`
3. 添加到场景：
   - `GameObject > UI Toolkit > UI Document`
   - 将 UXML 赋给 `UIDocument > Source Asset`

---

### UXML（UI 结构）

```xml
<!-- MainMenu.uxml -->
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <ui:VisualElement class="container">
        <ui:Label text="Main Menu" class="title" />
        <ui:Button name="play-button" text="Play" />
        <ui:Button name="settings-button" text="Settings" />
        <ui:Button name="quit-button" text="Quit" />
    </ui:VisualElement>
</ui:UXML>
```

---

### USS（样式）

```css
/* MainMenu.uss */
.container {
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    background-color: rgb(30, 30, 30);
}

.title {
    font-size: 48px;
    color: white;
    margin-bottom: 20px;
}

Button {
    width: 200px;
    height: 50px;
    margin: 10px;
    font-size: 24px;
}

Button:hover {
    background-color: rgb(100, 150, 200);
}
```

---

### C# 脚本（UI Toolkit）

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour {
    void OnEnable() {
        var root = GetComponent<UIDocument>().rootVisualElement;

        // Query elements by name
        var playButton = root.Q<Button>("play-button");
        var settingsButton = root.Q<Button>("settings-button");
        var quitButton = root.Q<Button>("quit-button");

        // Register callbacks
        playButton.clicked += OnPlayClicked;
        settingsButton.clicked += OnSettingsClicked;
        quitButton.clicked += Application.Quit;
    }

    void OnPlayClicked() {
        Debug.Log("Play clicked");
        // Load game scene
    }

    void OnSettingsClicked() {
        Debug.Log("Settings clicked");
        // Open settings menu
    }
}
```

---

### 常见 UI 元素

```csharp
// Label（文本显示）
var label = root.Q<Label>("score-label");
label.text = "Score: 100";

// Button
var button = root.Q<Button>("submit-button");
button.clicked += OnSubmit;

// TextField（文本输入）
var textField = root.Q<TextField>("name-input");
string playerName = textField.value;

// Toggle（复选框）
var toggle = root.Q<Toggle>("music-toggle");
bool isMusicEnabled = toggle.value;

// Slider
var slider = root.Q<Slider>("volume-slider");
float volume = slider.value; // 0-1

// DropdownField（下拉菜单）
var dropdown = root.Q<DropdownField>("difficulty-dropdown");
dropdown.choices = new List<string> { "Easy", "Normal", "Hard" };
dropdown.value = "Normal";
```

---

### 动态创建 UI（不使用 UXML）

```csharp
void CreateUI() {
    var root = GetComponent<UIDocument>().rootVisualElement;

    // Create elements
    var container = new VisualElement();
    container.AddToClassList("container");

    var label = new Label("Hello, UI Toolkit!");
    var button = new Button(() => Debug.Log("Clicked")) { text = "Click Me" };

    container.Add(label);
    container.Add(button);
    root.Add(container);
}
```

---

### USS Flexbox 布局

```css
/* Horizontal layout */
.horizontal {
    flex-direction: row;
}

/* Vertical layout (default) */
.vertical {
    flex-direction: column;
}

/* Center children */
.centered {
    align-items: center;
    justify-content: center;
}

/* Spacing */
.spaced {
    justify-content: space-between;
}
```

---

## UGUI（传统 Canvas UI）

### 基础设置（在 Unity 6 中仍可用）

```csharp
// GameObject > UI > Canvas（会创建 Canvas、EventSystem）

// UI Elements:
// - Text（建议改用 TextMeshPro）
// - Button
// - Image
// - Slider
// - Toggle
// - InputField
```

---

### UGUI 脚本

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro; // TextMeshPro

public class LegacyUI : MonoBehaviour {
    public TextMeshProUGUI scoreText;
    public Button playButton;
    public Slider volumeSlider;

    void Start() {
        // Update text
        scoreText.text = "Score: 100";

        // Button click
        playButton.onClick.AddListener(OnPlayClicked);

        // Slider value changed
        volumeSlider.onValueChanged.AddListener(OnVolumeChanged);
    }

    void OnPlayClicked() {
        Debug.Log("Play clicked");
    }

    void OnVolumeChanged(float value) {
        AudioListener.volume = value;
    }
}
```

---

### TextMeshPro（更好的文本渲染）

```csharp
// Install: Window > TextMeshPro > Import TMP Essential Resources

// Use TMP_Text instead of Unity's Text component
using TMPro;

public TextMeshProUGUI tmpText;
tmpText.text = "High Quality Text";
tmpText.fontSize = 24;
tmpText.color = Color.white;
```

---

## Canvas 设置（UGUI）

### 渲染模式

```csharp
// Screen Space - Overlay：UI 渲染在所有内容之上（不需要摄像机）
// Screen Space - Camera：UI 由指定摄像机渲染（可配合特效）
// World Space：UI 位于 3D 世界中（例如悬浮血条）
```

### Canvas Scaler（响应式 UI）

```csharp
// UI Scale Mode:
// - Constant Pixel Size：UI 元素使用固定像素尺寸
// - Scale With Screen Size：UI 按参考分辨率缩放（推荐）
// - Constant Physical Size：UI 元素使用固定物理尺寸（cm）

// Example: Scale With Screen Size
// Reference Resolution: 1920x1080
// Screen Match Mode: Match Width Or Height（0.5 = 平衡）
```

---

## Layout Groups（UGUI）

### Horizontal Layout Group

```csharp
// 自动按水平方向排列子元素
// Add: GameObject > Add Component > Horizontal Layout Group
```

### Vertical Layout Group

```csharp
// 自动按垂直方向排列子元素
```

### Grid Layout Group

```csharp
// 将子元素排列为网格
```

---

## 性能（UI Toolkit vs UGUI）

### UI Toolkit 优势
- ✅ 渲染更快（retained mode）
- ✅ 更适合包含大量元素的复杂 UI
- ✅ 样式编写更方便（类似 CSS）
- ✅ 更适合动态 UI

### UGUI 优势
- ✅ 更成熟，文档更丰富
- ✅ 与 Unity Editor 集成更好
- ✅ 对初学者更友好

---

## 常见模式

### 血条（UI Toolkit）

```csharp
var healthBar = root.Q<VisualElement>("health-bar");
healthBar.style.width = new StyleLength(new Length(healthPercent, LengthUnit.Percent));
```

### 血条（UGUI）

```csharp
public Image healthBarImage;

void UpdateHealth(float percent) {
    healthBarImage.fillAmount = percent; // 0-1
}
```

---

### 淡入/淡出（UI Toolkit）

```csharp
IEnumerator FadeIn(VisualElement element, float duration) {
    float elapsed = 0f;
    while (elapsed < duration) {
        elapsed += Time.deltaTime;
        element.style.opacity = Mathf.Lerp(0f, 1f, elapsed / duration);
        yield return null;
    }
}
```

---

## 调试

### UI Toolkit Debugger
- `Window > UI Toolkit > Debugger`
- 检查元素层级、样式、布局

### UGUI Event System Debugger
- 在 Hierarchy 中选择 EventSystem
- Inspector 会显示当前激活的输入模块和 raycast 信息

---

## Sources
- https://docs.unity3d.com/6000.0/Documentation/Manual/UIElements.html
- https://docs.unity3d.com/Packages/com.unity.ui@2.0/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.ugui@2.0/manual/index.html
