extends TextureButton

export(int) var tier

# Need to add OR condition in case a gizmo was activated
func _on_TierDeck_pressed():
	var player = GameManager.active_player
	if !player.disabled_actions['research'] and player.can_do('research'):
		if GameManager.finished_action() == false:
			print("Removed free research action")
			GameManager.dec_free_action('research')
		GameManager.research(tier)


func get_anim_player():
	return $AnimationPlayer


func _on_TierDeck_mouse_entered():
	if GameManager.current_state == "research":
		GameManager.hint_manager.set_all_animation(get_parent().get_anim_player_arr(), "Idle")
		$AnimationPlayer.stop()
		self.modulate = Color(1.4, 1.4, 1.4)


func _on_TierDeck_mouse_exited():
	self.modulate = Color(1, 1, 1)
