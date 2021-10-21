extends VBoxContainer


var player_info_scene = load("res://Scenes/PlayerInfo.tscn")


# Iterates through "Players" node in game and sets up their name and points
func init_turn_indicator(players_node) -> void:
	for player in players_node.get_children():
		var player_info = player_info_scene.instance()
		player_info.set_player_name(player.name)
		player_info.set_points(player.get_score())
		player_info.player_id = player.get_instance_id()
		self.add_child(player_info)
		player_info.set_turn_indicator(GameManager.active_player.get_instance_id())


# Updates turn indicator (green arrow displayed next to player's name)
func update_turn_indicator() -> void:
	for player_info in self.get_children():
		player_info.set_turn_indicator(GameManager.active_player.get_instance_id())


# Updates score of overview scoreboard in top right corner
func update_player_points(player_id : int, score : int) -> void:
	for player_info in self.get_children():
		if player_info.player_id == player_id:
			player_info.set_points(score)