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
	if card_info['status'] == GameManager.ACTIVE_GIZMO:
		if card_info['owner_id'] == GameManager.get_own_id():
			Server.send_event(GameManager.CARD_EFFECT, card_info)
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


func set_is_usable(can_use: bool):
	card_info['usable'] = can_use
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


# If active_player meets condition sets condition_met to true, false otherwise
func is_condition_met(player: Player) -> bool:
	var condition_split = string_to_func(card_info['action'])
	if condition_split[1]:
		condition_met = player.call(condition_split[0], condition_split[1])
	else:
		condition_met = player.call(condition_split[0])
	return condition_met


func get_anim_player():
	return $AnimationPlayer


func valid_archive_highlight():
	return GameManager.current_state == "archive" and not card_info.has('owner_id')


func valid_build_highlight():
	return GameManager.current_state == "build" and card_info['status'] != GameManager.ACTIVE_GIZMO


func _on_Card_mouse_entered():
	if valid_archive_highlight() or valid_build_highlight():
		GameManager.hint_manager.set_all_animation([get_anim_player()], "Idle")
		$AnimationPlayer.stop()
		self.modulate = Color(1.4, 1.4, 1.4)


func _on_Card_mouse_exited():
	self.modulate = Color(1, 1, 1)
