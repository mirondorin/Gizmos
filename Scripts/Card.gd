extends TextureButton

class_name Card

var id
var tier
var cost
var action
var effect
var is_usable
var face
var back

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _init(var card_json):
	id = card_json['id']
	tier = card_json['tier']
	cost = card_json['cost']
	action = card_json['action']
	effect = card_json['effect']
	face = load("res://Assets/Set"+str(tier)+"/card"+str(id)+".png")
	back = load("res://Assets/CardBack"+str(tier)+".png")
	set_normal_texture(face)
