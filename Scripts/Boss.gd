extends CharacterBody2D
class_name Boss

## Boss.gd
## Mengatur kecerdasan buatan (AI) Bos Raksasa:
## - Bebas menjelajah seluruh trek tanpa batas (bisa mengejar pemain ke mana saja)
## - Deteksi cerdas tepi jurang: melompat melompati jurang (parkour leap) atau menghindar agar tidak jatuh
## - Serangan Injak Raksasa (Stomp Slam) dari udara dengan gelombang kejut (Level 1 & 2)
## - Serangan Tebasan Pedang Raksasa (Giant Sword Slash) jarak dekat (KHUSUS Bos Level 2)
## - Tingkat kesulitan bertingkat & animasi lengkap (8 frame jalan, lompat, injak, tebas, dan pusing)
## - Sekuens kekalahan: Pusing (1.3s) -> Jatuh terkapar -> Memudar hilang -> Pop-up profil identitas

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

# Sistem Tebasan Pedang (KHUSUS Bos Level 2)
var can_use_sword: bool = false
var sword_cooldown: float = 1.8
var sword_timer: float = 0.5
var is_slashing: bool = false
var slash_anim_timer: float = 0.0
var tex_attack: Texture2D = null
var tex_slash_fx: Texture2D = null

# 8 Frame Animasi Komposit & Pose Injak
var walk_frames: Array[Texture2D] = []
var dizzy_frames: Array[Texture2D] = []
var tex_idle: Texture2D = null
var tex_stomp: Texture2D = null

var anim_timer: float = 0.0
var was_in_air: bool = false
var last_fall_speed: float = 0.0

# RayCasts pintar untuk navigasi jurang
var ledge_ray: RayCast2D
var chasm_leap_ray: RayCast2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var head_area: Area2D = $HeadHurtbox
@onready var body_area: Area2D = $BodyDamageArea if has_node("BodyDamageArea") else null
@onready var wall_ray: RayCast2D = $WallRay if has_node("WallRay") else null
@onready var health_bar: HealthBar = $HealthBar if has_node("HealthBar") else null

var player_ref: Node2D = null

func _ready() -> void:
	add_to_group("Boss")
	add_to_group("Hittable")

	# 1. RayCast deteksi tepi jurang tepat di depan kaki
	if not has_node("LedgeRay"):
		ledge_ray = RayCast2D.new()
		ledge_ray.name = "LedgeRay"
		ledge_ray.target_position = Vector2(0, 50)
		ledge_ray.position = Vector2(direction * 45.0, 35)
		ledge_ray.collision_mask = 1
		add_child(ledge_ray)
	else:
		ledge_ray = $LedgeRay

	# 2. RayCast deteksi daratan di seberang jurang (untuk melompat menyeberang)
	if not has_node("ChasmLeapRay"):
		chasm_leap_ray = RayCast2D.new()
		chasm_leap_ray.name = "ChasmLeapRay"
		chasm_leap_ray.target_position = Vector2(0, 90)
		chasm_leap_ray.position = Vector2(direction * 150.0, 35)
		chasm_leap_ray.collision_mask = 1
		add_child(chasm_leap_ray)
	else:
		chasm_leap_ray = $ChasmLeapRay

	# 3. Konfigurasi Kesulitan Sesuai Level
	if level_index >= 2:
		# Level 2 Bos: Jauh lebih tangguh, gesit, agresif menginjak, dan BISA MENEBAS DENGAN PEDANG!
		max_hp = 8
		patrol_speed = 85.0
		chase_speed = 145.0
		jump_stomp_force = -460.0
		jump_cooldown = 1.3
		chase_detection_range = 420.0
		can_use_sword = true
	else:
		# Level 1 Bos
		max_hp = 6
		patrol_speed = 55.0
		chase_speed = 95.0
		jump_stomp_force = -390.0
		jump_cooldown = 2.0
		chase_detection_range = 280.0
		can_use_sword = false

	hp = max_hp
	boss_data = GameManager.get_boss_for_level(level_index)

	# 4. Tentukan ID Bos & Muat Spritesheet
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

	var attack_path = base_path + "char_" + prefix + "_attack.png"
	if ResourceLoader.exists(attack_path):
		tex_attack = load(attack_path)

	var slash_path = base_path + "slash_fx.png"
	if ResourceLoader.exists(slash_path):
		tex_slash_fx = load(slash_path)

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
		# Deteksi mendarat dari lompatan tinggi
		if was_in_air and last_fall_speed > 120.0:
			_on_stomp_landed()
		was_in_air = false
		last_fall_speed = 0.0

	# Batas aman vertikal mutlak: Jangan biarkan bos pernah jatuh ke jurang/lahar bawah dunia
	if global_position.y > 355.0:
		global_position.y = 265.0
		velocity.y = -220.0

	# Timer tebasan pedang
	if is_slashing:
		slash_anim_timer -= delta
		if slash_anim_timer <= 0.0:
			is_slashing = false

	# Cari player jika belum ada referensinya
	if not player_ref:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_ref = players[0]

	if current_state == State.PATROL:
		_process_patrol(delta)
	elif current_state == State.CHASE:
		_process_chase(delta)
	elif current_state == State.DIZZY:
		_process_dizzy(delta)

	move_and_slide()
	_update_animation(delta)

## Navigasi Patroli Pintar: Melompat jika ada pijakan seberang, atau berbalik jika jurang buntu
func _process_patrol(delta: float) -> void:
	jump_timer += delta

	_update_ray_positions()

	if is_on_floor() and ledge_ray:
		ledge_ray.force_raycast_update()
		if not ledge_ray.is_colliding():
			# Ada jurang di depan! Periksa apakah ada daratan di seberang
			chasm_leap_ray.force_raycast_update()
			if chasm_leap_ray.is_colliding() and jump_timer >= jump_cooldown:
				# Melompat menyeberangi jurang ke platform berikutnya!
				jump_timer = 0.0
				velocity.y = jump_stomp_force * 0.95
				velocity.x = direction * patrol_speed * 1.3
			else:
				# Jurang terlalu lebar / tidak ada daratan -> putar balik agar tidak jatuh!
				direction *= -1.0
				_update_ray_positions()

	velocity.x = direction * patrol_speed

	if is_on_wall():
		direction *= -1.0
		_update_ray_positions()

	# Jika player mendekat dalam jarak deteksi, beralih ke mode mengejar (CHASE)
	if player_ref and global_position.distance_to(player_ref.global_position) < chase_detection_range:
		current_state = State.CHASE

## Navigasi Pengejaran Pintar & Serangan Taktis
func _process_chase(delta: float) -> void:
	if not player_ref:
		current_state = State.PATROL
		return

	jump_timer += delta
	sword_timer += delta

	var dist_x: float = player_ref.global_position.x - global_position.x
	var dist_total: float = global_position.distance_to(player_ref.global_position)
	var desired_dir: float = sign(dist_x) if abs(dist_x) > 15.0 else direction

	if desired_dir != 0.0:
		direction = desired_dir

	_update_ray_positions()

	# Logika Pintar Menghadapi Jurang saat Mengejar
	var is_chasm_ahead: bool = false
	if is_on_floor() and ledge_ray:
		ledge_ray.force_raycast_update()
		if not ledge_ray.is_colliding():
			is_chasm_ahead = true

	if is_chasm_ahead and is_on_floor():
		chasm_leap_ray.force_raycast_update()
		if chasm_leap_ray.is_colliding() and jump_timer >= 0.8:
			# Melompat melintasi jurang mengejar pemain!
			jump_timer = 0.0
			velocity.y = jump_stomp_force * 0.98
			velocity.x = direction * (chase_speed * 1.25)
		else:
			# Jurang terlalu dalam/lebar -> Berhenti persis di bibir jurang, jangan sampai jatuh!
			velocity.x = 0.0
	else:
		if not is_slashing:
			velocity.x = direction * chase_speed

	# 1. SERANGAN TEBASAN PEDANG RAKSASA (KHUSUS BOS LEVEL 2)
	if can_use_sword and not is_slashing:
		if dist_total < 110.0 and abs(player_ref.global_position.y - global_position.y) < 55.0:
			if sword_timer >= sword_cooldown and is_on_floor():
				sword_timer = 0.0
				_perform_sword_slash()

	# 2. SERANGAN INJAK RAKSASA (Lompat tinggi dan menghantam dari atas)
	if jump_timer >= jump_cooldown and is_on_floor() and not is_slashing:
		if abs(dist_x) > 100.0 and abs(dist_x) < 230.0:
			jump_timer = 0.0
			velocity.y = jump_stomp_force

	# Jika pemain kabur sangat jauh, kembali ke patroli santai
	if dist_total > (chase_detection_range + 180.0):
		current_state = State.PATROL

func _process_dizzy(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 150.0 * delta)

func _update_ray_positions() -> void:
	if ledge_ray:
		ledge_ray.position.x = direction * 45.0
	if chasm_leap_ray:
		chasm_leap_ray.position.x = direction * 150.0

## SERANGAN KHUSUS BOS LEVEL 2: TEBASAN PEDANG RAKSASA
func _perform_sword_slash() -> void:
	is_slashing = true
	slash_anim_timer = 0.4

	# Bos sedikit menerjang maju saat menebas
	velocity.x = direction * 80.0

	# Munculkan Efek Visual Tebasan Pedang (Slash FX) Raksasa
	_spawn_giant_slash_fx()

	# Cek apakah pemain terkena tebasan pedang
	if player_ref:
		var p_pos = player_ref.global_position
		var diff_x = p_pos.x - global_position.x
		var diff_y = abs(p_pos.y - global_position.y)

		# Jika pemain berada di depan arah tebasan dalam jarak 115px
		if sign(diff_x) == direction and abs(diff_x) < 115.0 and diff_y < 60.0:
			# Tebasan pedang bos berdamage besar (2 Damage) dan knockback kuat!
			var slash_kb = Vector2(direction * 250.0, -220.0)
			if player_ref.has_method("take_damage"):
				player_ref.take_damage(2, slash_kb)

## Visual Tebasan Pedang Raksasa
func _spawn_giant_slash_fx() -> void:
	var slash = Sprite2D.new()
	if tex_slash_fx:
		slash.texture = tex_slash_fx
	slash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slash.scale = Vector2(2.8, 2.8)
	slash.position = Vector2(direction * 48.0, 0.0)
	slash.flip_h = (direction < 0)
	slash.modulate = Color(1.3, 1.1, 0.6, 0.95) # Kilatan pedang emas menyala
	add_child(slash)

	var tween = create_tween()
	tween.tween_property(slash, "scale", Vector2(3.5, 3.5), 0.22)
	tween.parallel().tween_property(slash, "position:x", direction * 72.0, 0.22)
	tween.parallel().tween_property(slash, "modulate:a", 0.0, 0.25)
	tween.tween_callback(slash.queue_free)

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

	# 1. Pose Tebas Pedang (Jika sedang menebas)
	if is_slashing and tex_attack:
		sprite.texture = tex_attack
	# 2. Pose Injak (Jika meluncur turun dari udara)
	elif not is_on_floor() and velocity.y > 40.0 and tex_stomp:
		sprite.texture = tex_stomp
	# 3. Animasi Jalan (8 frame komposit)
	elif abs(velocity.x) > 5.0 and is_on_floor():
		if walk_frames.size() == 8:
			var w_idx = int(anim_timer) % 8
			sprite.texture = walk_frames[w_idx]
	# 4. Pose Diam
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

	if player_ref and "is_on_floor" in player_ref and player_ref.is_on_floor():
		var dist_to_p = abs(player_ref.global_position.x - global_position.x)
		if dist_to_p < 110.0 and abs(player_ref.global_position.y - global_position.y) < 60.0:
			var kb_dir = 1.0 if player_ref.global_position.x > global_position.x else -1.0
			if player_ref.has_method("take_damage"):
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

	if body.is_in_group("Player"):
		var p_vel_y = body.velocity.y if "velocity" in body else 0.0
		if p_vel_y >= -50.0:
			if body.has_method("bounce"):
				body.bounce(-320.0)
			take_damage(1)

## Deteksi saat tubuh Bos Raksasa mengenai Player
func _on_body_damage_area_body_entered(body: Node2D) -> void:
	if is_beaten:
		return

	if body.is_in_group("Player"):
		var stomp_kb = Vector2(direction * 180.0, -220.0)
		if body.has_method("take_damage"):
			body.take_damage(1, stomp_kb)

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
	spark.modulate = Color(1.0, 0.9, 0.2, 1.0)
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
		star.modulate = Color(1.0, 0.95, 0.3, 1.0)
		star.position = Vector2(-25 + i * 20, -75)
		add_child(star)
		var tween = create_tween().set_loops(4)
		tween.tween_property(star, "position:x", star.position.x + 10.0, 0.15)
		tween.tween_property(star, "position:x", star.position.x - 10.0, 0.15)
