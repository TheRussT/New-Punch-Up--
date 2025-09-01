extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		$Gloves.visible = true
	if $Gloves.visible == true:
		$Fade.color.a += delta * 2
	if $Fade.color.a >= 1.0:
		Global.scene_manager.change_scene("res://scenes/fight_selection.tscn")
