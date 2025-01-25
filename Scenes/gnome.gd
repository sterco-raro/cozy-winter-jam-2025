class_name MagicGnome extends Node2D

#region SIGNALS
signal magic_start()
signal magic_end()
#endregion

#region ONREADY
@onready
var _sprite_idle: Sprite2D = $SpriteIdle
@onready
var _sprite_magic: Sprite2D = $SpriteMagic
@onready
var _sprite_exclamation: Sprite2D = $SpriteExclamationMark
@onready
var _timer: Timer  = $MagicTimer
@onready
var _sounds: AudioStreamPlayer = $MagicSFX
#endregion

func _ready() -> void:
	magic_start.connect(_on_magic_start)

func toggle_sprite() -> void:
	_sprite_idle.visible = not _sprite_idle.visible
	_sprite_magic.visible = not _sprite_magic.visible

func show_exclamation_mark(value: bool) -> void:
	_sprite_exclamation.visible = value

func _on_magic_start():
	toggle_sprite()
	# Do magic stuff
	_timer.start()
	_sounds.play()

func _on_magic_timer_timeout() -> void:
	toggle_sprite()
	if _sounds.playing:
		_sounds.stop()
	magic_end.emit()
