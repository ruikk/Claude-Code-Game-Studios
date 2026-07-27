# 技能测试规范：/scope-check

## 技能摘要

`/scope-check` 是 Haiku 层级的只读技能，用于分析功能、迭代或故事的范围蔓延风险。
它读取迭代和故事文件，并与当前里程碑目标进行比较，适合在规划前或规划期间进行快速、
低成本检查。不调用总监门禁，也不写入文件。结论为：ON SCOPE、CONCERNS 或
SCOPE CREEP DETECTED。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：ON SCOPE、CONCERNS、SCOPE CREEP DETECTED
- [ ] 不要求使用 "May I write" 措辞（只读技能）
- [ ] 包含下一步交接（根据结论采取什么行动）

---

## 总监门禁检查

无。范围检查是只读建议技能，不调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——迭代故事与里程碑目标一致

**测试夹具：**
- `production/milestones/milestone-03.md` 列出 3 个目标：战斗系统、敌人 AI、关卡加载
- `production/sprints/sprint-006.md` 包含 5 个故事，均标记为 3 个目标之一
- `production/session-state/active.md` 将 milestone-03 作为当前里程碑引用

**输入：** `/scope-check`

**预期行为：**
1. 技能从 milestone-03 读取当前里程碑目标
2. 技能读取 sprint-006 故事，并逐一与里程碑目标核对
3. 全部 5 个故事均映射到 3 个目标之一
4. 技能输出映射表：故事 → 里程碑目标
5. 结论为 ON SCOPE

**断言：**
- [ ] 输出将每个故事映射到里程碑目标
- [ ] 所有故事均映射到里程碑目标时，结论为 ON SCOPE
- [ ] 不写入任何文件
- [ ] 技能不修改迭代或里程碑文件

---

### 用例 2：检测到范围蔓延——故事引入里程碑未包含的系统

**测试夹具：**
- `production/milestones/milestone-03.md` 的目标：战斗、敌人 AI、关卡加载
- `production/sprints/sprint-006.md` 包含 5 个故事：
  - 3 个故事映射到里程碑目标
  - 2 个故事引用“在线排行榜”和“成就系统”（milestone-03 未包含）

**输入：** `/scope-check`

**预期行为：**
1. 技能读取里程碑目标和迭代故事
2. 技能识别出 2 个没有匹配里程碑目标的故事
3. 技能明确列出范围外故事：“在线排行榜功能”“成就系统设置”
4. 结论为 SCOPE CREEP DETECTED

**断言：**
- [ ] 输出明确列出范围外故事名称
- [ ] 任一故事没有匹配的里程碑目标时，结论为 SCOPE CREEP DETECTED
- [ ] 技能不自动移除故事，发现仅供建议
- [ ] 输出建议将范围外故事推迟到后续里程碑

---

### 用例 3：未定义里程碑——CONCERNS；无法验证范围

**测试夹具：**
- `production/session-state/active.md` 没有里程碑引用
- `production/milestones/` 目录存在但为空
- `production/sprints/sprint-006.md` 有 4 个故事

**输入：** `/scope-check`

**预期行为：**
1. 技能读取 active.md，未找到里程碑引用
2. 技能检查 `production/milestones/`，未找到里程碑文件
3. 技能输出：“未定义当前里程碑，无法验证范围”
4. 结论为 CONCERNS

**断言：**
- [ ] 未定义里程碑时技能不报错
- [ ] 输出明确说明范围验证需要里程碑引用
- [ ] 结论为 CONCERNS（没有数据时不是 ON SCOPE 或 SCOPE CREEP DETECTED）
- [ ] 输出建议运行 `/milestone-review` 或创建里程碑

---

### 用例 4：单故事检查——依据其父史诗评估

**测试夹具：**
- 用户指定单个故事：`production/epics/combat/story-parry-timing.md`
- 故事引用父史诗：`epic-combat.md`
- `production/epics/combat/epic-combat.md` 的范围为：“近战战斗机制”
- 故事标题：“实现招架时机窗口”，与史诗范围匹配

**输入：** `/scope-check production/epics/combat/story-parry-timing.md`

**预期行为：**
1. 技能读取指定的故事文件
2. 技能读取父史诗以获取范围定义
3. 技能依据史诗范围评估故事，“招架时机”匹配“近战战斗”
4. 结论为 ON SCOPE

**断言：**
- [ ] 接受单文件参数（故事路径，而非迭代）
- [ ] 技能读取故事文件中引用的父史诗
- [ ] 单故事模式依据史诗范围（而非里程碑范围）评估故事
- [ ] 故事符合史诗范围时，结论为 ON SCOPE

---

### 用例 5：门禁合规——不调用门禁；可另行咨询 PR

**测试夹具：**
- 迭代有 2 个 SCOPE CREEP 故事和 3 个 ON SCOPE 故事
- `review-mode.txt` 包含 `full`

**输入：** `/scope-check`

**预期行为：**
1. 技能读取里程碑和迭代，识别出 2 个范围蔓延项
2. 无论审查模式为何，均不调用总监门禁
3. 技能展示发现，结论为 SCOPE CREEP DETECTED
4. 输出说明：“建议在迭代开始前向制作人提出范围顾虑”
5. 技能结束且不写入任何文件

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 建议（而非强制）咨询制作人
- [ ] 不写入任何文件
- [ ] 结论为 SCOPE CREEP DETECTED

---

## 协议合规性

- [ ] 分析前读取里程碑目标和迭代/故事文件
- [ ] 将每个故事映射到里程碑目标（或标记为未映射）
- [ ] 不写入任何文件
- [ ] 不调用总监门禁
- [ ] 在 Haiku 模型层级运行（快速、低成本）
- [ ] 结论为 ON SCOPE、CONCERNS、SCOPE CREEP DETECTED 之一

---

## 覆盖说明

- 此处未测试迭代文件本身不存在的情况；技能会输出 CONCERNS，并提示缺少迭代数据。
- 此处未明确测试部分范围重叠（故事涉及里程碑目标但也引入新范围）；实现可以将其
  分类为 CONCERNS，而非 SCOPE CREEP DETECTED。
