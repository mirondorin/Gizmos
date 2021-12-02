extends TextureButton

export(int) var energy_type

func _on_Control_pressed():
	if GameManager.action_id == GameManager.PICK:
		Server.send_event(GameManager.action_id, energy_type)


#func give_energy(player : Player, energy_type : int):
#	if GameManager.energy_row[energy_type] > 0:
#		if player.has_energy_space():
#			player.stats['energy'][energy_type] += 1
#			player.flags['picked'][energy_type] = 1
#			player.update_energy_counters()
#			GameManager.energy_row[energy_type] -= 1
#			decrement_counter()
#			GameManager.restock_energy_row()
#			if GameManager.finished_action() == false:
#				print("Removed free pick action")
#				GameManager.dec_free_action('pick')
#			player.get_node("PlayerBoard").check_condition_gizmos()
#			print(player.name + "'s energy ", player.stats['energy'])
#		else:
#			GameManager.set_warning("You do not have enough energy capacity")
#			print(player.name + " does not have enough energy capacity")
#	else:
#		GameManager.set_warning("No more energy of this type")
#		print("No more energy of this type")


func decrement_counter():
	var count = int($Counter.text)
	count -= 1
	$Counter.text = str(count)
	
	
func increment_counter():
	var count = int($Counter.text)
	count += 1
	$Counter.text = str(count)


func update_counter(value):
	$Counter.text = str(value)


func get_anim_player():
	return $AnimationPlayer


func _on_EnergyButton_mouse_entered():
	if GameManager.current_state == "pick":
		GameManager.hint_manager.set_all_animation(get_parent().get_parent().get_anim_player_arr(), "Idle")
		$AnimationPlayer.stop()
		self.modulate = Color(1.4, 1.4, 1.4)


func _on_EnergyButton_mouse_exited():
	self.modulate = Color(1, 1, 1)
