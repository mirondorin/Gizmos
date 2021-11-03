extends GridContainer


func get_anim_player_arr():
	var anim_player_arr = []
	for deck in self.get_children():
		anim_player_arr.append(deck.get_anim_player())
	return anim_player_arr
