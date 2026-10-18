class_name ObstaclesTileMapLayer
extends TileMapLayer

enum TILE_TYPE{
	LIGHTHOUSE ,
	WHIRLPOOL , FROG, ROCKS ,
	NULL = -1 ,
}

const TILESET_TYPES_ATLAS_COORDINATES : Dictionary[TILE_TYPE, Vector2i] = {
	TILE_TYPE.LIGHTHOUSE : Vector2i(0,0) ,
	TILE_TYPE.WHIRLPOOL : Vector2i(1,0) ,
	TILE_TYPE.FROG : Vector2i(2,1) ,
	TILE_TYPE.ROCKS : Vector2i(2,0) ,
}

const ATLAS_ID : int = 0

func is_tile_at_loc(loc : Vector2i) -> bool:
	return get_cell_tile_data(loc) != null

func get_tile_type_at_loc(loc : Vector2i) -> TILE_TYPE:
	var atlas_coords : Vector2i = get_cell_atlas_coords(loc)
	if atlas_coords == Vector2i(-1,-1):
		#push_error("Requested location don't have tile data")
		return TILE_TYPE.NULL
	return TILESET_TYPES_ATLAS_COORDINATES.find_key(atlas_coords)

func set_tile_type_at_loc(type : TILE_TYPE , loc : Vector2i) -> void:
	if type == TILE_TYPE.NULL:
		erase_cell(loc)
		return
	set_cell(
		loc ,
		ATLAS_ID ,
		TILESET_TYPES_ATLAS_COORDINATES[type]
	)

func find_tiles_loc_of_type(type : TILE_TYPE) -> Array[Vector2i]:
	var all_tiles : Array[Vector2i] = get_used_cells_by_id(ATLAS_ID)
	var found_tiles_loc : Array[Vector2i] = []
	for loc in all_tiles:
		if get_cell_atlas_coords(loc) == TILESET_TYPES_ATLAS_COORDINATES[type]:
			found_tiles_loc.append(loc)
	return found_tiles_loc

func erase_tile_at_loc(loc : Vector2i) -> void:
	erase_cell(loc)

func get_tile_offset(type : TILE_TYPE) -> Vector2i:
	return (tile_set.get_source(ATLAS_ID) as TileSetAtlasSource)\
		.get_tile_data(
		TILESET_TYPES_ATLAS_COORDINATES[type] , 0
		).texture_origin
