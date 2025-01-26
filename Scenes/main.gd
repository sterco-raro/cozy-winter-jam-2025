extends Node2D

#region PROPS
var action_in_progress: bool = false

var active_decoration: Decoration
var decorations: Array[Decoration]

var interactables: Array[Interactable]

var prefab_interactable: PackedScene = preload("res://Scenes/interactable.tscn")

@export
var textures: Array[Array] = []

var is_gnome_surprised: bool = false
#endregion

#region ONREADY
@onready
var gnome: MagicGnome = $Gnome
@onready
var gnome_surprised_timer: Timer = $Gnome/SurpriseTimer
@onready
var gnome_surprised_sfx: AudioStreamPlayer = $Gnome/SurpriseSFX
@onready
var _interactables_container: Node2D = $Objects
@onready
var _hud: CanvasLayer = $HUD
@onready
var _ending_sfx: AudioStreamPlayer = $EndingSFX
#endregion

#region DATA
const LEFT_X: int = -320
const LEFT_Y: int = -80
const RIGHT_X: int = 320
const RIGHT_Y: int = 60
#endregion

func _ready() -> void:
	_hud.hide()

	EventBus.task_start.connect(_on_task_start)
	EventBus.task_end.connect(_on_task_end)

	decorations.append($Decoration1)
	decorations.append($Decoration2)
	decorations.append($Decoration3)
	decorations.append($Decoration4)
	decorations.shuffle()

	$Decoration1.vfx_stop.connect(_on_decoration_vfx_stop)
	$Decoration2.vfx_stop.connect(_on_decoration_vfx_stop)
	$Decoration3.vfx_stop.connect(_on_decoration_vfx_stop)
	$Decoration4.vfx_stop.connect(_on_decoration_vfx_stop)

	# Spawn random interactable objects
	reset()

func _process(_delta: float) -> void:
	# Close the game
	if Input.is_action_just_released("quit"):
		get_tree().quit()

func reset() -> void:
	var x: int
	var y: int
	var obj: Interactable
	# One object for each available reward
	for i in range(decorations.size()):
		# Choose random object position
		x = randi_range(LEFT_X, RIGHT_X)
		y = randi_range(LEFT_Y, RIGHT_Y)
		while (not is_valid_spawn_point(Vector2(x, y))):
			x = randi_range(LEFT_X, RIGHT_X)
			y = randi_range(LEFT_Y, RIGHT_Y)
		# Instantiate prefab
		obj = prefab_interactable.instantiate() as Interactable
		obj.id = i
		obj.position = Vector2(x, y)

		var data = textures.pick_random()
		obj.texture_broken = data[0]
		obj.texture_fixed = data[1]

		interactables.append(obj)

		# Add to scene tree
		_interactables_container.add_child(obj)

func is_valid_spawn_point(point: Vector2) -> bool:
	# Ensure that the distance between each interactable object is >= 64
	for i in range(interactables.size()):
		if interactables[i].position.distance_to(point) < 64:
			return false
	return true

func _on_task_start(_id: int) -> void:
	EventBus.action_in_progress = true
	gnome.show_exclamation_mark(true)

func _on_task_end(_id: int) -> void:
	gnome.show_exclamation_mark(false)
	if decorations.size() > 0:
		active_decoration = decorations.pop_back()
		active_decoration.vfx_start.emit()
	gnome.magic_start.emit()

func _on_gnome_magic_end() -> void:
	EventBus.action_in_progress = false
	if active_decoration:
		active_decoration.vfx_stop.emit()
	active_decoration = null

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_gnome_surprised and not EventBus.action_in_progress and event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			gnome.show_exclamation_mark(true)
			gnome_surprised_timer.start()
			gnome_surprised_sfx.play()
			is_gnome_surprised = true

func _on_surprise_timer_timeout() -> void:
	if not EventBus.action_in_progress:
		gnome.show_exclamation_mark(false)
	is_gnome_surprised = false

func _on_decoration_vfx_stop() -> void:
	# Show ending screen when there's nothing else to do
	if not EventBus.action_in_progress and decorations.size() == 0:
		$EndingTimer.start()

func _on_ending_timer_timeout() -> void:
	get_tree().paused = true
	_hud.show()
	_ending_sfx.play()
