extends HBoxContainer

#TODO make it not depend on node name
func update_labels(params):
	for el in range (1, 4):
		get_node("TextureRect" + str(el) + "/Label").text = str(params[el - 1])
