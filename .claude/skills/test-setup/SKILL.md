---
name: test-setup
description: "为项目引擎搭建测试框架和 CI/CD 管线。创建 tests/ 目录结构、引擎专用测试运行器配置和 GitHub Actions 工作流。在第一个迭代开始前的 Technical Setup 阶段运行一次。"
argument-hint: "[force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write
model: sonnet
---

# 测试环境搭建

此技能为项目搭建自动化测试基础设施。它会检测已配置的引擎，生成适用的
测试运行器配置，创建标准目录结构，并接入 CI/CD，使每次推送都能运行测试。

在任何实现工作开始前的 Technical Setup 阶段运行一次。在迭代开始时安装
测试框架只需 30 分钟，到第四个迭代才安装则会耗费 3 个迭代。

**输出：** `tests/` 目录结构 + `.github/workflows/tests.yml`

---

## 阶段 1：检测引擎和现有状态

1. **读取引擎配置**：
   - 读取 `.claude/docs/technical-preferences.md` 并提取 `Engine:` 值。
   - 如果尚未配置引擎（`[TO BE CONFIGURED]`），则停止：
     “尚未配置引擎。请先运行 `/setup-engine`，然后重新运行 `/test-setup`。”

2. **检查现有测试基础设施**：
   - Glob `tests/`，检查目录是否存在。
   - Glob `tests/unit/` 和 `tests/integration/`，检查子目录是否存在。
   - Glob `.github/workflows/`，检查 CI 工作流文件是否存在。
   - Glob `tests/gdunit4_runner.gd`（Godot）、`tests/EditMode/`（Unity）或
     `Source/Tests/`（Unreal），检查引擎专用产物。

3. **报告检查结果**：
   - “引擎：[engine]。测试目录：[found / not found]。CI 工作流：[found / not found]。”
   - 如果所有内容都已存在，且未传入 `force` 参数：
     “测试基础设施似乎已就绪。如需重新生成，请使用 `/test-setup force` 再次运行。
     继续操作不会覆盖现有测试文件。”

如果传入 `force` 参数，则跳过“已存在”的提前退出并继续，但仍不得覆盖指定路径下
已有的文件。仅创建缺失的文件。

---

## 阶段 2：展示计划

根据检测到的引擎和现有状态展示计划：

```
## 测试环境搭建计划：[Engine]

我将创建以下内容（跳过已存在的内容）：

tests/
  unit/           — 针对公式、状态和逻辑的独立单元测试
  integration/    — 跨系统测试和保存/加载往返测试
  smoke/          — 关键路径测试清单（15 分钟人工门禁）
  evidence/       — 截图和人工测试签核记录
  README.md       — 测试框架文档

[Engine-specific files — see per-engine details below]

.github/workflows/tests.yml  — CI：每次推送到 main 时运行测试

预计用时：约 5 分钟完成所有文件的创建。
```

询问：“可以创建这些文件吗？我不会覆盖这些路径下已有的任何测试文件。”

未经批准不得继续。

---

## 阶段 3：创建目录结构

获得批准后，创建以下文件：

### `tests/README.md`

```markdown
# 测试基础设施

**引擎**：[engine name + version]
**测试框架**：[GdUnit4 | Unity Test Framework | UE Automation]
**CI**：`.github/workflows/tests.yml`
**搭建日期**：[date]

## 目录结构

```
tests/
  unit/           # 独立单元测试（公式、状态机、逻辑）
  integration/    # 跨系统测试和保存/加载测试
  smoke/          # /smoke-check 门禁使用的关键路径测试清单
  evidence/       # 截图日志和人工测试签核记录
```

## 运行测试

[Engine-specific command — see below]

## 测试命名

- **文件**：`[system]_[feature]_test.[ext]`
- **函数**：`test_[scenario]_[expected]`
- **示例**：`combat_damage_test.gd` → `test_base_attack_returns_expected_damage()`

## 故事类型 → 测试证据

| 故事类型 | 必需证据 | 位置 |
|---|---|---|
| Logic | 自动化单元测试，必须通过 | `tests/unit/[system]/` |
| Integration | 集成测试或试玩文档 | `tests/integration/[system]/` |
| Visual/Feel | 截图 + 负责人签核 | `tests/evidence/` |
| UI | 人工走查或交互测试 | `tests/evidence/` |
| Config/Data | 冒烟检查通过 | `production/qa/smoke-*.md` |

## CI

每次推送到 `main` 以及每个拉取请求都会自动运行测试。
测试套件失败时将阻止合并。
```
```

### 引擎专用文件

#### Godot 4 (`Engine: Godot`)

创建 `tests/gdunit4_runner.gd`：

```gdscript
# GdUnit4 测试运行器，由 CI 和 /smoke-check 调用
# 用法：godot --headless --script tests/gdunit4_runner.gd
extends SceneTree

func _init() -> void:
    var runner := load("res://addons/gdunit4/GdUnitRunner.gd")
    if runner == null:
        push_error("未找到 GdUnit4。请通过 AssetLib 或 addons/ 安装。")
        quit(1)
        return
    var instance = runner.new()
    instance.run_tests()
    quit(0)
```

创建 `tests/unit/.gdignore_placeholder`，内容如下：
`# 单元测试放在此处，每个系统一个子目录（例如 tests/unit/combat/）`

创建 `tests/integration/.gdignore_placeholder`，内容如下：
`# 集成测试放在此处，每个系统一个子目录`

在 README 中注明：**安装 GdUnit4**
```
1. 打开 Godot → AssetLib → 搜索 "GdUnit4" → Download & Install
2. 启用插件：Project → Project Settings → Plugins → GdUnit4 ✓
3. 重启编辑器
4. 验证：res://addons/gdunit4/ 存在
```

#### Unity (`Engine: Unity`)

创建 `tests/EditMode/` 占位文件 `tests/EditMode/README.md`：
```markdown
# Edit Mode 测试
无需进入 Play Mode 即可运行的单元测试。
用于纯逻辑：公式、状态机和数据验证。
需要程序集定义：`tests/EditMode/EditModeTests.asmdef`
```

创建 `tests/PlayMode/README.md`：
```markdown
# Play Mode 测试
在真实游戏场景中运行的集成测试。
用于跨系统交互、物理和协程。
需要程序集定义：`tests/PlayMode/PlayModeTests.asmdef`
```

在 README 中注明：**启用 Unity Test Framework**
```
Window → General → Test Runner
（Unity 2019+ 默认包含 Unity Test Framework）
```

#### Unreal Engine（`Engine: Unreal` 或 `Engine: UE5`）

创建 `Source/Tests/README.md`：
```markdown
# Unreal 自动化测试
测试使用 UE Automation Testing Framework。
运行方式：Session Frontend → Automation → 选择 "MyGame." 测试
或以无界面方式运行：UnrealEditor -nullrhi -ExecCmds="Automation RunTests MyGame.; Quit"

测试类命名：F[SystemName]Test
测试类别命名："MyGame.[System].[Feature]"
```

---

## 阶段 4：创建 CI/CD 工作流

### Godot 4

创建 `.github/workflows/tests.yml`：

```yaml
name: 自动化测试

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: 运行 GdUnit4 测试
    runs-on: ubuntu-latest

    steps:
      - name: 检出代码
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: 运行 GdUnit4 测试
        uses: MikeSchulze/gdUnit4-action@v1
        with:
          godot-version: '[VERSION FROM docs/engine-reference/godot/VERSION.md]'
          paths: |
            tests/unit
            tests/integration
          report-name: test-results

      - name: 上传测试结果
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: reports/
```

### Unity

创建 `.github/workflows/tests.yml`：

```yaml
name: 自动化测试

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: 运行 Unity 测试
    runs-on: ubuntu-latest

    steps:
      - name: 检出代码
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: 运行 Edit Mode 测试
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: editmode
          artifactsPath: test-results/editmode

      - name: 运行 Play Mode 测试
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: playmode
          artifactsPath: test-results/playmode

      - name: 上传测试结果
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results/
```

注意：Unity CI 需要 `UNITY_LICENSE` 密钥。请在首次运行 CI 前将其添加到
GitHub 仓库的密钥中。

### Unreal Engine

创建 `.github/workflows/tests.yml`：

```yaml
name: 自动化测试

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: 运行 UE 自动化测试
    runs-on: self-hosted  # UE 需要安装了编辑器的本地运行器

    steps:
      - name: 检出代码
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: 运行自动化测试
        run: |
          "$UE_EDITOR_PATH" "${{ github.workspace }}/[ProjectName].uproject" \
            -nullrhi -nosound \
            -ExecCmds="Automation RunTests MyGame.; Quit" \
            -log -unattended
        shell: bash

      - name: 上传日志
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-logs
          path: Saved/Logs/
```

注意：UE CI 需要安装了 Unreal Editor 的 self-hosted 运行器。
请在运行器上设置 `UE_EDITOR_PATH` 环境变量。

---

## 阶段 5：创建冒烟测试初始清单

创建 `tests/smoke/critical-paths.md`：

```markdown
# 冒烟测试：关键路径

**目的**：在任何 QA 移交前，用不到 15 分钟完成这 10-15 项检查。
**运行方式**：`/smoke-check`（该命令会读取此文件）
**更新要求**：实现新的核心系统时添加新条目。

## 核心稳定性（始终运行）

1. 游戏启动至主菜单且不崩溃
2. 可以从主菜单开始新游戏/会话
3. 主菜单能响应所有输入且不会卡死

## 核心机制（每个迭代更新）

<!-- 每个迭代的主要机制实现后，在此处添加 -->
<!-- 示例：“玩家可以移动、跳跃，且摄像机能正确跟随” -->
4. [Primary mechanic — update when first core system is implemented]

## 数据完整性

5. 保存游戏无错误完成（保存系统实现后）
6. 加载游戏能恢复正确状态（加载系统实现后）

## 性能

7. 在目标硬件上无明显帧率下降（目标 60fps）
8. 游玩 5 分钟内内存不增长（核心循环实现后）
```

---

## 阶段 6：搭建后总结

写入所有文件后，报告：

```
已为 [engine] 创建测试基础设施。

已创建文件：
- tests/README.md
- tests/unit/（目录）
- tests/integration/（目录）
- tests/smoke/critical-paths.md
- tests/evidence/（目录）
[engine-specific files]
- .github/workflows/tests.yml

后续步骤：
1. [Engine-specific install step, e.g., "Install GdUnit4 via AssetLib"]
2. 编写第一个测试：创建 tests/unit/[first-system]/[system]_test.[ext]
3. 在第一个迭代前运行 `/qa-plan sprint`，对故事分类并设置测试证据要求
4. 每次 QA 移交前运行 `/smoke-check`

门禁说明：/gate-check Technical Setup → Pre-Production 现在要求：
- tests/ 目录包含 unit/ 和 integration/ 子目录
- .github/workflows/tests.yml
- 至少一个示例测试文件
请先运行 /test-setup 并编写一个示例测试，再推进到下一阶段。

结论：**COMPLETE**，测试框架已搭建并已接入 CI/CD。
```

---

## 协作协议

- **绝不覆盖现有测试文件**，仅创建缺失的文件。如果测试运行器文件已存在，
  保持原样。
- **创建文件前始终询问**，阶段 2 要求明确批准。
- **必须检测引擎**。如果尚未配置引擎，则停止并引导至 `/setup-engine`，不得猜测。
- **`force` 标志会跳过“已存在”的提前退出，但绝不覆盖文件。**
  它表示“即使目录已存在，也创建所有缺失的文件”。
- 对于 Unity CI，请注明必须手动配置 `UNITY_LICENSE` 密钥。
  不要尝试自动管理许可证。
