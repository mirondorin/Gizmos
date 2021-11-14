extends Node

class_name BoardViewer


var player_board
var player_energy_row


func init(player):
	player_board = player.get_board()
	player_energy_row = player.get_energy_row()


func change_view(new_player):
	player_board.visible = false
	player_energy_row.visible = false
	new_player.visible = true
	player_board = new_player.get_node("PlayerBoard")
	player_board.visible = true
	player_energy_row = new_player.get_node("PlayerEnergy")
	player_energy_row.visible = true
#	var new_player_id = new_player.get_instance_id()
#	var new_player_board = GameManager.get_player_board(new_player_id)
#	var new_player_energy_row = GameManager.get_player_energy_row(new_player_id)
#	new_player_board.visible = true
#	new_player_energy_row.visible = true
