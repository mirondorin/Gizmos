extends TextureButton

export(int) var energy_type

func _on_Control_pressed():
	if GameManager.action_id == GameManager.PICK:
		Server.send_event(GameManager.action_id, energy_type)


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
