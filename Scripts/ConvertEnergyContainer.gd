extends HBoxContainer


var initial_energy_type
var energy_amount


# Sets what type of energy is going to be converted by the energy buttons
func set_converting_values(type: int, amount: int) -> void:
	initial_energy_type = type
	energy_amount = amount


# Return energy type to be converted and amount of excess energy to be received
func get_converting_values():
	return [initial_energy_type, energy_amount]
