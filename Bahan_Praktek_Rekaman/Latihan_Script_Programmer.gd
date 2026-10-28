extends CharacterBody2D

# Konstanta Fisika
const SPEED = 200.0
const JUMP_VELOCITY = -380.0
const BOUNCE_FORCE = -280.0

# Ambil nilai gravitasi default dari konfigurasi project Godot
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1. Terapkan Gravitasi jika karakter berada di udara
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Tangani Lompatan (Tombol Space / W / Panah Atas)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Tangani Pergerakan Horizontal (A / D atau Panah Kiri / Kanan)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 10.0 * delta)

	# 4. Eksekusi perpindahan karakter
	move_and_slide()

## Fungsi pantulan saat menginjak musuh dari atas
func bounce() -> void:
	velocity.y = BOUNCE_FORCE
