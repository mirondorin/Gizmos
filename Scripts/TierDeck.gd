extends TextureButton

export(int) var tier


func _on_TierDeck_pressed():
	Server.send_event(GameManager.RESEARCH, tier)
	

func get_anim_player():
	return $AnimationPlayer


func _on_TierDeck_mouse_entered():
	if GameManager.current_state == "research":
		GameManager.hint_manager.set_all_animation(get_parent().get_anim_player_arr(), "Idle")
		$AnimationPlayer.stop()
		self.modulate = Color(1.4, 1.4, 1.4)


func _on_TierDeck_mouse_exited():
	self.modulate = Color(1, 1, 1)
