extends Node2D

var round_number = 1

var enemy
var player
@onready var ref = $Ring/Ref

@onready var player_heathbar = $Ring/Player_Heathbar
var player_health = 96
#@onready var player_stambar = $Ring/Player_Stambar
var player_stam : int
@onready var enemy_heathbar = $Ring/Enemy_Heathbar
var enemy_health : int
#@onready var enemy_stambar = $Ring/Enemy_Stambar
var enemy_stam : int
@onready var star_animations = $Ring/Stars/Animations

@onready var background = $Ring/Background

var player_times_kod = 0
var player_times_kod_round = 0
var enemy_times_kod = 0
var enemy_times_kod_round = 0

var timer_speed = 0
var time = 180.0

var enemy_ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[1,0,0,0,0,0,0,0,0,0,0]}
# has list of times where events will occur, max 3 slots for each round.
#                  
var event_table = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
var event_index = 0

func _ready() -> void:
	ref.instantiate(self)
	
	var loaded_enemy = load("res://scenes/enemies/boss" + str(Global.current_fight_index + 1) + ".tscn")
	enemy = loaded_enemy.instantiate()
	add_child(enemy)
	#enemy = $Enemy # Instantiate later
	player = $Player
	enemy.player = player
	player.enemy = enemy
	player.ring = self
	enemy.ring = self
	enemy.fight_setup()
	
	player_stam = player.stamina_max
	generate_player_stam(player_stam)
	
	enemy_health = enemy.health
	enemy_stam = enemy.stamina_max
	generate_enemy_stam(enemy_stam)
	#enemy_stam = 1

func start_round():
	$Ring/Round_Number.set_frame(round_number)
	round_number += 1
	
	time = 180.0
	timer_speed = 0
	
	event_index = 3 * (round_number - 1)
	
	enemy.advantage_state = 0
	player.advantage_state = 0
	
	enemy.state_machine.change_state(enemy.intro_state)
	player.change_stamina(enemy.stamina_max - enemy.stamina)
	enemy_stam = enemy.stamina
	
	player.state_machine.change_state(player.intro_state)
	player.change_stamina(player.stamina_max - player.stamina)
	
	player_stam = player.stamina
	
	enemy.exit_OTR()
	player.exit_OTR()
	update_player_stam(player.stamina)
	update_enemy_stam(enemy.stamina)
	
	player_times_kod_round = 0
	enemy_times_kod_round = 0
	
	ref.instantiate(self)
	

func _process(delta: float) -> void:
	manage_progress_bars(delta)
	ref.process(delta)
	process_timer(delta)

func manage_progress_bars(delta):
	if player_health != player_heathbar.value:
		if player_health < player_heathbar.value:
			player_heathbar.value -= 1
		else:
			player_heathbar.value += 1
	if enemy_health != enemy_heathbar.value:
		if enemy_health < enemy_heathbar.value:
			enemy_heathbar.value -= 1
		else:
			enemy_heathbar.value += 1
	#if player_stam != player_stambar.value:
		#if abs(player_stam - player_stambar.value) < 1:
			#player_stambar.value = player_stam
		#else:
			#player_stambar.value += (player_stam - player_stambar.value) * 5 * delta
			#print("amount suptracted: " + str((player_stam - player_stambar.value) * 5 * delta))
	#if enemy_stam != enemy_stambar.value:
		#if abs(enemy_stam - enemy_stambar.value) < 1:
			#enemy_stambar.value = enemy_stam
		#else:
			#enemy_stambar.value += (enemy_stam - enemy_stambar.value) * 5 * delta

func process_timer(delta):
	var prior = int(time)
	time -= delta * timer_speed
	if (time <= 0):
		if round_number == 3:
			handle_decision()
		else:
			$Ring/Stars/Animations.play("round_end")
			enemy.animations.pause()
			player.animations.pause()
	else:
		var time_display = int(time)
		if (prior != time_display):
			if time_display == event_table[event_index]:
				enemy.schedule_event()
				event_index += 1
		@warning_ignore("integer_division")
		$Ring/Timer/Minute.set_frame(time_display/60)
		@warning_ignore("integer_division")
		$Ring/Timer/Decond.set_frame((time_display%60)/10)
		$Ring/Timer/Second.set_frame(time_display%10)

func end_round():
	time = 180
	Global.scene_manager.change_scene("res://scenes/between_fights.tscn", false)
	enemy.between_round_setup(round_number)

func handle_decision():
	if player_times_kod > enemy_times_kod || (player_times_kod
	== enemy_times_kod && player.health > enemy.health):
		Global.wins += 1;
		Global.scene_manager.change_scene("res://scenes/win_screen.tscn")
		Global.scene_manager.current_scene.display_screen(0.0, 2)
		if Global.fights_available < Global.current_fight_index + 2:
			Global.fights_available = Global.current_fight_index + 2
	else:
		Global.losses += 1;
		Global.scene_manager.change_scene("res://scenes/loss_screen.tscn")
		#lose screen
	Saveload.SaveFileData.fights_available = Global.fights_available
	Saveload.SaveFileData.wins = Global.wins
	Saveload.SaveFileData.losses = Global.losses
	Saveload._save()

func handle_stars(value):
	if value == 0:
		star_animations.pause()
		$Ring/Stars/Stars_Sprite.visible = false
	elif value == 1:
		$Ring/Stars/Stars_Sprite.visible = true
		$Ring/Stars/Stars_Sprite.set_frame(0)
	elif value == 2:
		$Ring/Stars/Stars_Sprite.visible = true
		$Ring/Stars/Stars_Sprite.set_frame(1)
	elif value == 3:
		$Ring/Stars/Stars_Sprite.visible = true
		star_animations.play("flashing")

func update_player_health(value):
	player_health = value
	#player_heathbar.value = value

func update_enemy_health(value):
	enemy_health = value
	#enemy_heathbar.value = value

func update_player_stam(value):
	var change = value - player_stam
	#print("stamina now " + str(value) + " meaning change of " + str(change))
	player_stam = value
	if change == 0:
		return
	if change < -4:
		$Ring/Player_Stambar/Animations.play("lose_large")
	elif change < -2:
		$Ring/Player_Stambar/Animations.play("lose_large")
	elif change < 0:
		$Ring/Player_Stambar/Animations.play("lose_small")
	elif change < 3:
		$Ring/Player_Stambar/Animations.play("gain_small")
	elif change < 5:
		$Ring/Player_Stambar/Animations.play("gain_large")
	else:
		$Ring/Player_Stambar/Animations.play("gain_large")

func update_enemy_stam(value):
	var change = value - enemy_stam
	enemy_stam = value
	if change == 0:
		return
	if change < -4:
		$Ring/Enemy_Stambar/Animations.play("lose_large")
	elif change < -2:
		$Ring/Enemy_Stambar/Animations.play("lose_large")
	elif change < 0:
		$Ring/Enemy_Stambar/Animations.play("lose_small")
	elif change < 3:
		$Ring/Enemy_Stambar/Animations.play("gain_small")
	elif change < 5:
		$Ring/Enemy_Stambar/Animations.play("gain_large")
	else:
		$Ring/Enemy_Stambar/Animations.play("gain_large")

func generate_player_stam(value):
	#print("called " + str(value))
	set_player_stam_color(Color("a81000"))
	$Ring/Player_Stambar/l1.visible = false
	$Ring/Player_Stambar/l2.visible = false
	$Ring/Player_Stambar/l3.visible = false
	$Ring/Player_Stambar/l4.visible = false
	$Ring/Player_Stambar/l5.visible = false
	$Ring/Player_Stambar/l6.visible = false
	$Ring/Player_Stambar/l7.visible = false
	$Ring/Player_Stambar/l8.visible = false
	if value > 0 && value < 47:
		$Ring/Player_Stambar/l1.visible = true
	if value > 8 && value < 55:
		$Ring/Player_Stambar/l2.visible = true
	if value > 16:
		$Ring/Player_Stambar/l3.visible = true
	if value > 24:
		$Ring/Player_Stambar/l4.visible = true
	if value > 32:
		$Ring/Player_Stambar/l5.visible = true
	if value > 40:
		$Ring/Player_Stambar/l6.visible = true
	if value > 48:
		$Ring/Player_Stambar/l7.visible = true
	if value > 56:
		$Ring/Player_Stambar/l8.visible = true

func generate_enemy_stam(value):
	#probably a better way to do this
	set_enemy_stam_color(Color("a81000"))
	$Ring/Enemy_Stambar/l1.visible = false
	$Ring/Enemy_Stambar/l2.visible = false
	$Ring/Enemy_Stambar/l3.visible = false
	$Ring/Enemy_Stambar/l4.visible = false
	$Ring/Enemy_Stambar/l5.visible = false
	$Ring/Enemy_Stambar/l6.visible = false
	$Ring/Enemy_Stambar/l7.visible = false
	$Ring/Enemy_Stambar/l8.visible = false
	if value > 0 && value < 47:
		$Ring/Enemy_Stambar/l1.visible = true
	if value > 8 && value < 55:
		$Ring/Enemy_Stambar/l2.visible = true
	if value > 16:
		$Ring/Enemy_Stambar/l3.visible = true
	if value > 24:
		$Ring/Enemy_Stambar/l4.visible = true
	if value > 32:
		$Ring/Enemy_Stambar/l5.visible = true
	if value > 40:
		$Ring/Enemy_Stambar/l6.visible = true
	if value > 48:
		$Ring/Enemy_Stambar/l7.visible = true
	if value > 56:
		$Ring/Enemy_Stambar/l8.visible = true

func generate_player_stam_from_animation(offset):
	generate_player_stam(player_stam + offset)
	#print($Ring/Player_Stambar/Animations.is_playing())
	if player_stam < 16 && !$Ring/Player_Stambar/Animations.is_playing():
		if player.OTR_buffer > 12:
			$Ring/Player_Stambar/Animations.play("flash_fast")
		else:
			$Ring/Player_Stambar/Animations.play("flash")

func generate_enemy_stam_from_animation(offset):
	generate_enemy_stam(enemy_stam + offset)
	if enemy_stam < 16 && !$Ring/Enemy_Stambar/Animations.is_playing():
		if enemy.OTR_buffer > enemy.OTR_max - 4:
			$Ring/Enemy_Stambar/Animations.play("flash_fast")
		else:
			$Ring/Enemy_Stambar/Animations.play("flash")

func set_player_stam_color(color : Color):
	$Ring/Player_Stambar/l1.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l2.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l3.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l4.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l5.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l6.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l7.material.set_shader_parameter("replace_color", color)
	$Ring/Player_Stambar/l8.material.set_shader_parameter("replace_color", color)

func set_enemy_stam_color(color : Color):
	$Ring/Enemy_Stambar/l1.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l2.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l3.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l4.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l5.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l6.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l7.material.set_shader_parameter("replace_color", color)
	$Ring/Enemy_Stambar/l8.material.set_shader_parameter("replace_color", color)

func player_enter_OTR():
	#anything needed with the ring
	enemy.advantage_state |= 2
	enemy.handle_state()

func player_exit_OTR():
	enemy.advantage_state &= 13
	enemy.handle_state()
	set_player_stam_color(Color8(168,16,0))

func player_tired():
	enemy.handle_state()


func handle_player_kod():
	player_times_kod += 1
	player_times_kod_round += 1
	ref.player_activated()

func handle_enemy_kod():
	enemy_times_kod += 1
	enemy_times_kod_round += 1
	ref.enemy_activated()

func player_got_up():
	ref.player_got_up()

func enemy_got_up():
	ref.enemy_got_up()

func enemy_fell_down():
	ref.enemy_fell_down()

func set_timer_speed(value):
	timer_speed = value
