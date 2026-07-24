# CCGS 技能测试框架（CCGS Skill Testing Framework）

**Claude Code Game Studios** 框架的质量保证基础设施。
它测试技能和代理本身，而不是使用它们构建的任何游戏。

> **此文件夹独立且可选。**
> 使用 CCGS 的游戏开发者不需要它。若要将其完全移除：
> `rm -rf "CCGS Skill Testing Framework"`，`.claude/` 中没有任何内容依赖它。

---

## 目录内容

```
CCGS Skill Testing Framework/
├── README.md              ← 当前文件
├── CLAUDE.md              ← 告诉 Claude 如何使用此框架
├── catalog.yaml           ← 主注册表：全部 73 个技能和 49 个代理，以及覆盖率跟踪信息
├── quality-rubric.md      ← /skill-test category 使用的分类专属通过/失败指标
│
├── skills/                ← 技能行为规范文件（每个技能一个）
│   ├── gate/              ← gate 分类规范
│   ├── review/            ← review 分类规范
│   ├── authoring/         ← authoring 分类规范
│   ├── readiness/         ← readiness 分类规范
│   ├── pipeline/          ← pipeline 分类规范
│   ├── analysis/          ← analysis 分类规范
│   ├── team/              ← team 分类规范
│   ├── sprint/            ← sprint 分类规范
│   └── utility/           ← utility 分类规范
│
├── agents/                ← 代理行为规范文件（每个代理一个）
│   ├── directors/         ← creative-director、technical-director、producer、art-director
│   ├── leads/             ← lead-programmer、narrative-director、audio-director 等
│   ├── specialists/       ← 引擎、代码、着色器和 UI 专家
│   ├── godot/             ← Godot 专属专家
│   ├── unity/             ← Unity 专属专家
│   ├── unreal/            ← Unreal 专属专家
│   ├── operations/        ← QA、live-ops、发布和本地化等
│   └── creative/          ← writer、world-builder、game-designer 等
│
├── templates/             ← 用于编写新规范的规范文件模板
│   ├── skill-test-spec.md ← 技能行为规范模板
│   └── agent-test-spec.md ← 代理行为规范模板
│
└── results/               ← 测试运行输出（由 /skill-test spec 写入，已被 Git 忽略）
```

---

## 使用方法

所有测试均由框架中已有的两个技能驱动：

### 检查结构合规性

```
/skill-test static [skill-name]     # 检查一个技能（7 项检查）
/skill-test static all              # 检查全部 73 个技能
```

### 运行行为规范测试

```
/skill-test spec gate-check         # 根据书面规范评估技能
/skill-test spec design-review
```

### 根据分类量规检查

```
/skill-test category gate-check     # 根据分类指标评估一个技能
/skill-test category all            # 对所有已分类技能运行量规检查
```

### 查看完整覆盖情况

```
/skill-test audit                   # 技能 + 代理：是否有规范、最近测试时间、结果
```

### 改进未通过测试的技能

```
/skill-improve gate-check           # 测试 → 诊断 → 提出修复方案 → 重新测试的循环
```

---

## 技能分类

| 分类 | 技能 | 关键指标 |
|----------|--------|-------------|
| `gate` | gate-check | 读取审查模式，提供 full/lean/solo 主管评审组，不自动推进 |
| `review` | design-review, architecture-review, review-all-gdds | 只读，执行 8 个章节的检查，给出正确结论 |
| `authoring` | design-system, quick-design, art-bible, create-architecture, … | 逐章节询问是否可以写入，先建立骨架 |
| `readiness` | story-readiness, story-done | 明确显示阻塞项，full 模式下设置主管门禁 |
| `pipeline` | create-epics, create-stories, dev-story, map-systems, … | 检查上游依赖，交接路径清晰 |
| `analysis` | consistency-check, balance-check, code-review, tech-debt, … | 只读报告，包含结论关键字，不写入文件 |
| `team` | team-combat, team-narrative, team-audio, … | 启动所有必需代理，明确显示阻塞状态 |
| `sprint` | sprint-plan, sprint-status, milestone-review, … | 读取迭代数据，包含状态关键字 |
| `utility` | start, adopt, hotfix, localize, setup-engine, … | 通过静态检查 |

---

## 代理层级

| 层级 | 代理 |
|------|--------|
| `directors` | creative-director, technical-director, producer, art-director |
| `leads` | lead-programmer, narrative-director, audio-director, ux-designer, qa-lead, release-manager, localization-lead |
| `specialists` | gameplay-programmer, engine-programmer, ui-programmer, tools-programmer, network-programmer, ai-programmer, level-designer, sound-designer, technical-artist |
| `godot` | godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist |
| `unity` | unity-specialist, unity-ui-specialist, unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist |
| `unreal` | unreal-specialist, ue-gas-specialist, ue-replication-specialist, ue-umg-specialist, ue-blueprint-specialist |
| `operations` | devops-engineer, security-engineer, performance-analyst, analytics-engineer, community-manager |
| `creative` | writer, world-builder, game-designer, economy-designer, systems-designer, prototyper |

---

## 更新目录

`catalog.yaml` 跟踪每个技能和代理的测试覆盖情况。运行测试后：

- `/skill-test spec [name]` 会询问是否更新 `last_spec` 和 `last_spec_result`
- `/skill-test category [name]` 会询问是否更新 `last_category` 和 `last_category_result`
- `last_static` 和 `last_static_result` 需手动更新或通过 `/skill-improve` 更新

---

## 编写新规范

1. 在 `templates/skill-test-spec.md` 中找到规范模板
2. 将其复制到 `skills/[category]/[skill-name].md`
3. 更新 `catalog.yaml` 中的 `spec:` 字段，使其指向新文件
4. 运行 `/skill-test spec [skill-name]` 进行验证

---

## 移除此框架

此文件夹未与主项目建立任何挂钩。若要移除：

```bash
rm -rf "CCGS Skill Testing Framework"
```

技能 `/skill-test` 和 `/skill-improve` 仍可运行，但它们会报告缺少
`catalog.yaml`，并建议运行 `/skill-test audit` 对其进行初始化。
