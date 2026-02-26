extends State

@export var walking_up: State

var mash_endgoal = 1.0
var mash_progress = 0.0
var mash_regression = 0.003
var mash_coefficient = 20
var is_last_input_left = false
var is_active = false
var getup_multiplier = 1

var health_regain_table = [80, 84, 90, 60, 76, 84, 1, 60, 72, 1, 32, 56, 1, 1, 24]

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("idle")
	parent.animations.advance(0)
	parent.animations.pause()
	parent.sprite.position.y = 32
	mash_progress = 0
	mash_coefficient -= 2
	mash_regression += 0.0002
	is_active = false
	parent.ring.handle_player_kod()
	if parent.ring.player_times_kod > 5:
		getup_multiplier = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if is_active:
		if is_last_input_left:
			if !parent.input_buffer.has("ui_accept") and parent.input_buffer.has("ui_cancel"):
				mash_progress += mash_coefficient * delta * getup_multiplier
				is_last_input_left = false
		else:
			if !parent.input_buffer.has("ui_cancel") and parent.input_buffer.has("ui_accept"):
				mash_progress += mash_coefficient * delta * getup_multiplier
				is_last_input_left = true
		mash_progress -= mash_regression
		if mash_progress < 0:
			mash_progress = 0.0
		parent.sprite.position.y = 32 + ((int(-40 * (mash_progress/mash_endgoal)) / 4) * 4)
		if mash_progress >= mash_endgoal:
			parent.ring.player_got_up()
			#print("times kod = " + str(parent.ring.player_times_kod) + " round number: " + str(parent.ring.round_number))
			parent.health = health_regain_table[(parent.ring.player_times_kod - 1) * 3 + parent.ring.round_number - 1]
			parent.ring.update_player_health(parent.health)
			parent.exit_OTR()
			parent.stamina = 0 
			parent.change_stamina(48)
			return walking_up
	return null

func activate(value):
	is_active = true
	if value == -1:
		is_active = false
