extends Control

## Victory.gd
## Menampilkan profil Pahlawan yang berhasil menyelesaikan game

@onready var label_title: Label = $VBoxContainer/LabelTitle
@onready var texture_avatar: TextureRect = get_node_or_null("VBoxContainer/PanelHero/Margin/VBox/HBox/SlotAvatar/Avatar") if has_node("VBoxContainer/PanelHero/Margin/VBox/HBox/SlotAvatar/Avatar") else get_node_or_null("VBoxContainer/PanelHero/Margin/VBox/HBox/Avatar")
@onready var label_nama: Label = $VBoxContainer/PanelHero/Margin/VBox/HBox/VBoxInfo/LabelNama
@onready var label_nim: Label = $VBoxContainer/PanelHero/Margin/VBox/HBox/VBoxInfo/LabelNIM
@onready var label_role: Label = $VBoxContainer/PanelHero/Margin/VBox/HBox/VBoxInfo/LabelRole
@onready var btn_restart: Button = $VBoxContainer/BtnRestart

func _ready() -> void:
	GameManager.play_sfx("res://Audio/confirmation_004.ogg", 3.0)
	var hero = GameManager.selected_hero
	if not hero.is_empty():
		label_nama.text = "Nama : " + str(hero.get("nama", "Pahlawan"))
		label_nim.text = "NIM  : " + str(hero.get("nim", "-"))
		label_role.text = "Peran: " + str(hero.get("role", "Hero"))
		
		if hero.has("avatar"):
			var tex = load(hero["avatar"])
			if tex:
				texture_avatar.texture = tex
				
	btn_restart.mouse_entered.connect(func(): GameManager.play_sfx("res://Audio/select_001.ogg", -4.0))
	btn_restart.pressed.connect(func(): 
		GameManager.play_sfx("res://Audio/click_001.ogg", 1.0)
		GameManager.restart_game()
	)
