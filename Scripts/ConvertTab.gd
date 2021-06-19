extends Control

var initial_energy = [-1, -1]
var result_energy = [-1, -1]
var amount_energy = [-1, -1]

# Recieves an arr of type [[], [], []] and sets values of above arays
func set_converter(arr) -> void:
	self.visible = true
	for el in range(0, arr[0].size()):
		initial_energy[el] = arr[0][el]
		result_energy[el] = arr[1][el]
		amount_energy[el] = arr[2][el]
	set_convert_btns(arr[0].size(), true)


# Set texture of gizmo that is being used
func set_gizmo_preview(card_texture):
	get_node("MarginContainer/VBoxContainer/Gizmo").texture = card_texture


# Function to toggle visibility of convert buttons and set their values
func set_convert_btns(count : int, can_see : bool) -> void:
	for el in range(1, count + 1):
		var btn = get_node("MarginContainer/VBoxContainer/HBoxContainer/ConvertActionBtn" + str(el))
		btn.visible = can_see
		btn.set_values(initial_energy[el - 1], result_energy[el - 1], amount_energy[el - 1])


# Returns EnergyContainer node
# Used for easier access of functions of energy container
func get_energy_container():
	return $MarginContainer/VBoxContainer/EnergyContainer


# Makes convert tab & action buttons invisible 
func _on_DoneBtn_pressed() -> void:
	set_convert_btns(2, false)
	self.visible = false
