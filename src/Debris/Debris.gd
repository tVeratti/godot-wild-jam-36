extends RigidBody

const MOVE_SPEED = 4.0
var _beam_anchor:Spatial


func attach_beam(anchor):
	_beam_anchor = anchor
	mode = MODE_KINEMATIC


func detach_beam():
	_beam_anchor = null
	mode = MODE_RIGID


func _physics_process(delta):
	if _beam_anchor != null:
		var target = _beam_anchor.global_transform.origin
		var direction = (target - global_transform.origin).normalized()
		var distance = global_transform.origin.distance_to(_beam_anchor.global_transform.origin)
		
		if distance > 15.0:
			detach_beam()
		if distance > 0.1:
			translation = Vector3(\
				lerp(translation.x, target.x, MOVE_SPEED * delta),
				0,
				lerp(translation.z, target.z, MOVE_SPEED * delta))

#func _integrate_forces(state):
#	if _beam_anchor != null:
#		var target = _beam_anchor.global_transform.origin
#		var direction = (target - global_transform.origin).normalized()
#		var distance = global_transform.origin.distance_to(_beam_anchor.global_transform.origin)
#		var current = global_transform.origin
#
#		if distance > 2:
#			linear_velocity = Vector3(\
#				lerp(current.x, target.x, MOVE_SPEED * state.step),
#				0,
#				lerp(current.z, target.z, MOVE_SPEED * state.step))
##			apply_central_impulse(direction * MOVE_SPEED * state.step)
