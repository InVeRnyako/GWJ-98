class_name ObsticlesTileMapLayer
extends TileMapLayer

enum TILE_TYPE{
	WHIRLPOOL ,
	NULL = -1 ,
}

const TILESET_TYPES_ATLAS_COORDINATES : Dictionary[TILE_TYPE, Vector2i] = {
	TILE_TYPE.WHIRLPOOL : Vector2i(0,0) ,
}

const ATLAS_ID : int = 0

func is_tile_at_loc(loc : Vector2i) -> bool:
	return get_cell_tile_data(loc) != null

func get_tile_type_at_loc(loc : Vector2i) -> TILE_TYPE:
	var atlas_coords : Vector2i = get_cell_atlas_coords(loc)
	if atlas_coords == Vector2i(-1,-1):
		push_error("Requested location don't have tile data")
		return TILE_TYPE.NULL
	return TILESET_TYPES_ATLAS_COORDINATES.find_key(loc)

func set_tile_type_at_loc(type : TILE_TYPE , loc : Vector2i) -> void:
	if type == TILE_TYPE.NULL:
		erase_cell(loc)
		return
	set_cell(
		loc ,
		ATLAS_ID ,
		TILESET_TYPES_ATLAS_COORDINATES[type]
	)

func erase_tile_at_loc(loc : Vector2i) -> void:
	erase_cell(loc)
