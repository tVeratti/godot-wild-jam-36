extends RigidBody


const ROTATION_SPEED = 0.05
const MAX_SPEED = 200.0

onready var _controller = $Controller

onready var power_line = $Body/LineRenderer
var rocket_power:float = 0.0

onready var _body = $Body
onready var _rocket_mesh = $Body/Rocket
onready var _rocket_bloom = $Body/Rocket/RocketLight

onready var _wing_rocket_bloom = $Body/Wing/Rocket/RocketLight
onready var _wing_rocket_bloom_2 = $Body/Wing/Rocket2/RocketLight

var _beaming:bool = false
export(NodePath) var beam_anchor_path
onready var beam_anchor:Spatial = get_node(beam_anchor_path)

#export(NodePath) var _camera_path:NodePath
#onready var _camera = get_node(_camera_path)

var rotation_angle:float = 0.0

func _ready():
	GlobalCamera.set_target(self)


func _input(event):
	_beaming = Input.is_action_pressed(Actions.BEAM)


func _physics_process(delta):
	var intersection =  GlobalCamera.mouse_intersection
	if intersection.empty(): return
	
	rocket_power = clamp(intersection.position.distance_to(global_transform.origin), 0, 10.0)
	power_line.points = [_rocket_mesh.global_transform.origin, intersection.position]
	
	rotation_angle = get_rotation_angle(intersection.position)	
	_rocket_mesh.rotation.y = rotation_angle #+ PI
	
	

func _integrate_forces(state):
	if angular_velocity.length() < 10:
		var body_rotation = _controller.get_rotation(state.step, _body)
		_wing_rocket_bloom.visible = body_rotation.y == 1
		_wing_rocket_bloom_2.visible = body_rotation.y == -1
		
		state.apply_torque_impulse(body_rotation * ROTATION_SPEED)
	#	state.set_angular_velocity(Vector3.UP * ((body_rotation * ROTATION_SPEED) ))
	
#	if linear_velocity.length() < MAX_SPEED:
	var direction:Vector3 = _controller.get_velocity(state.step, _rocket_mesh)
	_rocket_bloom.visible = direction.length() > 0.0
	apply_impulse(_rocket_bloom.translation, direction * rocket_power)


func get_rotation_angle(target):
	var current_transform = get_global_transform()
	var current_angle_y = current_transform.basis.get_euler().y
	var target_angle_y = current_transform.looking_at(target, Vector3.UP).basis.get_euler().y
	return wrapf(target_angle_y - current_angle_y, -PI, PI)


func _on_BeamArea_body_entered(body):
	if body.has_method('attach_beam'):
		body.attach_beam(beam_anchor)
