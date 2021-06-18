extends Control


func _on_HideBtn_pressed():
	self.visible = false
	self.get_parent().get_node("ResearchBtn").visible = true
	

func _on_DoneBtn_pressed():
	clear_cards()
	GameManager.finished_action()


func clear_cards():
	var card_container = $ResearchContainer/Bg/ScrollContainer/GridContainer
	for card in card_container.get_children():
		card.queue_free()
	self.visible = false


func add_card(card : Card):
	$ResearchContainer/Bg/ScrollContainer/GridContainer.add_child(card)
	card.status = Utils.RESEARCH_GIZMO
