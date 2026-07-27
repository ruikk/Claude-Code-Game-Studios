<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    将一个 Claude Code 会话变成一个完整的游戏开发工作室。
    <br />
    49 个代理。37 个工作流。一支协同的 AI 团队。
  </p>
</p>

> 本项目已完成绝大部分文件的汉化，可能仍有少部分内容尚未完整翻译，但不影响正常使用。非翻译相关问题请向原作者提交 issue。本项目仅承担汉化工作，源项目地址：[Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)。

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-73-green" alt="73 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-12-orange" alt="12 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20this%20project-FFDD00?logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Support%20this%20project-ea4aaa?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

---

## 为什么有这个项目

用 AI 独立开发游戏非常强大——但一个聊天会话缺乏结构。没有人阻止你硬编码魔法数字、跳过设计文档、或者写出面条代码。没有 QA 审查、没有设计评审、没有人问"这真的符合游戏愿景吗？"

**Claude Code Game Studios** 通过给你的 AI 会话赋予真实工作室的结构来解决这个问题。你得到的不是一个通用助手，而是 49 个按工作室层级组织的专业代理——总监守护愿景，部门负责人掌控各自领域，专家负责具体执行。每个代理都有明确的职责、上报路径和质量关卡。

结果是：你仍然做出每一个决定，但现在你有一个团队会提出正确的问题、尽早发现错误，并让你的项目从最初的头脑风暴到发布都保持有序。

---

## 目录

- [包含内容](#包含内容)
- [工作室层级](#工作室层级)
- [斜杠命令](#斜杠命令)
- [快速开始](#快速开始)
- [升级](#升级)
- [项目结构](#项目结构)
- [工作原理](#工作原理)
- [设计理念](#设计理念)
- [自定义](#自定义)
- [平台支持](#平台支持)
- [社区](#社区)
- [支持此项目](#支持此项目)
- [许可证](#许可证)

---

## 包含内容

| 类别 | 数量 | 描述 |
|----------|-------|-------------|
| **智能体** | 49 | 覆盖设计、程序、美术、音频、剧情、测试、项目管理的专业化子智能体 |
| **技能** | 73 | 适配各工作流程阶段的斜杠命令（/start, /design-system, /create-epics, /create-stories, /dev-story, /story-done, 等等） |
| **钩子** | 12 | 针对代码提交、推送、资源变更、会话生命周期、智能体操作审计日志、风险缺口检测执行自动化校验 |
| **规则** | 11 | 编辑游戏玩法、引擎、AI、UI、网络代码等时强制执行的路径范围编码标准 |
| **模板** | 41 | 游戏设计文档、交互规范、架构决策记录、迭代计划、平视界面设计、无障碍方案等文档模板 |

## 工作室层级

代理分为三个层级，与真实工作室的运作方式一致：

```
第一层级 — 总监 (Opus)
  creative-director    technical-director    producer

第二层级 — 部门负责人 (Sonnet)
  game-designer        lead-programmer       art-director
  audio-director       narrative-director    qa-lead
  release-manager      localization-lead

第三层级 — 专家 (Sonnet/Haiku)
  gameplay-programmer  engine-programmer     ai-programmer
  network-programmer   tools-programmer      ui-programmer
  systems-designer     level-designer        economy-designer
  technical-artist     sound-designer        writer
  world-builder        ux-designer           prototyper
  performance-analyst  devops-engineer       analytics-engineer
  security-engineer    qa-tester             accessibility-specialist
  live-ops-designer    community-manager
```

### 引擎专家

该模板内置适配三大主流游戏引擎的智能体套件，请选用与你的项目相匹配的套件：

| 引擎 | 主智能体 | 专项子智能体 |
|--------|-----------|-----------------|
| **Godot 4** | `godot-specialist` | GDScript, Shaders, GDExtension |
| **Unity** | `unity-specialist` | DOTS/ECS, Shaders/VFX, Addressables, UI Toolkit |
| **Unreal Engine 5** | `unreal-specialist` | GAS, Blueprints, Replication, UMG/CommonUI |

## 斜杠命令

在Claude Code中输入`/`即可访问全部73项技能：

**入门与导航**
`/start` `/help` `/project-stage-detect` `/setup-engine` `/adopt`

**游戏设计**
`/brainstorm` `/map-systems` `/design-system` `/quick-design` `/review-all-gdds` `/propagate-design-change`

**美术与资产**
`/art-bible` `/asset-spec` `/asset-audit`

**用户体验与界面设计**
`/ux-design` `/ux-review`

**架构**
`/create-architecture` `/architecture-decision` `/architecture-review` `/create-control-manifest`

**故事与迭代**
`/create-epics` `/create-stories` `/dev-story` `/sprint-plan` `/sprint-status` `/story-readiness` `/story-done` `/estimate`

**评审与分析**
`/design-review` `/code-review` `/balance-check` `/content-audit` `/scope-check` `/perf-profile` `/tech-debt` `/gate-check` `/consistency-check` `/security-audit`

**QA与测试**
`/qa-plan` `/smoke-check` `/soak-test` `/regression-suite` `/test-setup` `/test-helpers` `/test-evidence-review` `/test-flakiness` `/skill-test` `/skill-improve`

**生产**
`/milestone-review` `/retrospective` `/bug-report` `/bug-triage` `/reverse-document` `/playtest-report`

**发布**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix` `/day-one-patch`

**创意与内容**
`/prototype` `/onboard` `/localize`

**团队编排** (coordinate multiple agents on a single feature)
`/team-combat` `/team-narrative` `/team-ui` `/team-release` `/team-polish` `/team-audio` `/team-level` `/team-live-ops` `/team-qa`

## 快速开始

### 前置要求

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **推荐**: [jq](https://jqlang.github.io/jq/) (用于钩子验证) 以及 [Python 3](https://www.python.org/) (用于 JSON 验证)

如果缺少可选工具，所有钩子都会优雅地失败 — 不会出问题，只是验证功能会丢失。

### 安装

1. **克隆或用作模板**：
   ```bash
   git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
   cd my-game
   ```

2. **打开 Claude Code** 并启动会话：
   ```bash
   claude
   ```

3. **运行 `/start`** ——系统会询问你当前的状态（毫无头绪、模糊概念、清晰设计、已有工作），然后引导你进入正确的工作流。不做任何假设。

   如果你已经知道自己需要什么，也可以直接跳转到特定技能：
   - `/brainstorm` — 从零开始探索游戏创意
   - `/setup-engine godot 4.6` — 如果你已经确定引擎，配置你的引擎
   - `/project-stage-detect` — 分析已有项目

## 升级

已经在使用旧版本的模板？请查看 [UPGRADING.md](UPGRADING.md)，
获取逐步迁移指南、版本变更详情，以及哪些文件可以安全覆盖、哪些需要手动合并。

## 项目结构

```
CLAUDE.md                           # 主配置文件
.claude/
  settings.json                     # 钩子、权限、安全规则
  agents/                           # 49 个代理定义 (markdown + YAML frontmatter)
  skills/                           # 73 个斜杠命令（每个技能一个子目录）
  hooks/                            # 12 个钩子脚本（Bash，跨平台）
  rules/                            # 11 个路径范围的编码标准
  statusline.sh                     # 状态行脚本 (context%, model, stage, epic breadcrumb)
  docs/
    workflow-catalog.yaml           # 7 阶段管线定义（可通过 /help 查看）
    templates/                      # 41 个文档模板
src/                                # 游戏源代码
assets/                             # 美术、音频、VFX、着色器、数据文件
design/                             # GDD、叙事文档、关卡设计
docs/                               # 技术文档和 ADRs
tests/                              # 测试套件 (unit, integration, performance, playtest)
tools/                              # 构建和流水线工具
prototypes/                         # 一次性原型（与 src/ 隔离）
production/                         # 迭代计划、里程碑、发布跟踪
```

## 工作原理

### 代理协调

代理遵循结构化的委派模型：

1. **垂直委派** ——总监委派给部门负责人，部门负责人委派给专家
2. **横向协商** ——同层级代理可以相互协商，但不能做出跨领域的约束性决策
3. **冲突解决** ——分歧上报至共同的上级（设计冲突上报至 `creative-director`，技术冲突上报至 `technical-director`）
4. **变更传播** ——跨部门的变更由 `producer` 协调
5. **领域边界** ——代理不修改其领域之外的文件，除非有明确委派

### 协作，而非自主

这**不是**一个自动驾驶系统。每个代理遵循严格的协作协议：

1. **提问** ——代理在提出解决方案之前先提问
2. **展示选项** ——代理展示 2-4 个方案及其利弊
3. **你做决定** ——用户始终做出最终决定
4. **草稿** ——代理在最终确认前展示工作成果
5. **审批** ——没有你的确认，不会写入任何内容

你始终掌控全局。代理提供结构和专业知识，而不是自主行动。

### 自动化安全

**钩子** 在每次会话中自动运行：

| 钩子 | 触发条件 | 功能 |
|------|----------|------|
| `validate-commit.sh` | PreToolUse (Bash) | 检查硬编码常量、TODO 注释格式、JSON 文件合法性；若指令并非 git commit 则提前终止运行 |
| `validate-push.sh` | PreToolUse (Bash) | 向受保护分支推送代码时发出警告；若指令并非 git push 则提前终止运行 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 校验资源命名规范与 JSON 结构；若文件不在 assets/ 目录下则提前终止运行 |
| `session-start.sh` | 会话打开 | 展示当前分支与近期提交记录，提供上下文参考 |
| `detect-gaps.sh` | 会话打开 | 识别新建项目（提示执行 /start）；检测已有代码或原型但缺失设计文档的情况 |
| `pre-compact.sh` | 在压缩之前 | 保存会话过程记录 |
| `post-compact.sh` | 在压缩之后 | 提示 Claude 从 active.md 恢复会话状态 |
| `notify.sh` | 通知事件 | 通过 PowerShell 弹出 Windows 系统桌面通知 |
| `session-stop.sh` | 会话关闭 | 将 active.md 归档至会话日志，并记录 Git 操作信息 |
| `log-agent.sh` | 智能体启动 | 启动审计追踪，记录子智能体调用行为 |
| `log-agent-stop.sh` | 智能体停止 | 结束审计追踪，补全子智能体运行记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 当修改任意 .claude/skills/ 目录内容后，提醒执行 /skill-test |

> **注意**：`validate-commit.sh`、`validate-assets.sh` 和 `validate-skill-change.sh` 会在每次 Bash/Write 工具调用时触发，并且在命令或文件路径不相关时立即退出（exit 0）。这是钩子（hook）的正常行为——不影响性能。

settings.json 中的权限规则会自动放行安全操作（查看 Git 状态、运行测试），同时拦截高危操作（强制推送、rm -rf、读取 .env 环境文件）。

### 路径范围规则

编码标准根据文件位置自动强制执行：

| 路径 | 强制执行内容 |
|------|-------------|
| `src/gameplay/**` | 数据驱动值、delta time 使用、禁止 UI 引用 |
| `src/core/**` | 热路径零分配、线程安全、API 稳定性 |
| `src/ai/**` | 性能预算、可调试性、数据驱动参数 |
| `src/networking/**` | 服务器权威、版本化消息、安全性 |
| `src/ui/**` | 不持有游戏状态、支持本地化、无障碍访问 |
| `design/gdd/**` | 必须包含 8 个章节、公式格式、边界情况 |
| `tests/**` | 测试命名、覆盖率要求、测试夹具模式 |
| `prototypes/**` | 放宽标准、需要 README、记录假设 |

## 设计理念

本模板基于专业游戏开发实践：

- **MDA 框架** ——机制、动态、美学分析用于游戏设计
- **自我决定理论** ——自主性、能力感、关联性用于玩家动机
- **心流状态设计** ——挑战与技能的平衡用于玩家参与度
- **巴特尔玩家类型** ——目标受众定位与验证
- **验证驱动开发** ——先写测试，再实现功能

## 自定义

这是一个**模板**，不是锁定的框架。一切都可以自定义：

- **添加/删除代理** ——删除不需要的代理文件，为你的领域添加新代理
- **编辑代理提示词** ——调整代理行为，添加项目特定知识
- **修改技能** ——调整工作流以匹配你的团队流程
- **添加规则** ——为你的项目目录结构创建新的路径范围规则
- **调整钩子** ——调整验证严格程度，添加新检查
- **选择引擎** ——使用 Godot、Unity 或 Unreal 代理集（或都不用）
- **Set review intensity** — `full` (all director gates), `lean` (phase gates only), or `solo` (none). Set during `/start` or edit `production/review-mode.txt`. Override per-run with `--review solo` on any skill.

## 平台支持

主要在 **Windows 10** 上使用 Git Bash 开发和测试。
所有钩子都使用 POSIX 兼容的模式（`grep -E`，而不是 `grep -P`），并且包含缺失工具的备选方案，所以它们应该可以在 macOS 和 Linux 上运行。
`notify.sh` 钩子在 Windows 上使用 PowerShell 进行通知，而在其他地方不做任何操作——macOS/Linux 上的桌面通知尚未设置。
跨平台测试正在进行中；如果出现任何特定平台的问题，请提出问题反馈。

## 社区

- **讨论区** —— [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 用于提问、分享想法和展示你的作品
- **问题反馈** —— [Bug 报告和功能请求](https://github.com/Donchitos/Claude-Code-Game-Studios/issues)

---

## 支持此项目

Claude Code Game Studios 是免费和开源的。如果你节省了时间或帮助你发布了游戏，请考虑支持持续开发：

<p>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

- **[Buy Me a Coffee](https://www.buymeacoffee.com/donchitos3)** — 一次性支持
- **[GitHub Sponsors](https://github.com/sponsors/Donchitos)** — 通过 GitHub 的 recurring 支持

赞助帮助资助用于维护技能、添加新代理、保持与 Claude Code 和引擎 API 变更同步以及响应社区问题的时间。

---

*通过 Claude Code 构建. 维护和扩展中 — 欢迎通过以下方式贡献 [GitHub 讨论](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions).*

## 许可证

MIT 许可证。详见 [LICENSE](LICENSE)。
