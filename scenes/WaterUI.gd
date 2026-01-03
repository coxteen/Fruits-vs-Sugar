extends Label

func _ready():
	text = "Water: " + str(GameData.water_balance)
	
	GameData.water_changed.connect(update_text)

func update_text(new_amount):
	text = "Water: " + str(new_amount)
