extends Player_Damage_State

@export var idle: State
@export var walking_down: State

var next_state

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("right_jab")
	parent.animations.advance(0)
	next_state = idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return next_state
	return null

func damage_enemy():
	var result = parent.punch_enemy(0x104)
	if result == 0:
		next_state = walking_down
	#if result == 1:
		#parent.shake_timer = 14
		#parent.total_shake_time = 14
		#parent.shake_magnitude = 1
