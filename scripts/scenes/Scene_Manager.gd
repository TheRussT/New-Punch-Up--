class_name GameController extends Node

@export var scenes_2D : Node2D

var current_scene : Node2D
var stored_scene : Node2D

func _ready():
	Global.scene_manager = self
	current_scene = load("res://scenes/fight.tscn").instantiate()
	scenes_2D.add_child(current_scene)

func change_scene(new_scene : String, delete : bool = true, keep_running : bool = false):
	if current_scene != null:
		if delete:
			current_scene.queue_free()
		elif keep_running:
			current_scene.visible = false
		else:
			stored_scene = current_scene
			scenes_2D.remove_child(current_scene)
	var new = load(new_scene).instantiate()
	if new != null:
		scenes_2D.add_child(new)
		current_scene = new
	else:
		print("Error new scene unavailable")

func restore_scene():
	if stored_scene == null:
		print("error no scene is stored")
		return
	current_scene.queue_free()
	current_scene = stored_scene
	scenes_2D.add_child(current_scene)
	#pretty unsafe, can change later
	current_scene.start_round()
	
