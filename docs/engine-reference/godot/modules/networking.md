# Godot Networking — 快速参考

上次验证: 2026-02-12 | 引擎: Godot 4.6

## 自 ~4.3 以来的变更（LLM 截止版本）

### 4.6 变更
- **破坏性变更中的网络部分**: 有关 4.5→4.6 的具体信息，请参阅官方迁移指南

### 4.5 变更
- **网络 API 无重大破坏性变更**，核心多人游戏 API 保持稳定

## 当前 API 模式

### 高级多人游戏
```gdscript
# 服务器
func host_game(port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# 客户端
func join_game(address: String, port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_client(address, port)
    multiplayer.multiplayer_peer = peer
```

### RPCs
```gdscript
# 服务器权威模式
@rpc("any_peer", "call_local", "reliable")
func request_action(action_data: Dictionary) -> void:
    if not multiplayer.is_server():
        return
    # 在服务器上验证，然后广播
    _execute_action.rpc(action_data)

@rpc("authority", "call_local", "reliable")
func _execute_action(action_data: Dictionary) -> void:
    # 所有对等端执行已验证的操作
    pass
```

### MultiplayerSpawner and MultiplayerSynchronizer
```gdscript
# 使用 MultiplayerSpawner 自动复制节点
# 使用 MultiplayerSynchronizer 同步属性

# MultiplayerSynchronizer 设置:
# 1. 添加为待同步节点的子节点
# 2. 在编辑器中配置复制属性
# 3. 设置相关性可见性过滤器
```

### SceneMultiplayer 配置
```gdscript
func _ready() -> void:
    var scene_mp := multiplayer as SceneMultiplayer
    scene_mp.auth_callback = _authenticate_peer
    scene_mp.server_relay = false  # 对等端直接连接

func _authenticate_peer(id: int, data: PackedByteArray) -> void:
    # 自定义身份验证逻辑
    pass
```

## 常见错误
- 客户端到服务器的 RPC 未使用 `"any_peer"`（默认仅限 authority）
- 未经服务器端验证便信任客户端数据
- 对游戏状态变更使用 `"unreliable"`（应仅用于位置更新）
- 未在生成的节点上设置多人游戏权限（`set_multiplayer_authority()`）
