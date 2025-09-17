extends Node2D

@onready var animations = $Animations

var ring

enum {
	WALKING_UP, WALKING_BACK, COUNT, KO, TKO, INACTIVE, FIGHT
}
var state = INACTIVE
var is_player_kod = true

func instantiate(parent):
	animations.play("fight")
	animations.advance(0)
	animations.pause()
	ring = parent
	state = INACTIVE

func process(delta):
	if state == WALKING_UP:
		if !animations.is_playing():
			if is_player_kod:
				if ring.player_times_kod < 3:
					state = COUNT
					animations.play("count")
					ring.player.activate(0) # activate
				else:
					state = TKO
					animations.play("tko")
			else:
				if ring.enemy_times_kod < 3:
					state = COUNT
					animations.play("count")
				else:
					state = TKO
					animations.play("tko")
	elif state == WALKING_BACK:
		if !animations.is_playing():
			state = INACTIVE
	elif state == COUNT:
		if !animations.is_playing():
			# can change this later so enemy ko activates player
			# in order to celebrate 
			if is_player_kod:
				ring.player.activate(-1)
			state = KO
			animations.play("ko")
	elif state == KO:
		if !animations.is_playing():
			if is_player_kod:
				pass #lose
			else:
				Global.scene_manager.change_scene("res://scenes/win_screen.tscn")
				Global.scene_manager.current_scene.display_screen(ring.time + 180 * (ring.round_number - 1), 0)
				if Global.fights_available < Global.current_fight_index + 2:
					Global.fights_available = Global.current_fight_index + 2
	elif state == TKO:
		if !animations.is_playing():
			if is_player_kod:
				pass #lose
			else:
				Global.scene_manager.change_scene("res://scenes/win_screen.tscn")
				Global.scene_manager.current_scene.display_screen(ring.time + 180 * (ring.round_number - 1), 1)
				if Global.fights_available < Global.current_fight_index + 2:
					Global.fights_available = Global.current_fight_index + 2
	elif state == FIGHT:
		if !animations.is_playing():
			state = WALKING_BACK
			animations.play("walking_back")
			ring.player.activate(0)
			if !is_player_kod:
				ring.enemy.activate(ring.enemy_ko_table[ring.enemy_times_kod][0])
			else:
				ring.enemy.activate(0)

func player_activated():
	is_player_kod = true
	state = WALKING_UP
	animations.play("walking_out")

func enemy_activated():
	is_player_kod = false
	state = WALKING_UP
	animations.play("walking_out")

func player_got_up():
	state = FIGHT
	animations.play("fight")

func enemy_got_up():
	state = FIGHT
	animations.play("fight")

func count_for_enemy(value):
	if !is_player_kod:
		if ring.enemy_ko_table[ring.enemy_times_kod][value] > 0:
			ring.enemy.activate(ring.enemy_ko_table[ring.enemy_times_kod][value])
			animations.pause()
			state = INACTIVE

func enemy_fell_down():
	if state == INACTIVE:
		state = COUNT
		animations.play()
