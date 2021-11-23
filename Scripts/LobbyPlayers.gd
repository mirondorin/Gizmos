extends Panel


func set_player_list():
	$VBoxContainer/PlayerList.clear()
	for p in GameManager.players.values():
		$VBoxContainer/PlayerList.add_item(p)

func enable_ready_btn():
	$VBoxContainer/ReadyBtn.disabled = false


func _on_ReadyBtn_pressed():
	if GameManager.players > 2:
		print("Signal server that player is ready")
