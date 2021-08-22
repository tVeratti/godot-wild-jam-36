extends RigidBody

const MOVE_SPEED = 2.0
const MAX_POSITION = 80

var value:float = 100.0

var being_beamed:bool
var _beam_anchor:Spatial

var initial_scale
var initial_angular_velocity
var initial_linear_velocity
var velocity:Vector3 = Vector3.ZERO

onready var _collision_audio:AudioStreamPlayer3D = $CollisionAudio
onready var _beamed_audio:AudioStreamPlayer3D = $BeamedAudio

onready var teleport_timer:Timer = $TeleportDebounce
onready var _collision_timer:Timer = $CollisionDebounce

onready var _mesh:MeshInstance = $MeshInstance
onready var _collision_shape = $CollisionShape

onready var _ring:Sprite3D = $Ring
onready var _info = $Info
onready var _particles:Particles = $Particles


var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	_collision_timer.start(3)
		
	if initial_scale == null:
		# Randomize the size & value
		initial_scale = rng.randf_range(0.2, 3)
		
	mass *= initial_scale
	value = float(int(value * initial_scale))
	_collision_audio.pitch_scale = 2.0 / initial_scale
	
	var scale_vector = Vector3(initial_scale, initial_scale, initial_scale)
	_mesh.scale = scale_vector
	_collision_shape.scale = scale_vector
	_ring.scale = scale_vector

	if initial_linear_velocity == null:
		# Randomize the speed & rotation
		var initial_speed = rng.randf_range(1, 3)
		apply_central_impulse(Vector3(initial_speed, 0, 0))
	else:
#		_particles.emitting = true
		apply_central_impulse(initial_linear_velocity)
		Signals.emit_signal("debris_count_changed")
	
	var initial_spin_x = rng.randf_range( -0.5, 0.5)
	var initial_spin_z = rng.randf_range(-0.5, 0.5)
	apply_torque_impulse(Vector3(mass * initial_spin_x, 0, mass * initial_spin_z))


func attach_beam(anchor):
	_beam_anchor = anchor
	being_beamed = true
	_beamed_audio.pitch_scale = 1
	_beamed_audio.play()
	mode = MODE_STATIC
	Signals.emit_signal("debris_attached", self)


func detach_beam():
	being_beamed = false
	_beam_anchor = null
	_beamed_audio.pitch_scale = 0.5
	_beamed_audio.play()
	mode = MODE_RIGID
	Signals.emit_signal("debris_detached", self)
	
	# Apply an impulse to simulate the momentum it had
	apply_central_impulse(velocity * (-50 * mass))


func score():
	# This debris has entered the goal, remove self
	queue_free()


func _physics_process(delta):
	if being_beamed and _beam_anchor != null:
		var target = _beam_anchor.global_transform.origin
		var direction = (target - global_transform.origin).normalized()
		var distance = global_transform.origin.distance_to(_beam_anchor.global_transform.origin)
		
		if distance > 0.1:
			var speed = (MOVE_SPEED / mass) * delta
			var next_position = Vector3(\
				lerp(translation.x, target.x, speed),
				0,
				lerp(translation.z, target.z, speed))
				
			velocity = translation - next_position
			translation = next_position
	
	# Check out-of-bounds
	var position = global_transform.origin
	var do_teleport = false
	if not teleport_timer.time_left > 0:
		if abs(position.x) > MAX_POSITION:
			var offset = MAX_POSITION - position.x
			var new_x = (position.x - offset) * -1
			global_transform.origin = Vector3(new_x, 0, position.z)
			do_teleport = true
		elif(position.z) > MAX_POSITION:
			var offset = MAX_POSITION - position.z
			var new_z = (position.z - offset) * -1
			global_transform.origin = Vector3(position.x, 0, new_z)
			do_teleport = true
		
		if do_teleport: teleport_timer.start(5)
	
	# Update info
	_info.update(self)


#func _integrate_forces(state):
#	if _beam_anchor != null:
#		var target = _beam_anchor.global_transform.origin
#		var direction = (target - global_transform.origin).normalized()
#		var distance = global_transform.origin.distance_to(_beam_anchor.global_transform.origin)
#		var current = global_transform.origin
#
#		if distance > 2:
##			linear_velocity = Vector3(\
##				lerp(current.x, target.x, MOVE_SPEED * state.step),
##				0,
##				lerp(current.z, target.z, MOVE_SPEED * state.step))
#			apply_central_impulse(direction * distance * state.step)


func _on_Debris_body_entered(body):
	
	if body.has_method("attach_beam") or body.has_method("activate_beam"):
		# debounce collisions so they don't rub a million times
		if _collision_timer.time_left > 0: return
		_collision_timer.start(0.5)
		
		value -= (value / 10.0)
		
		# Check if the debris breaks apart
		if initial_scale > 0.2:
			var collision_speed = (body.linear_velocity + linear_velocity).length()
			var mass_difference = mass / body.mass
			var collision_strength = collision_speed * mass_difference
			var break_percentage = (collision_strength / 10) * 100
			var does_break = rng.randi_range(0, 100) < break_percentage
			if does_break:
				var children = [get_broken_child(body), get_broken_child(body)]
				Signals.emit_signal("debris_broken", self, children)
				queue_free()
	
	var pitch = rng.randf_range(-1, 1)
	_collision_audio.pitch_scale += pitch
	_collision_audio.play(0.5)
	
	Signals.emit_signal("debris_collision", self, body)


func get_broken_child(other):
	var child = {
		'initial_scale': initial_scale / 2.1,
		'origin': global_transform.origin,
		'initial_linear_velocity': linear_velocity.reflect(other.linear_velocity) * mass
	}
	return child


func _on_Debris_tree_exiting():
	Signals.emit_signal("debris_removed", self)


func _on_Debris_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			_ring.visible = !_ring.visible
			_info.set_visible(_ring.visible)


func _on_Debris_tree_exited():
	Signals.emit_signal("debris_count_changed")
