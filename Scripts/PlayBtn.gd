extends Button

var players_count = 2


# Instance new game with players_count players
func _on_PlayBtn_pressed() -> void:
	var new_game_resource = load("res://Scenes/Game.tscn")
	var new_game = new_game_resource.instance()
	new_game.players_count = players_count
	get_tree().get_root().add_child(new_game)


# Dropdown to choose how many players to start the game with
func _on_OptionButton_item_selected(index) -> void:
	players_count = index + 2
