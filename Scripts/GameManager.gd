extends Node

var game

# Variables

var _deck_object = Deck.new()
var deck = _deck_object.deck
var tier_decks = [[], [], []]
var start_card
var revealed_cards = [[], [], []]
var energy_dispenser
var energy_row
var node_energy_row
var players
var player_scene = preload("res://Scenes/Player.tscn")
var player_order = []
var active_player: Player # indicates whose turn it is
var current_state
var end_game = false

var hint_manager = HintManager.new()
# Constants

const MAX_DISPENSER = 13
const MAX_ENERGY_ROW = 6

const ARCHIVE_CARD = 3

# Functions

# Last card from deck is start_card
func set_deck() -> void:
	# TODO: Remove not_implemented once cards are implemented
	var not_implemented = [16, 17, 27, 28, 29, 30]
	if typeof(deck) == TYPE_DICTIONARY:
		var it = 0
		var deck_size = deck.size() - 1
		while it < deck_size:
			var card_json = deck[str(it)]
			var card_tier = card_json['tier']
			if card_json['id'] in not_implemented and card_json['tier'] == 3:
				print("Skip adding this card")
			else:
				tier_decks[card_tier - 1].append(card_json['id'])
			it += 1
		start_card = deck[str(it)]


# Fills all revealed_cards with cards from tier_decks
func fill_all() -> void:
	for i in range (0, 3):
		fill_tier_deck(i, 5 - (i + 1))


# Fills revealed_cards[tier] with count cards
func fill_tier_deck(tier : int, count : int) -> void:
	var size = revealed_cards[tier].size()
	var card = load("res://Scenes/Card.tscn")
	while size < count:
		var rand_card_id = tier_decks[tier][randi() % tier_decks[tier].size()]
		tier_decks[tier].erase(rand_card_id)
		revealed_cards[tier].push_back(rand_card_id)
		rand_card_id = rand_card_id + 36 * tier
		var rand_card = card.instance()
		rand_card.init(deck[str(rand_card_id)])
		rand_card.status = Utils.REVEALED_GIZMO
		game.get_node('Container/GridTier' + str(tier + 1)).add_child(rand_card)
		size += 1


# Removes cards from tier deck. Tier is 0 index based
func remove_tier_cards(tier : int, count: int) -> void:
	# Already removed 6 unimplemented cards. TODO remove if later
	if tier == 2:
		count = 14
	for _el in range (0, count):
		var rand_card_id = tier_decks[tier][randi() % tier_decks[tier].size()]
		tier_decks[tier].erase(rand_card_id)


# Create players_count instances of Player class and adds them to Game scene
# Sets up Player1 as first active player
func instance_players(players_count : int) -> void:
	var card = load("res://Scenes/Card.tscn")
	for _i in range(players_count):
		var new_player = player_scene.instance()
		new_player.name = "Player" + str(_i + 1)
		new_player.nickname = "Player" + str(_i + 1)
		new_player.visible = false
		new_player.board_viewer.init(new_player)
		player_order.append(new_player.get_instance_id())
		game.get_node('Players').add_child(new_player)
		var start_card_instance = card.instance()
		start_card_instance.init(start_card)
		start_card_instance.set_active()
		new_player.card_to_container(start_card_instance)
		new_player.stats['gizmos'].append(start_card_instance.get_deck_id())
		start_card_instance.owner_id = new_player.get_instance_id()
	active_player = game.get_node('Players/Player1')
	active_player.visible = true
	hint_manager.set_all_animation(active_player.get_btn_anim_player_arr(), "Highlight")


# Has to be id from JSON
func give_test_card(id : int, status: int, player : Player) -> void:
	var card = load("res://Scenes/Card.tscn").instance()
	card.init(deck[str(id)])
	card.is_usable = true
	card.status = status
	player.card_to_container(card, true)


func give_test_stats(player : Player, score, gizmos, energy):
	player.stats['vp_tokens'] = score
	for _i in range(0, gizmos):
		player.stats['gizmos'].append(0)
	player.stats['energy'][0] += energy


# Returns array of ScoreEntry nodes sorted so first player is first element
func get_final_scores():
	var score_entries = []
	var score_scene = load("res://Scenes/ScoreEntry.tscn")
	for player in game.get_node('Players').get_children():
		var score_instance = score_scene.instance()
		score_instance.set_info(player)
		score_entries.append(score_instance)
	score_entries.sort_custom(ScoreEntry, "custom_comparison")
	return score_entries


func debug_state(player: Player) -> void:
	for el in range(0, 4):
		player.stats['energy'][el] = 6
#		player.stats['excess_energy'][el] = 1


# Sets used_action to true if action finalized using action button
# Returns true if action was just used. False otherwise
func finished_action() -> bool:
	if active_player.using_action == true:
		GameManager.game.get_node("ActionStatus").text = ""
		current_state = ""
		active_player.using_action = false
		active_player.used_action = true
		active_player.get_node("EndBtn").visible = true
		active_player.get_node("PlayerBoard").toggle_buttons()
		return true
	return false


# Used in end_turn for setting up next active player
func get_next_player() -> String:
	var player_nr = (int(active_player.name) + 1) % (game.players_count + 1)
	if player_nr == 0:
		player_nr += 1
	return "Player" + str(player_nr)


# Used in end_turn for reseting values of used_action and using_action 
# for active_player
func reset_action_status() -> void:
	active_player.used_action = false
	active_player.using_action = false


# Ends turn for active_player and gets next active_player
func end_turn() -> void:
	active_player.visible = false
	reset_action_status()
	active_player.update_energy_counters()
	active_player.get_node("ResearchTab").clear_cards()
	active_player.get_node("ResearchBtn").visible = false
	active_player.get_node("PlayerBoard").toggle_buttons()
	game.get_node("ActionStatus").text = "You must pick an action"
	if GameManager.is_end_game():
		print("Game end flag triggered")
		if active_player.get_instance_id() == player_order[-1]:
			end_screen()
	var next_player = get_next_player()
	active_player = game.get_node('Players/' + next_player)
	active_player.visible = true
	active_player.get_node("PlayerBoard").visible = true
	active_player.get_node("PlayerEnergy").visible = true
	active_player.get_node("PlayerBoard").check_condition_gizmos() # Used for converters
	hint_manager.set_all_animation(active_player.get_btn_anim_player_arr(), "Highlight")
	var turn_indicator = game.get_node("TurnIndicator")
	turn_indicator.update_turn_indicator()
	turn_indicator.update_selected_view(turn_indicator.get_active_player_btn())


# Returns total energy in energy_row
func get_energy_row_count() -> int:
	var sum = 0
	for count in energy_row:
		sum += count
	return sum


# Actually adds energy to energy_dispenser and then restocks energy_row
func add_to_energy_row(energy_arr) -> void:
	for energy_type in range(0, 4):
		var count = energy_arr[energy_type]
		for _i in range (0, count):
			energy_dispenser.append(energy_type)
	restock_energy_row()
	node_energy_row.update_energy_counters(energy_row)


# Initializes energy_dispenser and energy_row
func init_energy_dispenser_row() -> void:
	energy_dispenser = []
	energy_row = [0, 0, 0, 0]
	for _i in range(MAX_DISPENSER):
		energy_dispenser.append(Utils.RED)
		energy_dispenser.append(Utils.YELLOW)
		energy_dispenser.append(Utils.BLUE)
		energy_dispenser.append(Utils.BLACK)
	restock_energy_row()


# Removes energy from energy_dispenser and returns energy
# Return value in range [0, 3]. Check above constants for energy type codes
func rand_from_dispenser():
	var dispenser_size = energy_dispenser.size()
	if dispenser_size == 0:
		print("Dispenser is empty")
		return
	var rand_energy = energy_dispenser[randi() % dispenser_size]
	energy_dispenser.erase(rand_energy)
	return rand_energy


# !Not treating case where dispenser is empty
func restock_energy_row():
	while get_energy_row_count() != MAX_ENERGY_ROW:
		var rand_energy = rand_from_dispenser()
		energy_row[rand_energy] += 1
		node_energy_row.update_energy_counters(energy_row)


# arr HAS TO BE revealed_cards or tier_decks
func remove_card(card : Card, arr):
	var tier = card.card_info['tier'] - 1
	var id = card.card_info['id']
#	print("Before removing card ", arr)
	arr[tier].erase(id)
#	print("After removing card ", arr)


func give_card(card: Card, player: Player):
	var card_parent = card.get_parent()
	card_parent.remove_child(card)
	match current_state:
		"": # Research action
			remove_card(card, tier_decks) 
		_: # Otherwise it was a build/archive action
			remove_card(card, revealed_cards)

	player.update_energy_counters()
	game.get_node("TurnIndicator").update_player_points(player.get_instance_id(), player.get_node("PlayerBoard").get_score())
	fill_all()
	update_tier_decks_counter()


func research(tier : int):
	var card = load("res://Scenes/Card.tscn")
	var research_tab = active_player.get_node("ResearchTab")
	for _i in range(0, active_player.stats['max_research']):
		var rand_card_id = tier_decks[tier][randi() % tier_decks[tier].size()]
		rand_card_id = rand_card_id + 36 * tier
		var rand_card = card.instance()
		rand_card.init(deck[str(rand_card_id)])
		rand_card.status = Utils.RESEARCH_GIZMO
		research_tab.add_card(rand_card)
	if active_player.using_action == true:
		active_player.used_action = true
	research_tab.visible = true


# Gives count random energy from energy_dispenser to active_player
func give_rand_energy(count : int):
	while count > 0:
		if active_player.has_energy_space():
			var energy_type = rand_from_dispenser()
			active_player.stats['energy'][energy_type] += 1
		else:
			active_player.update_energy_counters()
			return
		count -= 1
	active_player.update_energy_counters()


# params HAS TO BE array
# params[0] has value in action_code from Utils script
# params[1] is the amount of free actions player will get
func add_free_action(params):
	var action = Utils.action_code[params[0]]
	active_player.free_action[action] += params[1]
	current_state = action
	var format_string = "%s has %d free %s"
	var status = format_string % [active_player.name, params[1], action]
	game.get_node("ActionStatus").text = status
	hint_manager.action_highlight(action)
#	print(active_player.free_action)


# Remove one free_action of type action from active player
func dec_free_action(action: String) -> void:
	active_player.free_action[action] -= 1
	var counter = active_player.free_action[action]
	var format_string = "%s has %d free %s"
	var status = format_string % [active_player.name, counter, action]
	
	if counter:
		game.get_node("ActionStatus").text = status
	else:
		game.get_node("ActionStatus").text = ""
		current_state = ""


# params HAS TO BE array
# params[0] tier of building (0 index based tier 1 is tier 0)
# params[1] amount of free tier builds
func add_free_tier_build(params):
	current_state = "build"
	active_player.free_action['build_tier'][params[0]] += params[1]
	

# Disable action PERMANENTLY for player
func disable_action(code : int) -> void:
	var action = Utils.action_code[code]
	active_player.disabled_actions[action] = true
	print(active_player.disabled_actions)


# Gives count vp_tokens to active_player
func give_vp_tokens(count : int) -> void:
	active_player.stats['vp_tokens'] += count
	game.get_node("TurnIndicator").update_player_points(active_player.get_instance_id(), \
		active_player.get_node("PlayerBoard").get_score())
	print("From give_vp_tokens ", active_player.stats)


# params HAS TO be an array
func upgrade_capacities(params) -> void:
	active_player.stats['max_energy'] += params[0]
	active_player.stats['max_archive'] += params[1]
	active_player.stats['max_research'] += params[2]
	active_player.get_node("PlayerBoard").update_capacities()


# params HAS TO BE format of [[converting], [result], [amount]]
# Sets convert tab with the appropiate actions
func convert_tab(params) -> void:
	active_player.get_node("ConvertTab").set_converter(params)


# Checks if player has initial type of energy and
# Gives player excess_energy of type result if he does
func convert_energy(initial : int, result : int, amount : int) -> bool:
	if active_player.stats['excess_energy'][initial] > 0:
		active_player.stats['excess_energy'][initial] -= 1
		active_player.stats['excess_energy'][result] += amount
		active_player.update_energy_counters()
		print("Excess energy ", active_player.stats['excess_energy'])
		return true
	elif active_player.stats['energy'][initial] > 0:
		active_player.stats['energy'][initial] -= 1
		active_player.stats['excess_energy'][result] += amount
		active_player.update_energy_counters()
		print("Excess energy ", active_player.stats['excess_energy'])
		return true
	else:
		print(active_player.name + " does not have required energy type")
	return false


# Permanently reduces cost of building gizmos from the archive zone by amount
func reduce_archive_build(amount : int) -> void:
	active_player.build_discount['archive'] += amount


# Permanently reduces cost of building gizmos from the research zone by amount
func reduce_research_build(amount : int) -> void:
	active_player.build_discount['research'] += amount


# Permanently reduces cost of building specific tier gizmos by amount
# params[0] - tier, params[1] - amount
# 0 index based so if params[0] = 1, tier is actually 2
func reduce_tier_build(params) -> void:
	active_player.build_discount['tier'][params[0]] += params[1]


# Sets warning message for active_player
func set_warning(msg : String):
	active_player.get_node("Warning").text = msg
	yield(get_tree().create_timer(0.5), "timeout")
	active_player.get_node("Warning").text = ""


# Checks if a player built their 4th tier3 gizmo or their 16th gizmo
# Returns true if that's the case. False otherwise
func is_end_game() -> bool:
	if (active_player.stats['gizmos'].size() >= Utils.END_TOTAL_GIZMOS
	or active_player.get_node("PlayerBoard").get_tier_gizmos(3) >= Utils.END_TOP_TIER_GIZMOS):
		end_game = true
		print("Triggered end game")
	return end_game


# Updates the counter for each tier deck
func update_tier_decks_counter() -> void:
	var decks = game.get_node("Container/TierDeckContainer")
	
	for tier in range(0, 3):
		var el = decks.get_node("TierDeck" + str(tier + 1)) 
		el.get_node("Label").text = str(tier_decks[tier].size())


# Game has ended. Show final scoreboard
func end_screen() -> void:
	var score_board = load("res://Scenes/EndScoreBoard.tscn").instance()
	var score_nodes = get_final_scores()
	for score in score_nodes:
		score_board.get_node("Table").add_child(score)
	game.add_child(score_board)


func set_status(action):
	game.get_node("ActionStatus").text = active_player.name + " is doing " + action
	current_state = action
	active_player.using_action = true
	hint_manager.action_highlight(action)


func get_revealed_cards():
	var card_arr = []
	var container_arr = game.get_node("Container").get_children()
	for container in container_arr:
		if container.is_in_group("revealed_cards"):
			for card in container.get_children():
				card_arr.append(card)
	return card_arr


func get_cards_anim_player_arr(card_arr):
	var anim_player_arr = []
	for card in card_arr:
		anim_player_arr.append(card.get_anim_player())
	return anim_player_arr


# Returns array of archived cards from player
func get_archived_cards(player: Player):
	var card_arr = []
	var card_container = player.get_node("PlayerBoard").get_archive_container().get_children()
	for card in card_container:
		card_arr.append(card)
	return card_arr


func can_buy_card(player: Player, card: Card):
	var cost = player.apply_discounts(card, card.get_cost())
	var energy_type = card.get_energy_type()
	if player.get_energy_type_count(energy_type) >= cost or \
		player.can_tier_build(card.card_info['tier'] - 1):	
		return true
	return false


func get_affordable_cards(player: Player, card_arr):
	var affordable_cards = []
	for card in card_arr:
		if can_buy_card(player, card):
			affordable_cards.append(card)
	return affordable_cards


func view_player_board(player_id: int):
	for player in game.get_node("Players").get_children():
		if player.get_instance_id() == player_id:
			active_player.board_viewer.change_view(player)
			player.get_node("PlayerEnergy").update_label()
			

func get_player_board(player_id: int):
	for player in game.get_node("Players").get_children():
		if player.get_instance_id() == player_id:
			return player.get_board()


func get_player_energy_row(player_id: int):
	for player in game.get_node("Players").get_children():
		if player.get_instance_id() == player_id:
			return player.get_energy_row()
