extends Node

class_name BoardViewer


var player_board
var player_energy_row


func init(player):
	player_board = player.get_board()
	player_energy_row = player.get_energy_row()
	player.visible = true


func change_view(new_player):
	player_board.visible = false
	player_energy_row.visible = false
	new_player.visible = true
	player_board = new_player.get_node("PlayerBoard")
	player_board.visible = true
	player_energy_row = new_player.get_node("PlayerEnergy")
	player_energy_row.visible = true
