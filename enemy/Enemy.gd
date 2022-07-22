extends KinematicBody
class_name Enemy

export var wait_time: int
export var speed = 200
export(Array, NodePath) var home

var space_state
var target

var timer = Timer.new()

func _ready() -> void:
	space_state = get_world().direct_space_state
	
func _process(delta: float) -> void:
	if target:
		var result = space_state.intersect_ray(global_transform.origin, target.global_transform.origin)
		if result.collider.is_in_group("Player"):
			look_at(target.global_transform.origin, Vector3.UP)
			move_to_target(delta)
			set_color(Color(1,0,0))
		else:
			result = space_state.intersect_ray(global_transform.origin, target.global_transform.origin)
			look_at(target.global_transform.origin, Vector3.UP)
			move_to_target(delta)
			set_color(Color(0,1,0))
	else:
		randomize_home()
		
func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		target = body
		print(body.name + " entered")
		set_color(Color(1, 0, 0))
	elif body.is_in_group("Home") and body.is_in_group("Player") == false:
		pick_new_home()
		print(body.name + " entered")
		set_color(Color(0, 1, 0))

func _on_Area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		target = get_node(home[randi() % home.size()])
		print(body.name + " exited")
		set_color(Color(0, 1, 0))

func move_to_target(delta):
	var direction = (target.get_transform().origin - transform.origin).normalized()
	move_and_slide(direction * speed * delta, Vector3.UP)

func set_color(color):
	$MeshInstance.get_surface_material(0).set_albedo(color)

func pick_new_home():
	timer.connect("timeout", self, "randomize_home")
	timer.wait_time = wait_time
	timer.one_shot = false
	add_child(timer)
	timer.start()

func randomize_home():
	target = get_node(home[randi() % home.size()])
