extends Node

class_name HintManager

var prev_anim_players = []

# Used for highlight/idle animations
func set_animation(anim_player, animation):
	if anim_player.get_current_animation():
		anim_player.get_animation(anim_player.get_current_animation()).loop = false
	anim_player.get_animation(animation).loop = true
	anim_player.play(animation)


func set_all_animation(anim_player_arr, animation):
	for anim_player in anim_player_arr:
		set_animation(anim_player, animation)


# Gives highlight hint for interactable elements based on action
func action_highlight(action):
	set_all_animation(prev_anim_players, "Idle")
	prev_anim_players = get_action_anim_players(action)
	set_all_animation(prev_anim_players, "Highlight")


func get_action_anim_players(action):
	var game = GameManager.game
	var anim_player_arr = []
	match action:
		"archive":
#			print("get container")
			anim_player_arr = []
		"pick":
			anim_player_arr = game.get_node("EnergyRow").get_anim_player_arr()
		"build":
#			print("get container")
			anim_player_arr = []
		"research":
			anim_player_arr = game.get_node("Container").get_node("TierDeckContainer").get_anim_player_arr()
	return anim_player_arr
