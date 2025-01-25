class_name Decoration extends Node2D

#region SIGNALS
signal vfx_start()
signal vfx_stop()
#endregion

#region EXPORT
@export
var texture: Texture
@export_category("Particles")
@export
var amount: int = 8
@export_range(1, 100)
var emission_box_x: int = 1
@export_range(1, 100)
var emission_box_y: int = 1
#endregion

#region ONREADY
@onready
var _sprite: Sprite2D = $Sprite2D
@onready
var _particles: GPUParticles2D = $Sparkles
#endregion

func _ready() -> void:
	vfx_start.connect(_on_vfx_start)
	vfx_stop.connect(_on_vfx_stop)
	# Hide sprite at startup
	_sprite.visible = false
	_sprite.texture = texture
	# Amount of particles to spawn
	_particles.amount = amount
	# Emission shape
	var material: ParticleProcessMaterial = _particles.process_material
	material.emission_box_extents = Vector3(emission_box_x, emission_box_y, 1)

func _on_vfx_start() -> void:
	_particles.emitting = true

func _on_vfx_stop() -> void:
	_sprite.visible = true
	_particles.emitting = false
