extends Control


func set_turn_indicator() -> void:
	$TurnIndicator.init_turn_indicator(get_node("Players"))
	$TurnIndicator.init_selected_view()


func update_turn_indicator() -> void:
	$TurnIndicator.update_turn_indicator()


func player_stats_updated(player_id: String, player_stats: Dictionary) -> void:
	var player_container = get_player_node(player_id)
	player_container.stats = player_stats
	player_container.update_energy_counters()


func player_flags_updated(player_id: String, player_flags: Dictionary):
	var player_container = get_player_node(player_id)
	player_container.flags = player_flags
	player_container.get_node("PlayerBoard").check_condition_gizmos()


func disable_player_card(card_json: Dictionary, player_id: String):
	var player_container = get_player_node(player_id)
	var card = player_container.get_node("PlayerBoard").get_card(card_json)
	card.set_is_usable(false)
	card.set_condition_sign(false)


func get_player_node(player_id: String):
	return $Players.get_node(player_id)


func get_revealed_tier_node(tier: int):
	return get_node('Container/GridTier' + str(tier))


func set_action_status_text(msg: String) -> void:
	$ActionStatus.text = msg
