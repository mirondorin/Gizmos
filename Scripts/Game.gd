extends Control


func set_turn_indicator():
	$TurnIndicator.init_turn_indicator(get_node("Players"))
	$TurnIndicator.init_selected_view()
