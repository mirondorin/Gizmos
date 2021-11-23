extends Button


# Instance new game with players_count players
func _on_PlayBtn_pressed() -> void:
	var new_game_scene = load("res://Scenes/Game.tscn")
	var new_game = new_game_scene.instance()
	get_tree().get_root().add_child(new_game)
