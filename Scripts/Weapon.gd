extends Area2D
class_name Weapon

## Weapon.gd
## Menangani hitbox ayunan pedang jarak dekat (Melee), visual tebasan, 
## dan pemicu kerusakan 2x lebih besar (Damage = 2) pada monster/bos.

@export var damage: int = 2
@export var attack_duration: float = 0.2
@export var attack_cooldown: float = 0.35

var can_attack: bool = true
var is_attacking: bool = false
var duration_timer: float = 0.0
var cooldown_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_sword: Sprite2D = $SpriteSword if has_node("SpriteSword") else null
@onready var sprite_slash: Sprite2D = $SpriteSlash if has_node("SpriteSlash") else null
@onready var sfx_swing: AudioStreamPlayer2D = $SFXSwing if has_node("SFXSwing") else null

func _ready() -> void:
	monitoring = false
	monitorable = false
	if sprite_sword:
		sprite_sword.visible = false
	if sprite_slash:
		sprite_slash.visible = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_attacking:
		duration_timer -= delta
		if duration_timer <= 0.0:
			is_attacking = false
			monitoring = false
			if sprite_sword:
				sprite_sword.visible = false
			if sprite_slash:
				sprite_slash.visible = false

	if not can_attack:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_attack = true

func attack(facing_direction: float) -> bool:
	if not can_attack or is_attacking:
		return false

	can_attack = false
	is_attacking = true
	duration_timer = attack_duration
	cooldown_timer = attack_cooldown

	# Menyesuaikan arah ayunan pedang ke arah hadap pemain
	var dir_sign: float = 1.0 if facing_direction >= 0 else -1.0
	position.x = abs(position.x) * dir_sign
	scale.x = abs(scale.x) * dir_sign

	monitoring = true
	if sprite_sword:
		sprite_sword.visible = true
	if sprite_slash:
		sprite_slash.visible = true
	if sfx_swing and sfx_swing.stream:
		sfx_swing.play()

	# Langsung serang semua musuh/bos yang berada dalam jangkauan tebasan
	for b in get_overlapping_bodies():
		_hit(b)
	for a in get_overlapping_areas():
		if a.owner and a.owner != get_parent():
			_hit(a.owner)

	return true

func _on_body_entered(body: Node2D) -> void:
	_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area.owner and area.owner != get_parent():
		_hit(area.owner)

func _hit(target: Node) -> void:
	if target and target.has_method("take_damage") and target != get_parent():
		target.take_damage(damage)
