extends Button

export(String) var action
export(int) var action_id


func _on_TextureRect_pressed():
	GameManager.set_status(action)
	GameManager.set_action_id(action_id)


func get_anim_player():
	return $AnimationPlayer
