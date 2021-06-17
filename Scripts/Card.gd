extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp
var is_active
var is_usable
var face
var back
var action_container

# Constants

const ARCHIVE_ZONE = 7

# Functions

func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
#	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)
	init_card_actions_container()
	is_active = false
	is_usable = false


func _pressed():
	var action = GameManager.current_state
	get_card_info()
	if is_active:
		use_effect()
	else:
		match action:
			"archive":
				archive(GameManager.active_player)
			"build":
				build(GameManager.active_player)
			"research":
				action_container.visible = true


func set_active():
	is_active = true
	is_usable = true


func init_card_actions_container():
	var actions_scene = load("res://Scenes/CardActions.tscn")
	action_container = actions_scene.instance()
	action_container.visible = false
	self.add_child(action_container)
	action_container.rect_size.x = self.rect_size.x
	action_container.rect_size.y = self.rect_size.y
	

func get_card_info():
	print(card_info)
#	print("Usable, active ", is_usable, is_active)
#	var split = card_info['effect'].split('(')
#	var effect_func = split[0]
#	var params = split[1].split(')')[0]


func get_deck_id():
	return card_info['id'] + 36 * (card_info['tier'] - 1)


# Returns true if archive was succesful, false otherwise
func archive(player : Player) -> bool:
	if player.can_do('archive'):
		if player.stats['archive'].size() < player.stats['max_archive']:
			GameManager.give_card(self, player, ARCHIVE_ZONE)
			player.stats['archive'].append(get_deck_id())
			action_container.visible = false
			player.flags['archived'] = true
			return true
		else:
			print(player.name + " has no more archive space")
	return false


# Need exception for cards with cost [7, 7, 7, 7]
# Returns true if build was succesful, false otherwise
func build(player : Player) -> bool:
	if player.can_do('build'):
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


# TODO move the condition met steps into separate function maybe?
func use_effect():
	if is_usable:
		var condition_split = card_info['action'].split('(')
		var condition_func = condition_split[0]
		var condition_params = condition_split[1].split(')')[0]
		condition_params = str2var(condition_params)
		var condition_met
		if condition_params:
			condition_met = GameManager.active_player.call(condition_func, condition_params)
		else:
			condition_met = GameManager.active_player.call(condition_func)
			
		if condition_met:
			var effect_split = card_info['effect'].split('(')
			var effect_func = effect_split[0]
			var effect_params = effect_split[1].split(')')[0]
			
			if effect_params.is_valid_integer():
				effect_params = int(effect_params)
				print("Cast effect_params to int")
			else:
				print("Cast effect_params vector")
				effect_params = str2var(effect_params)
#			print(effect_func)
#			print(effect_params)
			GameManager.call(effect_func, effect_params)
			is_usable = false
		else:
			print("Condition for effect was not met")
	else:
		print("Gizmo was already used")
