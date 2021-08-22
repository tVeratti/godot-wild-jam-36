extends CanvasLayer

func _ready():
	State.bounds = 20
	State.no_break = true


func _on_Play_pressed():
	ScreenManager.change_to("res://Map/Map.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Resume_pressed():
	pass # Replace with function body.


func _on_Restart_pressed():
	pass # Replace with function body.
