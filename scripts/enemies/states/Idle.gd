extends Enemy_Damage_State

#can probably comment out

@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State
@export var high_block: State
@export var low_block: State
@export var jab: State
@export var hook: State
@export var dodge: State

var animation = "idle"

func enter():
	#print(parent.idle_guard)
	if parent.schedule_timer < parent.idle_cooldown * 120:
		parent.schedule_timer = parent.idle_cooldown * 120
	if parent.stamina_regain_timer > 0.5:
		parent.stamina_regain_timer -= 0.5
	parent.animations.play(animation)
	parent.animations.advance(0)
	parent.guard = parent.idle_guard

func process(delta):
	#print(delta)
	parent.schedule_timer -= delta * 120
	if parent.stamina < parent.stamina_max:
		parent.stamina_regain_timer += delta
		if parent.stamina_regain_timer > 3:
			parent.stamina_regain_timer -= 3
			if parent.stamina < parent.stamina_max:
				parent.stamina += 1
			#print("called from idle")
			parent.handle_state()
			parent.ring.update_enemy_stam(parent.stamina)
	if parent.schedule_timer <= 0:
		parent.advance_state()
