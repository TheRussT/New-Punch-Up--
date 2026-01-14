extends Enemy_Damage_State

@export var idle: State
@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State

@export var hits: int
@export var insta_ko: bool

# Called when the node enters the scene tree for the first time.
func enter():
	parent.sprite.visible = false
	parent.falling_sprite.visible = true
	parent.animations.play("stamina_loss")
	parent.sprite.material.set_shader_parameter("replace_color", Color("f878f8"))
	parent.sprite.material.set_shader_parameter("tolerance", 0.1)
	parent.falling_sprite.material.set_shader_parameter("tolerance", 0.1)
	parent.advantage_state |= 4
	parent.animations.advance(0)
	parent.available_hits = hits
	parent.recovery_hits = 3
	if insta_ko:
		parent.guard = [0,0,0,0,0]
	else:
		parent.guard = [1,1,1,1,1]

func exit():
	parent.sprite.visible = true
	parent.falling_sprite.visible = false
	parent.falling_sprite.material.set_shader_parameter("tolerance", 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.exit_stamina_loss()
		return idle
	return null
