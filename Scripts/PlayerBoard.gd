extends GridContainer


func update_capacities():
	get_node("UpgradeBtn").update_visual()


func get_action_btn_arr():
	var btn_arr = []
	for btn in self.get_children():
		if btn.is_in_group("action_btn"):
			btn_arr.append(btn)
	return btn_arr


func toggle_buttons():
	for btn in get_action_btn_arr():
		btn.disabled = !btn.disabled
