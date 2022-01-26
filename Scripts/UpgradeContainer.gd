extends TextureRect


func update_labels(params):
	for el in range (1, 4):
		get_node("Label" + str(el)).text = str(params[el - 1])
