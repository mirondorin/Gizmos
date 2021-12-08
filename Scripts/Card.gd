extends TextureButton

class_name Card

# Variables

var card_info = {} # id, tier, cost, action, effect, type_id, vp, owner_id, status, usable
var face
var back
var action_container
var is_used_container
var condition_met

# Constants

enum {
	UPGRADE = 1,
	CONVERT = 2,
	ARCHIVE = 3,
	PICK = 4,
	BUILD = 5,
	RESEARCH = 6
}

# Functions

func init(card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
#	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)
	init_card_actions_container()
	init_used_indicator()


func _pressed():
	if card_info['status'] == GameManager.ACTIVE_GIZMO and !is_passive():
		if card_info['owner_id'] == GameManager.get_own_id():
			use_effect()
		else:
			GameManager.set_warning("This is another player's card")
	elif card_info['status'] == GameManager.RESEARCH_GIZMO:
		action_container.visible = true
	else:
		match GameManager.current_state:
			"archive":
				Server.send_event(GameManager.ARCHIVE, card_info)
			"build":
				Server.send_event(GameManager.BUILD, card_info)


func set_is_usable(can_use : bool):
	is_used_container.visible = !can_use


func set_condition_sign(visible: bool):
	$Checkmark.visible = visible


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


func get_card_info():
	print(card_info)


func get_deck_id() -> int:
	return card_info['id'] + 36 * (card_info['tier'] - 1)


func get_energy_type():
	for energy_type in range(0, 4):
		if card_info['cost'][energy_type]:
			return energy_type


func get_cost():
	for cost in card_info['cost']:
		if cost:
			return cost


# Used to call effect function ONLY once when built
func is_passive() -> bool:
	return card_info['type_id'] == UPGRADE


func string_to_func(func_string : String):
	var func_split = func_string.split('(')
	var func_name = func_split[0]
	var func_params = func_split[1].split(')')[0]
	func_params = str2var(func_params)
	return [func_name, func_params]


# Need exception for cards with cost [7, 7, 7, 7]
# Returns true if build was succesful, false otherwise
# TODO code refactoring IS NECESSARY. DUPLICATE CODE
#func build(player : Player) -> bool:
#	if player.can_tier_build(card_info['tier'] - 1) and status != Utils.RESEARCH_GIZMO:
#		if status == Utils.ARCHIVED_GIZMO:
#			built_from_archive(player)
#		player.stats['gizmos'].append(get_deck_id())
#		set_built_flags(player)
#		player.free_action['build_tier'][card_info['tier'] - 1] -= 1
#
#		GameManager.give_card(self, player)
#
#		status = Utils.ACTIVE_GIZMO
#		is_usable = true
#		action_container.visible = false
#
#		if is_passive():
#			var effect_split = string_to_func(card_info['effect'])
#			if effect_split[1] != null:
#				GameManager.call(effect_split[0], effect_split[1])
#			else:
#				GameManager.call(effect_split[0])
#
#		player.get_node("PlayerBoard").check_condition_gizmos()
#		player.card_to_container(self)
#		owner_id = player.get_instance_id()
#		GameManager.game.get_node("ActionStatus").text = ""
#		GameManager.hint_manager.set_animation(get_anim_player(), "Idle")
#		return true
#
#	elif status == Utils.RESEARCH_GIZMO or player.can_do('build'):
#		var energy_type = get_energy_type()
#		var cost = get_cost()
#		cost = player.apply_discounts(self, cost)
#		if (player.stats['energy'][energy_type] 
#		+ player.stats['excess_energy'][energy_type] >= cost):			
#			while player.stats['excess_energy'][energy_type] > 0 and cost > 0:
#				player.stats['excess_energy'][energy_type] -= 1
#				cost -= 1
#			player.stats['energy'][energy_type] -= cost
#			var paid = [0, 0, 0, 0]
#			paid[energy_type] += cost
#
#			if status == Utils.ARCHIVED_GIZMO:
#				built_from_archive(player)
#			player.stats['gizmos'].append(get_deck_id())
#			set_built_flags(player)
#
#			GameManager.give_card(self, player)
#			GameManager.add_to_energy_row(paid)
#
#			if (status != Utils.RESEARCH_GIZMO 
#			and GameManager.finished_action() == false):
#				print("Removed free build action")
#				GameManager.dec_free_action('build')
#
#			status = Utils.ACTIVE_GIZMO
#			is_usable = true
#			action_container.visible = false
#
#			if is_passive():
#				var effect_split = string_to_func(card_info['effect'])
#				if effect_split[1] != null:
#					GameManager.call(effect_split[0], effect_split[1])
#				else:
#					GameManager.call(effect_split[0])
#
#			player.get_node("PlayerBoard").check_condition_gizmos()
#			player.card_to_container(self)
#			owner_id = player.get_instance_id()
#			GameManager.hint_manager.set_animation(get_anim_player(), "Idle")
#			return true
#		else:
#			GameManager.set_warning("You do not have enough energy")
#	else:
#		GameManager.set_warning("You can't build")
#	return false


func built_from_archive(player: Player):
	player.flags['built'][Utils.ARCHIVE_BUILT] = 1
	player.stats['archive'].erase(get_deck_id())


func set_built_flags(player: Player):
	var energy_type = get_energy_type()
	player.flags['built'][energy_type] = 1
	player.flags['built_tier'][card_info['tier'] - 1] = 1


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
	if card_info['usable']:
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
			if card_info['type_id'] == CONVERT:
				GameManager.active_player.get_node("ConvertTab").set_gizmo_preview(face)
			GameManager.call(effect_func, effect_params)
			set_is_usable(false)
			set_condition_sign(false)
		else:
			GameManager.set_warning("Condition for gizmo was not met")
	else:
		GameManager.set_warning("Gizmo was already used this turn")


func get_anim_player():
	return $AnimationPlayer


func _on_Card_mouse_entered():
	if GameManager.current_state == "archive" or GameManager.current_state == "build":
		GameManager.hint_manager.set_all_animation([get_anim_player()], "Idle")
		$AnimationPlayer.stop()
		self.modulate = Color(1.4, 1.4, 1.4)


func _on_Card_mouse_exited():
	self.modulate = Color(1, 1, 1)
