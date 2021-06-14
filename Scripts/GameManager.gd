extends Node

onready var game = get_node('/root/Game/')

# Variables

var _deck_object = Deck.new()
var deck = _deck_object.deck
var tier_decks = [[], [], []]
var revealed_cards = [[], [], []]
var energy_dispenser
var energy_row
var node_energy_row
var player_scene = preload("res://Scenes/Player.tscn")
var players_count = 2
var active_player # indicates whose turn it is
var current_state

# Constants

# Energy type codes
const RED = 0
const YELLOW = 1
const BLUE = 2
const BLACK = 3

const MAX_DISPENSER = 13
const MAX_ENERGY_ROW = 6

# Functions

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_deck()
	fill_all()
	instance_players()
	node_energy_row = game.get_node("EnergyRow")
	init_energy_dispenser_row()


# TODO: Remove some cards from tier3 at the beginning of game
func set_deck():
	if typeof(deck) == TYPE_DICTIONARY:
		var it = 0
		var deck_size = deck.size()
		while it < deck_size:
			var card_json = deck[str(it)]
			var card_tier = card_json['tier']
			tier_decks[card_tier - 1].append(card_json['id'])
			it += 1


# Fills all tier decks with cards from tier_decks
func fill_all():
	for i in range (0, 3):
		fill_tier_deck(i, 5 - (i + 1))


func fill_tier_deck(tier : int, count : int):
	var size = revealed_cards[tier].size()
	while size < count:
		var rand_card_id = tier_decks[tier][randi() % tier_decks[tier].size()]
		tier_decks[tier].erase(rand_card_id)
		revealed_cards[tier].push_back(rand_card_id)
		rand_card_id = rand_card_id + 36 * tier
		var rand_card = Card.new(deck[str(rand_card_id)])
		game.get_node('GridTier' + str(tier + 1)).add_child(rand_card)
		size += 1


func get_all_nodes(node):
	for N in node.get_children():
		if N.get_child_count() > 0:
			print("["+N.get_name()+"]")
			get_all_nodes(N)
		else:
			# Do something
			print("- "+N.get_name())


func instance_players():
	for _i in range(players_count):
		var new_player = player_scene.instance()
		new_player.name = "Player" + str(_i + 1)
		new_player.visible = false
		game.get_node('Players').add_child(new_player)
	active_player = game.get_node('Players/Player1')
	active_player.visible = true


# Sets used_action to true if action finalized using action button
func finished_action():
	if active_player.using_action == true:
		current_state = "nothing"
		active_player.using_action = false
		active_player.used_action = true
		active_player.get_node("EndBtn").visible = true

func get_energy_row_count():
	var sum = 0
	for count in energy_row:
		sum += count
	return sum


func add_to_energy_row(energy_arr):
	for energy_type in range(0, 4):
		var count = energy_arr[energy_type]
		for _i in range (0, count):
			energy_dispenser.append(energy_type)
	restock_energy_row()
	node_energy_row.update_energy_counters(energy_row)


func init_energy_dispenser_row():
	energy_dispenser = []
	energy_row = [0, 0, 0, 0]
	for _i in range(MAX_DISPENSER):
		energy_dispenser.append(RED)
		energy_dispenser.append(YELLOW)
		energy_dispenser.append(BLUE)
		energy_dispenser.append(BLACK)
	restock_energy_row()


func rand_from_dispenser():
	var dispenser_size = energy_dispenser.size()
	if dispenser_size == 0:
		print("Dispenser is empty")
		return
	var rand_energy = energy_dispenser[randi() % dispenser_size]
	energy_dispenser.erase(rand_energy)
	node_energy_row.update_energy_counters(energy_row)
	return rand_energy


# !Not treating case where dispenser is empty
func restock_energy_row():
	while get_energy_row_count() != MAX_ENERGY_ROW:
		var rand_energy = rand_from_dispenser()
		energy_row[rand_energy] += 1
		node_energy_row.update_energy_counters(energy_row)


func reset_action_status(player : Player):
	player.used_action = false
	player.using_action = false


func get_next_player():
	var player_nr = (int(active_player.name) + 1) % (players_count + 1)
	if player_nr == 0:
		player_nr += 1
	return "Player" + str(player_nr)


func end_turn():
	active_player.visible = false
	reset_action_status(active_player)
	var next_player = get_next_player()
	active_player = game.get_node('Players/' + next_player)
	active_player.visible = true


func remove_revealed_card(card : Card):
	var tier = card.card_info['tier'] - 1
	var id = card.card_info['id']
	revealed_cards[tier].erase(id)
	print("After removing card ", revealed_cards)

# Could add some flags to know what color the building was
# TODO add energy back to dispenser
func player_built():
	active_player.update_energy_counters()
	

func give_card(card : Card, player : Player, type : int):
	var card_parent = card.get_parent()
	card_parent.remove_child(card)
	remove_revealed_card(card)
	player.card_to_container(card, type)
	fill_all()
	
	if current_state == 'build':
		player_built()
	
	if player.using_action == true:
		finished_action()
	
