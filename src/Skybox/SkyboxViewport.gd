extends Spatial

onready var viewport = $Viewport


func _ready():
	var root_viewport = get_tree().root
	root_viewport.transparent_bg = true
	root_viewport.connect("size_changed", self, "_on_root_viewport_size_changed")
	viewport.size = root_viewport.size


func _on_root_viewport_size_changed():
	viewport.size = get_tree().root.size
