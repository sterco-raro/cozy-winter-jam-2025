class_name Interactable extends Node2D

# Identity
@export
var id: int

# Sprites
@export_category("Sprites")
@export
var texture_broken: Texture
@export
var texture_fixed: Texture

# Status
var _action_complete: bool = false

#region ONREADY PROPS
# Sprites
@onready
var _sprite_broken: Sprite2D = $SpriteBroken
@onready
var _sprite_fixed: Sprite2D = $SpriteFixed

# VFX/SFX
@onready
var _sounds: AudioStreamPlayer = $TidyUpSFX
@onready
var _particles: GPUParticles2D = $DustClouds
@onready
var _timer: Timer = $Timer
@onready
var _progress: ProgressBar = $UI/ProgressBar
#endregion

func _ready() -> void:
	_progress.min_value = 0
	_progress.max_value = _timer.wait_time
	# Assign sprites
	_sprite_broken.texture = texture_broken
	_sprite_fixed.texture = texture_fixed

func _process(_delta: float) -> void:
	if not _timer.paused:
		_progress.value = _timer.wait_time - _timer.time_left

func toggle_sprite() -> void:
	_sprite_broken.visible = not _sprite_broken.visible
	_sprite_fixed.visible = not _sprite_fixed.visible

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not EventBus.action_in_progress and not _action_complete:
		if event is InputEventMouseButton:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				# Start task
				_timer.start()
				_sounds.play()
				_particles.emitting = true
				_progress.visible = true
				EventBus.task_start.emit(id)

func _on_timer_timeout() -> void:
	# Task complete
	_action_complete = true
	if _sounds.playing:
		_sounds.stop()
	_particles.emitting = false
	_progress.visible = false
	toggle_sprite()
	EventBus.task_end.emit(id)
