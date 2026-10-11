class_name EnvironmentTileMapLayer
extends TileMapLayer

enum TILE_TYPE{
	DEFAULT ,
	WATER ,
	ERROR = -1
}
const TILESET_TYPES_ATLAS_COORDINATES : Dictionary = {
	TILE_TYPE.DEFAULT : Vector2i(0,0) ,
	TILE_TYPE.ERROR : Vector2i(0, 1) ,
	TILE_TYPE.WATER : [
		Vector2i(1, 0) , Vector2i(1, 1)
		] as Array[Vector2i] ,
}

const ATLAS_ID : int = 0

func get_tile_type_at_loc(loc : Vector2i) -> TILE_TYPE:
	var atlas_coords : Vector2i = get_cell_atlas_coords(loc)
	if atlas_coords == Vector2i(-1,-1):
		push_error("Requested location don't have tile data")
		return TILE_TYPE.ERROR
	
	for type in TILESET_TYPES_ATLAS_COORDINATES.keys():
		if _is_type_have_variations(type):
			for variation in TILESET_TYPES_ATLAS_COORDINATES[type]:
				if variation == atlas_coords:
					return type
		else:
			if TILESET_TYPES_ATLAS_COORDINATES.get(type) == atlas_coords:
				return type
	return TILE_TYPE.ERROR

func set_tile_type_at_loc(type : TILE_TYPE, loc : Vector2i) -> void:
	if not TILESET_TYPES_ATLAS_COORDINATES.has(type):
		push_error("Missing coordinates for type: %s" % [TILE_TYPE.find_key(type)])
		return
	if _is_type_have_variations(type):
		_set_tile_type_with_variation(loc , type)
	else:
		_set_tile_type_without_variations(loc , type)

#region Helpers
func _set_tile_type_without_variations(loc : Vector2i , type : TILE_TYPE) -> void:
	set_cell(loc , ATLAS_ID , TILESET_TYPES_ATLAS_COORDINATES.get(type))

func _set_tile_type_with_variation(loc : Vector2i, type : TILE_TYPE) -> void:
	var variations : Array[Vector2i] = TILESET_TYPES_ATLAS_COORDINATES.get(type)
	set_cell(loc , ATLAS_ID , variations.pick_random())

func _is_type_have_variations(type : TILE_TYPE) -> bool:
	var type_value : Variant = TILESET_TYPES_ATLAS_COORDINATES.get(type)
	if type_value is Vector2i:
		return false
	elif type_value is Array[Vector2i]:
		assert(
			not type_value.is_empty() ,
			"Empty array of coordinates for type: %s" % [TILE_TYPE.find_key(type)]
		)
		return true
	else:
		assert(false, "Wrong type of data in: %s for type: %s" % ["const TILESET_TYPES_ATLAS_COORDINATES" , TILESET_TYPES_ATLAS_COORDINATES.find_key(type)])
		return false
#endregion
