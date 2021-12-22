extends Button

var initial
var result
var amount


func set_values(init: int, res: int, amnt: int):
	self.initial = init
	self.result = res
	self.amount = amnt
	

func _on_ConvertActionBtn_pressed():
	var player = GameManager.active_player
	
	self.visible = false
	if result == GameManager.WILD_ENERGY:
		var energy_container = player.get_node("ConvertTab").get_energy_container()
		energy_container.visible = true
		energy_container.set_converting_values(initial, amount)
	else:
		Server.convert_request(initial, result, amount)
