extends Control


# Receive custom signal from GameManager
func _on_player_joined():
	refresh_lobby()


func _on_JoinBtn_pressed():
	if !$JoinMenu.valid_name() or !$JoinMenu.valid_ip():
		return

	$JoinMenu.close()
	$Players.show()

	var player_name = $JoinMenu.get_player_name()
	Server.connect_to_server(player_name)


func refresh_lobby():
	$Players.set_player_list()
