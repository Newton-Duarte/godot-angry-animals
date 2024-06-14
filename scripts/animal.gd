extends RigidBody2D

enum ANIMAL_STATE { READY, DRAG, RELEASE }

const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0

var state: ANIMAL_STATE = ANIMAL_STATE.READY
var start: Vector2 = Vector2.ZERO
var drag_start: Vector2 = Vector2.ZERO
var dragged_vector: Vector2 = Vector2.ZERO
var last_dragged_vector: Vector2 = Vector2.ZERO
var arrow_scale_x: float = 0.0
var last_collision_count: int = 0

@onready var kick_sound = $KickSound
@onready var launch_sound = $LaunchSound
@onready var stretch_sound = $StretchSound
@onready var arrow = $Arrow


func _ready():
	arrow_scale_x = arrow.scale.x
	arrow.hide()
	start = position

func _physics_process(delta):
	update(delta)

func get_impulse() -> Vector2:
	return dragged_vector * -1 * IMPULSE_MULT

func set_release() -> void:
	arrow.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch_sound.play()
	SignalManager.attempt_made.emit()

func set_drag() -> void:
	drag_start = get_global_mouse_position()
	arrow.show()

func set_new_state(new_state: ANIMAL_STATE) -> void:
	state = new_state
	if state == ANIMAL_STATE.RELEASE:
		set_release()
	elif state == ANIMAL_STATE.DRAG:
		set_drag()

func scale_arrow() -> void:
	var impulse_len = get_impulse().length()
	var perc = impulse_len / IMPULSE_MAX
	arrow.scale.x = (arrow_scale_x * perc) + arrow_scale_x
	arrow.rotation = (start - position).angle()

func play_stretch_sound() -> void:
	if (last_dragged_vector - dragged_vector).length() > 0:
		if !stretch_sound.playing:
			stretch_sound.play()

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - drag_start

func drag_in_limits() -> void:
	last_dragged_vector = dragged_vector

	dragged_vector.x = clampf(dragged_vector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	dragged_vector.y = clampf(dragged_vector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	position = start + dragged_vector

func detect_release() -> bool:
	if state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag"):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func update_drag() -> void:
	if detect_release():
		return
	
	var gmp = get_global_mouse_position()
	dragged_vector = get_dragged_vector(gmp)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()

func play_collision() -> void:
	if last_collision_count == 0 and get_contact_count() > 0 and !kick_sound.playing:
		kick_sound.play()
	last_collision_count = get_contact_count()

func update_flight() -> void:
	play_collision()

func update(delta: float) -> void:
	match state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()

func die() -> void:
	SignalManager.player_died.emit()
	queue_free()

func _on_screen_exited():
	die()

func _on_input_event(viewport, event: InputEvent, shape_idx):
	if state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)

func _on_sleeping_state_changed():
	if sleeping:
		var colliding_bodies = get_colliding_bodies()
		if colliding_bodies.size() > 0:
			colliding_bodies[0].die()
		call_deferred("die")
