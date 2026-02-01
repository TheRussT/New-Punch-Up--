extends Enemy_Damage_State

@export var idle: State
@export var stamina_loss: State

# Called when the node enters the scene tree for the first time.
func enter():
	#if parent.recovery_hits > 0:
		#print("big dodge")
	parent.recovery_hits -= 1
	parent.animations.play("dodge_big")
	#else:
		#parent.animations.play("dodge")
	parent.animations.advance(0)
	parent.change_stamina(-2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		if parent.stamina <= 0:
			return stamina_loss
		return idle
	return null
