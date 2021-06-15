extends TextureButton

export(int) var tier


func _on_TierDeck_pressed():
	GameManager.research(tier)
