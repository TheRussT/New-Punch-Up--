extends Node2D

var glove_position = 0
var can_continue = 0

func _ready() -> void:
	if Saveload._has_data():
		can_continue = 1
		$continue.set("theme_override_colors/font_color", Color("#fcfcfc"))
		#$continue.font_color = Color("#fcfcfc")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		if glove_position == 1 && can_continue:
			Saveload._load()
			Global.fights_available = Saveload.SaveFileData.fights_available
			Global.kos = Saveload.SaveFileData.kos
			Global.losses = Saveload.SaveFileData.losses
			Global.wins = Saveload.SaveFileData.wins
			$Gloves.visible = true
		elif glove_position == 0:
			$Gloves.visible = true
		elif glove_position == 2:
			Global.scene_manager.change_scene("res://scenes/control_screen.tscn")
	elif Input.is_action_just_pressed("ui_down") && glove_position < 2 && $Gloves.visible == false:
		$selector.position.y += 16
		glove_position += 1
	elif Input.is_action_just_pressed("ui_up") && glove_position > 0 && $Gloves.visible == false:
		$selector.position.y -= 16
		glove_position -= 1
	if $Gloves.visible == true:
		$Fade.color.a += delta * 2
	if $Fade.color.a >= 1.0:
		Global.scene_manager.change_scene("res://scenes/fight_selection.tscn")
