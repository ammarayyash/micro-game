extends CharacterBody2D
class_name Player

## Player.gd
## Kontrol pergerakan pahlawan: lari, lompatan tinggi, 8 frame animasi gerak,
## tebasan pedang melee (2 Damage) & tembakan gelombang pedang berelemen (1 Damage),
## HP & invulnerability, dan respawn checkpoint.

signal hp_changed(current_hp: int, max_hp: int)
signal player_died

const SPEED: float = 165.0
const JUMP_VELOCITY: float = -420.0
const BOUNCE_VELOCITY: float = -280.0
const FALL_LIMIT_Y: float = 500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

# Sistem Kesehatan & Respawn
var max_hp: int = 3
var hp: int = 3
var is_invulnerable: bool = false
var spawn_point: Vector2 = Vector2.ZERO

# Status Arah & Serangan
var facing_direction: float = 1.0
var is_attacking_anim: bool = false
var attack_anim_timer: float = 0.0

# Sistem Tembakan Gelombang Pedang (Sword Beam)
var arrow_scene: PackedScene = preload("res://Scenes/Prefabs/Arrow.tscn")
var shoot_timer: float = 0.0
const SHOOT_COOLDOWN: float = 0.35

# 8 Frame Animasi Gerak
var walk_frames: Array[Texture2D] = []
var jump_frames: Array[Texture2D] = []
var tex_idle: Texture2D
var tex_attack: Texture2D

var anim_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon: Weapon = $Weapon if has_node("Weapon") else null
@onready var sfx_jump: AudioStreamPlayer2D = $SFXJump if has_node("SFXJump") else null
@onready var sfx_stomp: AudioStreamPlayer2D = $SFXStomp if has_node("SFXStomp") else null

func _ready() -> void:
	add_to_group("Player")
	spawn_point = global_position
	
	# Muat 8 frame animasi sesuai hero yang dipilih (Member 1, Member 2, atau Member 3)
	var hero_id: int = GameManager.selected_hero.get("id", 0)
	var prefix: String = "m1"
	if hero_id == 1:
		prefix = "m2"
	elif hero_id == 2:
		prefix = "m3"
	var base_path: String = "res://Assets/Characters/Composite/"
	
	walk_frames.clear()
	jump_frames.clear()
	for i in range(8):
		walk_frames.append(load(base_path + "char_" + prefix + "_walk_" + str(i) + ".png"))
		jump_frames.append(load(base_path + "char_" + prefix + "_jump_" + str(i) + ".png"))
		
	tex_idle = walk_frames[0]
	tex_attack = load(base_path + "char_" + prefix + "_attack.png")
	
	if sprite and tex_idle:
		sprite.texture = tex_idle

func _physics_process(delta: float) -> void:
	# 1. Terapkan Gravitasi jika di udara
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Deteksi Jatuh ke Jurang -> Respawn ke CheckPoint
	if global_position.y > FALL_LIMIT_Y:
		respawn()
		return

	# 3. Logika Lompat Tinggi
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		GameManager.play_sfx("res://Audio/pluck_001.ogg", -2.0, randf_range(0.95, 1.05))

	# 4. Serangan Senjata Pedang (Tombol Z / J / Klik Kiri)
	if Input.is_action_just_pressed("attack") and weapon:
		if weapon.attack(facing_direction):
			_play_attack_anim()

	# 5. Serangan Panah (Tombol X / K / Klik Kanan)
	if shoot_timer > 0.0:
		shoot_timer -= delta
	elif Input.is_action_just_pressed("shoot_arrow"):
		_shoot_arrow()

	# 6. Timer animasi serangan
	if is_attacking_anim:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0.0:
			is_attacking_anim = false

	# 7. Input Gerakan Horizontal
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		facing_direction = direction
		if sprite:
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 8.0 * delta)

	move_and_slide()
	_update_animation(delta, direction)

## Mengatur pergantian 8 frame animasi jalan & lompat
func _update_animation(delta: float, direction: float) -> void:
	if not sprite:
		return

	if is_attacking_anim:
		if tex_attack:
			sprite.texture = tex_attack
		return

	# Animasi Lompat (8 frames mengikuti ketinggian vertikal)
	if not is_on_floor():
		if jump_frames.size() == 8:
			var jump_progress = clampf(1.0 - (velocity.y / JUMP_VELOCITY), 0.0, 0.99)
			var j_idx = int(jump_progress * 8.0)
			sprite.texture = jump_frames[j_idx]
	# Animasi Berjalan (8 frames bergantian halus)
	elif direction != 0:
		anim_timer += delta * 12.0
		var w_idx = int(anim_timer) % 8
		if walk_frames.size() == 8:
			sprite.texture = walk_frames[w_idx]
	else:
		anim_timer = 0.0
		if tex_idle:
			sprite.texture = tex_idle

func _play_attack_anim() -> void:
	is_attacking_anim = true
	attack_anim_timer = 0.18
	if sprite and tex_attack:
		sprite.texture = tex_attack

## Menembakkan gelombang tebasan pedang berelemen jarak jauh (Sword Beam)
func _shoot_arrow() -> void:
	shoot_timer = SHOOT_COOLDOWN
	_play_attack_anim()
	
	if arrow_scene:
		var beam = arrow_scene.instantiate()
		var spawn_pos = global_position + Vector2(facing_direction * 22.0, -2.0)
		get_parent().add_child(beam)
		beam.setup(facing_direction, spawn_pos)
		
	GameManager.play_sfx("res://Audio/drawKnife1.ogg", -2.0, randf_range(0.95, 1.05))

## Menerima luka dari musuh/bos
func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable:
		return

	hp -= amount
	hp_changed.emit(hp, max_hp)
	is_invulnerable = true
	GameManager.play_sfx("res://Audio/error_001.ogg", 1.0)

	if knockback != Vector2.ZERO:
		velocity = knockback
	else:
		velocity = Vector2(-facing_direction * 120.0, -180.0)

	# Efek kedip saat terkena luka
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	get_tree().create_timer(0.8).timeout.connect(func():
		is_invulnerable = false
	)

	if hp <= 0:
		player_died.emit()
		GameManager.play_sfx("res://Audio/drop_001.ogg", 1.0)
		respawn()

## Menyimpan titik respawn dari checkpoint yang disentuh
func set_checkpoint(pos: Vector2) -> void:
	spawn_point = pos

## Mengembalikan pemain ke titik checkpoint terakhir
func respawn() -> void:
	velocity = Vector2.ZERO
	global_position = spawn_point
	hp = max_hp
	hp_changed.emit(hp, max_hp)
	if sprite:
		sprite.modulate.a = 1.0
	is_invulnerable = false

## Dipanggil saat menginjak kepala musuh/bos
func bounce(force: float = BOUNCE_VELOCITY) -> void:
	velocity.y = force
	GameManager.play_sfx("res://Audio/bong_001.ogg", 1.0)
