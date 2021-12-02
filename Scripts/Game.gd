extends Control


func set_turn_indicator() -> void:
	$TurnIndicator.init_turn_indicator(get_node("Players"))
	$TurnIndicator.init_selected_view()


func player_stats_updated(player_id: String, player_stats: Dictionary) -> void:
	var player_container = get_player_node(player_id)
	player_container.stats = player_stats
	player_container.update_energy_counters()


func get_player_node(player_id: String):
	return $Players.get_node(player_id)


func set_action_status_text(message: String) -> void:
	$ActionStatus.text = message
