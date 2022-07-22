extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3

onready var head = $Head
onready var camera = $Head/Camera

var target
var space_state
var velocity = Vector3()
var camera_x_rotation = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -92 and camera_x_rotation + x_delta < 89:
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta

func _ready() -> void:
	pass
		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var head_basis = head.get_global_transform().basis
	
	var direction = Vector3()
	if Input.is_action_pressed("forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("back"):
		direction += head_basis.z
	
	if Input.is_action_pressed("left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("right"):
		direction += head_basis.x
	
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)
	#Hack to fix a bug with move_and_slide in godot.
	#discussion/demo: https://www.reddit.com/r/godot/comments/hc4lur/how_to_move_and_stop_correctly_on_slopes_using
	#see funcion "slope()"
	var slides = get_slide_count()
	if(slides):
		slope(slides)
#Hack to fix a bug with move_and_slide in godot.
#discussion/demo: https://www.reddit.com/r/godot/comments/hc4lur/how_to_move_and_stop_correctly_on_slopes_using
func slope(slides : int):
	for i in slides:
		var touched = get_slide_collision(i)
		if is_on_floor() && touched.normal.y < 1.0 && (velocity.x != 0.0 || velocity.z != 0.0):
			velocity.y = touched.normal.y
