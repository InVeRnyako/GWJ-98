class_name ObstaclesManager
extends Manager

const DEADLY_OBSTACLE_TYPES : Array[ObstaclesTileMapLayer.TILE_TYPE] = [
	ObstaclesTileMapLayer.TILE_TYPE.WHIRLPOOL , 
	ObstaclesTileMapLayer.TILE_TYPE.FROG , 
	ObstaclesTileMapLayer.TILE_TYPE.ROCKS ,
]

const DEFAULT_LIGHTHOUSE_LOC : Vector2i = Vector2i(10,4)

@export_group("Settings")
@export var obstacles_textures : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Texture2D]
@export var obstacles_frame_size : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Vector2i]
# Frame count is assumed to be equal to Vector2i.x * Vector2i.y
@export var frog_attack_distance : int = 1
@export_group("Connections")
@export var obstacles_folder: Folder2D
@export var obstacles_tile_map_layer: ObstaclesTileMapLayer
@export var space_conversion_manager: SpaceConversionManager
@export var environment_tile_map_layer: EnvironmentTileMapLayer
@export var lighthouse_manager: LighthouseManager
@export var frog_tong_line: FrogTong


var obstacle_sprites : Dictionary[ObstaclesTileMapLayer.TILE_TYPE, Array]   = {} # Array[ObstacleSprite]
var animated_types : Array[ObstaclesTileMapLayer.TILE_TYPE] = []
var obstacle_locations : Dictionary[Vector2i , ObstacleSprite] = {}

var frog_eating_ship_at_loc : Vector2i = Vector2i(-1, -1)

#region Setup
func _validate_connections() -> void:
	if not (obstacles_folder and obstacles_tile_map_layer and \
	space_conversion_manager and lighthouse_manager and \
	frog_tong_line):
		push_error("ObstaclesManager missing @export connection(s)")

func setup() -> void:
	_reset()
	_get_obstacles()

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
		if type == ObstaclesTileMapLayer.TILE_TYPE.LIGHTHOUSE:
			var lighthouse_location : Vector2i = DEFAULT_LIGHTHOUSE_LOC
			if locations.size() != 1:
				push_error("ObstaclesManager: There should be exactly 1 lighthouse tile placed on ObstaclesTileMapLayer")
				if locations.size() > 1:
					lighthouse_location = locations.pick_random()
				elif locations.size() == 1:
					lighthouse_location = locations[0]
			lighthouse_manager.setup_lighthouse(
				lighthouse_location , 
				Vector2(obstacles_tile_map_layer.get_tile_offset(
					ObstaclesTileMapLayer.TILE_TYPE.LIGHTHOUSE
					))
			)
			continue
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
	new_sprite.type = type
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
	return DEADLY_OBSTACLE_TYPES.has(loc_type)

func find_frog_at_attack_distance(loc : Vector2i) -> Vector2i:
	var check_area : Array[Vector2i] = \
		space_conversion_manager.get_locations_in_radius_around_loc(
			loc,
			frog_attack_distance
		)
	for possible_frog_loc in check_area:
		if obstacle_locations.has(possible_frog_loc):
			if obstacle_locations[possible_frog_loc].type == ObstaclesTileMapLayer.TILE_TYPE.FROG:
				return possible_frog_loc
	return Vector2i(-1,-1)

func toggle_frog_sprite(at_loc : Vector2i , to_mouth_open : bool) -> void:
	var frog_sprite : ObstacleSprite = obstacle_locations.get(at_loc)
	if frog_sprite == null or frog_sprite.type != ObstaclesTileMapLayer.TILE_TYPE.FROG:
		return
	frog_sprite.frame = int(to_mouth_open)
	if to_mouth_open:
		lighthouse_manager.allways_revealed_zone.append(at_loc)
		frog_tong_line.prepare_to_grab(frog_sprite.global_position)

func drag_ship_into_frog(ship : Ship, frog_loc : Vector2i, travel_time : float) -> void:
	var frog_global_position : Vector2 = space_conversion_manager.board_loc_to_global_position(frog_loc)
	var ship_start_position : Vector2 = ship.global_position
	frog_tong_line.prepare_to_grab(frog_global_position)
	var tween : Tween = create_tween()
	print(ship.global_position)
	tween.tween_method(
		frog_tong_line.change_tong_end_global_pos ,
		frog_global_position , 
		ship_start_position ,
		travel_time
	)
	tween.tween_property(
		ship , 
		"global_position" , 
		frog_global_position,
		travel_time
	)
	tween.parallel().tween_method(
		frog_tong_line.change_tong_end_global_pos ,
		ship_start_position , 
		frog_global_position ,
		travel_time
	)
	await tween.finished
	frog_tong_line.hide()

func _apply_difficulty_settings() -> void:
	match Global.difficulty:
		Global.DIFFICULTIES.EASY:
			frog_attack_distance = 1
		Global.DIFFICULTIES.NORMAL, Global.DIFFICULTIES.HARD:
			frog_attack_distance = 2
		Global.DIFFICULTIES.IMPOSSIBLE:
			frog_attack_distance = 3
