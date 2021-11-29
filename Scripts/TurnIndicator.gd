extends VBoxContainer


var player_info_scene = load("res://Scenes/PlayerInfo.tscn")
var selected_view


# Iterates through "Players" node in game and sets up their name and points
func init_turn_indicator(players_node) -> void:
	for player in players_node.get_children():
		var player_info = player_info_scene.instance()
		player_info.set_player_name(player.nickname)
		player_info.set_points(player.get_node("PlayerBoard").get_score())
		player_info.player_id = player.name
		self.add_child(player_info)
		player_info.set_turn_indicator(GameManager.active_player.name)


func init_selected_view() -> void:
	for player_info in self.get_children():
		if player_info.player_id == GameManager.get_own_id():
			selected_view = player_info.get_player_name_btn()
			selected_view.disabled = true
			break 


func update_selected_view(player_name_btn) -> void:
	selected_view.disabled = false
	selected_view = player_name_btn
	selected_view.disabled = true


# Updates turn indicator (green arrow displayed next to player's name)
func update_turn_indicator() -> void:
	for player_info in self.get_children():
		player_info.set_turn_indicator(GameManager.active_player.name)


# Updates score of overview scoreboard in top right corner
func update_player_points(player_id: String, score: int) -> void:
	for player_info in self.get_children():
		if player_info.player_id == player_id:
			player_info.set_points(score)


func get_active_player_btn():
	for player_info in self.get_children():
		if player_info.player_id == GameManager.active_player.name:
			return player_info.get_player_name_btn()
