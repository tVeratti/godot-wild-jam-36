extends Spatial

var Debris = preload("res://Map/Debris/Debris.tscn")
var Pause = preload("res://Map/Pause.tscn")

onready var _debris:Spatial = $Debris
onready var _camera:Camera = $MainCamera

var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	State.bounds = 80
	State.no_break = false
	GlobalCamera.set_camera(_camera)
	
	Signals.connect("debris_broken", self, "_on_debris_broken")


func _input(event):
	if Input.is_action_just_pressed("escape"):
		add_child(Pause.instance())

		


func _on_debris_broken(parent, children):
	for child in children:
		var debris = Debris.instance()
		debris.initial_scale = child.initial_scale
		debris.initial_linear_velocity = child.initial_linear_velocity
		_debris.add_child(debris)
		debris.global_transform.origin = child.origin
