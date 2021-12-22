extends Control


func update_energy_counters(energy_arr):
	var energy_type = GameManager.RED
	var energy_container = $EnergyContainer
	for energy_btn in energy_container.get_children():
		energy_btn.update_counter(energy_arr[energy_type])
		energy_type += 1


func get_anim_player_arr():
	var anim_player_arr = []
	for energy_btn in $EnergyContainer.get_children():
		anim_player_arr.append(energy_btn.get_anim_player())
	return anim_player_arr
