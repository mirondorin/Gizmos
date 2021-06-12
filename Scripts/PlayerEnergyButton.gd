extends TextureButton


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
