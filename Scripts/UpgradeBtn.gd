extends Button

func update_visual():
	var container = get_node("UpgradeContainer")
	container.update_labels(get_parent().get_parent().get_capacities())
