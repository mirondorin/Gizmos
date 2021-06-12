extends TextureButton

class_name Card

var card_info = {} # id, tier cost, action, effect
var is_usable
var face
var back

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _init(var card_json):
	card_info = card_json
	face = load("res://Assets/Set"+str(card_info['tier'])+"/card"+str(card_info['id'])+".png")
	back = load("res://Assets/CardBack"+str(card_info['tier'])+".png")
	set_normal_texture(face)


func _pressed():
	get_card_info()


func get_card_info():
	print(card_info)
