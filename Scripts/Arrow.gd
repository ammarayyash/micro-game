extends Area2D
class_name SwordBeam

## Arrow.gd / SwordBeam.gd
## Gelombang tebasan pedang jarak jauh (Sword Beam / Wave Slash).
## Menggunakan proyektil tebasan berelemen (sword_beam.png).
## Memiliki damage = 1 (lebih kecil daripada tebasan pedang langsung melee yang ber-damage 2).

@export var speed: float = 440.0
@export var damage: int = 1

var direction: float = 1.0
var lifetime: float = 3.0
var time_elapsed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func setup(dir: float, start_pos: Vector2) -> void:
	direction = dir
	global_position = start_pos
	if sprite:
		sprite.flip_h = direction < 0

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	position.x += direction * speed * delta
	# Efek gelombang energi vertikal tipis saat meluncur
	position.y += sin(time_elapsed * 18.0) * 0.8
	
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.owner and area.owner != self and not (area.owner is Player):
		if area.owner.has_method("take_damage"):
			area.owner.take_damage(damage)
			queue_free()
