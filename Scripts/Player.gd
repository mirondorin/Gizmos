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
var used_action = false
var using_action = false

func get_energy_count():
	var sum = 0
	for count in stats['energy']:
		sum += count
	print(self.name + "'s energy count is ", sum)
	return sum


func update_energy_counters():
	$PlayerEnergy.update_energy_counters(stats['energy'])


func _on_EndBtn_button_up():
	$EndBtn.visible = false
	GameManager.end_turn()


func card_to_container(card, id : int):
	get_node("ScrollContainer" + str(id) + "/VBoxContainer").add_child(card)
