extends Node2D

var fading = false
var reading = false
var select_timer = 0.0
var select_position = 0
var last_position = -1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		if last_position == select_position:
			$explanation.visible_ratio = 1
		elif select_position == 0:
			$explanation.text = "to perform a punch use o\nand p keys for left and \nright punches respectively.
			these hooks will hit an \nenemy low. To perform a \nhigh jab, hold the w key\nand press the o or p keys\nfor left or right jabs
			respectively. Make sure to\nstrike at just the right\ntime!"
			reading = true
			$explanation.visible_ratio = 0
			last_position = 0
		elif select_position == 1:
			$explanation.text = "you can dodge right and\nleft with the d and a keys\nrespectively. length can\nvary based on holding or\ntapping the other
			direction. Ducking dodges\nmore but is slower.\ndifferent attacks require\ndifferent dodge types to\navoid"
			reading = true
			$explanation.visible_ratio = 0
			last_position = 1
		elif select_position == 2:
			$explanation.text = "certain weaker enemy\nattacks can be blocked at\nthe cost of some stamina.\nblocking is done by\npressing w. if the enemy's
			attack lands right when\nstarting a block, a parry \nis performed instead and\nthe enemy loses stamina"
			reading = true
			$explanation.visible_ratio = 0
			last_position = 2
		elif select_position == 3:
			$explanation.text = "the player can gain stars\nfrom punching the enemy at\njust the right moment.\nthey can then use space to\nunleash a star uppercut,
			dealing massive damage.\nStars can stack for more\ndamage but will disaprear\nwhen hit."
			reading = true
			$explanation.visible_ratio = 0
			last_position = 3
		else:
			fading = true
	if !fading && Input.is_action_just_pressed("ui_up"):
		select_position = (select_position - 1) % 5
		$selector.position.y = 16 + (select_position * 16)
	elif !fading && Input.is_action_just_pressed("ui_down"):
		select_position = (select_position + 1) % 5
		$selector.position.y = 16 + (select_position * 16)
	if fading:
		$Fade.color.a += delta * 2
	if reading:
		$explanation.visible_ratio += delta / 8
		if $explanation.visible_ratio >= 1:
			reading = false
	if $Fade.color.a >= 1.0:
		Global.scene_manager.change_scene("res://scenes/title_screen.tscn")
