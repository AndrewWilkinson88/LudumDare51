extends CanvasLayer
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	pass

func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	
	#Make a one-shot timer and wait for it to finish
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()
	pass
	
func update_score(score):
	$ScoreLabel.text = str(score)
	pass
	
func _on_MessageTimer_timeout():
	$Message.hide()
	pass


func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
	pass
