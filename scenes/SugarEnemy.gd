extends Area3D

@export var speed: float = 1.5
@export var health: int = 100
@export var damage: int = 10

@onready var attackTimer = $AttackTimer

var current_target: Area3D = null
var is_eating: bool = false

func _ready():
	area_entered.connect(_on_area_entered)
	attackTimer.timeout.connect(_on_attack_timer_timeout)

func _process(delta):
	if not is_eating:
		position.x -= speed * delta

func take_damage(amount: int):
	health -= amount
	
	var mesh = $MeshInstance3D
	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
		tween.tween_property(mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	
	if health <= 0:
		die()

func die():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("fruits") or area.is_in_group("basket"):
		start_eating(area)

func start_eating(plant_area):
	if is_eating: return
	
	print("Chomp! Started eating: ", plant_area.name)
	is_eating = true
	current_target = plant_area
	$AttackTimer.start()

func _on_attack_timer_timeout():
	if is_instance_valid(current_target):
		if current_target.has_method("take_damage"):
			current_target.take_damage(damage)
	else:
		stop_eating()

func stop_eating():
	is_eating = false
	current_target = null
	$AttackTimer.stop()
	print("Finished eating. Moving again.")
