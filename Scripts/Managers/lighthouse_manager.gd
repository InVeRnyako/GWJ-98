class_name LighthouseManager
extends Manager

@export_group("Connections")
@export var obsticles_tile_map_layer: ObsticlesTileMapLayer
@export var space_conversion_manager: SpaceConversionManager
@export var lighthouse_light_sprite_2d: Sprite2D
@export var lighthouse_light_way_polygon_2d: Polygon2D


var lighthouse_global_position : Vector2
@export var lighthouse_lightsource_offset : Vector2 = Vector2(0, -32)
var last_light_location : Vector2i = Vector2i(-1, -1)


#region Setup
func _ready() -> void:
	super._ready()
	_find_lighthouse_position()

func _validate_connections() -> void:
	if not (obsticles_tile_map_layer and space_conversion_manager and \
	lighthouse_light_sprite_2d and lighthouse_light_way_polygon_2d):
		push_error("LigthhouseManager missing @export connection(s)")

func _find_lighthouse_position() -> void:
	var ligthhouse_loc : Array[Vector2i] = obsticles_tile_map_layer.find_tiles_loc_of_type(ObsticlesTileMapLayer.TILE_TYPE.LIGHTHOUSE)
	if ligthhouse_loc.is_empty():
		push_error("LighthouseManager: Didn't find lighthouse at %s" % [
			obsticles_tile_map_layer.name])
		return
	if ligthhouse_loc.size() > 1:
		push_error("LighthouseManager: Found multiple lighthouses at %s.
			Locations: %s" % [obsticles_tile_map_layer.name, ligthhouse_loc])
		return
	lighthouse_global_position = space_conversion_manager.board_loc_to_global_position(
		ligthhouse_loc[0]
	)
	print(lighthouse_global_position)
#endregion

func _process(_delta: float) -> void:
	var mouse_loc : Vector2i = space_conversion_manager.get_location_at_mouse_position()
	if last_light_location != mouse_loc:
		_update_light(mouse_loc)

func _update_light(new_location : Vector2i):
	lighthouse_light_sprite_2d.global_position = \
		space_conversion_manager.board_loc_to_global_position(
			new_location
	)
	_update_lightway_polygon()

func _update_lightway_polygon() -> void:
	lighthouse_light_way_polygon_2d.polygon = _get_lightway_points()
	lighthouse_light_way_polygon_2d.queue_redraw()
	
func _get_lightway_points() -> PackedVector2Array:
	var light_sprite_center : Vector2 = lighthouse_light_sprite_2d.global_position
	var light_sprite_radius : float = lighthouse_light_sprite_2d.texture.get_width() / 2.0
	var lighthouse_light_source_position : Vector2 = lighthouse_global_position + lighthouse_lightsource_offset
	
	var direction_to_light : Vector2 = light_sprite_center - lighthouse_light_source_position
	var perpendicular_direction : Vector2 = Vector2.RIGHT
	
	if not is_equal_approx(direction_to_light.length_squared(), 0.0):
		perpendicular_direction = direction_to_light.rotated(deg_to_rad(90)).normalized()
	
	var first_edge_point : Vector2 = light_sprite_center + perpendicular_direction * light_sprite_radius
	var second_edge_point : Vector2 = light_sprite_center - perpendicular_direction * light_sprite_radius
	return PackedVector2Array([
		lighthouse_light_source_position , first_edge_point, second_edge_point
	])
	
