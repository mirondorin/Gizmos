extends Panel


func close():
	self.hide()
	$VBoxContainer/ErrorLabel.text = ""


func valid_name():
	if $VBoxContainer/Name.text == "":
		$VBoxContainer/ErrorLabel.text = "Invalid name!"
		return false
	return true


func valid_ip():
	var ip = $VBoxContainer/IPAddress.text
	if not ip.is_valid_ip_address():
		$VBoxContainer/ErrorLabel.text = "Invalid IP address!"
		return false
	return true


func get_player_name():
	return $VBoxContainer/Name.text
