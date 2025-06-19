extends Player_Damage_State

@export var idle: State
@export var walking_down: State

var next_state
var power

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("star_punch")
	parent.animations.advance(0)
	power = 3
	if parent.stars == 2:
		power = 2
		parent.animations.advance(0.316)
	elif parent.stars == 1:
		power = 1
		parent.animations.advance(0.516)
	parent.stars = 0
	parent.ring.handle_stars(0)
	next_state = idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return next_state
	return null

func damage_enemy():
	var result 
	if power == 1:
		result = parent.punch_enemy(0x410)
	elif power == 2:
		result = parent.punch_enemy(0x42b)
	else:
		result = parent.punch_enemy(0x440)
	if result == 0:
		next_state = walking_down
	#if result == 1:
		#parent.shake_timer = 14
		#parent.total_shake_time = 14
		#parent.shake_magnitude = 1
