extends Node

var stats = {
	"max_energy": 5,
	"max_archive": 1,
	"max_research": 3,
	"energy": [0, 0, 0, 0],
	"archive": [],
	"gizmos": []
}
var used_action = false

func get_energy_count():
	var sum = 0
	for count in stats['energy']:
		sum += count
	print(self.name + "'s energy count is ", sum)
	return sum