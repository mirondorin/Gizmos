extends Node


# Variables

var game

var _deck_object = Deck.new()
var deck = _deck_object.deck
var tier_decks = [[], [], []]
var revealed_cards = [[], [], []]

var energy_dispenser
var energy_row
var node_energy_row

var players
var ready_players
var player_scene = preload("res://Scenes/Player.tscn")
var player_order = []
var active_player

var current_state
var action_id # Will become the new current_state
var end_game = false

var board_viewer = BoardViewer.new()
var hint_manager = HintManager.new()

# Constants

enum {ARCHIVE, PICK, BUILD, RESEARCH}
enum {ACTIVE_GIZMO, ARCHIVED_GIZMO, RESEARCH_GIZMO, REVEALED_GIZMO}
const MAX_ENERGY_ROW = 6

# Custom signals

signal player_joined
signal players_instanced

# Functions

func _ready():
	self.connect("player_joined", get_tree().get_root().get_node("Lobby"), "_on_player_joined")
	self.connect("players_instanced", self, "_on_players_instanced")


# Create instance for each player and add them to Game scene
func instance_players() -> void:
	yield() # Waiting for player order
	for id in player_order:
		var new_player = player_scene.instance()
		new_player.name = id
		new_player.nickname = players[id]
		new_player.visible = false
		game.get_node('Players').add_child(new_player)
	active_player = game.get_player_node(player_order[0])
	emit_signal("players_instanced")


func set_active_player(s_player_id: String) -> void:
	active_player = game.get_player_node(s_player_id)
	update_turn_indicator()
	
	if s_player_id == get_own_id():
		set_action_status_text("You must pick an action")
		active_player.get_node("PlayerBoard").disable_action_buttons(false)
		hint_manager.set_all_animation(active_player.get_btn_anim_player_arr(), "Highlight")
	else:
		var format_msg = "Waiting for %s to end his turn"
		var actual_msg = format_msg % active_player.nickname
		set_action_status_text(actual_msg)


# Gives start card to client
func give_start_card(s_start_card: Dictionary, s_player_id: String) -> void:
	var start_card = load("res://Scenes/Card.tscn").instance()
	start_card.init(s_start_card)

	var player_node = game.get_player_node(s_player_id)
	player_node.card_to_active_container(start_card)


# Removes card from old parent node and adds it to player board
func give_card(s_card_json: Dictionary, s_prev_card_state: int, s_player_id: String) -> void:
	var player = game.get_player_node(s_player_id)
	var card
	
	match s_prev_card_state:
		REVEALED_GIZMO:
			card = get_revealed_card(s_card_json)
		ARCHIVED_GIZMO:
			card = get_archived_card(s_card_json, s_player_id)

	card.card_info = s_card_json
	var card_parent = card.get_parent()
	card_parent.remove_child(card)
	
	if s_card_json['status'] == ACTIVE_GIZMO:
		player.card_to_active_container(card)
	else:
		player.card_to_archive_container(card)

#	game.get_node("TurnIndicator").update_player_points(player.get_instance_id(), player.get_node("PlayerBoard").get_score())
	Server.fetch_tier_decks_count()


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


# Sets used_action to true if action finalized using action button
# Returns true if action was just used. False otherwise
func finished_action() -> bool:
	if active_player.using_action == true:
		set_action_status_text("")
		current_state = ""
		active_player.using_action = false
		active_player.used_action = true
		active_player.get_node("EndBtn").visible = true
		active_player.get_node("PlayerBoard").toggle_buttons()
		return true
	return false


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
#	var next_player = get_next_player()
#	active_player = game.get_node('Players/' + next_player)
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
func update_tier_decks_counter(tier_decks_count: Array) -> void:
	var deck_container = game.get_node("Container/TierDeckContainer")
	
	for tier in range(0, 3):
		var el = deck_container.get_node("TierDeck" + str(tier + 1)) 
		el.get_node("Label").text = str(tier_decks_count[tier])


# Game has ended. Show final scoreboard
func end_screen() -> void:
	var score_board = load("res://Scenes/EndScoreBoard.tscn").instance()
	var score_nodes = get_final_scores()
	for score in score_nodes:
		score_board.get_node("Table").add_child(score)
	game.add_child(score_board)


func set_status(action: String) -> void:
	var format_message = "You are doing %s"
	var status_message = format_message % action
	set_action_status_text(status_message)
	current_state = action
	active_player.using_action = true
	hint_manager.action_highlight(action)


func get_revealed_card(card_json: Dictionary):
	var revealed_container = game.get_revealed_tier_node(card_json['tier'])
	for card in revealed_container.get_children():
		if card.card_info['id'] == card_json['id']:
			return card


func get_revealed_card_arr():
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


func get_archived_card(card_json: Dictionary, player_id: String):
	var player = game.get_player_node(player_id)
	var card_container = player.get_node("PlayerBoard").get_archive_container().get_children()
	for card in card_container:
		if card.card_info['id'] == card_json['id'] and card.card_info['tier'] == card_json['tier']:
			return card


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


func view_player_board(player_id: String) -> void:
	var player_node = game.get_player_node(player_id)
	board_viewer.change_view(player_node)
	player_node.get_node("PlayerEnergy").update_label()


func get_player_board(player_id: int):
	for player in game.get_node("Players").get_children():
		if player.name == player_id:
			return player.get_board()


func get_player_energy_row(player_id: int):
	for player in game.get_node("Players").get_children():
		if player.get_instance_id() == player_id:
			return player.get_energy_row()


func set_players(s_players) -> void:
	players = s_players
	emit_signal("player_joined")


func set_ready_players(s_ready_players) -> void:
	ready_players = s_ready_players


# Sets turn order for players
func set_player_order(s_player_order: Array):
	var wait_player_order = GameManager.instance_players()
	player_order = s_player_order
	wait_player_order.resume()


func start_game() -> void:
	get_tree().get_root().get_node("Lobby").visible = false
	
	var new_game_scene = load("res://Scenes/Game.tscn")
	game = new_game_scene.instance()
	get_tree().get_root().add_child(game)
	node_energy_row = game.get_node("EnergyRow")
	Server.player_loaded()


func setup_game() -> void:
	Server.fetch_player_order()


func _on_players_instanced() -> void:
	game.set_turn_indicator()
	Server.fetch_start_card()
	board_viewer.init(game.get_player_node(get_own_id()))
	Server.fetch_first_player()


# Update player node with new stats
func player_stats_updated(s_player_id: String, s_player_stats: Dictionary) -> void:
	game.player_stats_updated(s_player_id, s_player_stats)


# Update counters of energy row
func update_energy_row(s_energy_row: Array) -> void:
	node_energy_row.update_energy_counters(s_energy_row)


# Reveals new card to players
func add_revealed_card(s_card_json: Dictionary) -> void:
	var card = load("res://Scenes/Card.tscn")
	var new_card = card.instance()
	new_card.init(s_card_json)
	var revealed_container = game.get_revealed_tier_node(s_card_json['tier'])
	revealed_container.add_child(new_card)


func set_action_id(id: int) -> void:
	action_id = id


func get_own_id() -> String:
	return str(get_tree().get_network_unique_id())


func display_end_btn() -> void:
	var player_container = game.get_player_node(get_own_id())
	player_container.display_end_btn()


func set_action_status_text(s_msg: String) -> void:
	game.set_action_status_text(s_msg)


func update_turn_indicator() -> void:
	game.update_turn_indicator()


# Disable player board after initial action and set state to nothing
func successful_action() -> void:
	GameManager.current_state = ""
	active_player.get_node("PlayerBoard").disable_action_buttons(true)
