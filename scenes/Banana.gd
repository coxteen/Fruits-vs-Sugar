extends Area3D

@export var water_drop_scene: PackedScene
@export var cost: int = 50
@export var max_health: int = 100
var current_health: int

@onready var timer = $Timer

func _ready():
	current_health = max_health
	timer.timeout.connect(_on_timer_timeout)

func take_damage(amount: int):
	current_health -= amount
	print(name, " health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	queue_free()

func _on_timer_timeout():
	spawn_drop()

func spawn_drop():
	if water_drop_scene:
		var drop = water_drop_scene.instantiate()
		get_parent().add_child(drop)
		drop.position = position + Vector3(0, 2.0, 0.5) 
