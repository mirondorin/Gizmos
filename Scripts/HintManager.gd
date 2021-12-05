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
	prev_anim_players = anim_player_arr


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
			var revealed_cards = GameManager.get_revealed_card_arr()
			anim_player_arr = GameManager.get_cards_anim_player_arr(revealed_cards)
		"pick":
			anim_player_arr = game.get_node("EnergyRow").get_anim_player_arr()
		"build":
			var player = GameManager.active_player
			var revealed_cards = GameManager.get_revealed_card_arr()
			var archived_cards = GameManager.get_archived_cards(player)
			var affordable_cards = GameManager.get_affordable_cards(player, revealed_cards + archived_cards)
			anim_player_arr = GameManager.get_cards_anim_player_arr(affordable_cards)
		"research":
			anim_player_arr = game.get_node("Container").get_node("TierDeckContainer").get_anim_player_arr()
	return anim_player_arr
