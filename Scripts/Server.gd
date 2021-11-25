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
	GameManager.new_game()


func player_loaded():
	rpc_id(1, "player_loaded")


remote func add_revealed_card(s_card_json):
	GameManager.add_revealed_card(s_card_json)
