# 文档目录

在此目录中创建或编辑文件时，请遵循以下规范。

## 架构决策记录（Architecture Decision Records，`docs/architecture/`）

使用 ADR 模板：`.claude/docs/templates/architecture-decision-record.md`

**必需章节：** 标题（Title）、状态（Status）、背景（Context）、决策（Decision）、后果（Consequences）、
ADR 依赖项（ADR Dependencies）、引擎兼容性（Engine Compatibility）、已覆盖的 GDD 需求（GDD Requirements Addressed）

**状态生命周期：** `Proposed` → `Accepted` → `Superseded`
- 切勿跳过 `Accepted`：引用 `Proposed` ADR 的故事会被自动阻止
- 使用 `/architecture-decision`，通过引导式流程创建 ADR

**TR 注册表（TR Registry）：** `docs/architecture/tr-registry.yaml`
- 使用稳定的需求 ID（例如 `TR-MOV-001`）将 GDD 需求关联到故事
- 切勿重新编号现有 ID，只能追加新 ID
- 由 `/architecture-review` 的阶段 8 更新

**控制清单（Control Manifest）：** `docs/architecture/control-manifest.md`
- 扁平化的程序员规则表：按层级列出必需项（Required）/ 禁止项（Forbidden）/ 约束条件（Guardrails）
- 标头中的 `Manifest Version:` 带有日期戳
- 故事会嵌入此版本；`/story-done` 会检查版本是否过期

**验证：** 完成一组 ADR 后，运行 `/architecture-review`。

## 引擎参考资料（Engine Reference，`docs/engine-reference/`）

与特定版本绑定的引擎 API 快照。**使用任何引擎 API 之前，务必先在此处查阅**，
因为 LLM 的训练数据早于所绑定的引擎版本。

当前引擎：请参阅 `docs/engine-reference/godot/VERSION.md`
