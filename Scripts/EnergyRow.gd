extends Control

func update_counters(energy_arr):
	var step = 1
	for value in energy_arr:
		var energy_btn = get_node("EnergyRowContainer/EnergyButton" + str(step))
		energy_btn.update_counter(value)
		step += 1
	pass
