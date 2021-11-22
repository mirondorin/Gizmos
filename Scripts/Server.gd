extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var PORT = 1909


func connect_to_server(player_name):
	network.create_client(ip, PORT)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	yield(get_tree().create_timer(1.0), "timeout")
	rpc_id(1, "register_player", player_name)


func _on_connection_failed():
	print("Failed to connect")


func _on_connection_succeeded():
	print("Successfully connected")


func fetch_player_list():
	rpc_id(1, "fetch_player_list")


remote func return_player_list(s_players):
	GameManager.players = s_players
	get_tree().get_root().get_node("Lobby").refresh_lobby()
