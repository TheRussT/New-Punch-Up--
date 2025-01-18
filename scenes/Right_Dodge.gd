extends State

@export var recovery: State
var animation_timer
# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("right_dodge")
	animation_timer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	animation_timer += 1
	if animation_timer == 20:
		if parent.input_buffer.has("ui_up"):
			return recovery
	if animation_timer == 28:
		if !parent.input_buffer.has("ui_down"):
			return recovery
	if animation_timer == 36:
		return recovery
	return null
