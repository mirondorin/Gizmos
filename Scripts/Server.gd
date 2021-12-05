extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var PORT = 1909


func connect_to_server(player_name):
	network.create_client(ip, PORT)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	yield(get_tree().create_timer(0.2), "timeout")
	rpc_id(1, "register_player", player_name)


func _on_connection_failed():
	print("Failed to connect")


func _on_connection_succeeded():
	print("Successfully connected")


remote func set_player_list(s_players):
	GameManager.set_players(s_players)


func set_player_status(player_status):
	rpc_id(1, "set_player_status", player_status)


remote func set_ready_players(s_ready_players):
	GameManager.set_ready_players(s_ready_players)


remote func start_game():
	GameManager.start_game()


remote func setup_game():
	GameManager.setup_game()


func player_loaded():
	rpc_id(1, "player_loaded")


func fetch_player_order():
	rpc_id(1, "fetch_player_order")


remote func return_player_order(s_player_order: Array):
	GameManager.set_player_order(s_player_order)


func fetch_first_player():
	rpc_id(1, "fetch_first_player")


remote func return_active_player(s_player_id: String):
	GameManager.set_active_player(s_player_id)


remote func player_stats_updated(s_player_id: String, s_player_stats: Dictionary):
	GameManager.player_stats_updated(s_player_id, s_player_stats)


func send_event(action_id: int, info):
	rpc_id(1, "process_event", action_id, info)


remote func successful_action():
	GameManager.successful_action()


remote func receive_status_msg(s_msg: String):
	GameManager.set_action_status_text(s_msg)


remote func add_revealed_card(s_card_json: Dictionary):
	GameManager.add_revealed_card(s_card_json)
	fetch_tier_decks_count()


func fetch_energy_row() -> void:
	rpc_id(1, "fetch_energy_row")


remote func return_energy_row(s_energy_row: Array):
	GameManager.update_energy_row(s_energy_row)


func fetch_start_card():
	rpc_id(1, "fetch_start_card")


remote func return_start_card(s_start_card: Dictionary, s_player_id: String):
	GameManager.give_start_card(s_start_card, s_player_id)


remote func give_player_card(s_card_json: Dictionary, s_player_id: String):
	GameManager.give_card(s_card_json, s_player_id)


# Fetch cards left in each tier deck
func fetch_tier_decks_count():
	rpc_id(1, "fetch_tier_decks_count")


remote func return_tier_decks_count(s_tier_decks_count: Array):
	GameManager.update_tier_decks_counter(s_tier_decks_count)


remote func display_end_btn():
	GameManager.display_end_btn()


func end_turn():
	rpc_id(1, "end_turn")
