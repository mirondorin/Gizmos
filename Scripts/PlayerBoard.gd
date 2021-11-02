extends GridContainer


func update_capacities():
	get_node("UpgradeBtn").update_visual()


#TODO change has_method to is_in_group("action buttons")

# Disables highlight for other action buttons when a button was pressed
func update_highlight():
	for btn in self.get_children():
		if btn.has_method("set_animation") and GameManager.current_state != btn.action:
			btn.set_animation("Idle")


func all_highlight():
	for btn in self.get_children():
		if btn.has_method("set_animation"):
			btn.set_animation("Highlight")


func toggle_buttons():
	for btn in self.get_children():
		if btn.has_method("set_animation"):
			btn.disabled = !btn.disabled
