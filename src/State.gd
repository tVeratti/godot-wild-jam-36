extends Spatial


enum STATES { ONE }

var ship:RigidBody # player

var debris_value:float = 0.0
var debris_collisions:int = 0

var bounds = 80
var no_break = false


func _ready():
	
	Signals.connect("debris_scored", self, "_on_debris_scored")
	Signals.connect("debris_collision", self, "_on_debris_collision")


func score_debris(value):
	debris_value = stepify(debris_value + value, 0.01)
	Signals.emit_signal("score_changed")


func _on_debris_scored(debris):
	score_debris(debris.value)


func _on_debris_collision(a, b):
	debris_collisions += 1
	Signals.emit_signal("score_changed")
