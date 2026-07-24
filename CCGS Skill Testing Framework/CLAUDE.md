# CCGS 技能测试框架 — Claude 使用说明

此文件夹是 Claude Code Game Studios 技能/代理框架的质量保证层。
它自成一体，与任何游戏项目相互独立。

## 关键文件

| 文件 | 用途 |
|------|---------|
| `catalog.yaml` | 全部 73 个技能和 49 个代理的主注册表。包含类别、规范路径和最近一次测试的跟踪字段。运行任何测试命令时，务必先读取此文件。 |
| `quality-rubric.md` | 各类别专用的通过/失败指标。运行 `/skill-test category` 时，请读取与技能类别对应的 `###` 章节。 |
| `skills/[category]/[name].md` | 技能的行为规范：5 个测试用例及协议合规性断言。 |
| `agents/[tier]/[name].md` | 代理的行为规范：5 个测试用例及协议合规性断言。 |
| `templates/skill-test-spec.md` | 用于编写新技能规范文件的模板。 |
| `templates/agent-test-spec.md` | 用于编写新代理规范文件的模板。 |
| `results/` | 保存结果时由 `/skill-test spec` 写入。已被 Git 忽略。 |

## 路径约定

- 技能规范：`CCGS Skill Testing Framework/skills/[category]/[name].md`
- 代理规范：`CCGS Skill Testing Framework/agents/[tier]/[name].md`
- 目录：`CCGS Skill Testing Framework/catalog.yaml`
- 评判标准：`CCGS Skill Testing Framework/quality-rubric.md`

`catalog.yaml` 中的 `spec:` 字段是每个技能/代理规范的权威路径。
务必读取该字段，不要猜测路径。

## 技能类别

```
gate        → gate-check
review      → design-review, architecture-review, review-all-gdds
authoring   → design-system, quick-design, architecture-decision, art-bible,
              create-architecture, ux-design, ux-review
readiness   → story-readiness, story-done
pipeline    → create-epics, create-stories, dev-story, create-control-manifest,
              propagate-design-change, map-systems
analysis    → consistency-check, balance-check, content-audit, code-review,
              tech-debt, scope-check, estimate, perf-profile, asset-audit,
              security-audit, test-evidence-review, test-flakiness
team        → team-combat, team-narrative, team-audio, team-level, team-ui,
              team-qa, team-release, team-polish, team-live-ops
sprint      → sprint-plan, sprint-status, milestone-review, retrospective,
              changelog, patch-notes
utility     → 所有其余技能
```

## 代理层级

```
directors   → creative-director, technical-director, producer, art-director
leads       → lead-programmer, narrative-director, audio-director, ux-designer,
              qa-lead, release-manager, localization-lead
specialists → gameplay-programmer, engine-programmer, ui-programmer,
              tools-programmer, network-programmer, ai-programmer,
              level-designer, sound-designer, technical-artist
godot       → godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
              godot-shader-specialist, godot-gdextension-specialist
unity       → unity-specialist, unity-ui-specialist, unity-shader-specialist,
              unity-dots-specialist, unity-addressables-specialist
unreal      → unreal-specialist, ue-gas-specialist, ue-replication-specialist,
              ue-umg-specialist, ue-blueprint-specialist
operations  → devops-engineer, security-engineer, performance-analyst,
              analytics-engineer, community-manager
creative    → writer, world-builder, game-designer, economy-designer,
              systems-designer, prototyper
```

## 技能测试工作流

1. 读取 `catalog.yaml`，获取技能的 `spec:` 路径和 `category:`
2. 读取 `.claude/skills/[name]/SKILL.md` 中的技能
3. 读取 `spec:` 路径下的规范
4. 逐个用例评估断言
5. 提议将结果写入 `results/` 并更新 `catalog.yaml`

## 技能改进工作流

使用 `/skill-improve [name]`。它会处理完整循环：
测试 → 诊断 → 提出修复方案 → 重写 → 重新测试 → 保留或还原。

## 规范有效性说明

此文件夹中的规范描述的是**当前行为**，而非理想行为。这些规范是通过读取技能编写的，
因此可能将缺陷也固化其中。当技能在实际使用中表现异常时，应先修正技能，再更新规范，
使其与修正后的行为一致。应将规范测试失败视为“此问题需要调查”，而不是“该技能肯定有误”。

## 此文件夹可以删除

`.claude/` 中没有任何内容从此处导入。删除此文件夹不会影响 CCGS 技能或代理本身。
`/skill-test` 和 `/skill-improve` 会报告 `catalog.yaml` 缺失，并引导用户初始化该文件。
