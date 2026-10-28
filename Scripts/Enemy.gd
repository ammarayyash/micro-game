extends CharacterBody2D
class_name Enemy

## Enemy.gd
## Monster penjaga rute dengan 5 varian unik & kaya efek visual:
## 1. "zombie"   : Patroli santai (speed 40), deteksi jurang
## 2. "skeleton" : Patroli cepat (speed 65), deteksi jurang
## 3. "chaser"   : Babi Hutan - Patroli biasa, MENGEJAR kencang dengan aura membara saat melihat pahlawan
## 4. "shooter"  : Alien Penyihir - Berjaga & MENEMBAK bola api sihir dengan efek kilat berkala
## 5. "hedgehog" : Landak Berduri - Bergerak lincah di tanah, terlindung duri tajam di punggungnya
##
## Dilengkapi deteksi ujung platform (Ledge Detection) agar tidak jatuh ke jurang.
## Efek: Percikan hit, indikator damage melayang, asap kekalahan, dan efek aura.

signal enemy_defeated(enemy_node: Node2D)

@export var enemy_type: String = "zombie" # "zombie", "skeleton", "chaser", "shooter", "hedgehog"
@export var speed: float = 40.0
@export var max_hp: int = 2
var hp: int = 2

var direction: float = -1.0
var is_dead: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

# Status Spesial Chaser (Pengejar)
var is_chasing: bool = false
const CHASE_SPEED: float = 135.0

# Status Spesial Shooter (Penembak)
var projectile_scene: PackedScene = null
var shoot_cooldown: float = 2.0
var shoot_timer: float = 1.0
var is_shooting_anim: bool = false
var shoot_anim_timer: float = 0.0

var tex_walk1: Texture2D
var tex_walk2: Texture2D
var tex_shoot: Texture2D
var anim_timer: float = 0.0
var walk_frame: int = 0

var ledge_ray: RayCast2D
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var head_area: Area2D = $HeadHurtbox if has_node("HeadHurtbox") else null
@onready var body_area: Area2D = $BodyDamageArea if has_node("BodyDamageArea") else null
@onready var sfx_hit: AudioStreamPlayer2D = $SFXHit if has_node("SFXHit") else null

func _ready() -> void:
	add_to_group("Enemy")
	add_to_group("Hittable")

	# Siapkan RayCast pendeteksi ujung daratan jika belum ada
	if not has_node("LedgeRay"):
		ledge_ray = RayCast2D.new()
		ledge_ray.name = "LedgeRay"
		ledge_ray.target_position = Vector2(0, 28)
		ledge_ray.position = Vector2(direction * 18.0, 12)
		ledge_ray.collision_mask = 1
		add_child(ledge_ray)
	else:
		ledge_ray = $LedgeRay

	# Muat proyektil secara aman tanpa circular dependency
	if ResourceLoader.exists("res://Scenes/Prefabs/EnemyProjectile.tscn"):
		projectile_scene = load("res://Scenes/Prefabs/EnemyProjectile.tscn")

	var base_path: String = "res://Assets/Characters/Composite/"
	match enemy_type:
		"skeleton":
			tex_walk1 = load(base_path + "enemy_skeleton_walk1.png")
			tex_walk2 = load(base_path + "enemy_skeleton_walk2.png")
			speed = 65.0
			max_hp = 2
		"chaser":
			tex_walk1 = load(base_path + "enemy_boar_walk1.png")
			tex_walk2 = load(base_path + "enemy_boar_walk2.png")
			speed = 40.0
			max_hp = 3
		"shooter":
			tex_walk1 = load(base_path + "enemy_alien_idle.png")
			tex_walk2 = load(base_path + "enemy_alien_idle.png")
			tex_shoot = load(base_path + "enemy_alien_shoot.png")
			speed = 20.0
			max_hp = 2
		"hedgehog":
			tex_walk1 = load(base_path + "enemy_hedgehog_walk1.png")
			tex_walk2 = load(base_path + "enemy_hedgehog_walk2.png")
			speed = 70.0
			max_hp = 2
		_: # zombie
			tex_walk1 = load(base_path + "enemy_zombie_walk1.png")
			tex_walk2 = load(base_path + "enemy_zombie_walk2.png")
			speed = 40.0
			max_hp = 2

	hp = max_hp

	if sprite and tex_walk1:
		sprite.texture = tex_walk1
		sprite.flip_h = direction < 0

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	# Cari player jika belum ada
	if not player_ref:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_ref = players[0]

	# Logika Perilaku Khusus per Tipe Monster
	match enemy_type:
		"chaser":
			_process_chaser_behavior(delta)
		"shooter":
			_process_shooter_behavior(delta)
		_:
			_process_patrol_behavior(delta)

	move_and_slide()
	_update_animation(delta)

## Perilaku Patroli Biasa (Zombie, Skeleton, Hedgehog)
func _process_patrol_behavior(_delta: float) -> void:
	_check_ledge_and_wall()
	velocity.x = direction * speed

## Perilaku Babi Hutan (Chaser): Mengejar pemain saat masuk jangkauan
func _process_chaser_behavior(_delta: float) -> void:
	if player_ref:
		var diff: Vector2 = player_ref.global_position - global_position
		# Jika player berada dalam jarak 250px horizontal dan dekat secara vertikal
		if abs(diff.x) < 250.0 and abs(diff.y) < 75.0:
			is_chasing = true
			direction = sign(diff.x) if abs(diff.x) > 10.0 else direction
		elif abs(diff.x) > 350.0:
			is_chasing = false

	_check_ledge_and_wall()
	
	var current_spd = CHASE_SPEED if is_chasing else speed
	velocity.x = direction * current_spd
	
	# Efek visual aura membara saat mengejar
	if sprite:
		sprite.modulate = Color(1.0, 0.5, 0.5, 1.0) if is_chasing else Color(1.0, 1.0, 1.0, 1.0)

## Perilaku Alien Penyihir (Shooter): Berhenti dan menembak bola api sihir
func _process_shooter_behavior(delta: float) -> void:
	var can_see_player: bool = false
	if player_ref:
		var diff: Vector2 = player_ref.global_position - global_position
		if abs(diff.x) < 320.0 and abs(diff.y) < 90.0:
			can_see_player = true
			direction = sign(diff.x) if abs(diff.x) > 5.0 else direction

	if can_see_player:
		velocity.x = 0.0 # Berhenti membidik
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_cooldown
			_shoot_fireball()
	else:
		_check_ledge_and_wall()
		velocity.x = direction * speed

	if is_shooting_anim:
		shoot_anim_timer -= delta
		if shoot_anim_timer <= 0.0:
			is_shooting_anim = false

## Menembakkan bola api proyektil ke arah pemain dengan efek kilau
func _shoot_fireball() -> void:
	is_shooting_anim = true
	shoot_anim_timer = 0.35
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		var spawn_pos = global_position + Vector2(direction * 20.0, -4.0)
		get_parent().add_child(proj)
		if proj.has_method("setup"):
			proj.setup(direction, spawn_pos)

		_spawn_shoot_flash()

func _spawn_shoot_flash() -> void:
	var flash = Label.new()
	flash.text = "*"
	flash.theme_override_colors/font_color = Color(1.0, 0.9, 0.2, 1.0)
	flash.position = Vector2(direction * 18.0 - 5.0, -14.0)
	add_child(flash)
	var tween = create_tween()
	tween.tween_property(flash, "scale", Vector2(2.0, 2.0), 0.15)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

## Pengecekan ujung platform dan tabrakan tembok
func _check_ledge_and_wall() -> void:
	if is_on_floor() and ledge_ray:
		ledge_ray.position.x = direction * 18.0
		ledge_ray.force_raycast_update()
		if not ledge_ray.is_colliding():
			direction *= -1.0
			ledge_ray.position.x = direction * 18.0

	if is_on_wall():
		direction *= -1.0
		if ledge_ray:
			ledge_ray.position.x = direction * 18.0

func _update_animation(delta: float) -> void:
	if not sprite or is_dead:
		return

	if direction != 0.0:
		sprite.flip_h = direction < 0

	if enemy_type == "shooter" and is_shooting_anim and tex_shoot:
		sprite.texture = tex_shoot
		return

	anim_timer += delta * (11.0 if is_chasing else 6.5)
	if anim_timer >= 1.0:
		anim_timer = 0.0
		walk_frame = 1 - walk_frame
		sprite.texture = tex_walk1 if walk_frame == 0 else tex_walk2

## Menerima serangan tebasan pedang biasa (2 damage) atau gelombang pedang (1 damage)
func take_damage(amount: int) -> void:
	if is_dead:
		return

	hp -= amount

	# Efek kedip putih-merah saat terkena serangan
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(2.0, 0.4, 0.4, 1.0), 0.07)
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)

	# Efek percikan & teks luka
	_spawn_hit_spark(amount)

	# Knockback sedikit ke belakang
	velocity.x = -direction * 80.0
	velocity.y = -60.0

	if hp <= 0:
		die()

func _spawn_hit_spark(dmg: int) -> void:
	var lbl = Label.new()
	lbl.text = "-" + str(dmg)
	lbl.position = Vector2(randf_range(-12, 12), -26)
	lbl.theme_override_colors/font_color = Color(1.0, 0.25, 0.25, 1.0)
	lbl.theme_override_font_sizes/font_size = 10
	add_child(lbl)
	var tween = create_tween()
	tween.tween_property(lbl, "position:y", lbl.position.y - 20.0, 0.3)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.3)
	tween.tween_callback(lbl.queue_free)

## Deteksi injakan dari atas kepala
func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		var p_vel_y = body.velocity.y if "velocity" in body else 0.0
		if p_vel_y >= -50.0:
			if enemy_type == "hedgehog":
				# Landak Berduri: Punggung tajam! Menginjaknya melukai player!
				if body.has_method("bounce"):
					body.bounce(-200.0)
				if body.has_method("take_damage"):
					body.take_damage(1, Vector2(-direction * 120.0, -180.0))
			else:
				if body.has_method("bounce"):
					body.bounce(-250.0)
				take_damage(2)

## Deteksi jika player menabrak tubuh monster
func _on_body_damage_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		var push_dir = direction if direction != 0.0 else (1.0 if body.global_position.x > global_position.x else -1.0)
		var kb_force = 160.0 if is_chasing else 110.0
		if body.has_method("take_damage"):
			body.take_damage(1, Vector2(push_dir * kb_force, -170.0))

func die() -> void:
	if is_dead:
		return
	is_dead = true
	enemy_defeated.emit(self)

	# Matikan pergerakan & collision
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	if head_area:
		head_area.monitoring = false
	if body_area:
		body_area.monitoring = false

	if sfx_hit and sfx_hit.stream:
		sfx_hit.play()

	_spawn_defeat_puff()

	# Efek tumbang & pudar
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "rotation", PI * 0.5 * (1.0 if direction >= 0 else -1.0), 0.18)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
		tween.finished.connect(queue_free)
	else:
		queue_free()

func _spawn_defeat_puff() -> void:
	var puff = Label.new()
	puff.text = "+"
	puff.theme_override_colors/font_color = Color(1.0, 0.95, 0.8, 1.0)
	puff.position = Vector2(-4, -16)
	get_parent().add_child(puff)
	puff.global_position = global_position + Vector2(-4, -16)
	var tween = puff.create_tween()
	tween.tween_property(puff, "scale", Vector2(2.0, 2.0), 0.25)
	tween.parallel().tween_property(puff, "modulate:a", 0.0, 0.25)
	tween.tween_callback(puff.queue_free)
