extends CharacterBody2D

enum PROCESS_IN {
	PHYSICS_PROCESS,
	PROCESS,
	INPUT_METHOD
}

var speed = 400
var input_process_mode = PROCESS_IN.PHYSICS_PROCESS
var draggable = true
var run_multiplier = 2
var jump_speed = -400
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _has_mouse = false
var _mouse_down = false

@onready var sprite = $Sprite2D


func _handle_keys(delta):
	# Add the gravity.
	velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction.
	var direction = Input.get_axis("left", "right")
	var total_speed = speed
	if(Input.is_key_pressed(KEY_SHIFT)):
		total_speed *= run_multiplier
	velocity.x = direction * total_speed


func _handle_mouse(_delta):
	velocity = Vector2.ZERO
	position = get_viewport().get_mouse_position()


func _handle_input(delta):
	if(draggable and _mouse_down):
		_handle_mouse(delta)
	else:
		_handle_keys(delta)
		move_and_slide()


func _physics_process(delta):
	if(input_process_mode == PROCESS_IN.PHYSICS_PROCESS):
		_handle_input(delta)


func _process(delta):
	if(input_process_mode == PROCESS_IN.PROCESS):
		_handle_input(delta)


# ----------------
# Events
# ----------------
func _on_mouse_entered():
	_has_mouse = true
	sprite.modulate = Color(1.5, 1.5, 1.5)


func _on_mouse_exited():
	_has_mouse = false
	sprite.modulate = Color(1, 1, 1)


func _on_input_event(_viewport, event, _shape_idx):
	if(event is InputEventMouseButton and _has_mouse):
		_mouse_down = event.pressed
