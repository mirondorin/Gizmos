extends Button

var initial
var result
var amount


func set_values(init : int, res : int, amnt : int):
	self.initial = init
	self.result = res
	self.amount = amnt
	

func _on_ConvertActionBtn_pressed():
	var player = GameManager.active_player
	
	if result == Utils.WILD_ENERGY:
		self.visible = false
		var energy_container = player.get_node("ConvertTab").get_energy_container()
		energy_container.visible = true
		energy_container.set_converting_values(initial, amount)
	else:
		var conv_succ = GameManager.convert_energy(initial, result, amount)
		if conv_succ:
			self.visible = false
