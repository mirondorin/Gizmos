extends Control


var players_count

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GameManager.game = self
	GameManager.set_deck()
	GameManager.fill_all()
	GameManager.remove_tier_cards(2, 20) # Randomly remove 20 cards from tier 3
	GameManager.update_tier_decks_counter()
	GameManager.instance_players(players_count)
	get_node("TurnIndicator").init_turn_indicator(get_node("Players"))
	GameManager.node_energy_row = get_node("EnergyRow")
	GameManager.init_energy_dispenser_row()
