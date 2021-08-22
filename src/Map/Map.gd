extends Spatial

var Debris = preload("res://Map/Debris/Debris.tscn")

onready var _debris:Spatial = $Debris
onready var _camera:Camera = $MainCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalCamera.set_camera(_camera)
	
	Signals.connect("debris_broken", self, "_on_debris_broken")


func _on_debris_broken(parent, children):
	for child in children:
		var debris = Debris.instance()
		debris.initial_scale = child.initial_scale
		debris.initial_linear_velocity = child.initial_linear_velocity
		debris.global_transform.origin = child.origin
		_debris.add_child(debris)
