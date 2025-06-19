extends State

@export var idle: State

var is_active = false
# Called when the node enters the scene tree for the first time.
func enter():
	is_active = false
	if parent.health <= 0:
		parent.animations.play("walking_down")
		parent.animations.pause()
	else:
		parent.animations.play("waiting")
	parent.animations.advance(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if is_active:
		if !parent.animations.is_playing():
			return idle
	return null

func activate(value):
	is_active = true
	parent.animations.play("walking_down")
	parent.animations.advance(0)
	if value > 0:
		parent.health = value
		parent.ring.update_enemy_health(value)
		parent.handle_state()
	#else:
		#parent.position.y += 40
