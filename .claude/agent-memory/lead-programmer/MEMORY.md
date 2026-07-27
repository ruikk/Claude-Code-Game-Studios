# Lead Programmer — 代理记忆

## 技能编写约定

### Frontmatter
- 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- 独立运行的只读分析技能还包含 `context: fork` 和 `agent:`
- 交互式技能（写入文件、提出问题）不使用 `context: fork`
- `AskUserQuestion` 是在技能正文中描述的使用模式，不会列入
  Frontmatter 的 `allowed-tools`（现有技能均不这样做）

### 文件布局
- 技能位于 `.claude/skills/<name>/SKILL.md`（每个技能使用一个子目录，绝不使用扁平的 .md 文件）
- 章节标题使用 `##` 表示阶段，使用 `###` 表示子章节
- 阶段名称遵循 "Phase N: Verb Noun" 模式（例如 "Phase 1: Find the Story"）
- 输出格式模板放在围栏代码块中

### 已知规范路径（在新技能中引用前进行验证）
- 技术债务登记表：`docs/tech-debt-register.md`（不是 `production/tech-debt.md`）
- 迭代文件：`production/sprints/`
- Epic 故事文件：`production/epics/[epic-slug]/story-[NNN]-[slug].md`
- 控制清单：`docs/architecture/control-manifest.md`
- 会话状态：`production/session-state/active.md`
- 系统索引：`design/gdd/systems-index.md`
- 引擎参考：`docs/engine-reference/[engine]/VERSION.md`

### 已完成的技能
- `story-done` — 故事结束时的完成交接（Phase 1-8，写入故事文件）
