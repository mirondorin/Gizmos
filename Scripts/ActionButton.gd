extends TextureButton

export(String) var action


func _on_TextureRect_pressed():
	print("Current state is: " + action)
	match action:
		"archive":
			archive()
		"pick":
			pick()
		"build":
			build()
		"research":
			research()
		_:
			GameManager.current_state = "nothing"

	if action != "nothing":
		GameManager.active_player.using_action = true
	else:
		GameManager.active_player.using_action = false
#	print(GameManager.active_player.using_action)


func archive():
	GameManager.current_state = "archive"

	
func pick():
	GameManager.current_state = "pick"


func build():
	GameManager.current_state = "build"


func research():
	GameManager.current_state = "research"
