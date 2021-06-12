extends Node

onready var game = get_node('/root/Game/')

# Variables

var _deck_object = Deck.new()
var deck = _deck_object.deck
var tier_decks = [[], [], []]
var revealed_cards = [[], [], []]
var energy_dispenser# 13 for each energy type
var energy_row # 6 energy always available 
var node_energy_row
var players
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
	set_deck()
	fill_all()
	active_player = game.get_node("Player1")
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
	randomize()
	for i in range (0, 3):
		fill_tier_deck(i, 5 - (i + 1))


func fill_tier_deck(tier : int, count : int):
	var size = revealed_cards[tier].size()
	while size < count:
		var rand_card_id = tier_decks[tier][randi() % tier_decks[tier].size()]
		tier_decks[tier].erase(rand_card_id)
		rand_card_id = rand_card_id + 36 * tier
		var rand_card = Card.new(deck[str(rand_card_id)])
		game.get_node('GridTier' + str(tier + 1)).add_child(rand_card)
		revealed_cards[tier].push_back(rand_card_id)
		size += 1


func get_energy_row_count():
	var sum = 0
	for count in energy_row:
		sum += count
	return sum


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
