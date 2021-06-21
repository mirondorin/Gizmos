extends TextureButton

export(String) var action


func _on_TextureRect_pressed():
#	print("Current state is: " + action)
	if GameManager.active_player.used_action:
		return
	GameManager.game.get_node("ActionStatus").text = GameManager.active_player.name + " is doing " + action
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


func archive():
	GameManager.current_state = "archive"

	
func pick():
	GameManager.current_state = "pick"


func build():
	GameManager.current_state = "build"


func research():
	GameManager.current_state = "research"


func update_visual():
	if has_node("UpgradeContainer"):
		var container = get_node("UpgradeContainer")
		container.update_labels(GameManager.active_player.get_capacities())
