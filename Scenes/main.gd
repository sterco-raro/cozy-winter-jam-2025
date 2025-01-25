extends Node2D

#region PROPS
var action_in_progress: bool = false

var active_decoration: Decoration
var decorations: Array[Decoration]

var interactables: Array[Interactable]

var prefab_interactable: PackedScene = preload("res://Scenes/interactable.tscn")

var items_data = [
	[ "res://Assets/Graphics/pencils-broken.png", "res://Assets/Graphics/pencils-fixed.png"]
]
#endregion

#region ONREADY
@onready
var gnome: MagicGnome = $Gnome
@onready
var gnome_surprised_timer: Timer = $Gnome/SurpriseTimer
@onready
var _interactables_container: Node2D = $Objects
#endregion

#region DATA
const LEFT_X: int = -320
const LEFT_Y: int = -80
const RIGHT_X: int = 320
const RIGHT_Y: int = 60
#endregion

func _ready() -> void:
	EventBus.task_start.connect(_on_task_start)
	EventBus.task_end.connect(_on_task_end)

	decorations.append($Decoration1)
	decorations.append($Decoration2)
	decorations.shuffle()

	# Spawn random interactable objects
	reset()

func _process(_delta: float) -> void:
	# Close the game
	if Input.is_action_just_released("quit"):
		get_tree().quit()

	## Restart
	#if Input.is_action_just_released("reset"):
		#action_in_progress = true
		#gnome.toggle_exclamation_mark()
		#gnome.magic_start.emit()
		#if decorations.size() > 0:
			#active_decoration = decorations.pop_back()
			#active_decoration.vfx_start.emit()

	# Ending condition
	# TODO block processing and show ending screen
	#if not EventBus.action_in_progress and decorations.size() == 0:
		#print("YAY")
		#get_tree().paused = true

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

		var texture = ImageTexture.new()
		var data = items_data.pick_random()
		obj.texture_broken = texture.create_from_image(Image.load_from_file(data[0]))
		obj.texture_fixed = texture.create_from_image(Image.load_from_file(data[1]))

		interactables.append(obj)

		# Add to scene tree
		_interactables_container.add_child(obj)

func is_valid_spawn_point(point: Vector2) -> bool:
	# Ensure that the distance between each interactable object is >= 64
	for i in range(interactables.size()):
		if interactables[i].position.distance_to(point) < 64:
			return false
	return true

func _on_task_start(id: int) -> void:
	EventBus.action_in_progress = true
	gnome.show_exclamation_mark(true)

func _on_task_end(id: int) -> void:
	gnome.show_exclamation_mark(false)
	# TODO add different decorations
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
	if not EventBus.action_in_progress and event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			gnome.show_exclamation_mark(true)
			gnome_surprised_timer.start()

func _on_surprise_timer_timeout() -> void:
	if not EventBus.action_in_progress:
		gnome.show_exclamation_mark(false)
