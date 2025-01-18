extends State

@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State
@export var high_block: State
@export var low_block: State
@export var jab: State
@export var hook: State
@export var dodge: State

func enter():
	parent.animations.play("idle")
