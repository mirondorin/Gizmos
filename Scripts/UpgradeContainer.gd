extends HBoxContainer


func update_labels(params):
	for el in range (1, 4):
		get_node("TextureRect" + str(el) + "/Label").text = str(params[el - 1])
