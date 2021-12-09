extends ColorRect


func _on_ArchiveBtn_pressed():
	Server.send_event(GameManager.ARCHIVE, get_parent().card_info)
	


func _on_BuildBtn_pressed():
	Server.send_event(GameManager.BUILD, get_parent().card_info)


func _on_HideBtn_pressed():
	self.visible = false


func hide():
	self.visible = false
	GameManager.active_player.hide_research_tab()
	GameManager.active_player.get_node("ResearchTab").clear_cards()
