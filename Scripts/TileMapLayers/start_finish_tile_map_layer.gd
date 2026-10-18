class_name StartFinishTileMapLayer
extends TileMapLayer

const ATLAS_ID : int = 0

enum TILE_TYPE{
	START ,
	FINISH , 
	NULL = -1
}

const TILE_ATLAS_COORDINATES : Dictionary[TILE_TYPE , Vector2i] = {
	TILE_TYPE.START : Vector2i(1,0) , 
	TILE_TYPE.FINISH : Vector2i(0,0) ,
	
	TILE_TYPE.NULL : Vector2i(-1,-1) ,
}

var start_zone : Array[Vector2i] = []
var finish_zone : Array[Vector2i] = []
var keep_revealed_zone : Array[Vector2i] = []

func _ready() -> void:
	_setup()

func _setup() -> void:
	hide()
	var cells_to_erase : Array[Vector2i] = []
	for loc in get_used_cells():
		var tile_type : TILE_TYPE = get_tile_type_at_loc(loc)
		match tile_type:
			TILE_TYPE.START:
				start_zone.append(loc)
			TILE_TYPE.FINISH:
				finish_zone.append(loc)
			_:
				pass
		if not Global.TILEMAP_BORDERS.has_point(loc):
			cells_to_erase.append(loc)
			continue
	keep_revealed_zone.append_array(start_zone)
	keep_revealed_zone.append_array(finish_zone)
	for loc in cells_to_erase:
		erase_cell(loc)
		start_zone.erase(loc)
		finish_zone.erase(loc)

func get_tile_type_at_loc(loc : Vector2i) -> TILE_TYPE:
	var atlas_coords : Vector2i = get_cell_atlas_coords(loc)
	if atlas_coords == Vector2i(-1,-1):
		return TILE_TYPE.NULL
	
	for type in TILE_ATLAS_COORDINATES.keys():
		if TILE_ATLAS_COORDINATES.get(type) == atlas_coords:
			return type
	return TILE_TYPE.NULL

func get_start_zone() -> Array[Vector2i]:
	return start_zone

func get_finish_zone() -> Array[Vector2i]:
	return finish_zone
