extends Control


# Iterates through energy and excess_energy player has and sends signal
# to each EnergyBtn to update their counter
func update_energy_counters(energy_arr, excess_energy):
	for step in range (0, energy_arr.size()):
		var energy_btn = get_node("EnergyContainer/PlayerEnergyButton" + str(step + 1))
		var counter = str(energy_arr[step])
		if excess_energy[step]:
			counter += "+" + str(excess_energy[step])
		energy_btn.update_counter(counter)
