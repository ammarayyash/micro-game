extends Control

## CharacterSelect.gd
## Menangani pengeditan Nama & NIM 3 anggota tim secara langsung,
## serta pemilihan 1 Hero (2 anggota lain otomatis menjadi Bos Level 1 & Bos Level 2).

@onready var edit_nama_0: LineEdit = $VBoxContainer/HBoxCards/Card0/VBox/EditNama
@onready var edit_nim_0: LineEdit = $VBoxContainer/HBoxCards/Card0/VBox/EditNIM
@onready var btn_char_0: Button = $VBoxContainer/HBoxCards/Card0/BtnPilih

@onready var edit_nama_1: LineEdit = $VBoxContainer/HBoxCards/Card1/VBox/EditNama
@onready var edit_nim_1: LineEdit = $VBoxContainer/HBoxCards/Card1/VBox/EditNIM
@onready var btn_char_1: Button = $VBoxContainer/HBoxCards/Card1/BtnPilih

@onready var edit_nama_2: LineEdit = $VBoxContainer/HBoxCards/Card2/VBox/EditNama
@onready var edit_nim_2: LineEdit = $VBoxContainer/HBoxCards/Card2/VBox/EditNIM
@onready var btn_char_2: Button = $VBoxContainer/HBoxCards/Card2/BtnPilih

func _ready() -> void:
	# Isi teks awal dari data GameManager
	if GameManager.team_members.size() > 0:
		edit_nama_0.text = str(GameManager.team_members[0].get("nama", "Mamank (M1)"))
		edit_nim_0.text = str(GameManager.team_members[0].get("nim", "220101001"))
	if GameManager.team_members.size() > 1:
		edit_nama_1.text = str(GameManager.team_members[1].get("nama", "Member 2"))
		edit_nim_1.text = str(GameManager.team_members[1].get("nim", "220101002"))
	if GameManager.team_members.size() > 2:
		edit_nama_2.text = str(GameManager.team_members[2].get("nama", "Member 3"))
		edit_nim_2.text = str(GameManager.team_members[2].get("nim", "220101003"))

	# Simpan perubahan secara real-time saat pengguna mengetik
	edit_nama_0.text_changed.connect(func(val): GameManager.update_member_info(0, val, edit_nim_0.text))
	edit_nim_0.text_changed.connect(func(val): GameManager.update_member_info(0, edit_nama_0.text, val))
	edit_nama_1.text_changed.connect(func(val): GameManager.update_member_info(1, val, edit_nim_1.text))
	edit_nim_1.text_changed.connect(func(val): GameManager.update_member_info(1, edit_nama_1.text, val))
	edit_nama_2.text_changed.connect(func(val): GameManager.update_member_info(2, val, edit_nim_2.text))
	edit_nim_2.text_changed.connect(func(val): GameManager.update_member_info(2, edit_nama_2.text, val))

	btn_char_0.pressed.connect(func(): _on_select(0))
	btn_char_1.pressed.connect(func(): _on_select(1))
	btn_char_2.pressed.connect(func(): _on_select(2))

func _save_inputs_to_gamemanager() -> void:
	if edit_nama_0 and edit_nim_0:
		GameManager.update_member_info(0, edit_nama_0.text, edit_nim_0.text)
	if edit_nama_1 and edit_nim_1:
		GameManager.update_member_info(1, edit_nama_1.text, edit_nim_1.text)
	if edit_nama_2 and edit_nim_2:
		GameManager.update_member_info(2, edit_nama_2.text, edit_nim_2.text)

func _on_select(char_id: int) -> void:
	_save_inputs_to_gamemanager()
	GameManager.start_game(char_id)
