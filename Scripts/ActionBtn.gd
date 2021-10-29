extends Button

export(String) var action


func _ready():
	set_animation("Highlight")


func _on_TextureRect_pressed():
#	print("Current state is: " + action)
	if GameManager.active_player.used_action:
		GameManager.set_warning("You already used your action")
		return

	GameManager.set_status(action)


# Used for highlight/idle animations
func set_animation(animation):
	if $AnimationPlayer.get_current_animation():
		$AnimationPlayer.get_animation($AnimationPlayer.get_current_animation()).loop = false
	$AnimationPlayer.get_animation(animation).loop = true
	$AnimationPlayer.play(animation)
