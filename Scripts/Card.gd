extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp
var is_usable
var face
var back
var action_container

# Constants

const ARCHIVE = 7

# Functions

func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)
	init_card_actions_container()


func _pressed():
	get_card_info()
	var action = GameManager.current_state
	match action:
		"archive":
			archive(GameManager.active_player)
		"build":
			build(GameManager.active_player)
		"research":
			action_container.visible = true


func init_card_actions_container():
	var actions_scene = load("res://Scenes/CardActions.tscn")
	action_container = actions_scene.instance()
	action_container.visible = false
	self.add_child(action_container)
	action_container.rect_size.x = self.rect_size.x
	action_container.rect_size.y = self.rect_size.y
	

func get_card_info():
	print(card_info)


func get_deck_id():
	return card_info['id'] + 36 * (card_info['tier'] - 1)


# Returns true if archive was succesful, false otherwise
func archive(player : Player) -> bool:
	if GameManager.active_player.used_action == false:
		if player.stats['archive'].size() < player.stats['max_archive']:
			GameManager.give_card(self, player, ARCHIVE)
			player.stats['archive'].append(get_deck_id())
			action_container.visible = false
			return true
		else:
			print(player.name + " has no more archive space")
			return false
	else:
		print("Player already used action")
		return false


# Need exception for cards with cost [7, 7, 7, 7]
# Returns true if build was succesful, false otherwise
func build(player : Player) -> bool:
	if GameManager.active_player.used_action == false:
		for energy_type in range (0, 4):
			var cost = card_info['cost'][energy_type]
			if cost:
				if player.stats['energy'][energy_type] >= cost:
					player.stats['energy'][energy_type] -= cost
					player.stats['gizmos'].append(get_deck_id())
					GameManager.give_card(self, player, card_info['type_id'])
					GameManager.add_to_energy_row(card_info['cost'])
					action_container.visible = false
					return true
				else:
					print(player.name + " does not have enough energy")
		return false
	else:
		print("Player already used action")
		return false
