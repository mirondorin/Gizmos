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


func archive():
	GameManager.current_state = "archive"

	
func pick():
	GameManager.current_state = "pick"


func build():
	GameManager.current_state = "build"


func research():
	GameManager.current_state = "research"
