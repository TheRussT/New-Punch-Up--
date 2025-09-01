extends Node2D

var round_number = 1

var enemy
var player
@onready var ref = $Ring/Ref

@onready var player_heathbar = $Ring/Player_Heathbar
var player_health = 96
@onready var player_stambar = $Ring/Player_Stambar
var player_stam = 32
@onready var enemy_heathbar = $Ring/Enemy_Heathbar
var enemy_health
@onready var enemy_stambar = $Ring/Enemy_Stambar
var enemy_stam
@onready var star_animations = $Ring/Stars/Animations

@onready var background = $Ring/Background

var player_times_kod = 0
var enemy_times_kod = 0

var timer_speed = 0
var time = 180.0

var enemy_ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[72,0,1,0,3], 2:[42,0,0,0,0,1,0,0,3]}

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
	
	player_stambar.max_value = player_stam
	
	enemy_health = enemy.health
	enemy_stam = enemy.stamina_max
	enemy_stambar.max_value = enemy_stam
	#enemy_stam = 1

func start_round():
	round_number += 1
	
	time = 180.0
	timer_speed = 0
	
	enemy.state_machine.change_state(enemy.intro_state)
	enemy.stamina = enemy.stamina_max
	enemy_stam = enemy.stamina
	
	player.state_machine.change_state(player.intro_state)
	player.stamina = player.stamina_max
	player_stam = player.stamina
	
	ref.instantiate(self)
	

func _process(delta: float) -> void:
	manage_progress_bars(delta)
	ref.process(delta)
	process_timer(delta)

func manage_progress_bars(delta):
	if player_health != player_heathbar.value:
		if abs(player_health - player_heathbar.value) < 1:
			player_heathbar.value = player_health
		else:
			player_heathbar.value += (player_health - player_heathbar.value) * 5 * delta
	if enemy_health != enemy_heathbar.value:
		if abs(enemy_health - enemy_heathbar.value) < 1:
			enemy_heathbar.value = enemy_health
		else:
			enemy_heathbar.value += (enemy_health - enemy_heathbar.value) * 5 * delta
	if player_stam != player_stambar.value:
		if abs(player_stam - player_stambar.value) < 1:
			player_stambar.value = player_stam
		else:
			player_stambar.value += (player_stam - player_stambar.value) * 5 * delta
	if enemy_stam != enemy_stambar.value:
		if abs(enemy_stam - enemy_stambar.value) < 1:
			enemy_stambar.value = enemy_stam
		else:
			enemy_stambar.value += (enemy_stam - enemy_stambar.value) * 5 * delta

func process_timer(delta):
	time -= delta * timer_speed
	if (time <= 0):
		if round_number == 3:
			handle_decision()
		else:
			time = 180
			Global.scene_manager.change_scene("res://scenes/between_fights.tscn", false)
			enemy.between_round_setup(round_number)
	else:
		var time_display = int(time)
		$Ring/Timer/Minute.set_frame(time_display/60)
		$Ring/Timer/Decond.set_frame((time_display%60)/10)
		$Ring/Timer/Second.set_frame(time_display%10)

func handle_decision():
	if player_times_kod > enemy_times_kod || (player_times_kod
	== enemy_times_kod && player.health > enemy.health):
		Global.scene_manager.change_scene("res://scenes/win_screen.tscn")

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

func update_enemy_health(value):
	enemy_health = value

func update_player_stam(value):
	player_stam = value

func update_enemy_stam(value):
	enemy_stam = value

func handle_player_kod():
	player_times_kod += 1
	ref.player_activated()

func handle_enemy_kod():
	enemy_times_kod += 1
	ref.enemy_activated()

func player_got_up():
	ref.player_got_up()

func enemy_got_up():
	ref.enemy_got_up()

func enemy_fell_down():
	ref.enemy_fell_down()

func set_timer_speed(value):
	timer_speed = value
