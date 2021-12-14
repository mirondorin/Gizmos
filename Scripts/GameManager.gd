extends Node


# Variables

var game

var energy_row
var node_energy_row

var players
var ready_players
var player_scene = preload("res://Scenes/Player.tscn")
var player_order = []
var active_player

var current_state
var action_id # Will become the new current_state

var board_viewer = BoardViewer.new()
var hint_manager = HintManager.new()

# Constants

enum {ARCHIVE, PICK, BUILD, RESEARCH, CARD_EFFECT}
enum {ACTIVE_GIZMO, ARCHIVED_GIZMO, RESEARCH_GIZMO, REVEALED_GIZMO}

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
	active_player.get_node("PlayerBoard").reset_active_gizmos()
	active_player.get_node("PlayerBoard").check_condition_gizmos()
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
			var card_parent = card.get_parent()
			card_parent.remove_child(card)
		ARCHIVED_GIZMO:
			card = get_archived_card(s_card_json, s_player_id)
			var card_parent = card.get_parent()
			card_parent.remove_child(card)
		RESEARCH_GIZMO:
			card = get_research_card(s_card_json)
			if s_player_id == get_own_id():
				player.get_node("ResearchTab").clear_cards()

	card.card_info = s_card_json
	
	if s_card_json['status'] == ACTIVE_GIZMO:
		player.card_to_active_container(card)
	else:
		player.card_to_archive_container(card)

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


func research(s_research_cards: Array):
	var card = load("res://Scenes/Card.tscn")
	var player_node = game.get_player_node(get_own_id())
	var research_tab = player_node.get_node("ResearchTab")
	research_tab.visible = true
	
	for card_json in s_research_cards:
		var rand_card = card.instance()
		rand_card.init(card_json)
		research_tab.add_card(rand_card)


func get_research_card(card_json: Dictionary):
	var card = load("res://Scenes/Card.tscn").instance()
	card.init(card_json)
	card.action_container.visible = false
	return card


# params HAS TO BE format of [[converting], [result], [amount]]
# Sets convert tab with the appropiate actions
func set_converter_tab(s_convert_arr: Array) -> void:
	active_player.get_node("ConvertTab").set_converter(s_convert_arr)


func set_converter_card_face(s_card_json: Dictionary) -> void:
	var card_face = load("res://Assets/Set"+str(s_card_json['tier'])+"/card"+str(s_card_json['id'])+".png")
	active_player.get_node("ConvertTab").set_gizmo_preview(card_face)


# Sets warning message
func set_warning(s_msg: String):
	var warning_label = game.get_node("WarningStatus")
	warning_label.text = s_msg
	yield(get_tree().create_timer(0.5), "timeout")
	warning_label.text = ""


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


func set_status(action: String, s_action_id: int) -> void:
	var format_message = "You are doing %s"
	var status_message = format_message % action
	set_action_status_text(status_message)
	set_action_id(s_action_id)

	current_state = action
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


func player_flags_updated(s_player_id: String, s_player_flags: Dictionary):
	game.player_flags_updated(s_player_id, s_player_flags)


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
