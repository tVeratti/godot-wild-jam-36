extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	ScreenManager.main = self
	ScreenManager.change_to("res://Screens/Enter.tscn")
	
