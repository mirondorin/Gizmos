extends Node

class_name Deck

var deck_path = "res://Deck/deck_json.json"
var deck
var deck_json


func _init():
	var deck_file = File.new()
	deck_file.open(deck_path, File.READ)
	deck_json = JSON.parse(deck_file.get_as_text())
	deck_file.close()
	deck = deck_json.result
