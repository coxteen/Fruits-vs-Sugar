extends Area3D

signal basket_destroyed 

@export var max_health: int = 5
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("basket") 

func take_damage(amount: int):
	current_health -= amount
	print("Basket Health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("Basket destroyed! The Sugar Rush has won.")
	basket_destroyed.emit()
	queue_free()
