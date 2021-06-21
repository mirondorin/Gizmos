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
