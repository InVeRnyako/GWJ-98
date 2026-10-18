class_name FogTileMapLayer
extends TileMapLayer

const FOG_ATLAS_COORDS : Vector2i = Vector2i(0,0)
const ATLAS_ID : int = 0

var fog_rect : Rect2i

func reset_fog() -> void:
	fog_rect = Global.TILEMAP_BORDERS
	fog_rect.position += Vector2i(-2, -2)
	fog_rect.size += Vector2i(4,4)
	for x in range(fog_rect.position.x , fog_rect.size.x):
		for y in range(fog_rect.position.y , fog_rect.size.y):
			set_fog_at_loc(
				Vector2i(x,y) ,
				true
				)

func is_loc_valid(loc : Vector2i) -> bool:
	return fog_rect.has_point(loc)

func update_fog(locs_to_reveal : Array[Vector2i] , locs_to_hide : Array[Vector2i] = []) -> void:
	for loc in locs_to_hide:
		set_fog_at_loc(loc , true)
	for loc in locs_to_reveal:
		set_fog_at_loc(loc , false)

func set_fog_at_loc(loc : Vector2i , fog_state : bool) -> void:
	if fog_state:
		set_cell(
			loc ,
			ATLAS_ID ,
			FOG_ATLAS_COORDS
		)
	else:
		erase_cell(loc)
