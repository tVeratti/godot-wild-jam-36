extends Spatial

onready var _camera:Camera = $MainCamera
onready var _test = $MouseTest

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalCamera.set_camera(_camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var intersection = GlobalCamera.mouse_intersection
	if not intersection.empty():
		_test.global_transform.origin = intersection.position
