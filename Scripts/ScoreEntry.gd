extends MarginContainer


class_name ScoreEntry

var player_name
var points 
var active_gizmos
var energy


# Sets player info for final scores
func set_info(player: Player):
	player_name = player.nickname
	points = player.get_node("PlayerBoard").get_score()
	active_gizmos = player.stats['gizmos'].size()
	energy = player.get_energy_count()
	set_labels()


func set_labels():
	$PlayerStats/Name.text = player_name
	$PlayerStats/VP.text = str(points)
	$PlayerStats/Gizmos.text = str(active_gizmos)
	$PlayerStats/Energy.text = str(energy)


# Sort based on points, active gizmos and total energy
static func custom_comparison(left, right):
	if left.points > right.points:
		return true
	elif left.points == right.points:
		if left.active_gizmos > right.active_gizmos:
			return true
		elif left.active_gizmos == right.active_gizmos:
			if left.energy > right.energy:
				return true
	return false
