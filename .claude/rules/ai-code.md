---
paths:
  - "src/ai/**"
---

# AI 代码规则

- AI 更新预算（Update Budget）：每帧最多 2ms — 须通过性能分析（Profile）验证
- 所有 AI 参数必须可从数据文件中调节（行为树权重、感知范围、计时器）
- AI 必须可调试（Debuggable）：为所有 AI 状态实现可视化钩子（路径、感知锥、决策树）
- AI 应预先传达意图（Telegraph Intentions）— 玩家需要时间来阅读和反应
- 优先使用效用系统（Utility-based）或行为树（Behavior Tree）方法，而非硬编码的 if/else 链
- 群体 AI 必须支持从数据中配置编队（Formation）、侧翼包抄（Flanking）和角色分配（Role Assignment）
- 所有 AI 状态机（State Machine）必须记录状态转换日志，以便调试
- 切勿在未验证的情况下信任来自网络的 AI 输入
