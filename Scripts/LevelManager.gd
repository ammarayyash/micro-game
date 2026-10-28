extends Node2D

## LevelManager.gd
## Mengatur seluruh alur interaksi level:
## - Penghitung musuh rintangan & pembukaan gerbang arena bos secara otomatis
## - Penyimpanan koordinat checkpoint
## - Pembaruan HUD HP Player & sisa musuh
## - Penanganan kekalahan bos & pembukaan pintu exit

@export var level_index: int = 1

var total_enemies: int = 0
var remaining_enemies: int = 0
var gate_opened: bool = false

@onready var player: Player = $Player if has_node("Player") else null
@onready var boss: Boss = $Boss if has_node("Boss") else null
@onready var popup: ProfilePopup = $ProfilePopup if has_node("ProfilePopup") else null
@onready var goal_door: GoalDoor = $GoalDoor if has_node("GoalDoor") else null
@onready var checkpoint: CheckPoint = $CheckPoint if has_node("CheckPoint") else null
@onready var arena_gate: StaticBody2D = $WorldGeometry/ArenaGate if has_node("WorldGeometry/ArenaGate") else null
@onready var label_hp: Label = get_node_or_null("CanvasLayerHUD/LabelHP")
@onready var label_enemies: Label = get_node_or_null("CanvasLayerHUD/HUDPanel/MarginContainer/VBox/LabelEnemies") if has_node("CanvasLayerHUD/HUDPanel/MarginContainer/VBox/LabelEnemies") else get_node_or_null("CanvasLayerHUD/LabelEnemies")
@onready var hearts_container: HBoxContainer = get_node_or_null("CanvasLayerHUD/HUDPanel/MarginContainer/VBox/HBoxHP/Hearts")

var tex_heart_full: Texture2D = preload("res://Assets/UI/ui_heart_full.png")
var tex_heart_empty: Texture2D = preload("res://Assets/UI/ui_heart_empty.png")

func _ready() -> void:
	# 1. Hubungkan Player ke HUD & Checkpoint
	if player:
		player.hp_changed.connect(_on_player_hp_changed)
		_update_hp_display(player.hp, player.max_hp)

	if checkpoint and player:
		checkpoint.checkpoint_activated.connect(func(pos: Vector2):
			player.set_checkpoint(pos)
		)

	# 2. Inisialisasi musuh via call_deferred
	call_deferred("_setup_enemies")

	# 3. Hubungkan Bos & Pop-up
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
	if popup:
		popup.popup_closed.connect(_on_popup_closed)

func _physics_process(_delta: float) -> void:
	# Buka gerbang otomatis jika pemain sudah tiba di dekat gerbang ATAU seluruh musuh kalah
	if not gate_opened and arena_gate and player:
		var dist_to_gate = player.global_position.distance_to(arena_gate.global_position)
		if remaining_enemies <= 0 or dist_to_gate < 150.0:
			_open_arena_gate()

func _setup_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	total_enemies = enemies.size()
	remaining_enemies = total_enemies
	_update_hud_enemies()

	for enemy in enemies:
		if enemy.has_signal("enemy_defeated"):
			enemy.enemy_defeated.connect(_on_enemy_defeated)
		enemy.tree_exited.connect(func():
			if not gate_opened:
				remaining_enemies = get_tree().get_nodes_in_group("Enemy").size()
				_update_hud_enemies()
				if remaining_enemies <= 0:
					_open_arena_gate()
		)

func _on_enemy_defeated(_enemy_node: Node2D) -> void:
	remaining_enemies = max(0, remaining_enemies - 1)
	_update_hud_enemies()
	if remaining_enemies <= 0:
		_open_arena_gate()

func _update_hud_enemies() -> void:
	if label_enemies:
		if remaining_enemies > 0:
			label_enemies.text = "Musuh Tersisa: " + str(remaining_enemies) + " / " + str(total_enemies)
			label_enemies.modulate = Color(1.0, 0.9, 0.4, 1.0)
		else:
			label_enemies.text = "OK Semua Musuh Kalah! Gerbang Bos Terbuka!"
			label_enemies.modulate = Color(0.4, 1.0, 0.4, 1.0)

func _open_arena_gate() -> void:
	if gate_opened:
		return
	gate_opened = true
	GameManager.play_sfx("res://Audio/doorOpen_1.ogg", 3.0)

	if arena_gate:
		var col = arena_gate.get_node_or_null("CollisionShape2D")
		var vis = arena_gate.get_node_or_null("GateVisual")
		var lbl = arena_gate.get_node_or_null("LabelGate")

		if lbl is Label:
			lbl.text = "OK GERBANG TERBUKA!"
			lbl.modulate = Color(0.3, 1.0, 0.3, 1.0)

		# Matikan tabrakan gerbang seketika agar pemain bisa lewat
		if col is CollisionShape2D:
			col.set_deferred("disabled", true)

		# Animasi gerbang terangkat ke atas & memudar
		if vis:
			var tween = create_tween()
			tween.tween_property(vis, "position:y", vis.position.y - 150.0, 0.7)
			tween.parallel().tween_property(vis, "modulate:a", 0.0, 0.7)

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	_update_hp_display(current_hp, max_hp)

func _update_hp_display(current_hp: int, max_hp: int) -> void:
	if label_hp:
		var hearts: String = ""
		for i in range(max_hp):
			hearts += "❤ " if i < current_hp else "🖤 "
		label_hp.text = "HP: " + hearts.strip_edges()

	if hearts_container:
		var heart_nodes = hearts_container.get_children()
		for i in range(heart_nodes.size()):
			if heart_nodes[i] is TextureRect:
				var h_rect := heart_nodes[i] as TextureRect
				if h_rect:
					h_rect.texture = tex_heart_full if i < current_hp else tex_heart_empty

func _on_boss_defeated(data: Dictionary) -> void:
	var title = "BOS 1 DIKALAHKAN!" if level_index == 1 else "BOS TERAKHIR DIKALAHKAN!"
	if popup:
		popup.show_profile(data, title)

func _on_popup_closed() -> void:
	if goal_door:
		goal_door.unlock()
