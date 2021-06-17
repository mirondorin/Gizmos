extends ColorRect


func _on_ArchiveBtn_pressed():
	var archive_succ = self.get_parent().archive(GameManager.active_player)
	if archive_succ:
		self.visible = false
		GameManager.active_player.hide_research_tab()
		GameManager.active_player.get_node("ResearchTab").clear_cards()


func _on_BuildBtn_pressed():
	var build_succ = self.get_parent().build(GameManager.active_player)
	if build_succ:
		self.visible = false
		GameManager.active_player.hide_research_tab()
		GameManager.active_player.get_node("ResearchTab").clear_cards()


func _on_HideBtn_pressed():
	self.visible = false
