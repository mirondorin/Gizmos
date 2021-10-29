extends GridContainer


func update_capacities():
	get_node("UpgradeBtn").update_visual()


func update_highlight():
	for btn in self.get_children():
		if btn.has_method("set_animation") and GameManager.current_state != btn.action:
			btn.set_animation("Disabled")
			print(btn.get_node("AnimationPlayer").current_animation)


func all_highlight():
	for btn in self.get_children():
		if btn.has_method("set_animation"):
			btn.set_animation("Highlight")
