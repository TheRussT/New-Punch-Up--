extends Node2D

@onready var animations = $Animations
@onready var state_machine = $State_Machine
@onready var sprite = $Boss
@onready var falling_sprite = $Boss_Falling

var available_hits = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.init(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_machine.process(delta)
