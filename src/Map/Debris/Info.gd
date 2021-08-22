extends Spatial


onready var Visibility = $VisibilityNotifier
onready var Display = $Display
onready var Value = $Display/Value
onready var Speed = $Display/Speed

func _ready():
	pass


func _process(delta):
	if Visibility.is_on_screen():
		# Render the 2d root according to the 3d translation.
		var screen_position = GlobalCamera.camera.unproject_position(global_transform.origin)
		Display.set_position(Vector2(screen_position.x , screen_position.y))


func set_visible(value):
	Display.visible = value


func update(debris):
	Speed.text = "%sk mph" % String(stepify(debris.linear_velocity.length(), 0.1))
	Value.text = "$%s" % String(debris.value)
