extends Control

#TODO make it not depend on node name

func update_energy_counters(energy_arr):
	var step = 1
	for value in energy_arr:
		var energy_btn = get_node("EnergyContainer/EnergyButton" + str(step))
		energy_btn.update_counter(value)
		step += 1


func get_anim_player_arr():
	var anim_player_arr = []
	for energy_btn in $EnergyContainer.get_children():
		anim_player_arr.append(energy_btn.get_anim_player())
	return anim_player_arr
