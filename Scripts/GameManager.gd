extends Node

## GameManager.gd
## Autoload Singleton: Mengatur data 3 profil anggota tim dan penugasan Hero vs 2 Bos dinamis.

signal character_selected(hero_data)

# Data profil 3 anggota tim
var team_members: Array = [
	{
		"id": 0,
		"nama": "Mamank (Member 1)",
		"nim": "220101001",
		"role": "Programmer",
		"avatar": "res://Assets/Profiles/member_1.png",
		"sprite_idle": "res://Assets/Characters/Composite/char_m1_idle.png",
		"sprite_dizzy": "res://Assets/Characters/Composite/boss_m1_dizzy_0.png",
		"color": Color(1, 1, 1, 1)
	},
	{
		"id": 1,
		"nama": "Member 2",
		"nim": "220101002",
		"role": "Artist",
		"avatar": "res://Assets/Profiles/member_2.png",
		"sprite_idle": "res://Assets/Characters/Composite/char_m2_idle.png",
		"sprite_dizzy": "res://Assets/Characters/Composite/boss_m2_dizzy_0.png",
		"color": Color(1, 1, 1, 1)
	},
	{
		"id": 2,
		"nama": "Member 3",
		"nim": "220101003",
		"role": "Level Designer",
		"avatar": "res://Assets/Profiles/member_3.png",
		"sprite_idle": "res://Assets/Characters/Composite/char_m3_idle.png",
		"sprite_dizzy": "res://Assets/Characters/Composite/boss_m3_dizzy_0.png",
		"color": Color(1, 1, 1, 1)
	}
]

var selected_hero: Dictionary = {}
var boss_1: Dictionary = {}
var boss_2: Dictionary = {}

func _ready() -> void:
	# Default fallback jika langsung jalankan scene level untuk testing
	if selected_hero.is_empty():
		assign_roles(0)

## Memperbarui nama dan NIM anggota tim secara dinamis dari input Character Select
func update_member_info(member_index: int, new_name: String, new_nim: String) -> void:
	if member_index >= 0 and member_index < team_members.size():
		if new_name.strip_edges() != "":
			team_members[member_index]["nama"] = new_name.strip_edges()
		if new_nim.strip_edges() != "":
			team_members[member_index]["nim"] = new_nim.strip_edges()

## Fungsi pemilihan karakter: 1 jadi Hero, 2 anggota lainnya otomatis menjadi Bos Level 1 & Bos Level 2!
func assign_roles(hero_index: int) -> void:
	selected_hero = team_members[hero_index]
	
	# Ambil 2 anggota tim lainnya yang tidak dipilih
	var remaining: Array = []
	for i in range(team_members.size()):
		if i != hero_index:
			remaining.append(team_members[i])
			
	# Anggota yang tidak dipilih menjadi Bos Level 1 dan Bos Level 2
	boss_1 = remaining[0]
	boss_2 = remaining[1]
	
	character_selected.emit(selected_hero)

func get_boss_for_level(lvl: int) -> Dictionary:
	if lvl == 2:
		return boss_2
	return boss_1

func start_game(hero_index: int) -> void:
	assign_roles(hero_index)
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")

func go_to_level_2() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level2.tscn")

func go_to_victory() -> void:
	get_tree().change_scene_to_file("res://Scenes/Victory.tscn")

func restart_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")
