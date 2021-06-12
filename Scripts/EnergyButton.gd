extends TextureButton

export(int) var type

func _on_Control_pressed():
	if GameManager.current_state == 'pick':
		give_energy(GameManager.active_player, type)


func give_energy(player : Player, energy_type : int):
	if GameManager.energy_row[energy_type] > 0:
		if player.get_energy_count() < player.stats['max_energy']:
			player.stats['energy'][energy_type] += 1
			player.update_energy_counters()
			GameManager.energy_row[energy_type] -= 1
			decrement_counter()
			print(player.name + "'s energy ", player.stats['energy'])
		else:
			print(player.name + " does not have enough energy capacity")
	else:
		print("No more energy of this type")


func decrement_counter():
	var count = int($Counter.text)
	count -= 1
	$Counter.text = str(count)
	
	
func increment_counter():
	var count = int($Counter.text)
	count += 1
	$Counter.text = str(count)


func update_counter(value):
	$Counter.text = str(value)
