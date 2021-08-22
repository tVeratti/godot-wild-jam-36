extends Node

const TURN_MOVE_MULTIPLIER = 0.92
const JUMP_FORCE = 11.0
const MOVE_SPEED:float = 8.0
const TURN_SPEED:float = 4.0
const ACCELERATION:float = 5.0
const DE_ACCELERATION:float = 8.0

#const GRAVITY = 30.0

var velocity:Vector3
var direction:Vector3 = Vector3.ZERO
var controls_blocked:bool = false

var facing
var turn_degrees:float = 0.0
var mouse_delta:Vector2 = Vector2.ZERO

var is_turning:bool = false
var is_right_down:bool = false
var is_jumping:bool = false


func _input(event):    
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func get_velocity(delta, ship:RigidBody, rocket:Spatial, rocket_power:float):
	facing = rocket.global_transform.basis
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed(Actions.BACKWARD):
		velocity = -ship.linear_velocity
		return velocity.normalized() * 0.5
		
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		velocity += facing[2]
		return velocity.normalized() * rocket_power
	
	return velocity


func get_rotation(delta, ship, body):
	var torque:Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed(Actions.BACKWARD):
		return -ship.angular_velocity
		
	if Input.is_action_pressed(Actions.RIGHT):
		torque = Vector3.UP * -1
	if Input.is_action_pressed(Actions.LEFT):
		torque = Vector3.UP
	
		
	return torque
	
#	process_input()
#	if Input.is_action_pressed(Actions.BACKWARD):
#		direction = -lerp(unit.linear_velocity, Vector3.ZERO, 0.0001)
#	direction = direction.normalized()
		
#	if not controls_blocked:
#		var intersection = GlobalCamera.mouse_intersection
#		if not intersection.empty():
#			var same_height_intersection = Vector3(intersection.position.x, 0, intersection.position.z)
#			unit.look_at(same_height_intersection, Vector3.UP)
#		if is_right_down:
			# Turn the unit along with mouse movement
#		unit.rotate_y(-lerp(0, GlobalCamera.mouse_sensitivity, mouse_delta.x * delta))
#
#			# Rotate Core anchor for camera rotation
#			unit.CoreAnchor.rotate_x(lerp(0, GlobalCamera.mouse_sensitivity, mouse_delta.y * delta))
#			unit.CoreAnchor.rotation.x = clamp(unit.CoreAnchor.rotation.x, -0.3, 0.76)
#
##			mouse_delta = Vector2.ZERO
#		if turn_degrees != 0:
#			unit.global_rotate(Vector3.UP, turn_degrees  * TURN_SPEED * delta)
#
#	var destination = direction * MOVE_SPEED
#	var acceleration = DE_ACCELERATION
#
#	var horizontal_velocity = Vector3(velocity.x, velocity.y, velocity.z)
#	if direction.dot(horizontal_velocity) > 0:
#		acceleration = ACCELERATION
#
#	horizontal_velocity.y = 0
#	horizontal_velocity = horizontal_velocity.linear_interpolate(destination, acceleration * delta)
#
#	velocity.x = horizontal_velocity.x
#	velocity.z = horizontal_velocity.z
#	velocity.y = 0
#
#	if is_jumping and unit.is_on_floor():
#		velocity.y = JUMP_FORCE
	
	return direction
