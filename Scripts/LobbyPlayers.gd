extends Panel


var player_ready = false


func set_player_list():
	$VBoxContainer/PlayerList.clear()
	for p in GameManager.players.values():
		$VBoxContainer/PlayerList.add_item(p)

	if len(GameManager.players) >= 2:
		disable_ready_btn(false)
	else:
		disable_ready_btn(true)


func set_player_ready():
	player_ready = !player_ready
	
	if player_ready:
		$VBoxContainer/ReadyBtn.text = "UNREADY!"
	else:
		$VBoxContainer/ReadyBtn.text = "READY!"


func disable_ready_btn(option: bool):
	$VBoxContainer/ReadyBtn.disabled = option


func _on_ReadyBtn_pressed():
	set_player_ready()
	Server.set_player_status(player_ready)
