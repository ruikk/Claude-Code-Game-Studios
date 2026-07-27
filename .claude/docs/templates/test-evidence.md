# 测试证据 (Test Evidence): [Story Title]

> **Story**: `[path to story file]`
> **Story Type**: [Visual/Feel | UI]
> **Date**: [date]
> **Tester**: [who performed the test]
> **Build / Commit**: [version or git hash]

---

## 测试内容 (What Was Tested)

[用一段话描述已验证的功能或行为。包含此证据所覆盖的 story 中的验收标准（acceptance criteria）编号。]

**Acceptance criteria covered**: [AC-1, AC-2, AC-3]

---

## 验收标准结果 (Acceptance Criteria Results)

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | [exact criterion text] | PASS / FAIL | [any observations] |
| AC-2 | [exact criterion text] | PASS / FAIL | |
| AC-3 | [exact criterion text] | PASS / FAIL | |

---

## 截图 / 视频 (Screenshots / Video)

在下方列出所有采集到的证据文件。将文件存储在与本文档相同的目录，或存储到 `production/qa/evidence/[story-slug]/`。

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `[filename.png]` | [brief description of what is visible] | AC-1 |
| 2 | `[filename.png]` | | AC-2 |

*If video: note the timestamp and what it demonstrates.*

---

## 测试条件 (Test Conditions)

- **Game state at start**: [e.g., "fresh save, player at level 1, no items"]
- **Platform / hardware**: [e.g., "Windows 11, GTX 1080, 1080p"]
- **Framerate during test**: [e.g., "stable 60fps" or "~45fps — within budget"]
- **Any special setup required**: [e.g., "dev menu used to trigger specific state"]

---

## 观察记录 (Observations)

[记录任何值得注意但未导致 FAIL 的事项。示例：轻微画面抖动、高负载下掉帧、行为在技术上通过但 game feel 略有偏差。这些都可作为 polish 阶段工作的候选项。]

- [Observation 1]
- [Observation 2]

If nothing notable: *No significant observations.*

---

## 签署确认 (Sign-Off)

在可通过 `/story-done` 将 story 标记为 COMPLETE 之前，必须完成三方签署。
Visual/Feel 类型的 story 需要设计师或美术负责人签署。
UI 类型的 story 需要 UX 负责人或设计师签署。

**独立开发者**：每个角色的所有签字都可以由同一个人完成。
意图是有人在标记完成之前刻意审查证据——并不是必须由三个人参与。

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer (implemented) | | | [ ] Approved |
| Designer / Art Lead / UX Lead | | | [ ] Approved |
| QA Lead | | | [ ] Approved |

**任何签字都可以标注为“Deferred — [reason]”**，如果该人无法出席。
延期签字必须在故事通过冲刺评审前解决。


---

*Template: `.claude/docs/templates/test-evidence.md`*
*Used for: Visual/Feel and UI story type evidence records*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
