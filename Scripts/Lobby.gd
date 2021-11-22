extends Control


func _on_JoinBtn_pressed():
	if $Connect/VBoxContainer/Name.text == "":
		$Connect/VBoxContainer/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/VBoxContainer/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/VBoxContainer/ErrorLabel.text = "Invalid IP address!"
		return
	
	$Connect.hide()
	$Players.show()
	$Connect/VBoxContainer/ErrorLabel.text = ""

	var player_name = $Connect/VBoxContainer/Name.text
	Server.connect_to_server(player_name)


func refresh_lobby():
	$Players/VBoxContainer/PlayerList.clear()
	for p in GameManager.players.values():
		$Players/VBoxContainer/PlayerList.add_item(p)
