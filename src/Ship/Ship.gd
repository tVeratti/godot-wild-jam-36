extends RigidBody


const ROTATION_SPEED = 0.05
const MAX_SPEED = 200.0
const BEAM_COLOR_ON = Color("3740ff3f")
const BEAM_COLOR_OFF = Color("0040ff3f")

onready var _controller = $Controller

#onready var power_line = $Body/LineRenderer
var rocket_power:float = 0.0

onready var _body = $Body
onready var _rocket_mesh = $Body/Rocket
onready var _rocket_bloom = $Body/Rocket/RocketLight
onready var _arrow = $Arrow

onready var _wing_rocket_bloom_left = $Body/Wing/Rocket/RocketLight
onready var _wing_rocket_bloom_right = $Body/Wing/Rocket2/RocketLight

onready var _beam_audio:AudioStreamPlayer3D = $BeamAudio
onready var _tween:Tween = $Tween

var _beaming:bool = false
var _beam_target:Spatial # Debris within range to beam
var _beam_active:Spatial # Debris actively being beamed

export(NodePath) var beam_line_path
onready var beam_line = get_node(beam_line_path)

export(NodePath) var beam_origin_path
onready var beam_origin:Spatial = get_node(beam_origin_path)

export(NodePath) var beam_visual_path
onready var beam_visual:Spatial = get_node(beam_visual_path)

export(NodePath) var beam_plane_path
onready var beam_plane:MeshInstance = get_node(beam_plane_path)

export(NodePath) var beam_anchor_path
onready var beam_anchor:Spatial = get_node(beam_anchor_path)

#export(NodePath) var _camera_path:NodePath
#onready var _camera = get_node(_camera_path)

var rotation_angle:float = 0.0

func _ready():
	GlobalCamera.set_target(self)
	GlobalCamera.set_anchor($CameraAnchor)
	
	Signals.connect("debris_removed", self, "_on_debris_removed")
	Signals.connect("debris_collision", self, "_on_debris_collision")
	Signals.connect("debris_scored", self, "_on_debris_scored")
	
	State.ship = self


func _input(event):
	if Input.is_action_just_pressed(Actions.BEAM):
		if not _beaming:
			activate_beam()
		else:
			deactivate_beam()


func _physics_process(delta):
	var intersection =  GlobalCamera.mouse_intersection
	if intersection.empty(): return
	
	rocket_power = clamp(intersection.position.distance_to(global_transform.origin), 0, 10.0)
#	power_line.points = [_rocket_mesh.global_transform.origin, intersection.position]
	
	rotation_angle = get_rotation_angle(intersection.position)	
	_rocket_mesh.rotation.y = rotation_angle #+ PI
	_arrow.rotation.y = rotation_angle
	
	if _beam_active != null:
		beam_line.visible = true
		beam_line.points = [beam_origin.global_transform.origin, _beam_active.global_transform.origin]
	elif beam_line.points.size() > 0:
		beam_line.points = []
		beam_line.visible = false


func _integrate_forces(state):
	# Rotation / Torque
	if angular_velocity.length() < 5:
		var body_rotation = _controller.get_rotation(state.step, self, _body)
		state.apply_torque_impulse(body_rotation * ROTATION_SPEED)
	#	state.set_angular_velocity(Vector3.UP * ((body_rotation * ROTATION_SPEED) ))
		
		# Visually show which rocket is adding torque
		_wing_rocket_bloom_left.visible = body_rotation.y == -1
		_wing_rocket_bloom_right.visible = body_rotation.y == 1
	
	# Velocity / Impulse
	if linear_velocity.length() < MAX_SPEED:
		var direction:Vector3 = _controller.get_velocity(state.step, self, _rocket_mesh, rocket_power)
		apply_impulse(_rocket_bloom.translation, direction)
		
		_rocket_bloom.visible = direction.length() > 0.0


func get_rotation_angle(target):
	var current_transform = get_global_transform()
	var current_angle_y = current_transform.basis.get_euler().y
	var target_angle_y = current_transform.looking_at(target, Vector3.UP).basis.get_euler().y
	return wrapf(target_angle_y - current_angle_y, -PI, PI)


func activate_beam():
	_beaming = true
	try_attach_beam_to_debris()
	Signals.emit_signal("beam_activated")
#	_beam_audio.play()
	show_beam_plane(_beam_active == null)


func deactivate_beam():
	_beaming = false
	try_detach_beam_from_debris()
	Signals.emit_signal("beam_deactivated")
	show_beam_plane(false)


func show_beam_plane(on):
	if on:
		beam_visual.visible = true
		beam_plane.visible = true
	
	var material:SpatialMaterial = beam_plane.get_surface_material(0)
	var new_color = BEAM_COLOR_ON if on else BEAM_COLOR_OFF
	_tween.interpolate_property(
		material,
		"albedo_color",
		material.albedo_color,
		new_color,
		0.5,
		Tween.EASE_IN_OUT,
		Tween.EASE_IN_OUT)
	_tween.start()


func try_attach_beam_to_debris():
	if (_beaming and _beam_active == null) and \
		(_beam_target != null and _beam_target.has_method("attach_beam")):
			_beam_active = _beam_target
			_beam_target.attach_beam(beam_anchor)
			beam_plane.visible = false
			show_beam_plane(false)
	
	
func try_detach_beam_from_debris():
	if _beam_active != null and _beam_active.has_method("detach_beam"):
			_beam_active.detach_beam()
			_beam_active = null
			
			if _beaming:
				show_beam_plane(true)


func _on_BeamArea_body_entered(body):
	if body.has_method('attach_beam'):
		_beam_target = body
		
		if _beaming:
			try_attach_beam_to_debris()


func _on_BeamArea_body_exited(body):
	if body.has_method('exit_beam'):
		body.exit_beam()
	_beam_target = null


func _on_debris_removed(debris):
	if debris.has_method("detach_beam") and debris.being_beamed:
		try_detach_beam_from_debris()
		deactivate_beam()


func _on_debris_collision(a, b):
	if (a.has_method('detach_beam') and a.being_beamed) \
		or (b.has_method('detach_beam') and b.being_beamed):
		try_detach_beam_from_debris()
		deactivate_beam()


func _on_debris_scored(debris):
	pass


func _on_Tween_tween_all_completed():
	beam_visual.visible = _beaming
