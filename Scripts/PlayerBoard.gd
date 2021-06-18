extends GridContainer


func update_all():
	for el in range(1, 7):
		get_node("TextureRect" + str(el)).update_visual()
