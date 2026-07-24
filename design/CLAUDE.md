# 设计目录

在此目录中编写或编辑文件时，必须遵循以下标准。

## GDD 文件（`design/gdd/`）

每份 GDD 都必须按此顺序包含全部 **8 个必需章节**：
1. 概述（Overview）——一段式摘要
2. 玩家幻想（Player Fantasy）——预期感受与体验
3. 详细规则（Detailed Rules）——明确、无歧义的机制规则
4. 公式（Formulas）——所有数学公式均须定义所用变量
5. 边界情况（Edge Cases）——处理异常情形
6. 依赖关系（Dependencies）——列出其他系统
7. 调优旋钮（Tuning Knobs）——明确可配置的值
8. 验收标准（Acceptance Criteria）——可测试的成功条件

**文件命名：** `[system-slug].md`（例如 `movement-system.md`、`combat-system.md`）

**系统索引：** 新增 GDD 时，必须更新 `design/gdd/systems-index.md`。

**设计顺序：** 基础（Foundation）→ 核心（Core）→ 功能（Feature）→ 表现（Presentation）→ 打磨（Polish）

**验证：** 编写任何 GDD 后，必须运行 `/design-review [path]`。
完成一组相关 GDD 后，必须运行 `/review-all-gdds`。

## 快速规格（`design/quick-specs/`）

用于调优变更、小型机制或平衡性调整的轻量级规格。
必须使用 `/quick-design` 编写。

## UX 规格（`design/ux/`）

- 单界面规格：`design/ux/[screen-name].md`
- HUD 设计：`design/ux/hud.md`
- 交互模式库：`design/ux/interaction-patterns.md`
- 无障碍要求：`design/ux/accessibility-requirements.md`

必须使用 `/ux-design` 编写。移交给 `/team-ui` 前，必须使用 `/ux-review` 验证。
