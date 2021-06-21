extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp
var status # Will use for active, archived, in research tab, or revealed gizmo
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
	is_usable = false


func _pressed():
	var action = GameManager.current_state
	get_card_info()
	if status == Utils.ACTIVE_GIZMO:
		if !is_passive():
			use_effect()
	elif status == Utils.RESEARCH_GIZMO:
		action_container.visible = true
	else:
		match action:
			"archive":
				archive(GameManager.active_player)
			"build":
				build(GameManager.active_player)



func set_active():
	status = Utils.ACTIVE_GIZMO
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


func get_deck_id() -> int:
	return card_info['id'] + 36 * (card_info['tier'] - 1)


# Used to call effect function ONLY once when built
func is_passive() -> bool:
	return card_info['type_id'] == 1


func string_to_func(func_string : String):
	var func_split = func_string.split('(')
	var func_name = func_split[0]
	var func_params = func_split[1].split(')')[0]
	func_params = str2var(func_params)
	return [func_name, func_params]


# Returns true if archive was succesful, false otherwise
func archive(player : Player) -> bool:
	if (!player.disabled_actions['archive'] and status != Utils.ARCHIVED_GIZMO and 
		(status == Utils.RESEARCH_GIZMO or player.can_do('archive'))):
			if player.stats['archive'].size() < player.stats['max_archive']:
				GameManager.give_card(self, player, ARCHIVE_ZONE)
				GameManager.current_state = "nothing"
				
				player.stats['archive'].append(get_deck_id())
				action_container.visible = false
				player.flags['archived'] = true
				
				if status != Utils.RESEARCH_GIZMO and GameManager.finished_action() == false:
					print("Removed free archive action")
					GameManager.dec_free_action('archive')
					
				status = Utils.ARCHIVED_GIZMO
				return true
			else:
				print(player.name + " has no more archive space")
	return false


# Need exception for cards with cost [7, 7, 7, 7]
# Returns true if build was succesful, false otherwise
func build(player : Player) -> bool:
	if status == Utils.RESEARCH_GIZMO or player.can_do('build'):
		for energy_type in range (0, 4):
			var cost = card_info['cost'][energy_type]
			if cost:
				cost = player.apply_discounts(self, cost)
				
				if (player.stats['energy'][energy_type] 
				+ player.stats['excess_energy'][energy_type] >= cost):
					if status == Utils.ARCHIVED_GIZMO:
						player.flags['built'][Utils.ARCHIVE_BUILT] = 1
						player.stats['archive'].erase(get_deck_id())
						
					while player.stats['excess_energy'][energy_type] > 0 and cost > 0:
						player.stats['excess_energy'][energy_type] -= 1
						cost -= 1
					player.stats['energy'][energy_type] -= cost
					var paid = [0, 0, 0, 0]
					paid[energy_type] += cost
					
					player.stats['gizmos'].append(get_deck_id())
					player.flags['built'][energy_type] = 1
					player.flags['built_tier'][card_info['tier'] - 1] = 1
					
					GameManager.give_card(self, player, card_info['type_id'])
					GameManager.add_to_energy_row(paid)
					
					if (status != Utils.RESEARCH_GIZMO 
					and GameManager.finished_action() == false):
						print("Removed free build action")
						GameManager.dec_free_action('build')
					
					status = Utils.ACTIVE_GIZMO
					is_usable = true
					action_container.visible = false
					
					if is_passive():
						var effect_split = string_to_func(card_info['effect'])
						if effect_split[1] != null:
							GameManager.call(effect_split[0], effect_split[1])
						else:
							GameManager.call(effect_split[0])
					return true
				else:
					print(player.name + " does not have enough energy")
	return false


# TODO move the condition met steps into separate function maybe?
func use_effect():
	if is_usable:
		var condition_split = string_to_func(card_info['action'])
		var condition_met
		if condition_split[1]:
			condition_met = GameManager.active_player.call(condition_split[0], condition_split[1])
		else:
			condition_met = GameManager.active_player.call(condition_split[0])
			
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
			if card_info['type_id'] == 2:
				GameManager.active_player.get_node("ConvertTab").set_gizmo_preview(face)
			GameManager.call(effect_func, effect_params)
			is_usable = false
		else:
			print("Condition for effect was not met")
	else:
		print("Gizmo was already used")
