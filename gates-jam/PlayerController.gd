extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var gravity_multiplier: float = 1.0

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera3D
@onready var raycast: RayCast3D = $RayCast3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Yerçekimi
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	# Zıplama
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# WASD input
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()

	# Kameraya göre yön hesaplama
	var forward := -transform.basis.z
	var right := transform.basis.x

	var move_dir := (right * input_dir.x + forward * input_dir.y)
	move_dir.y = 0
	move_dir = move_dir.normalized()

	if move_dir != Vector3.ZERO:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

	# Interact
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact() -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print(collider)
		
		if collider and collider.has_method("interact"):
			collider.interact()
			
