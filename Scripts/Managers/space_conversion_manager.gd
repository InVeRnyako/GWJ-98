class_name SpaceConversionManager
extends Manager

@export_group("Connections")
@export var environment_tile_map_layer: EnvironmentTileMapLayer

func _validate_connections() -> void:
	if not (environment_tile_map_layer):
		push_error("SpaceConversionManager missing @export connection(s)")

func get_location_of_adjacent_tile(loc : Vector2i, direction : Global.DIRECTIONS) -> Vector2i:
	match direction:
		Global.DIRECTIONS.EAST:
			return loc + Vector2i(1,0)
		Global.DIRECTIONS.WEST:
			return loc + Vector2i(-1,0)
		Global.DIRECTIONS.NORTH_EAST:
			return loc + Vector2i(
				loc.y % 2,
				-1)
		Global.DIRECTIONS.NORTH_WEST:
			return loc + Vector2i(
				loc.y % 2 - 1,
				-1)
		Global.DIRECTIONS.SOUTH_EAST:
			return loc + Vector2i(
				loc.y % 2,
				1)
		Global.DIRECTIONS.SOUTH_WEST:
			return loc + Vector2i(
				loc.y % 2 - 1,
				1)
	return Vector2i(-1,-1)

func snap_global_position(global_pos : Vector2) -> Vector2:
	return board_loc_to_global_position(
		board_loc_at_global_position(global_pos)
	)

func board_loc_to_global_position(loc : Vector2i) -> Vector2:
	return environment_tile_map_layer.to_global(
		environment_tile_map_layer.map_to_local(loc)
		)

func board_loc_at_global_position(global_pos : Vector2) -> Vector2i:
	return environment_tile_map_layer.local_to_map(
		environment_tile_map_layer.to_local(global_pos)
	)

func is_valid_location(loc : Vector2i) -> bool:
	return environment_tile_map_layer.get_used_cells().has(loc)
