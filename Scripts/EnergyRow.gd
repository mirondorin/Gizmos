extends Control

#TODO make it not depend on node name

func update_energy_counters(energy_arr):
	var step = 1
	for value in energy_arr:
		var energy_btn = get_node("EnergyContainer/EnergyButton" + str(step))
		energy_btn.update_counter(value)
		step += 1


func all_highlight():
	for energy_btn in $EnergyContainer.get_children():
		energy_btn.set_animation("Highlight")


func all_idle():
	for energy_btn in $EnergyContainer.get_children():
		energy_btn.set_animation("Idle")
