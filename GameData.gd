extends Node

signal water_changed(new_amount)

var water_balance: int = 3000

func add_water(amount: int):
	water_balance += amount
	water_changed.emit(water_balance)
	print("Water Collected! Total: ", water_balance)

func spend_water(amount: int) -> bool:
	if water_balance >= amount:
		water_balance -= amount
		water_changed.emit(water_balance)
		return true
	else:
		return false
