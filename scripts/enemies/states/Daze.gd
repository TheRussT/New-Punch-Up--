extends Enemy_Damage_State

@export var idle: State
@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State

var daze_timer

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("daze")
	parent.animations.advance(0)
	parent.guard = [1,1,1,1,1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.available_hits = 0
		return idle
	return null
