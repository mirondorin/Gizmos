extends Node

onready var game = get_node('/root/Game/')
var _deck_object = Deck.new()
var deck = _deck_object.deck

# Called when the node enters the scene tree for the first time.
func _ready():
	fillTierDeck1()
	print(deck)


func fillAll():
	pass


func fillTierDeck1():
	if typeof(deck) == TYPE_DICTIONARY:
		var it = 0
		var deck_size = deck.size()
		while it < deck_size:
			var card_json = deck[str(it)]
			var new_card = Card.new(card_json)
			game.get_node('GridTier1').add_child(new_card)
			deck.erase(str(it))
			it += 1

	
func fillTierDeck2():
	pass
	
	
func fillTierDeck3():
	pass
