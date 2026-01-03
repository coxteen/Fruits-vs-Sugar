extends Button

signal card_selected(plant_scene, cost, button_ref)
signal card_deselected() 

@export var plant_cost: int = 50
@export var plant_scene: PackedScene 

var original_text: String = ""

func _ready():
	original_text = text 

func _toggled(toggled_on):
	if toggled_on:
		text = original_text + " (Selected)"
		card_selected.emit(plant_scene, plant_cost, self)
	else:
		text = original_text
		card_deselected.emit()

func force_deselect():
	set_pressed_no_signal(false)
	text = original_text
