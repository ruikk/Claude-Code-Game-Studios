# 声音圣经（Sound Bible）: [Project Name]

## 音频愿景（Audio Vision）

### 声音身份（Sonic Identity）
[用 2-3 句话描述游戏整体的音频个性。这个游戏“听起来”是什么感觉？音频应唤起哪些情绪？]

### 音频支柱（Audio Pillars）
1. **[Pillar 1]**: [该支柱如何在音频中体现]
2. **[Pillar 2]**: [该支柱如何在音频中体现]
3. **[Pillar 3]**: [该支柱如何在音频中体现]

### 参考游戏 / 媒体（Reference Games / Media）
| Reference | 借鉴点（What to Take From It） | 避免点（What to Avoid） |
| ---- | ---- | ---- |
| [Game/Film 1] | [要借鉴的具体音频特质] | [不符合我们愿景的内容] |
| [Game/Film 2] | [要借鉴的具体音频特质] | [不符合我们愿景的内容] |

---

## 音乐方向（Music Direction）

### 风格与类型（Style and Genre）
[主要音乐风格、配器音色板、节奏范围]

### 配器音色板（Instrumentation Palette）
- **Core instruments**: [列出定义整体声音的主要乐器/合成器]
- **Accent instruments**: [用于强调、转场、特殊时刻]
- **Avoid**: [不适合本游戏的乐器或风格]

### 自适应音乐系统（Adaptive Music System）
| Game State | 音乐行为（Music Behavior） | 转场（Transition） |
| ---- | ---- | ---- |
| Exploration | [速度、能量、配器] | [如何转入下一个状态] |
| Combat | [速度、能量、配器] | [触发条件与 crossfade 时长] |
| Stealth/Tension | [速度、能量、配器] | [触发与转场方式] |
| Victory/Reward | [Stinger 或转场行为] | [回到探索状态] |
| Menu/UI | [菜单音乐风格] | [游戏开始时的淡出] |

### 音乐规则（Music Rules）
- [关于循环的规则，例如："All exploration tracks must loop seamlessly after 2-4 minutes"]
- [关于留白的规则，例如："Allow 10-15 seconds of silence between exploration loops"]
- [关于强度的规则，例如："Combat music must reach full intensity within 3 seconds of combat start"]
- [关于转场的规则，例如："All music transitions use 1.5 second crossfades"]

---

## 音效（Sound Effects）

### SFX 音色板（SFX Palette）
| Category | 描述（Description） | 风格说明（Style Notes） |
| ---- | ---- | ---- |
| Player Actions | [移动、攻击、能力] | [有冲击力、响应快、混音前排] |
| Enemy Actions | [攻击、能力、死亡] | [与玩家音效明显区分，略靠后] |
| UI | [按钮点击、菜单转场、通知] | [干净、克制、重复播放也不烦躁] |
| Environment | [环境循环、天气、物体] | [沉浸式、分层、具空间感] |
| Feedback | [受伤、拾取道具、升级] | [清晰、满足感强、不易听觉疲劳] |

### 音频反馈优先级（Audio Feedback Priority）
当多个声音竞争时，按以下优先级决定播放：
1. 玩家受伤 / 关键警告（始终可听见）
2. 玩家动作（攻击、技能）
3. 敌人动作（优先附近敌人）
4. UI 反馈
5. 环境 / 氛围声

### SFX 规则（SFX Rules）
- [关于重复的规则，例如："Every SFX with >3 plays/minute needs 3+ variations"]
- [关于空间音频的规则，例如："All gameplay SFX must be 3D positioned, UI SFX are 2D"]
- [关于 ducking 的规则，例如："Player hit SFX ducks all other SFX by 3dB for 200ms"]
- [关于响应时间的规则，例如："Action SFX must trigger within 1 frame of the action"]

---

## 混音（Mixing）

### 混音总线结构（Mix Bus Structure）
| Bus | 内容（Content） | 目标电平（Target Level） |
| ---- | ---- | ---- |
| Master | 全部声音 | 0 dB |
| Music | 所有音乐轨道 | [target dBFS] |
| SFX | 所有音效 | [target dBFS] |
| Dialogue | 所有语音/旁白 | [target dBFS] |
| UI | 所有界面声音 | [target dBFS] |
| Ambient | 环境循环声 | [target dBFS] |

### 混音规则（Mixing Rules）
- 对话始终优先——对话期间压低音乐与 SFX
- 音乐应“被感受到”而非“压过一切”——若玩家听不清 SFX，说明音乐过大
- Master 输出严禁削波——在 master bus 上使用 limiter
- 所有音量必须允许玩家调节（按 bus 分组）
- 默认混音需同时适配音箱与耳机

### 动态范围（Dynamic Range）
- [指定响度目标，例如："Target -14 LUFS integrated, -1 dBTP true peak"]
- [指定压缩策略，例如："Light compression on SFX bus, no compression on music"]

---

## 技术规格（Technical Specifications）

### 格式要求（Format Requirements）
| Type | Format | Sample Rate | Bit Depth | Notes |
| ---- | ---- | ---- | ---- | ---- |
| Music | [OGG/WAV] | [44.1/48 kHz] | [16/24 bit] | [Streaming from disk] |
| SFX | [WAV/OGG] | [44.1/48 kHz] | [16 bit] | [Loaded into memory] |
| Ambient | [OGG] | [44.1 kHz] | [16 bit] | [Streaming, loopable] |
| Dialogue | [OGG/WAV] | [44.1 kHz] | [16 bit] | [Streaming] |

### 命名规范（Naming Convention）
`[category]_[subcategory]_[name]_[variation].ext`
- 示例：`sfx_weapon_sword_swing_01.wav`
- 示例：`music_exploration_forest_loop.ogg`
- 示例：`amb_environment_cave_drip_loop.ogg`

### 内存预算（Memory Budget）
- 总音频内存： [目标值，例如 128 MB]
- SFX 池： [目标值]
- 音乐流缓冲： [目标值]
- 语音流缓冲： [目标值]

---

## 无障碍（Accessibility）

- 所有关键音频提示都必须有视觉替代（字幕、屏幕闪烁、图标）
- 为听障玩家提供单声道音频选项
- 为所有总线提供独立音量控制
- 提供关闭突发大音量声音的选项
- 所有对话都支持字幕并标注说话者
