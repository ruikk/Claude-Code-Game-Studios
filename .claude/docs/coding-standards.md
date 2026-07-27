# 编码标准（Coding Standards）

- 所有游戏代码都必须为公共 API 添加文档注释
- 每个系统都必须在 `docs/architecture/` 中有对应的架构决策记录（architecture decision record）
- 玩法数值必须采用数据驱动（外部配置），严禁硬编码
- 所有公共方法都必须可进行单元测试（优先依赖注入而非单例）
- 提交（commit）必须引用相关设计文档或任务 ID
- **验证驱动开发（Verification-driven development）**：新增玩法系统时先写测试。
  对于 UI 变更，使用截图进行验证。将预期输出与实际输出对比后，
  才能标记工作完成。每项实现都应有可证明其正确性的方式。

# 设计文档标准（Design Document Standards）

- 所有设计文档均使用 Markdown
- 每个机制（mechanic）在 `design/gdd/` 中必须有独立文档
- 文档必须包含以下 8 个必需章节：
  1. **概述（Overview）** -- 单段摘要
  2. **玩家幻想（Player Fantasy）** -- 期望传达的感受与体验
  3. **详细规则（Detailed Rules）** -- 无歧义的机制规则
  4. **公式（Formulas）** -- 所有数学关系均以变量定义
  5. **边界情况（Edge Cases）** -- 对非常规场景的处理
  6. **依赖项（Dependencies）** -- 列出相关系统
  7. **可调参数（Tuning Knobs）** -- 标识可配置值
  8. **验收标准（Acceptance Criteria）** -- 可测试的成功条件
- 平衡性数值必须链接到其来源公式或设计依据

# 测试标准（Testing Standards）

## 按 Story 类型划分的测试证据（Test Evidence by Story Type）

所有 Story 在标记为 Done 之前都必须具备相应的测试证据：

| Story Type | Required Evidence | Location | Gate Level |
|---|---|---|---|
| **Logic**（公式、AI、状态机） | 自动化单元测试——必须通过 | `tests/unit/[system]/` | BLOCKING |
| **Integration**（多系统） | 集成测试 或 已文档化的玩法测试（playtest） | `tests/integration/[system]/` | BLOCKING |
| **Visual/Feel**（动画、VFX、手感） | 截图 + 负责人签字确认 | `production/qa/evidence/` | ADVISORY |
| **UI**（菜单、HUD、界面） | 手动走查文档 或 交互测试 | `production/qa/evidence/` | ADVISORY |
| **Config/Data**（数值调优） | 冒烟检查通过 | `production/qa/smoke-[date].md` | ADVISORY |

## 自动化测试规则（Automated Test Rules）

- **命名**：文件使用 `[system]_[feature]_test.[ext]`；函数使用 `test_[scenario]_[expected]`
- **确定性**：测试每次运行必须产出相同结果——禁止随机种子、禁止依赖时间的断言
- **隔离性**：每个测试都要独立构建与清理自身状态；测试不得依赖执行顺序
- **禁止硬编码数据**：测试夹具应使用常量文件或工厂函数，不使用内联 magic number
  （例外：边界值测试中，精确数字本身就是测试重点）
- **独立性**：单元测试不得调用外部 API、数据库或文件 I/O——应采用依赖注入

## 不应自动化的内容（What NOT to Automate）

- 视觉保真度（着色器输出、VFX 外观、动画曲线）
- “手感”特性（输入响应、重量感、节奏感）
- 平台特定渲染（应在目标硬件上测试，而非纯无头环境）
- 完整玩法流程（由玩法测试覆盖，而非自动化）

## CI/CD 规则（CI/CD Rules）

- 自动化测试套件应在每次推送到 main 和每个 PR 上运行
- 若测试失败，禁止合并——测试是 CI 中的阻塞门禁（blocking gate）
- 严禁通过禁用或跳过失败测试来让 CI 通过——应修复根因
- 引擎特定 CI 命令：
  - **Godot**: `godot --headless --script tests/gdunit4_runner.gd`
  - **Unity**: `game-ci/unity-test-runner@v4` (GitHub Actions)
  - **Unreal**: headless runner with `-nullrhi` flag
