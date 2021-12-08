extends ColorRect


func _on_ArchiveBtn_pressed():
	Server.send_event(GameManager.ARCHIVE, get_parent().card_info)
	


func _on_BuildBtn_pressed():
	var build_succ = self.get_parent().build(GameManager.active_player)
	if build_succ:
		hide()


func _on_HideBtn_pressed():
	self.visible = false


func hide():
	self.visible = false
	GameManager.active_player.hide_research_tab()
	GameManager.active_player.get_node("ResearchTab").clear_cards()
