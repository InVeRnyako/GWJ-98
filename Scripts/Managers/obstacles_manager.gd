class_name ObstaclesManager
extends Manager

const deadly_obstacle_types : Array[ObstaclesTileMapLayer.TILE_TYPE] = [
	ObstaclesTileMapLayer.TILE_TYPE.WHIRLPOOL , 
	ObstaclesTileMapLayer.TILE_TYPE.FROG , 
	ObstaclesTileMapLayer.TILE_TYPE.ROCKS ,
]

@export_group("Settings")
@export var obstacles_textures : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Texture2D]
@export var obstacles_frame_size : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Vector2i]
# Frame count is assumed to be equal to Vector2i.x * Vector2i.y
@export_group("Connections")
@export var obstacles_folder: Folder2D
@export var obstacles_tile_map_layer: ObstaclesTileMapLayer
@export var space_conversion_manager: SpaceConversionManager
@export var environment_tile_map_layer: EnvironmentTileMapLayer


var obstacle_sprites : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Array]   = {} # Array[ObstacleSprite]
var animated_types : Array[ObstaclesTileMapLayer.TILE_TYPE] = []
var obstacle_locations : Dictionary[Vector2i , ObstacleSprite] = {}

#region Setup
func _ready() -> void:
	super._ready()
	_reset()
	_get_obstacles()

func _validate_connections() -> void:
	if not (obstacles_folder and obstacles_tile_map_layer and space_conversion_manager):
		push_error("ObstaclesManager missing @export connection(s)")

func _reset() -> void:
	obstacle_sprites.clear()
	animated_types.clear()
	for type in ObstaclesTileMapLayer.TILE_TYPE.values():
		obstacle_sprites[type] = [] as Array[ObstacleSprite]
		
		if obstacles_frame_size.has(type):
			var frame_size : Vector2i = obstacles_frame_size[type]
			if frame_size.x < 1 or frame_size.y < 1:
				push_error("ObstaclesManager: Frame size cannot be less than (1,1).
					Issue with type: %s. Defaulted to (1,1)" % [ObstaclesTileMapLayer.TILE_TYPE.find_key(type)])
				obstacles_frame_size[type] = Vector2i.ONE
			elif frame_size.x > 1 or frame_size.y > 1:
				animated_types.append(type)

func _get_obstacles() -> void:
	for type in obstacles_tile_map_layer.TILE_TYPE.values():
		if type < 0:
			continue
		var locations : Array[Vector2i] = obstacles_tile_map_layer.find_tiles_loc_of_type(
			type
		)
		for loc in locations:
			_create_obstacle_sprite(type , loc)

func _create_obstacle_sprite(type : ObstaclesTileMapLayer.TILE_TYPE, at_loc : Vector2i) -> void:
	var new_sprite = ObstacleSprite.new()
	new_sprite.texture = obstacles_textures.get(type)
	if new_sprite.texture == null:
		push_error("ObstaclesManager: %s type missing texture" % [ObstaclesTileMapLayer.TILE_TYPE.find_key(type)])
		return
	if animated_types.has(type):
		var frame_size : Vector2i = obstacles_frame_size[type]
		new_sprite.hframes = frame_size.x
		new_sprite.vframes = frame_size.y
	new_sprite.loc = at_loc
	obstacles_folder.add_child(new_sprite)
	obstacle_sprites[type].append(new_sprite)
	obstacle_locations[at_loc] = new_sprite
	new_sprite.global_position = \
		space_conversion_manager.board_loc_to_global_position(at_loc) \
		- Vector2(obstacles_tile_map_layer.get_tile_offset(type))
	new_sprite.hide()
#endregion

func advance_animation(animation : AnimationsManager.ANIMATION) -> void:
	var type_to_advance : ObstaclesTileMapLayer.TILE_TYPE = ObstaclesTileMapLayer.TILE_TYPE.NULL
	match animation:
		AnimationsManager.ANIMATION.WHIRLPOOL:
			type_to_advance = ObstaclesTileMapLayer.TILE_TYPE.WHIRLPOOL
		_:
			pass
	if type_to_advance == ObstaclesTileMapLayer.TILE_TYPE.NULL:
		return
	for sprite in obstacle_sprites[type_to_advance]:
		if sprite is ObstacleSprite:
			sprite.frame = \
				(sprite.frame + 1) % \
				(obstacles_frame_size[type_to_advance].x * \
				obstacles_frame_size[type_to_advance].y)
		else:
			push_error("ObstaclesManager: Wrong type of data stored in obstacle_sprites")
			continue

func toggle_obstacle_visibility_at_loc(loc : Vector2i, to_on : bool) -> void:
	if not obstacle_locations.has(loc):
		return
	obstacle_locations[loc].visible = to_on

func is_location_movable_to(loc : Vector2i) -> bool:
	if not Global.TILEMAP_BORDERS.has_point(loc):
		return false
	if environment_tile_map_layer.get_tile_type_at_loc(loc) != EnvironmentTileMapLayer.TILE_TYPE.WATER:
		return false
	return true

func is_location_deadly(loc : Vector2i) -> bool:
	var loc_type : ObstaclesTileMapLayer.TILE_TYPE = obstacles_tile_map_layer.get_tile_type_at_loc(loc)
	return deadly_obstacle_types.has(loc_type)
