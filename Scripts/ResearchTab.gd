extends Control


func _on_HideBtn_pressed():
	self.visible = false
	self.get_parent().get_node("ResearchBtn").visible = true
	

func _on_DoneBtn_pressed():
	clear_cards()


func clear_cards():
	var card_container = get_card_container()
	for card in card_container.get_children():
		card.queue_free()
	self.visible = false


func add_card(card: Card):
	get_card_container().add_child(card)


func get_card_container():
	return $ResearchContainer/Bg/ScrollContainer/GridContainer
