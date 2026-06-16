# CLAUDE.md — Don't Touch Button (Godot 4.6 + Jolt Physics 3D)

## Project Structure

```
res://
├── scenes/          # .tscn 场景文件
│   ├── actors/      # 玩家、敌人、NPC
│   ├── ui/          # UI 场景
│   ├── levels/      # 关卡/地图
│   └── props/       # 道具、可交互物
├── scripts/         # 共享 GDScript (.gd)
│   ├── autoload/    # 全局单例
│   ├── components/  # 可复用组件
│   └── utilities/   # 纯工具
├── assets/          # 美术资源
│   ├── sprites/  sounds/  fonts/  shaders/
└── docs/            # 文档
```

- 场景根节点脚本跟 `.tscn` 放在一起，只有被多个场景共享的脚本才放 `scripts/`

## Naming

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件/脚本 | snake_case | `player_controller.gd` |
| 类名 | PascalCase | `class_name PlayerController` |
| 函数/变量/信号 | snake_case | `func take_damage()` `var max_health` |
| 常量/枚举值 | UPPER_SNAKE | `const MAX_SPEED = 400.0` |
| 私有成员/方法 | `_` 前缀 | `var _current_health` `func _apply_knockback()` |
| 节点名 | PascalCase | `HealthBar` `CollisionShape3D` |
| 信号回调 | `_on_<node>_<signal>` | `func _on_button_pressed()` |

## GDScript Rules

### Always use type hints
```gdscript
var speed: float = 200.0
func deal_damage(target: Node3D, amount: int) -> bool:
```
Exception: temp variables in `_ready()`.

### Code order within a file
1. `class_name` / `extends`
2. signals → enums → constants → `@export` vars → public vars → private vars → `@onready` vars
3. `_ready()` → `_process()` → `_physics_process()`
4. signal callbacks
5. public methods → private methods

### Early return over deep nesting
```gdscript
func process_target(target: Node) -> void:
    if not is_instance_valid(target):
        return
    if not target.is_alive:
        return
    _apply_damage(target)
```

### Dependencies via @export, not hardcoded paths
```gdscript
@export var hurtbox: Area3D          # good
var hurtbox: Area3D = $"../../../Hurtbox"  # bad
```

### Use `tr()` for user-facing strings
```gdscript
label.text = tr("Press Start")
```

### Comments
- Don't comment WHAT the code does — code should be self-explanatory
- Only comment WHY when it's non-obvious (workarounds, design decisions)

## Scene Design

- **Downward calls, upward signals** — parent calls child methods directly; child notifies parent via signals
- **Single responsibility** — one scene = one job. Split if you need "and" to describe it
- **@export injection** — never hardcode node paths
- Each scene should be runnable standalone (F6) without depending on a launcher level

## Autoload Usage

Only for: global state (`GameState`), event bus (`EventBus`), utility functions (`Utils`).
Autoloads must NOT hold direct references to scene nodes — use signals.

## Performance

- `create_tween()` over `Tween` nodes
- `@onready` cache over `get_node()` in `_process()`
- `CharacterBody3D` + physics over manual collision
- `MultiMeshInstance3D` for bulk identical objects

## Workflow

- Get it running first, optimize later
- Small commits — commit whenever the scene runs
- New interactions → signal + external response pattern
- Prefer `.tres` over `.res` for version control friendliness
