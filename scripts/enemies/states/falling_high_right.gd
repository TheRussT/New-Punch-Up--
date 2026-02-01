extends State

@export var fallen: State

var fall_type = 0
# Called when the node enters the scene tree for the first time.
func enter():
	parent.ring.set_timer_speed(0)
	parent.available_hits = 0
	parent.sprite.visible = false
	parent.falling_sprite.visible = true
	print("called from falling")
	parent.exit_OTR()
	parent.stamina = 0
	parent.change_stamina(48)
	print("fall " + str(fall_type) + " entered")
	
	if fall_type == 0:
		parent.animations.play("falling_right")
	elif fall_type == 1:
		parent.animations.play("falling_left")
	elif fall_type == 2:
		parent.animations.play("falling_belly_right")
	elif fall_type == 3:
		parent.animations.play("falling_belly_left")
	elif fall_type == 4:
		print("problem")
		parent.animations.speed_scale = 1.5
		parent.animations.play("falling_hard")
		fall_type = 1
	parent.animations.advance(0)

func exit():
	parent.animations.speed_scale = 1
	parent.position.x = parent.base_x + parent.falling_sprite.position.x
	parent.position.y = parent.base_y + parent.falling_sprite.position.y + 52
	parent.ring.handle_enemy_kod()
	print("state exited, animation timr is " + str(parent.animations.get_current_animation_position()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		print("animation not playing")
		return fallen
	return null
