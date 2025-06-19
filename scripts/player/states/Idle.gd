extends Player_Damage_State

@export var left_dodge: State
@export var left_hook: State
@export var left_jab: State
@export var right_dodge: State
@export var right_hook: State
@export var right_jab: State
@export var duck: State
@export var star_punch: State
@export var parry: State
@export var tired: State

func enter():
	if parent.stamina <= 0:
		parent.state_machine.change_state(tired)
	else:
		parent.animations.play("idle")
		parent.animations.advance(0)

func process(delta):
	if parent.input_buffer.size() != 0:
		var key = parent.input_buffer.back()
		if Input.is_action_pressed(key):
			if key == "ui_accept":
				if Input.is_action_pressed("ui_up"):
					return left_jab
				return left_hook
			elif key == "ui_cancel":
				if Input.is_action_pressed("ui_up"):
					return right_jab
				return right_hook
			elif key == "ui_up":
				return parry
			elif key == "ui_down":
				return duck
			elif key == "ui_left":
				return left_dodge
			elif key == "ui_right":
				return right_dodge
			elif key == "ui_select":
				if parent.stars > 0:
					return star_punch
	return null
