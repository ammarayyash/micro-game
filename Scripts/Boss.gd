extends CharacterBody2D
class_name Boss

## Boss.gd
## Mengatur pergerakan Bos Raksasa (3x ukuran pemain):
## - 8 frame animasi jalan & pusing
## - Animasi Injak Raksasa (Stomp Slam) saat melayang ke bawah
## - Efek hentakan tanah / shockwave saat bos menginjak bumi
## - Tingkat kesulitan bertingkat: Level 2 bos lebih gesit, HP lebih tinggi, lebih agresif
## - Perlindungan arena & jurang agar bos tidak pernah jatuh ke bawah dunia atau keluar arena
## - Sekuens kekalahan: Pusing (1.3s) -> Jatuh terkapar -> Memudar hilang -> Pop-up profil muncul

signal boss_defeated(boss_data: Dictionary)
signal hp_updated(current_hp: int, max_hp: int)

enum State { PATROL, CHASE, DIZZY, DEFEATED }

@export var level_index: int = 1
@export var max_hp: int = 6

var hp: int = 6
var current_state: State = State.PATROL
var direction: float = -1.0
var boss_data: Dictionary = {}
var is_beaten: bool = false
var is_invulnerable: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

# Kecepatan & Kelincahan dinamis per level
var patrol_speed: float = 55.0
var chase_speed: float = 95.0
var jump_stomp_force: float = -390.0
var jump_cooldown: float = 2.0
var jump_timer: float = 0.0
var chase_detection_range: float = 280.0

# Batas arena bos
var arena_min_x: float = 3780.0
var arena_max_x: float = 4260.0

# 8 Frame Animasi Komposit & Pose Injak
var walk_frames: Array[Texture2D] = []
var dizzy_frames: Array[Texture2D] = []
var tex_idle: Texture2D
var tex_stomp: Texture2D

var anim_timer: float = 0.0
var was_in_air: bool = false
var last_fall_speed: float = 0.0

var ledge_ray: RayCast2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var head_area: Area2D = $HeadHurtbox
@onready var body_area: Area2D = $BodyDamageArea if has_node("BodyDamageArea") else null
@onready var wall_ray: RayCast2D = $WallRay if has_node("WallRay") else null
@onready var health_bar: HealthBar = $HealthBar if has_node("HealthBar") else null

var player_ref: Player = null

func _ready() -> void:
	add_to_group("Boss")
	add_to_group("Hittable")

	# RayCast deteksi ujung jurang agar bos tidak melangkah jatuh
	if not has_node("LedgeRay"):
		ledge_ray = RayCast2D.new()
		ledge_ray.name = "LedgeRay"
		ledge_ray.target_position = Vector2(0, 50)
		ledge_ray.position = Vector2(direction * 45.0, 35)
		ledge_ray.collision_mask = 1
		add_child(ledge_ray)
	else:
		ledge_ray = $LedgeRay

	# Konfigurasi Kesulitan Sesuai Level
	if level_index >= 2:
		# Level 2 Bos: Jauh lebih tangguh (8 HP), gesit (145 speed), dan agresif menginjak!
		max_hp = 8
		patrol_speed = 85.0
		chase_speed = 145.0
		jump_stomp_force = -460.0
		jump_cooldown = 1.25
		chase_detection_range = 360.0
		arena_min_x = 4490.0
		arena_max_x = 5220.0
	else:
		# Level 1 Bos (6 HP)
		max_hp = 6
		patrol_speed = 55.0
		chase_speed = 95.0
		jump_stomp_force = -390.0
		jump_cooldown = 2.0
		chase_detection_range = 280.0
		arena_min_x = 3780.0
		arena_max_x = 4260.0

	hp = max_hp
	boss_data = GameManager.get_boss_for_level(level_index)

	# Tentukan ID Bos & Prefix Spritesheet
	var boss_id: int = boss_data.get("id", 1 if level_index == 1 else 2)
	var prefix: String = "m" + str(boss_id + 1)
	var base_path: String = "res://Assets/Characters/Composite/"

	walk_frames.clear()
	dizzy_frames.clear()
	for i in range(8):
		walk_frames.append(load(base_path + "char_" + prefix + "_walk_" + str(i) + ".png"))
		dizzy_frames.append(load(base_path + "boss_" + prefix + "_dizzy_" + str(i) + ".png"))

	tex_idle = walk_frames[0]
	var stomp_path = base_path + "char_" + prefix + "_stomp.png"
	if ResourceLoader.exists(stomp_path):
		tex_stomp = load(stomp_path)
	else:
		tex_stomp = load(base_path + "char_" + prefix + "_attack.png")

	if sprite and tex_idle:
		sprite.texture = tex_idle
		sprite.flip_h = direction < 0

	if health_bar:
		var prefix_title = "BOS 1: " if level_index == 1 else "BOS 2 (AKHIR): "
		var b_name: String = prefix_title + str(boss_data.get("nama", "MONSTER"))
		health_bar.setup(max_hp, b_name)

func _physics_process(delta: float) -> void:
	if current_state == State.DEFEATED:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
		last_fall_speed = velocity.y
	else:
		# Deteksi mendarat dari lompatan injak tinggi
		if was_in_air and last_fall_speed > 120.0:
			_on_stomp_landed()
		was_in_air = false
		last_fall_speed = 0.0

	# Batas arena: Bos tidak pernah keluar arena dan tidak pernah jatuh ke jurang
	if global_position.x < arena_min_x:
		global_position.x = arena_min_x
		direction = 1.0
	elif global_position.x > arena_max_x:
		global_position.x = arena_max_x
		direction = -1.0

	# Batas aman vertikal: Jangan biarkan bos pernah tembus ke bawah lantai
	if global_position.y > 360.0:
		global_position.y = 265.0
		velocity.y = 0.0

	# Cari player jika belum ada referensinya
	if not player_ref:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_ref = players[0] as Player

	if current_state == State.PATROL:
		_process_patrol(delta)
	elif current_state == State.CHASE:
		_process_chase(delta)
	elif current_state == State.DIZZY:
		_process_dizzy(delta)

	move_and_slide()
	_update_animation(delta)

func _process_patrol(_delta: float) -> void:
	# Putar balik saat mendekati tepi jurang
	if is_on_floor() and ledge_ray:
		ledge_ray.position.x = direction * 45.0
		ledge_ray.force_raycast_update()
		if not ledge_ray.is_colliding():
			direction *= -1.0
			ledge_ray.position.x = direction * 45.0

	velocity.x = direction * patrol_speed

	if is_on_wall():
		direction *= -1.0

	# Jika player mendekat dalam jarak deteksi, beralih ke mode mengejar (CHASE)
	if player_ref and global_position.distance_to(player_ref.global_position) < chase_detection_range:
		current_state = State.CHASE

func _process_chase(delta: float) -> void:
	if not player_ref:
		current_state = State.PATROL
		return

	var dist_x: float = player_ref.global_position.x - global_position.x
	direction = sign(dist_x) if abs(dist_x) > 15.0 else 0.0

	# CEK JURANG SAAT MENGEJAR: Bos tidak akan bunuh diri melangkah ke dalam jurang!
	if is_on_floor() and ledge_ray:
		ledge_ray.position.x = direction * 45.0
		ledge_ray.force_raycast_update()
		if not ledge_ray.is_colliding():
			velocity.x = 0.0
		else:
			velocity.x = direction * chase_speed
	else:
		velocity.x = direction * chase_speed

	# Bos melompat tinggi untuk melakukan SERANGAN INJAK RAKSASA!
	jump_timer += delta
	if jump_timer >= jump_cooldown and is_on_floor():
		jump_timer = 0.0
		if abs(dist_x) < 220.0:
			velocity.y = jump_stomp_force

	# Jika player kabur terlalu jauh, kembali ke patrol
	if global_position.distance_to(player_ref.global_position) > (chase_detection_range + 100.0):
		current_state = State.PATROL

func _process_dizzy(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 150.0 * delta)

func _update_animation(delta: float) -> void:
	if not sprite:
		return

	anim_timer += delta * (12.0 if level_index >= 2 else 10.0)

	if current_state == State.DIZZY or current_state == State.DEFEATED:
		if dizzy_frames.size() == 8:
			var d_idx = int(anim_timer) % 8
			sprite.texture = dizzy_frames[d_idx]
		return

	if direction != 0.0:
		sprite.flip_h = direction < 0

	# Jika sedang jatuh / melayang ke bawah saat serangan injak -> Tampilkan animasi injak!
	if not is_on_floor() and velocity.y > 40.0 and tex_stomp:
		sprite.texture = tex_stomp
	elif abs(velocity.x) > 5.0 and is_on_floor():
		if walk_frames.size() == 8:
			var w_idx = int(anim_timer) % 8
			sprite.texture = walk_frames[w_idx]
	else:
		if tex_idle:
			sprite.texture = tex_idle

## Efek Hentakan Tanah Saat Bos Mendarat dari Serangan Injak
func _on_stomp_landed() -> void:
	if sprite:
		var cur_scale = sprite.scale
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(cur_scale.x * 1.15, cur_scale.y * 0.85), 0.08)
		tween.tween_property(sprite, "scale", cur_scale, 0.12)

	_spawn_ground_shockwave()

	if player_ref and player_ref.is_on_floor():
		var dist_to_p = abs(player_ref.global_position.x - global_position.x)
		if dist_to_p < 110.0 and abs(player_ref.global_position.y - global_position.y) < 60.0:
			var kb_dir = 1.0 if player_ref.global_position.x > global_position.x else -1.0
			player_ref.take_damage(1, Vector2(kb_dir * 200.0, -220.0))

## Visual Shockwave Hentakan Tanah
func _spawn_ground_shockwave() -> void:
	var shockwave = ColorRect.new()
	shockwave.color = Color(1.0, 0.85, 0.4, 0.8)
	shockwave.size = Vector2(16, 6)
	shockwave.position = Vector2(-8, 55)
	add_child(shockwave)

	var tween = create_tween()
	tween.tween_property(shockwave, "scale", Vector2(7.0, 1.5), 0.25)
	tween.parallel().tween_property(shockwave, "position:x", -56.0, 0.25)
	tween.parallel().tween_property(shockwave, "modulate:a", 0.0, 0.25)
	tween.tween_callback(shockwave.queue_free)

## Menerima luka serangan dari Player (pedang, gelombang pedang, atau injakan)
func take_damage(amount: int) -> void:
	if is_beaten or is_invulnerable:
		return

	hp -= amount
	is_invulnerable = true

	if health_bar:
		health_bar.update_hp(hp)
	hp_updated.emit(hp, max_hp)

	# Efek kedip merah saat terkena serangan
	if sprite:
		sprite.modulate = Color(1.0, 0.2, 0.2, 1.0)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.22)

	_spawn_hit_sparks()

	velocity.x = -direction * 70.0
	velocity.y = -50.0

	if hp <= 0:
		_defeat_boss()
	else:
		get_tree().create_timer(0.35).timeout.connect(func():
			is_invulnerable = false
		)

## Deteksi injakan kepala oleh Player (Pemain melompat tinggi dan menginjak kepala bos)
func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	if is_beaten:
		return

	if body is Player:
		var player := body as Player
		if player.velocity.y >= -50.0:
			player.bounce(-320.0)
			take_damage(1)

## Deteksi saat tubuh Bos Raksasa mengenai Player
func _on_body_damage_area_body_entered(body: Node2D) -> void:
	if is_beaten:
		return

	if body is Player:
		var player := body as Player
		var stomp_kb = Vector2(direction * 180.0, -220.0)
		player.take_damage(1, stomp_kb)

## Sekuens Kekalahan Bos: Pusing -> Jatuh -> Hilang -> Pop-up Profil
func _defeat_boss() -> void:
	if is_beaten:
		return
	is_beaten = true
	current_state = State.DIZZY
	velocity = Vector2.ZERO

	if health_bar:
		health_bar.update_hp(0)

	if head_area:
		head_area.set_deferred("monitoring", false)
		head_area.set_deferred("monitorable", false)
	if body_area:
		body_area.set_deferred("monitoring", false)
		body_area.set_deferred("monitorable", false)

	_spawn_dizzy_stars()

	# Tahap 1: Bos pusing selama 1.3 detik
	await get_tree().create_timer(1.3).timeout

	# Tahap 2: Bos jatuh miring terkapar ke lantai (Jatuh)
	current_state = State.DEFEATED
	var fall_side = -direction if direction != 0 else 1.0
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", fall_side * 90.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(sprite, "position:y", 35.0, 0.45)

	# Tahap 3: Bos memudar dan hilang (Hilang)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.45)
	await tween.finished

	# Tahap 4: Tampilkan pop-up profil kemenangan & buka pintu, lalu hapus bos
	boss_defeated.emit(boss_data)
	queue_free()

func _spawn_hit_sparks() -> void:
	var spark = Label.new()
	spark.text = "*"
	spark.position = Vector2(randf_range(-20, 20), randf_range(-40, 10))
	add_child(spark)
	var tween = create_tween()
	tween.tween_property(spark, "position:y", spark.position.y - 30.0, 0.35)
	tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.35)
	tween.tween_callback(spark.queue_free)

func _spawn_dizzy_stars() -> void:
	for i in range(3):
		var star = Label.new()
		star.text = "*"
		star.position = Vector2(-25 + i * 20, -75)
		add_child(star)
		var tween = create_tween().set_loops(4)
		tween.tween_property(star, "position:x", star.position.x + 10.0, 0.15)
		tween.tween_property(star, "position:x", star.position.x - 10.0, 0.15)
