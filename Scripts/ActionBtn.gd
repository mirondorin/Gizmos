extends Button

export(String) var action


func _on_TextureRect_pressed():
	if GameManager.active_player.used_action:
		GameManager.set_warning("You already used your action")
		return

	GameManager.set_status(action)


func get_anim_player():
	return $AnimationPlayer
