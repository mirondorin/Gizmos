extends Node

class_name Player

var stats = {
	"max_energy": 5,
	"max_archive": 1,
	"max_research": 3,
	"energy": [0, 0, 0, 0],
	"archive": [],
	"gizmos": []
}
var flags = {
	"archived": false,
	"picked": [0, 0, 0, 0],
	"built": [0, 0, 0, 0, 0] # Last element is if built from archive
}
var free_action = {
	"archive": 0,
	"pick" : 0,
	"build": 0,
	"research": 0
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
	$PlayerEnergy.update_energy_counters(stats['energy'])


func _on_EndBtn_button_up():
	$EndBtn.visible = false
	reset_active_gizmos()
	reset_flags()
	reset_free_action()
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
	print(flags['picked'])
	print(flags['built'])


# Resets all values from free_action to 0
func reset_free_action():
	for action in free_action:
		free_action[action] = 0


# Returns true if player can do action
func can_do(action : String) -> bool:
	if used_action == false and GameManager.current_state == action \
		or free_action[action] > 0:
			return true
	else:
		print(self.name + " can't do " + action)
	return false
