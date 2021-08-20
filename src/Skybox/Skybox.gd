extends Spatial


onready var _camera = $Camera
onready var _initial_y_basis = $Camera.global_transform.basis[1]


func _process(_delta):
	if GlobalCamera.camera != null:
		var tmp_scale = _camera.scale
		var global_basis = GlobalCamera.camera.global_transform.basis
		_camera.global_transform.basis = global_basis 
#		_camera.global_transform.basis[1] = _initial_y_basis
		_camera.scale = tmp_scale
