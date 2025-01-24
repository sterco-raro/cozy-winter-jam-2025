extends Node2D

#region ONREADY PROPS
#endregion

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Close the game
	if Input.is_action_just_released("quit"):
		get_tree().quit()

	# Restart
	if Input.is_action_just_released("reset"):
		reset()

func reset() -> void:
	print_debug("RESET")
