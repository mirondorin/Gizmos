extends GridContainer


var btn_arr = []
var action_btn_arr = []


func _ready():
	init_btn_arr()


func update_capacities():
	$UpgradeBtn.update_visual()


func init_btn_arr():
	for btn in self.get_children():
		btn_arr.append(btn)
		if btn.is_in_group("action_btn"):
			action_btn_arr.append(btn)


func get_btn_arr():
	return btn_arr


func get_action_btn_arr():
	return action_btn_arr


func get_card_container(card: Card):
	var container_id = card.card_info['type_id'] - 1
	return btn_arr[container_id].get_node("ScrollContainer/VBoxContainer")


func get_archive_container():
	return btn_arr[-1].get_node("ScrollContainer/VBoxContainer")


# Returns number of active gizmos of certain tier
func get_tier_gizmos(tier: int) -> int:
	var count = 0
	for btn in btn_arr:
		if btn.is_in_group("active_gizmo_btn"):
			var card_container = btn.get_node("ScrollContainer/VBoxContainer")
			var card_arr = card_container.get_children()
			for card in card_arr:
				if card.card_info['tier'] == tier:
					count += 1
	return count


# TODO: Make new class ScoreManager and move this function there
# Returns score of player (includes vp_tokens)
func get_score() -> int:
	var total = self.get_parent().stats['vp_tokens']
	for btn in btn_arr:
		if btn.is_in_group("active_gizmo_btn"):
			var card_container = btn.get_node("ScrollContainer/VBoxContainer")
			var card_arr = card_container.get_children()
			for card in card_arr:
				total += card.card_info['vp']
	return total


func toggle_buttons():
	for btn in action_btn_arr:
		btn.disabled = !btn.disabled


# Iterates through all active gizmos player has and if gizmo is usable
# show the checkmark on the bottom right 
func check_condition_gizmos():
	for btn in btn_arr:
		if btn.is_in_group("effect_gizmo_btn"):
			var card_container = btn.get_node("ScrollContainer/VBoxContainer")
			var card_arr = card_container.get_children()
			for card in card_arr:
				if card.is_usable and card.is_condition_met(self.get_parent()):
					card.condition_met_sign.visible = true
				else:
					card.condition_met_sign.visible = false


# Makes all active gizmos usable again after player ends his turn
func reset_active_gizmos():
	for btn in btn_arr:
		if btn.is_in_group("effect_gizmo_btn"):
			var card_container = btn.get_node("ScrollContainer/VBoxContainer")
			var card_arr = card_container.get_children()
			for card in card_arr:
				card.set_is_usable(true)
				card.condition_met_sign.visible = false
