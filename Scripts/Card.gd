extends TextureButton

class_name Card

var card_info = {} # id, tier cost, action, effect
var is_usable
var face
var back

func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)


func _pressed():
	get_card_info()
	var action = GameManager.current_state
	match action:
		"archive":
			archive(GameManager.active_player)
		"build":
			print("Should build")

func get_card_info():
	print(card_info)


func archive(player : Player):
	if GameManager.active_player.used_action == false:
		if player.stats['archive'].size() < player.stats['max_archive']:
			GameManager.give_card(self, player)
			player.stats['archive'].append(card_info['id'])
		else:
			print(player.name + " has no more archive space")
	else:
		print("Player already used action")
