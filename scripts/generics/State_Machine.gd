extends Node

@export var starting_state: State
var current_state

# Called when the node enters the scene tree for the first time.
func init(parent):
	for child in get_children():
		child.parent = parent
		
	change_state(starting_state)

func change_state(new_state):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func process(delta):
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)

func damage(value):
	return current_state.damage(value)
