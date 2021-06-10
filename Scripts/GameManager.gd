extends Node

onready var game = get_node('/root/Game/')
var _deck_object = Deck.new()
var deck = _deck_object.deck
var tier_decks = [[], [], []]
var revealed_cards = [[], [], []]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_deck()
	fill_all()


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
