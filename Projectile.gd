extends Area3D

@export var speed: int = 3
@export var damage: int = 25
@onready var lifeTimer = $LifeTimer

func _ready():
	lifeTimer.timeout.connect(queue_free)
	area_entered.connect(_on_hit)

func _process(delta):
	position.x += speed * delta

func _on_hit(area):
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		
		queue_free()
