extends Button

export(String) var action
export(int) var action_id


func _on_TextureRect_pressed():
	var format_message = "You are doing %s"
	var status_message = format_message % action
	
	GameManager.set_status(action, action_id)
	GameManager.set_action_status_text(status_message)


func get_anim_player():
	return $AnimationPlayer
