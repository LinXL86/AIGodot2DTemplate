# CLAUDE.md — Godot 4.6 2D 模板

## 项目结构

```
res://
├── scenes/          # .tscn 场景文件
│   ├── actors/      # 玩家、敌人、NPC
│   ├── ui/          # UI 场景
│   ├── levels/      # 关卡/地图
│   └── props/       # 道具、可交互物
├── scripts/         # 共享 GDScript (.gd)
│   ├── autoload/    # 全局单例（EventBus, GameState）
│   ├── components/  # 可复用组件（@export 注入）
│   └── utilities/   # 纯工具
├── assets/          # 美术资源
│   ├── sprites/  sounds/  fonts/  shaders/
├── .trae/skills/    # Godot 各领域开发参考（Skill），实现功能时优先查阅对应 skill
└── docs/            # 文档（.gdignore 阻止 Godot 导入）
```

- 场景根节点脚本跟 `.tscn` 放在一起，只有被多个场景共享的脚本才放 `scripts/`

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件/脚本 | snake_case | `player_controller.gd` |
| 类名 | PascalCase | `class_name PlayerController` |
| 函数/变量/信号 | snake_case | `func take_damage()` `var max_health` |
| 常量/枚举值 | UPPER_SNAKE | `const MAX_SPEED = 400.0` |
| 私有成员/方法 | `_` 前缀 | `var _current_health` `func _apply_knockback()` |
| 节点名 | PascalCase | `HealthBar` `CollisionShape2D` |
| 信号回调 | `_on_<node>_<signal>` | `func _on_button_pressed()` |

- 禁止保留默认名称如 `Node2D`、`ColorRect`、`Sprite2D3`
- 同类节点用数字后缀：`EnemySpawnPoint1`、`EnemySpawnPoint2`

## GDScript 规则

### 始终使用类型注解
```gdscript
var speed: float = 200.0
func deal_damage(target: Node2D, amount: int) -> bool:
```
例外：`_ready()` 中的临时变量。

### 文件内代码顺序
1. `class_name` / `extends`
2. signals → enums → constants → `@export` vars → public vars → private vars → `@onready` vars
3. `_ready()` → `_process()` → `_physics_process()`
4. signal callbacks
5. public methods → private methods

### 缩进
- Tab 缩进（遵循 `.editorconfig`）

### 提前返回优于深层嵌套
```gdscript
func process_target(target: Node) -> void:
    if not is_instance_valid(target):
        return
    if not target.is_alive:
        return
    _apply_damage(target)
```

### 依赖通过 @export 注入，禁止硬编码路径
```gdscript
@export var hitbox: Area2D              # 正确
var hitbox: Area2D = $"../../../Hitbox" # 错误
```

### 用户可见字符串使用 `tr()`
```gdscript
label.text = tr("Press Start")
```
格式化使用插值：`"Health: %d/%d" % [current, max_health]`

### 注释
- 不要注释代码做了什么——代码应自解释
- 只在非显而易见时注释为什么（workaround、设计决策）

### 信号连接
- 代码连接的信号集中在 `_ready()` 中
- 编辑器连接的信号使用 `_on_<node>_<signal>` 命名
- 信号名用过去式描述已发生事件：`health_changed`、`enemy_died`（非 `update_health`、`die`）

### 运行时安全
- 动态创建的节点用 `queue_free()` 释放，禁止直接 `free()`（避免 use-after-free）
- `await` 之后节点可能已被释放，恢复前检查 `is_instance_valid(self)`
- 重写 `_ready()` / `_process()` 等虚方法时，若父类有实现则首行调用 `super()`
- `@onready` 变量在 `_enter_tree()` 期间为 null，仅在 `_ready()` 及之后可用

## 资源管理
- 编译时已知路径用 `preload("res://...")`；运行时动态路径用 `load(path)`
- 项目资源只读用 `res://`，用户数据（存档/配置）用 `user://`

## 场景设计

- **向下调用，向上通知** — 父节点直接调用子节点方法；子节点通过信号通知父节点。兄弟节点通过共同祖先或 EventBus 通信。
- **单一职责** — 一个场景只做一件事。如果需要用"和"来描述它，就该拆分。
- **@export 注入** — 禁止硬编码节点路径
- **组合优于继承** — 可复用行为拆成独立子场景（如 HealthComponent），通过 @export 组合，而非深 extends 链
- 每个场景应可独立运行（F6），不依赖启动关卡
- **不手写 `.tscn`** — 场景文件一律在 Godot 编辑器中创建和编辑

## Autoload 使用

仅用于：全局状态（`GameState`）、事件总线（`EventBus`）、工具函数（`Utils`）。
Autoload 禁止持有场景节点的直接引用——使用信号。

模板自带两个 autoload：
- **EventBus** — 全局信号总线；在此添加项目信号：`signal my_event`
- **GameState** — 全局状态，分辨率预设

## 性能

- 优先使用 `create_tween()` 而非 `Tween` 节点
- `_process()` 中用 `@onready` 缓存替代 `get_node()`
- 无需逐帧更新时调用 `set_process(false)` 禁用 `_process()`
- `_process()` 中字符串比较用 `&"run"`（StringName 字面量）而非 `"run"`（避免每帧 String 分配）
- 优先使用 `CharacterBody2D` + 物理系统而非手动碰撞
- 大量相同精灵用 `MultiMeshInstance2D`

## 工作流

- **一次一个功能** — 跑通再叠下一个，避免一次写太多导致调试困难
- 先跑通再优化
- 小步提交——场景能跑就提交
- 新交互 → 信号 + 外部响应模式
- 优先使用 `.tres` 而非 `.res`，便于版本控制

## 模板功能

- **窗口**：1280×720（设计分辨率），可调整大小，canvas_items stretch + expand
- **拉伸**：expand 模式表示可见区域随窗口增大——如需固定游戏区域用 Camera2D limits 约束。如需留黑边，在项目设置中切换为 `keep`。
- **InputMap** 预配置：move（WASD/方向键）、ui_accept（空格/回车）、ui_cancel（Esc）、interact（E）
- **DebugOverlay**：FPS 计数器，发布版本自动隐藏
- **主场景**：`scenes/main.tscn` — Node2D 根节点，可在此开始搭建

## Skill 索引

项目 `.trae/skills/` 提供 Godot 各领域开发参考，实现功能时 AI 自动加载对应 skill：

| 功能领域 | Skill |
|---------|-------|
| 2D 核心（TileMap/视差/光照） | 2d-essentials |
| 玩家移动/输入 | player-controller, input-handling |
| UI / HUD | godot-ui, hud-system |
| 动画/过渡 | animation-system, tween-animation |
| 物理/碰撞 | physics-system |
| AI / 导航 | ai-navigation |
| 状态机 | state-machine |
| 性能优化 | godot-optimization |
| 调试 | godot-debugging |
| 存档 | save-load |
| 测试 | godot-testing |
| 着色器 | shader-basics |
| 背包/道具 | inventory-system |
| 多人联机 | multiplayer-basics, multiplayer-sync |
| 本地化 | localization |
| 移动端 | mobile-development |
