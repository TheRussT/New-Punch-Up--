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
	parent.animations.play("stamina_loss")
	parent.animations.advance(0)
	parent.sprite.visible = false
	parent.falling_sprite.visible = true
	parent.available_hits = hits
	if insta_ko:
		parent.guard = [0,0,0,0,0]
	else:
		parent.guard = [1,1,1,1,1]

func exit():
	parent.sprite.visible = true
	parent.falling_sprite.visible = false
	if parent.stamina_next > 6:
		parent.stamina_next -= 2
	parent.stamina = parent.stamina_next
	parent.ring.update_enemy_stam(parent.stamina)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return idle
	return null
