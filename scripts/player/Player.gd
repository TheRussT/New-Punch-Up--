extends Node2D

var input_buffer = []
var stars = 0
@onready var animations = $Animations
@onready var state_machine = $State_Machine

func _ready():
	state_machine.init(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		input_buffer.push_back("ui_right")
	elif Input.is_action_just_released("ui_right"):
		input_buffer.erase("ui_right")
	if Input.is_action_just_pressed("ui_left"):
		input_buffer.push_back("ui_left")
	elif Input.is_action_just_released("ui_left"):
		input_buffer.erase("ui_left")
	if Input.is_action_just_pressed("ui_down"):
		input_buffer.push_back("ui_down")
	elif Input.is_action_just_released("ui_down"):
		input_buffer.erase("ui_down")
	if Input.is_action_just_pressed("ui_up"):
		input_buffer.push_back("ui_up")
	elif Input.is_action_just_released("ui_up"):
		input_buffer.erase("ui_up")
	if Input.is_action_just_pressed("ui_accept"):
		input_buffer.push_back("ui_accept")
	elif Input.is_action_just_released("ui_accept"):
		input_buffer.erase("ui_accept")
	if Input.is_action_just_pressed("ui_cancel"):
		input_buffer.push_back("ui_cancel")
	elif Input.is_action_just_released("ui_cancel"):
		input_buffer.erase("ui_cancel")
	if Input.is_action_just_pressed("ui_select"):
		input_buffer.push_back("ui_select")
	elif Input.is_action_just_released("ui_select"):
		input_buffer.erase("ui_select")
	if (!Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_up")
	 and !Input.is_action_pressed("ui_accept") and !Input.is_action_pressed("ui_cancel") and !Input.is_action_pressed("ui_select")):
		input_buffer.clear()
	state_machine.process(delta)
