extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp
var status # Will use for active, archived, in research tab, or revealed gizmo
var is_usable
var face
var back
var action_container
var is_used_container
var condition_met
var condition_met_sign
# Constants

const ARCHIVE_ZONE = 7

# Functions

func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
#	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)
	init_card_actions_container()
	init_used_indicator()
	init_condition_indicator()
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


# Set's card as unusable and makes it grayed out
func set_is_usable(can_use : bool):
	is_usable = can_use
	is_used_container.visible = !can_use


func init_card_actions_container():
	var actions_scene = load("res://Scenes/CardActions.tscn")
	action_container = actions_scene.instance()
	action_container.visible = false
	action_container.rect_size.x = self.rect_size.x
	action_container.rect_size.y = self.rect_size.y
	self.add_child(action_container)
	

func init_used_indicator():
	is_used_container = ColorRect.new()
	is_used_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_used_container.rect_size.x = face.get_size()[0]
	is_used_container.rect_size.y = face.get_size()[1]
	is_used_container.color = Color("82000000") # Gray background
	is_used_container.visible = false
	self.add_child(is_used_container)


func init_condition_indicator():
	var texture = load("res://Assets/Ok.png")
	condition_met_sign = TextureRect.new()
	condition_met_sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	condition_met_sign.texture = texture
	condition_met_sign.visible = false
	self.add_child(condition_met_sign)
	condition_met_sign.anchor_left = 1
	condition_met_sign.anchor_right = 1
	condition_met_sign.anchor_top = 1
	condition_met_sign.anchor_bottom = 1
	condition_met_sign.margin_left = -62 # texture's width
	condition_met_sign.margin_top = -62 # texture's width
	

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
				player.check_condition_gizmos()
				return true
			else:
				GameManager.set_warning("You do not have enough archive space")
				print(player.name + " has no more archive space")
	else:
		GameManager.set_warning("You can't archive")
	return false


# Need exception for cards with cost [7, 7, 7, 7]
# Returns true if build was succesful, false otherwise
# TODO code refactoring IS NECESSARY. DUPLICATE CODE
func build(player : Player) -> bool:
	if (status == Utils.RESEARCH_GIZMO or player.can_do('build')
	or player.can_tier_build(card_info['tier'] - 1)):
		for energy_type in range (0, 4):
			var cost = card_info['cost'][energy_type]
			if cost:
				cost = player.apply_discounts(self, cost)
				
				if player.can_tier_build(card_info['tier'] - 1) and status != Utils.RESEARCH_GIZMO:
					print("BUILT WITH FREE TIER BUILD")
					if status == Utils.ARCHIVED_GIZMO:
						player.flags['built'][Utils.ARCHIVE_BUILT] = 1
						player.stats['archive'].erase(get_deck_id())
					player.stats['gizmos'].append(get_deck_id())
					player.flags['built'][energy_type] = 1
					player.flags['built_tier'][card_info['tier'] - 1] = 1
					player.free_action['build_tier'][card_info['tier'] - 1] -= 1
					
					GameManager.give_card(self, player, card_info['type_id'])

					status = Utils.ACTIVE_GIZMO
					is_usable = true
					action_container.visible = false
					
					if is_passive():
						var effect_split = string_to_func(card_info['effect'])
						if effect_split[1] != null:
							GameManager.call(effect_split[0], effect_split[1])
						else:
							GameManager.call(effect_split[0])
					
					player.check_condition_gizmos()
					GameManager.game.get_node("ActionStatus").text = ""
					return true
					
				elif (player.stats['energy'][energy_type] 
				+ player.stats['excess_energy'][energy_type] >= cost):			
					while player.stats['excess_energy'][energy_type] > 0 and cost > 0:
						player.stats['excess_energy'][energy_type] -= 1
						cost -= 1
					player.stats['energy'][energy_type] -= cost
					var paid = [0, 0, 0, 0]
					paid[energy_type] += cost
					
					if status == Utils.ARCHIVED_GIZMO:
						player.flags['built'][Utils.ARCHIVE_BUILT] = 1
						player.stats['archive'].erase(get_deck_id())
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
							
					player.check_condition_gizmos()
					return true
				else:
					GameManager.set_warning("You do not have enough energy")
					print(player.name + " does not have enough energy")
	else:
		GameManager.set_warning("You can't build")
	return false


# If active_player meets condition sets condition_met to true, false otherwise
func is_condition_met(player : Player) -> bool:
	var condition_split = string_to_func(card_info['action'])
	if condition_split[1]:
		condition_met = player.call(condition_split[0], condition_split[1])
	else:
		condition_met = player.call(condition_split[0])
	return condition_met


# If card is usable and player meets card's conditions then use effect
func use_effect():
	if is_usable:
		if is_condition_met(GameManager.active_player):
			var effect_split = card_info['effect'].split('(')
			var effect_func = effect_split[0]
			var effect_params = effect_split[1].split(')')[0]
			
			if effect_params.is_valid_integer():
				effect_params = int(effect_params)
				print("Cast effect_params to int")
			else:
				print("Cast effect_params to vector")
				effect_params = str2var(effect_params)
#			print(effect_func)
#			print(effect_params)
			if card_info['type_id'] == 2: # if is converter card
				GameManager.active_player.get_node("ConvertTab").set_gizmo_preview(face)
			GameManager.call(effect_func, effect_params)
			set_is_usable(false)
			condition_met_sign.visible = false
		else:
			GameManager.set_warning("Condition for gizmo was not met")
			print("Condition for effect was not met")
	else:
		GameManager.set_warning("Gizmo was already used this turn")
		print("Gizmo was already used")
