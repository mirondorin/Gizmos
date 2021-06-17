extends TextureButton

export(int) var tier

# Need to add OR condition in case a gizmo was activated
func _on_TierDeck_pressed():
	if GameManager.active_player.can_do('research'):
		GameManager.research(tier)
