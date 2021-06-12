extends Control

func update_energy_counters(energy_arr):
	var step = 1
	for value in energy_arr:
		var energy_btn = get_node("EnergyContainer/PlayerEnergyButton" + str(step))
		energy_btn.update_counter(value)
		step += 1
