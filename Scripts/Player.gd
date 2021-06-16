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
	"archived": false
}
var used_action = false
var using_action = false


# Returns energy total of player
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
	GameManager.end_turn()


func card_to_container(card, id : int):
	get_node("ScrollContainer" + str(id) + "/VBoxContainer").add_child(card)


func _on_ResearchBtn_pressed():
	$ResearchTab.visible = true
	$ResearchBtn.visible = false


func hide_research_tab():
	$ResearchTab.visible = false


# Sets a flag's value
func set_flag(condition : String, value):
	flags[condition] = value


func has_archived():
	return flags['archived']


# Makes all active gizmos usable again after player ends his turn
func reset_active_gizmos():
	for _i in range(2, 7):
		var cards = get_node("ScrollContainer" + str(_i) + "/VBoxContainer")
		for card in cards.get_children():
			card.is_usable = true


func reset_flags():
	flags['archived'] = false
