extends Area3D

@export var value: int = 25
@export var fall_speed: float = 1.0
@export var end_y_position: float = 1.0

var is_landed: bool = false

func _process(delta):
	if position.y > end_y_position:
		position.y -= fall_speed * delta
	else:
		is_landed = true

func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect_water()

func collect_water():
	GameData.add_water(value)
	queue_free()
