extends Node

const TOLERANCE:float = 0.1
const SPEED:float = 50.0
const DISTANCE:Vector3 = Vector3(0, 5.0, 0.0)

var camera:Camera
var target:Spatial
var anchor:Spatial

var ray_origin
var ray_end
var intersection
var mouse_intersection
var mouse_position


func _process(delta):
	if camera != null and target != null:
		camera.look_at(target.global_transform.origin, Vector3.UP)
		
		var offset = Vector3.ONE
			
		# Move the camera to the target tile (x, y)
		var anchor_origin = anchor.global_transform.origin
		if camera.translation.distance_to(anchor_origin) >= TOLERANCE:
			camera.translation = Vector3(\
			lerp(camera.translation.x, anchor_origin.x + DISTANCE.x, SPEED * delta),\
			lerp(camera.translation.y, anchor_origin.y + DISTANCE.y, SPEED * delta),
			lerp(camera.translation.z, anchor_origin.z + DISTANCE.z, SPEED * delta))


func _unhandled_input(event):
	ray_origin = null
	ray_end = null
	
	
func _physics_process(delta): 
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 3000
	
	var space_state = camera.get_world().direct_space_state
	intersection = space_state.intersect_ray(ray_origin, ray_end)
	mouse_intersection = space_state.intersect_ray(ray_origin, ray_end, [], 16)


func set_camera(new_camera:Camera):
	camera = new_camera


func set_target(new_target):
	target = new_target

func set_anchor(new_anchor):
	anchor = new_anchor
