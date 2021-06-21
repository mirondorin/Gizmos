extends Node

class_name Player

var stats = {
	"max_energy": 5,
	"max_archive": 1,
	"max_research": 3,
	"energy": [0, 0, 0, 0],
	"excess_energy": [0, 0, 0, 0],
	"archive": [],
	"gizmos": [],
	"vp_tokens": 0
}
var flags = {
	"archived": false,
	"picked": [0, 0, 0, 0],
	"built": [0, 0, 0, 0, 0], # Last element is if built from archive
	"built_tier": [0, 0, 0]
}
var build_discount = {
	"archive" : 0,
	"research" : 0,
	"tier" : [0, 0, 0]
}
var free_action = {
	"archive": 0,
	"pick" : 0,
	"build": 0,
	"research": 0,
	"build_tier": [0, 0, 0]
}
var disabled_actions = {
	"archive": false,
	"research": false
}
var used_action = false
var using_action = false


# Returns total energy of player
func get_energy_count() -> int:
	var sum = 0
	for count in stats['energy']:
		sum += count
#	print(self.name + "'s energy count is ", sum)
	return sum


# Returns true if player has space for energy
# else return false
func has_energy_space():
	if get_energy_count() < stats['max_energy']:
		return true
	return false


func update_energy_counters():
	$PlayerEnergy.update_energy_counters(stats['energy'], stats['excess_energy'])


func get_capacities():
	return [stats['max_energy'], stats['max_archive'], stats['max_research']]


func _on_EndBtn_button_up():
	$EndBtn.visible = false
	reset_active_gizmos()
	reset_flags()
	reset_free_action()
	reset_excess_energy()
	GameManager.end_turn()


func card_to_container(card, id : int):
	get_node("ScrollContainer" + str(id) + "/VBoxContainer").add_child(card)


func _on_ResearchBtn_pressed():
	$ResearchTab.visible = true
	$ResearchBtn.visible = false


func hide_research_tab():
	$ResearchTab.visible = false


# Returns true if player archived gizmo this turn
func has_archived():
	return flags['archived']


# energy_type HAS TO BE an arr. Values of arr in range [0,3].
# Check color codes for energy in Utilty script
func has_picked(energy_type):
	for el in energy_type:
		if flags['picked'][el]:
			return true
	return false


# Checks if player has any of the energy types in energy_arr
# Returns true if he does, false otherwise
func has_energy_type(energy_arr) -> bool:
	for energy_type in energy_arr:
		if energy_type == Utils.WILD_ENERGY:
			return get_energy_count() > 0
		elif stats['energy'][energy_type] or stats['excess_energy'][energy_type]:
			return true
	return false


# build_type HAS TO BE an arr. Values of arr in range [0,4] resemble the code 
# for building color. Refer to Utils script to check color codes
func has_built(build_type):
	for el in build_type:
		if flags['built'][el]:
			return true
	return false
	

# build_tier HAS TO BE an arr. Values of arr in range [0,2] resemble the tier of
# the building. 0 index based so tier 0 is actually tier 1
func has_built_tier(build_tier):
	for el in build_tier:
		if flags['built_tier'][el]:
			return true
	return false


# Makes all active gizmos usable again after player ends his turn
func reset_active_gizmos():
	for _i in range(2, 7):
		var cards = get_node("ScrollContainer" + str(_i) + "/VBoxContainer")
		for card in cards.get_children():
			card.is_usable = true


# Resets all flag values to default
func reset_flags():
	flags['archived'] = false
	for el in range(0, flags['picked'].size()):
		flags['picked'][el] = 0
	for el in range(0, flags['built'].size()):
		flags['built'][el] = 0
	for el in range(0, flags['built_tier'].size()):
		flags['built_tier'][el] = 0
#	print(flags['picked'])
#	print(flags['built'])


# Resets all values from free_action to 0
func reset_free_action():
	for action in free_action:
		if typeof(free_action[action]) == TYPE_INT:
			free_action[action] = 0
		else:
			# Should actually create 0 array of size free_action[action]
			free_action[action] = [0, 0, 0]


# Resets all excess energy to 0
func reset_excess_energy():
	for el in range(0, stats['excess_energy'].size()):
		stats['excess_energy'][el] = 0


# Returns true if player can do action
func can_do(action : String) -> bool:
	if free_action[action] > 0:
		return true
	elif (using_action == true and used_action == false 
	and GameManager.current_state == action):
		return true
	else:
		print(self.name + " can't do " + action)
	return false


# Returns true if player has free_tier build
# 0 index based. Tier 1 is actually tier 0 in free_action
func can_tier_build(tier : int):
	return free_action['build_tier'][tier] > 0
	

# Receives card and returns reduced cost of card depending 
# on player's build_discount and/or card's type
func apply_discounts(card, cost : int):
	var card_tier = card.card_info['tier']
	cost -= build_discount['tier'][card_tier - 1]
	if card.status == Utils.ARCHIVED_GIZMO:
		cost -= build_discount['archive']
	elif card.status == Utils.RESEARCH_GIZMO:
		cost -= build_discount['research']
	if cost > 0:
		return cost
	return 0
