extends Node2D

var current_fighter = 0
var is_fading = false

func _ready() -> void:
	if Global.fights_available > 0:
		$portraits/boss1.visible = true
	if Global.fights_available > 1:
		$portraits/boss2.visible = true
	if Global.fights_available > 2:
		$portraits/boss3.visible = true
	if Global.fights_available > 3:
		$portraits/boss4.visible = true

func _process(delta: float) -> void:
	if !is_fading:
		handle_input()
	else:
		$Fade.color.a += delta * 2
		if $Fade.color.a >= 1.0:
			Global.scene_manager.change_scene("res://scenes/between_fights.tscn")

func handle_input():
	if Input.is_action_just_pressed("ui_select"):
		is_fading = true
		Global.current_fight_index = current_fighter
		$cursor.set_frame(1)
	if Input.is_action_just_pressed("ui_right"):
		if current_fighter == 0 && Global.fights_available > 1:
			$cursor.position.x = 128
			current_fighter = 1
		if current_fighter == 2 && Global.fights_available > 3:
			$cursor.position.x = 128
			current_fighter = 3
	if Input.is_action_just_pressed("ui_left"):
		if current_fighter == 1:
			$cursor.position.x = 48
			current_fighter = 0
		if current_fighter == 3:
			$cursor.position.x = 48
			current_fighter = 2
	if Input.is_action_just_pressed("ui_down"):
		if current_fighter == 0 && Global.fights_available > 2:
			$cursor.position.y = 200
			current_fighter = 2
		if current_fighter == 1 && Global.fights_available > 3:
			$cursor.position.y = 200
			current_fighter = 3
	if Input.is_action_just_pressed("ui_up"):
		if current_fighter == 2:
			$cursor.position.y = 120
			current_fighter = 0
		if current_fighter == 3:
			$cursor.position.y = 120
			current_fighter = 1
