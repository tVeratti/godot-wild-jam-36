extends CanvasLayer


export(NodePath) var score_path
onready var score:Label =  get_node(score_path)

export(NodePath) var collisions_path
onready var collisions:Label =  get_node(collisions_path)

export(NodePath) var value_path
onready var value:Label =  get_node(value_path)


func _ready():
	update_score()
	Signals.connect("score_changed", self, "_on_score_changed")
	Signals.connect("debris_count_changed", self, "_on_score_changed")


func update_score():
	if is_inside_tree():
		var debris_count = get_tree().get_nodes_in_group("debris").size()
		score.text = "Remaining: %s" % String(debris_count)
		collisions.text = "Collisions: %s" % String(State.debris_collisions)
		value.text = "Value Saved: $%s" % String(State.debris_value)
	

func _on_score_changed():
	update_score()
