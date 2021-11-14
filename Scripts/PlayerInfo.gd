extends HBoxContainer

var player_id


# Sets the name of the player
func set_player_name(name : String) -> void:
	$PlayerName.text = name


# Sets points for player
func set_points(score : int) -> void:
	$PointsContainer/Points.text = str(score)


# Receives a player's id as parameter and sets visibility for green arrow
func set_turn_indicator(id : int) -> void:
	if player_id == id:
		$Arrow.visible = true
	else:
		$Arrow.visible = false


func _on_PlayerName_button_up():
	GameManager.view_player_board(player_id)
