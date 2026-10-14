class_name FogTileMapLayer
extends TileMapLayer

const FOG_ATLAS_COORDS : Vector2i = Vector2i(0,0)
const ATLAS_ID : int = 0

func reset_fog(lighthouse_revealed_zone : Array[Vector2i]) -> void:
	clear()
	var fog_zone : Rect2i = Global.TILEMAP_BORDERS
	fog_zone.position += Vector2i(-2, -2)
	fog_zone.size += Vector2i(4,4)
	for x in range(fog_zone.position.x , fog_zone.size.x):
		for y in range(fog_zone.position.y , fog_zone.size.y):
			var loc : Vector2i = Vector2i(x,y)
			if not lighthouse_revealed_zone.has(loc):
				set_fog_at_loc(loc , true)

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
