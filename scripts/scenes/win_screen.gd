extends Node2D

var round := 1
var time := 180.00
var fading = false

#func _ready() -> void:
	#print("win scene ready")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		fading = true
	if fading:
		$Fade.color.a += delta * 2
	if $Fade.color.a >= 1.0:
		Global.scene_manager.change_scene("res://scenes/fight_selection.tscn")

func display_screen(time_total, win_type):
	#for win type: 0 = ko, 1 = tko, 2 = decision
	if win_type == 1:
		$win_method.text = "tko"
		$win_method.position.x = 112
	elif win_type == 2:
		$win_method.text = "decision"
		$ko_info.visible = false
		return
	if time_total > 360:
		time = time_total - 360
		round = 3
	elif time_total > 180:
		time = time_total - 180
		round = 2
	else:
		time = time_total
	$ko_info/round.text = "round " + str(round)
	
	var total_milliseconds = int(time_total * 100)
	
	var minutes = total_milliseconds / 6000
	var milliseconds_remaining = total_milliseconds % 6000
	
	var seconds = milliseconds_remaining / 100
	var milliseconds = milliseconds_remaining % 100
	
	$ko_info/time.text = str(minutes) + ":" + str(seconds) + "." + str(milliseconds)
