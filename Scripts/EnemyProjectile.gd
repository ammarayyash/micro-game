extends Area2D
class_name EnemyProjectile

## EnemyProjectile.gd
## Proyektil bola api / sihir yang ditembakkan oleh monster penembak (Shooter).

@export var speed: float = 190.0
@export var damage: int = 1

var direction: float = -1.0
var lifetime: float = 4.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(dir: float, start_pos: Vector2) -> void:
	direction = dir
	global_position = start_pos
	if sprite:
		sprite.flip_h = direction < 0

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	if sprite:
		sprite.rotation += 10.0 * delta * direction
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") or body.is_in_group("Boss"):
		return
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, Vector2(direction * 120.0, -160.0))
		GameManager.play_sfx("res://Audio/glass_004.ogg", -1.0)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		GameManager.play_sfx("res://Audio/glass_004.ogg", -3.0)
		queue_free()
