extends Area3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.5
@export var projectile_spawn_offset: Vector3 = Vector3(0.5, 0.5, 0)
@export var max_health: int = 100
var current_health: int

@onready var raycast = $RayCast3D
@onready var timer = $FireRate

var can_shoot: bool = true

func _ready():
	current_health = max_health
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	
func take_damage(amount: int):
	current_health -= amount
	print(name, " health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	queue_free()

func _physics_process(_delta):
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.is_in_group("enemy"):
			if can_shoot:
				shoot()
				can_shoot = false
				timer.start()

func shoot():
	if projectile_scene:
		var shot = projectile_scene.instantiate()
		get_tree().current_scene.add_child(shot)
		
		shot.global_position = global_position + projectile_spawn_offset
		
func _on_timer_timeout():
	can_shoot = true
	timer.stop()
