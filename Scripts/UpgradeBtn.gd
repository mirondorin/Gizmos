extends Button

func update_visual():
	var container = get_node("UpgradeContainer")
	container.update_labels(GameManager.active_player.get_capacities())
