extends TextureButton


func decrement_counter() -> void:
	var count = int($Counter.text)
	count -= 1
	$Counter.text = str(count)
	
	
func increment_counter() -> void:
	var count = int($Counter.text)
	count += 1
	$Counter.text = str(count)


# Receives string from player energy script and updates player's
# energy button counter
func update_counter(str_value : String) -> void:
	$Counter.text = str_value
