extends Button

export(String) var action


func _ready():
	highlight()


func _on_TextureRect_pressed():
#	print("Current state is: " + action)
	if GameManager.active_player.used_action:
		GameManager.set_warning("You already used your action")
		return

	#TODO move these 3 lines into a set_status function
	GameManager.game.get_node("ActionStatus").text = GameManager.active_player.name + " is doing " + action
	GameManager.current_state = action
	GameManager.active_player.using_action = true


func highlight():
	$AnimationPlayer.current_animation = "Highlight"
