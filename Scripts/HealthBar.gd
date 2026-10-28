extends Node2D
class_name HealthBar

## HealthBar.gd
## Menampilkan bilah nyawa (HP) Bos dengan latar belakang dan bar merah.

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label_name: Label = $LabelName if has_node("LabelName") else null

func setup(max_hp: int, entity_name: String = "BOS HP") -> void:
	if progress_bar:
		progress_bar.max_value = max_hp
		progress_bar.value = max_hp
	if label_name:
		label_name.text = entity_name

func update_hp(current_hp: int) -> void:
	if progress_bar:
		progress_bar.value = current_hp
