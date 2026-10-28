extends Area2D
class_name GoalDoor

## GoalDoor.gd
## Pintu akhir rute yang terbuka setelah bos dikalahkan.

@export var is_locked: bool = true
@export var target_level: int = 2 # 2 untuk ke Level 2, 3 untuk ke Victory

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	update_appearance()

func unlock() -> void:
	is_locked = false
	update_appearance()

func update_appearance() -> void:
	if sprite:
		# Pintu terkunci sedikit transparan / gelap, jika terbuka cerah
		sprite.modulate = Color(1, 1, 1, 1) if not is_locked else Color(0.5, 0.5, 0.5, 0.7)

func _on_body_entered(body: Node2D) -> void:
	if is_locked:
		return
		
	if body is Player:
		if target_level == 2:
			GameManager.go_to_level_2()
		else:
			GameManager.go_to_victory()
