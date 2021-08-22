extends CanvasLayer

onready var _close_timer:Timer =  $CloseTimer


func _ready():
	get_tree().paused = true
	_close_timer.start(0.5)


func _process(delta):
	if Input.is_action_just_pressed("escape") and not _close_timer.time_left > 0:
		get_tree().paused = false
		queue_free()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Resume_pressed():
	get_tree().paused = false
	queue_free()


func _on_Restart_pressed():
	ScreenManager.change_to("res://Map/Map.tscn")
