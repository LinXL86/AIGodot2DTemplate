# CLAUDE.md — Godot 4.6 3D 模板

## 项目结构

```
res://
├── scenes/          # .tscn 场景文件
│   ├── actors/      # 玩家、敌人、NPC
│   ├── ui/          # UI 场景
│   ├── levels/      # 关卡/地图
│   ├── props/       # 道具、可交互物
│   └── environment/ # 环境场景（光照探头、反射探头、天空）
├── scripts/         # 共享 GDScript (.gd)
│   ├── autoload/    # 全局单例（EventBus, GameState）
│   ├── components/  # 可复用组件（@export 注入）
│   └── utilities/   # 纯工具
├── assets/          # 美术资源
│   ├── models/      # .glb/.obj 模型文件
│   ├── textures/    # 贴图（漫反射、法线、ORM）
│   ├── materials/   # .tres 材质资源
│   ├── sprites/  sounds/  fonts/  shaders/
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
| 节点名 | PascalCase | `HealthBar` `CollisionShape3D` |
| 信号回调 | `_on_<node>_<signal>` | `func _on_button_pressed()` |

- 禁止保留默认名称如 `Node3D`、`MeshInstance3D`、`ColorRect`
- 同类节点用数字后缀：`EnemySpawnPoint1`、`EnemySpawnPoint2`

### 3D 专有规范

- **材质优先用 .tres** — 避免 SubResource 嵌入 .tscn，便于版本控制和复用
- **PBR 工作流**：Base Color + Roughness + Metallic + Normal + AO 贴图按标准金属/粗糙度流程
- **模型单位**：1 单位 = 1 米，导出 .glb 前确认 Blender/Maya 中比例正确
- **光照单位**：DirectionalLight3D 用 `light_energy` 1.0~2.0、OmniLight3D 用实际流明值

## GDScript 规则

### 始终使用类型注解
```gdscript
var speed: float = 200.0
func deal_damage(target: Node3D, amount: int) -> bool:
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
func process_target(target: Node3D) -> void:
    if not is_instance_valid(target):
        return
    if not target.is_alive:
        return
    _apply_damage(target)
```

### 依赖通过 @export 注入，禁止硬编码路径
```gdscript
@export var hitbox: Area3D              # 正确
var hitbox: Area3D = $"../../../Hitbox" # 错误
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

## 场景设计

- **向下调用，向上通知** — 父节点直接调用子节点方法；子节点通过信号通知父节点。兄弟节点通过共同祖先或 EventBus 通信。
- **单一职责** — 一个场景只做一件事。如果需要用"和"来描述它，就该拆分。
- **@export 注入** — 禁止硬编码节点路径
- 每个场景应可独立运行（F6），不依赖启动关卡
- **不手写 `.tscn`** — 场景文件一律在 Godot 编辑器中创建。仅允许编辑已有 `.tscn` 来添加脚本引用、碰撞层/掩码、分组、信号连接，**禁止**修改或编造 UID（`uid://...`），必须保留编辑器生成的原始 UID

### 3D 场景最低配置

每个 3D 场景必须包含以下节点才能正常渲染：
- **WorldEnvironment** — 提供天空、环境光、色调映射、雾效
- **Camera3D** — 当前激活的摄像机（`current = true`）
- **至少一盏 DirectionalLight3D** — 提供主光照和阴影

缺少 WorldEnvironment 时场景将显示为纯黑色（仅有默认清理色）。

## Autoload 使用

仅用于：全局状态（`GameState`）、事件总线（`EventBus`）、工具函数（`Utils`）。
Autoload 禁止持有场景节点的直接引用——使用信号。

模板自带两个 autoload：
- **EventBus** — 全局信号总线；在此添加项目信号：`signal my_event`
- **GameState** — 全局状态，分辨率预设

## 性能

- 优先使用 `create_tween()` 而非 `Tween` 节点
- `_process()` 中用 `@onready` 缓存替代 `get_node()`
- 优先使用 `CharacterBody3D` + 物理系统而非手动碰撞
- 大量相同模型用 `MultiMeshInstance3D`
- 光源数量控制在 4~8 盏以内，静态场景用 LightmapGI 烘焙
- 阴影仅在必要光源上开启，非关键光源设 `shadow_enabled = false`
- 远处模型使用 LOD（`GeometryInstance3D.visibility_range_*`）降低顶点数

## 工作流

- **一次一个功能** — 跑通再叠下一个，避免一次写太多导致调试困难
- 先跑通再优化
- 小步提交——场景能跑就提交
- 新交互 → 信号 + 外部响应模式
- 优先使用 `.tres` 而非 `.res`，便于版本控制

## 模板功能

- **窗口**：1280×720，可调整大小，3D 以原生分辨率渲染（无 2D 拉伸）
- **摄像机**：自由飞行调试模式——右击捕获鼠标 + WASD 移动 + 鼠标环顾 + 滚轮调速
- **环境**：ProceduralSky（程序化天空）+ ACES 色调映射
- **光照**：DirectionalLight3D 带阴影（PSSM）
- **地面**：20×20 灰色平面 + StaticBody3D 碰撞，提供空间参照
- **InputMap** 预配置：move（WASD/方向键）、look（手柄右摇杆）、ui_accept（空格/回车）、ui_cancel（Esc）、interact（E）
- **DebugOverlay**：FPS 计数器，发布版本自动隐藏
- **主场景**：`scenes/main.tscn` — Node3D 根节点，可在此开始搭建

## 协作模式

**场景归用户，脚本归 Claude。** Claude 不创建或覆盖 `.tscn` 文件。

| 任务 | 谁做 | 方式 |
|------|------|------|
| 创建场景（节点层级、碰撞形状） | 用户 | Godot 编辑器 |
| 修改场景属性（脚本引用、碰撞层、分组、信号连接） | 用户按说明操作 | Claude 口述步骤 |
| 编写 `.gd` 脚本 | Claude | 直接写文件 |
| 调整 Config 数值 | 用户 | 编辑器打开 `.tres` |
| 调试 | 用户跑 → 贴日志 → Claude 定位 | 加 print 定位 |

### `.tscn` 编辑铁律

- **不创建**新的 `.tscn` 文件
- **不覆盖**已有的 `.tscn` 内容
- 仅追加：脚本引用、碰撞层/掩码、分组、信号连接
- **绝不动 UID**（`uid://...`），必须保留编辑器生成的原始值
- 若必须修改节点属性，先口述让用户确认，再最小化编辑

### 碰撞层速查

`.tscn` 中 `collision_layer` / `collision_mask` 是**位域值**，不是层号：

| 层号 | 位域值 | 计算 |
|------|--------|------|
| Layer 1 | 1 | 2^0 |
| Layer 2 | 2 | 2^1 |
| Layer 3 | 4 | 2^2 |
| Layer 4 | 8 | 2^3 |
| Layer 5 | 16 | 2^4 |

代码中 `set_collision_layer_value(N, true)` 的参数 N 是**层号**（1-32），不是位域值。不要混淆。

### 资源引用

- 优先 `@export var` 在编辑器中指认，而非 `preload("res://...")` 硬编码路径
- `preload` 仅用于 shader、PackedScene 等编译期确定不变的资源
- 贴图、模型、材质等美术资源用 `@export`，方便替换且避免导出时依赖断裂

### 数据配置规范

- **代码中禁止硬编码数值**。所有可调参数（速度、血量、冷却、重力等）必须写入配置 Resource，通过 `.tres` 文件配置
- **新增功能前先确认**：涉及数值时，先列出需要配置的参数并说明含义，得到用户确认后再写入配置
- **配置注释**：配置 Resource 脚本中每个 `@export` 变量必须带有注释说明其作用和单位
- **数值来源单一**：同一个参数只存在于配置中，不分散在脚本的默认值里

### 路径大小写

- 所有文件路径统一使用 **小写 snake_case**
- Windows 编辑器不区分大小写但导出 PCK 区分，路径大小写不匹配会导致 exe 闪退
