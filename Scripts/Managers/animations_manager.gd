class_name AnimationsManager
extends Manager

enum ANIMATION{
	FOG , WHIRLPOOL ,
}
const FRAME_COUNT_RESET_AFTER : int = 99999
const FOG_SCROLL_PARAMETER_NAME : String = "manual_scroll"

@export_group("Settings")
@export var animation_every_frames : Dictionary[ANIMATION , int]
@export_subgroup("Animation specific settings")
@export var fog_advance_distance : float = 1.0
@export_group("Connections")
@export var fog_tile_map_layer: FogTileMapLayer
@export var obstacles_manager: ObstaclesManager


var current_frame_count : int = 0

func _advance_fog() -> void:
	var fog_material : ShaderMaterial = fog_tile_map_layer.material
	fog_material.set_shader_parameter(
		FOG_SCROLL_PARAMETER_NAME , 
		fog_material.get_shader_parameter(
			FOG_SCROLL_PARAMETER_NAME
		) + fog_advance_distance
	)

func _next_frame() -> void:
	current_frame_count += 1
	for animation in animation_every_frames.keys():
		if current_frame_count % animation_every_frames[animation] == 0:
			_advance_animation(animation)
	if current_frame_count > FRAME_COUNT_RESET_AFTER:
		current_frame_count = 0

func _advance_animation(animation : ANIMATION) -> void:
	match animation:
		ANIMATION.FOG:
			_advance_fog()
		ANIMATION.WHIRLPOOL: # add new obstacle animations here
			obstacles_manager.advance_animation(animation)

func _on_animation_timer_timeout() -> void:
	_next_frame()
