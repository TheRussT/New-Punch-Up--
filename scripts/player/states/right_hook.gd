extends Player_Damage_State

@export var idle: State
@export var jab: State
@export var walking_down: State

var next_state: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("right_hook")
	parent.animations.advance(0)
	next_state = idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if parent.animations.get_current_animation_position() < 0.033:
		if parent.input_buffer.has("ui_up"):
			return jab
	if !parent.animations.is_playing():
		return next_state
	return null

func damage_enemy():
	var result = parent.punch_enemy(0x304)
	if result == 0:
		next_state = walking_down
	#var result = parent.enemy.damage(0x304)
	#if result == 1:
		#parent.shake_timer = 14
		#parent.total_shake_time = 14
		#parent.shake_magnitude = 1
