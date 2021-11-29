extends Control


func set_turn_indicator() -> void:
	$TurnIndicator.init_turn_indicator(get_node("Players"))
	$TurnIndicator.init_selected_view()


func get_player_node(player_id: String):
	return $Players.get_node(player_id)
