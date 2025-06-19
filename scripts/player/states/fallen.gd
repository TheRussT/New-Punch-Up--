extends State

@export var walking_up: State

var mash_endgoal = 1.0
var mash_progress = 0.0
var mash_regression = 0.004
var mash_coefficient = 16
var is_last_input_left = false
var is_active = false

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("idle")
	parent.animations.advance(0)
	parent.animations.pause()
	parent.sprite.position.y = 32
	mash_progress = 0
	mash_coefficient -= 2
	is_active = false
	parent.ring.handle_player_kod()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if is_active:
		if is_last_input_left:
			if !parent.input_buffer.has("ui_accept") and parent.input_buffer.has("ui_cancel"):
				mash_progress += mash_coefficient * delta
				is_last_input_left = false
		else:
			if !parent.input_buffer.has("ui_cancel") and parent.input_buffer.has("ui_accept"):
				mash_progress += mash_coefficient * delta
				is_last_input_left = true
		mash_progress -= mash_regression
		if mash_progress < 0:
			mash_progress = 0.0
		parent.sprite.position.y = 32 + int(-40 * (mash_progress/mash_endgoal))
		if mash_progress >= mash_endgoal:
			parent.ring.player_got_up()
			parent.health = 96
			parent.ring.update_player_health(parent.health)
			parent.stamina = 24
			parent.ring.update_player_stam(parent.stamina)
			return walking_up
	return null

func activate(value):
	is_active = true
	if value == -1:
		is_active = false
