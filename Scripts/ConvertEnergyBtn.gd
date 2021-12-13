extends Button

export(int) var energy_type


func _on_EnergyBtn_pressed():
	var converting_split = get_parent().get_converting_values()
	Server.convert_request(converting_split[0], energy_type, converting_split[1])
	get_parent().visible = false
