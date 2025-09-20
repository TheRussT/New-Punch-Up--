extends Node2D

var menu_index = 0
var fight_index = 0
var scroll_progress = 0.0
var scroll_active = false
var picture_timer = 0.0
var is_reading
#var read_timer
var player_message
var enemy_message
var mess_table = ["you undig-\nnified\namerican!\ni come from\na long line\nof sir-\nrendreres!" , "I was over-\nconfident,\ni think\ni'll\ncapitulate\nsoon!" , "I'd better\nsay au\nrevoir to\nmy family",
"","if you\nthink you\ncan beat\nme, you're\nin de-nile\nhahaha!","","","fool! I\ntake hits\nbetter\nthan any\nother \nsoccer \nplayer!"]
# Called when the node enters the scene tree for the first time.
func _ready():
	fight_index = Global.current_fight_index
	#may refactor to not be an if-else but currently is the best option
	if fight_index == 0:
		$Enemy/record.text = " 1- 9  1ko"
		$Enemy/name.text = "\nsir rendre"
		$Enemy/rank.text = "ranked: #3"
		$Enemy/Statistics/age.text = "age: 22"
		$Enemy/Statistics/weight.text = "weight:144"
		$Enemy/Statistics/location.text = "from\n lyon,\n    france"
	elif fight_index == 1:
		$Enemy/record.text = "13-23 10ko"
		$Enemy/name.text = "\nsarwat"
		$Enemy/rank.text = "ranked: #2"
		$Enemy/Statistics/age.text = "age: 36"
		$Enemy/Statistics/weight.text = "weight:261"
		$Enemy/Statistics/location.text = "from\n cairo,\n     egypt"
	elif fight_index == 2:
		$Enemy/record.text = "16-5  14ko"
		$Enemy/name.text = "m'babe\nfutbol"
		$Enemy/rank.text = "ranked: #1"
		$Enemy/Statistics/age.text = "age: 26"
		$Enemy/Statistics/weight.text = "weight:227"
		$Enemy/Statistics/location.text = "from\nsao paulo,\n    brazil"
	elif fight_index == 3:
		$Enemy/record.text = "20-2  19ko"
		$Enemy/name.text = "gelje\nsherpa"
		$Enemy/rank.text = "champion"
		$Enemy/Statistics/age.text = "age: 24"
		$Enemy/Statistics/weight.text = "weight:212"
		$Enemy/Statistics/location.text = "from\nkathmandu,\n     nepal"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_pictures(delta)
	if scroll_active:
		handle_scroll(delta)
	if Input.is_action_just_pressed("ui_select"):
		if $Player/profile.visible_ratio < 1:
			$Player/profile.visible_ratio = 1
		elif $Enemy/profile.visible_ratio < 1:
			$Enemy/profile.visible_ratio = 1
			is_reading = false
		else:
			scroll_active = true
		#$round_number.set_frame(GlobalScript.round)
	if(is_reading == true):
		
		if $Player/profile.visible_ratio < 1:
			$Player/profile.visible_ratio += delta/3
		elif $Enemy/profile.visible_ratio < 1:
			$Enemy/profile.visible_ratio += delta/3
		else:
			is_reading = false
		#read_timer -= 1
		#if(read_timer <= 0):
			#partial += message[index]
			#index += 1
			#read_timer = 10
			#$Enemy/e_profile.text = partial
			#if(partial == message):
				#isreading = false

func handle_pictures(delta):
	picture_timer += delta
	if picture_timer > 2:
		picture_timer = 0.0
	elif picture_timer > 1:
		$Enemy/picture.set_frame(fight_index * 9 + 2)
		$Player/picture.set_frame(2)
	else:
		$Enemy/picture.set_frame(fight_index * 9 + 1)
		$Player/picture.set_frame(1)

func handle_scroll(delta):
	scroll_progress += delta
	position.y = int(-224 * (scroll_progress))
	if(position.y <= -224):
		scroll_active = false
		#GlobalScript.round += 1
		if Global.scene_manager.stored_scene == null:
			Global.scene_manager.change_scene("res://scenes/fight.tscn")
		else:
			Global.scene_manager.restore_scene()

func set_up_messages(round_number : int):
	$round_number.set_frame(round_number)
	if player_message == null || enemy_message == null:
		return
	$Enemy/profile.text = enemy_message
	$Enemy/profile.visible_ratio = 0
	$Player/profile.text = player_message
	$Player/profile.visible_ratio = 0
	$Enemy/Statistics.visible = false
	$Player/Statistics.visible = false
	is_reading = true
	
