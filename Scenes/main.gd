extends Node2D

#region PROPS
var action_in_progress: bool = false
#endregion

#region ONREADY
@onready
var gnome: MagicGnome = $Gnome
#endregion

#region DATA
const up_left: Vector2 = Vector2(-380, -140)
const up_right: Vector2 = Vector2(380, -140)
const bot_left: Vector2 = Vector2(-400, 80)
const bot_right: Vector2 = Vector2(400, 80)
#endregion

func _ready() -> void:
	EventBus.task_start.connect(_on_task_start)
	EventBus.task_end.connect(_on_task_end)

func _process(_delta: float) -> void:
	# Close the game
	if Input.is_action_just_released("quit"):
		get_tree().quit()

	# Restart
	if Input.is_action_just_released("reset"):
		reset()

func reset() -> void:
	print_debug("RESET")
	gnome.magic_start.emit()

func _on_task_start(id: int, title: String) -> void:
	action_in_progress = true
	# TODO add exclamation mark above gnome's head

func _on_task_end(id: int, title: String) -> void:
	action_in_progress = false
	# TODO remove exclamation mark above gnome's head
	# TODO choose decoration and activate popup vfx and sfx
	gnome.magic_start.emit()

func _on_gnome_magic_end() -> void:
	pass # Replace with function body.
