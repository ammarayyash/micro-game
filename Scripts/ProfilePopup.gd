extends CanvasLayer
class_name ProfilePopup

## ProfilePopup.gd
## Menampilkan pop-up profil identitas (Nama, NIM, Peran, Foto Pixelate)
## Berjalan dalam mode PROCESS_MODE_ALWAYS agar tetap aktif saat game di-pause.

signal popup_closed

@onready var panel_container: Control = $Control
@onready var texture_avatar: TextureRect = get_node_or_null("Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/SlotAvatar/TextureAvatar") if has_node("Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/SlotAvatar/TextureAvatar") else get_node_or_null("Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/TextureAvatar")
@onready var label_title: Label = $Control/Panel/MarginContainer/VBoxContainer/LabelTitle
@onready var label_nama: Label = $Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxInfo/LabelNama
@onready var label_nim: Label = $Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxInfo/LabelNIM
@onready var label_role: Label = $Control/Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxInfo/LabelRole
@onready var btn_continue: Button = $Control/Panel/MarginContainer/VBoxContainer/BtnContinue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_container.visible = false
	if btn_continue:
		btn_continue.pressed.connect(_on_continue_pressed)

func show_profile(data: Dictionary, custom_title: String = "IDENTITAS TERUNGKAP!") -> void:
	if label_title:
		label_title.text = custom_title
	
	if label_nama:
		label_nama.text = "Nama : " + str(data.get("nama", "-"))
	if label_nim:
		label_nim.text = "NIM  : " + str(data.get("nim", "-"))
	if label_role:
		label_role.text = "Peran: " + str(data.get("role", "-"))
		
	if texture_avatar and data.has("avatar"):
		var tex = load(data["avatar"])
		if tex:
			texture_avatar.texture = tex
			
	panel_container.visible = true
	# Hentikan gameplay selagi pemain membaca identitas
	get_tree().paused = true

func _on_continue_pressed() -> void:
	panel_container.visible = false
	get_tree().paused = false
	popup_closed.emit()
