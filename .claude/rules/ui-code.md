---
paths:
  - "src/ui/**"
---

# UI 代码规则

- UI 绝不能拥有或直接修改游戏状态（Game State）——仅负责展示，使用命令/事件（Command/Event）来请求变更
- 所有 UI 文本必须通过本地化（Localization）系统——禁止硬编码（Hardcode）面向用户的字符串
- 所有交互元素必须同时支持键盘/鼠标（Keyboard/Mouse）和游戏手柄（Gamepad）输入
- 所有动画必须可跳过，并尊重用户的运动/无障碍（Motion/Accessibility）偏好设置
- UI 音效通过音频事件系统（Audio Event System）触发，不得直接触发
- UI 绝不能阻塞游戏线程（Game Thread）
- 可缩放文本和色盲模式（Colorblind Mode）是强制要求，而非可选功能
- 必须在最低和最高支持分辨率下测试所有界面
