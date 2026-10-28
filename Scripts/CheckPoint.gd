extends Area2D
class_name CheckPoint

## CheckPoint.gd
## Titik simpan respawn pemain jika terjatuh ke jurang.

signal checkpoint_activated(pos: Vector2)

var is_activated: bool = false
@onready var flag_sprite: ColorRect = $FlagVisual if has_node("FlagVisual") else null
@onready var label_hint: Label = $LabelHint if has_node("LabelHint") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body is Player:
		is_activated = true
		checkpoint_activated.emit(global_position)
		GameManager.play_sfx("res://Audio/handleCoins.ogg", 2.0)
		if flag_sprite:
			flag_sprite.color = Color(0.2, 0.9, 0.3, 1) # Berubah jadi hijau tanda aktif
		if label_hint:
			label_hint.text = "✓ Checkpoint Tersimpan!"
			label_hint.modulate = Color(0.4, 1.0, 0.4, 1)
