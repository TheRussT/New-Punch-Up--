extends Player_Damage_State

@export var left_dodge: State
@export var right_dodge: State
@export var duck: State
@export var parry: State

func enter():
	parent.animations.play("tired")
	parent.animations.advance(0)
	if parent.sprite.material.get_shader_parameter("tolerance") == 0.0:
		parent.sprite.material.set_shader_parameter("tolerance", 0.1)

func process(delta):
	if parent.input_buffer.size() != 0:
		var key = parent.input_buffer.back()
		if Input.is_action_pressed(key):
			#if key == "ui_up":
				#return parry
			#el
			if key == "ui_down":
				return duck
			elif key == "ui_left":
				return left_dodge
			elif key == "ui_right":
				return right_dodge
	return null
