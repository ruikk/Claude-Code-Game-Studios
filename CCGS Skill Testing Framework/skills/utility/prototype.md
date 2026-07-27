# 技能测试规范：/prototype

## 技能摘要

`/prototype` 管理快速原型流程，用于在投入完整生产实现前验证游戏机制。原型创建在
`prototypes/[mechanic-name]/` 中，并且有意设计为一次性产物，编码标准可以放宽（无需 ADR，AC 可以很简略，也允许硬编码值）。
实现完成后，该技能会生成一份发现文档，总结已获得的结论并推荐下一步行动。

该技能在创建文件前会询问“May I write to `prototypes/[name]/`?”。如果原型已经存在，技能会提供扩展、替换或归档选项。不适用主管门禁。判定结果：PROTOTYPE COMPLETE（原型已构建且发现已记录）或 PROTOTYPE ABANDONED（机制被发现不可行）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：PROTOTYPE COMPLETE、PROTOTYPE ABANDONED
- [ ] 创建原型文件前包含“May I write”协作措辞
- [ ] 包含下一步交接说明（例如使用 `/design-system` 正式化，或归档）

---

## 主管门禁检查

无。原型是一次性的验证产物。不适用主管门禁。

---

## 测试用例

### 用例 1：正常路径：机制概念完成原型，发现已记录

**测试夹具：**
- `prototypes/` 目录存在
- 不存在“grapple-hook”的现有原型

**输入：** `/prototype grapple-hook`

**预期行为：**
1. 技能询问“May I write to `prototypes/grapple-hook/`?”
2. 获得批准后：创建 `prototypes/grapple-hook/` 目录和基本实现骨架（主场景、玩家控制器扩展）
3. 技能实现最小化的抓钩机制（有意保持粗糙，不做润色，允许硬编码值）
4. 技能生成 `prototypes/grapple-hook/findings.md`，包含：
   - 测试了什么
   - 哪些有效
   - 哪些无效
   - 建议（继续 / 放弃 / 修改概念）
5. 判定结果为 PROTOTYPE COMPLETE

**断言：**
- [ ] 在创建任何文件前询问“May I write to `prototypes/grapple-hook/`?”
- [ ] 实现隔离在 `prototypes/` 中（不在 `src/` 中）
- [ ] 创建 `findings.md`，至少包含：测试内容、有效内容、无效内容和建议
- [ ] 判定结果为 PROTOTYPE COMPLETE

---

### 用例 2：原型已存在：提供扩展、替换或归档选项

**测试夹具：**
- `prototypes/grapple-hook/` 已在之前的原型会话中存在
- 其中包含基本实现和 findings.md

**输入：** `/prototype grapple-hook`

**预期行为：**
1. 技能检测到已有的 `prototypes/grapple-hook/` 目录
2. 技能报告：“grapple-hook 的原型已存在”
3. 技能提供 3 个选项：
    - 扩展：向现有原型添加新功能
    - 替换：重新开始（询问“May I replace `prototypes/grapple-hook/`?”）
    - 归档：移动到 `prototypes/archive/grapple-hook/`，然后重新开始
4. 用户选择后，技能按相应方式继续

**断言：**
- [ ] 检测并报告现有原型
- [ ] 恰好提供 3 个选项（扩展、替换、归档）
- [ ] 替换路径包含“May I replace”确认
- [ ] 归档路径移动现有原型，而不是删除

---

### 用例 3：原型验证机制：建议进入生产阶段

**测试夹具：**
- 原型实现完成
- 发现：抓钩机制有趣且技术上可行

**输入：** `/prototype grapple-hook`（原型会话完成）

**预期行为：**
1. 原型构建并测试完成后，总结发现
2. findings.md 中的建议为：“机制已验证，建议继续使用 `/design-system` 编写完整规格”
3. 技能交接消息明确建议使用 `/design-system grapple-hook`
4. 判定结果为 PROTOTYPE COMPLETE

**断言：**
- [ ] `findings.md` 包含明确建议
- [ ] 机制验证通过时，建议引用 `/design-system`
- [ ] 交接消息复述该建议
- [ ] 判定结果为 PROTOTYPE COMPLETE（不是 PROTOTYPE ABANDONED）

---

### 用例 4：原型揭示机制不可行：PROTOTYPE ABANDONED

**测试夹具：**
- 已为“procedural-dialogue”实现原型
- 测试后发现：机制会生成不连贯的对话树，游玩体验令人沮丧

**输入：** `/prototype procedural-dialogue`

**预期行为：**
1. 构建原型
2. 发现文档记录失败原因：输出不连贯、玩家困惑、技术复杂度高
3. findings.md 中的建议为：“机制不可行，放弃该方案”
4. `findings.md` 记录机制失败的具体原因
5. 技能在交接中建议替代方案（例如改用策划好的对话）
6. 判定结果为 PROTOTYPE ABANDONED

**断言：**
- [ ] 判定结果为 PROTOTYPE ABANDONED（不是 PROTOTYPE COMPLETE）
- [ ] `findings.md` 记录具体失败原因（而非含糊描述）
- [ ] 交接中建议替代方案
- [ ] 保留原型文件（不删除）供参考

---

### 用例 5：主管门禁检查：无门禁，原型是验证产物

**测试夹具：**
- 已提供机制概念

**输入：** `/prototype wall-jump`

**预期行为：**
1. 技能创建并记录原型
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定结果为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED，不是门禁判定

---

## 协议合规性

- [ ] 创建任何文件前询问“May I write to `prototypes/[name]/`?”
- [ ] 所有文件均创建在 `prototypes/` 下（不在 `src/` 下）
- [ ] 生成包含测试内容、有效内容、无效内容和建议的 `findings.md`
- [ ] 说明生产编码标准是有意放宽的
- [ ] 原型已存在时提供扩展、替换和归档选项
- [ ] 判定结果为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED

---

## 覆盖说明

- 原型实现质量（代码风格）不会被测试，因为原型是一次性产物，不适用质量标准。
- 用例 2 提到了归档机制，但没有对归档格式进行详细断言测试。
- 引擎特定的原型脚手架（GDScript 场景与 C# MonoBehaviour）遵循相同流程，只使用适合引擎的文件类型。
