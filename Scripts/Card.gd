extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp
var is_usable
var face
var back

# Constants

const ARCHIVE = 7

# Functions

func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)


func _pressed():
	get_card_info()
	var action = GameManager.current_state
	match action:
		"archive":
			archive(GameManager.active_player)
		"build":
			build(GameManager.active_player)


func get_card_info():
	print(card_info)


func get_deck_id():
	return card_info['id'] + 36 * card_info['tier']

func archive(player : Player):
	if GameManager.active_player.used_action == false:
		if player.stats['archive'].size() < player.stats['max_archive']:
			GameManager.give_card(self, player, ARCHIVE)
			player.stats['archive'].append(get_deck_id())
		else:
			print(player.name + " has no more archive space")
	else:
		print("Player already used action")

# Need exception for cards with cost [7, 7, 7, 7]
func build(player : Player):
	if GameManager.active_player.used_action == false:
		for energy_type in range (0, 4):
			var cost = card_info['cost'][energy_type]
			if cost:
				if player.stats['energy'][energy_type] >= cost:
					player.stats['energy'][energy_type] -= cost
					player.stats['gizmos'].append(get_deck_id())
					GameManager.give_card(self, player, card_info['type_id'])
					GameManager.add_to_energy_row(card_info['cost'])
				else:
					print(player.name + " does not have enough energy")
	else:
		print("Player already used action")
