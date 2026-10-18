class_name LighthouseManager
extends Manager

const LIGHT_BEAM_LIGHTSOURCE_OFFSET : Vector2 = Vector2(0, -30)

@export_group("Settings")
@export_range(1, 7) var lighthouse_light_radius : int = 1
@export_range(1, 7) var lighthouse_around_light_radius : int = 1
@export_range(0, 7) var ship_light_radius : int = 1
@export_group("Connections")
@export_subgroup("Managers")
@export var ship_manager: ShipManager
@export var obstacles_manager: ObstaclesManager
@export var morse_code_manager: MorseCodeManager
@export var space_conversion_manager: SpaceConversionManager

@export_subgroup("Other")
@export var obstacles_tile_map_layer: ObstaclesTileMapLayer
@export var fog_tile_map_layer: FogTileMapLayer
@export var lighthouse_light_circle: DynamicCircle
@export var lighthouse_light_way_polygon_2d: Polygon2D
@export var lighthouse_sprite_2d: LighthouseSprite2D



var lighthouse_global_position : Vector2

var last_light_location : Vector2i = Vector2i(-1, -1)
var lighthouse_allways_revealed_zone : Array[Vector2i] = []
var lightbeam_revealed_zone : Array[Vector2i] = []
var ship_revealed_zone : Array[Vector2i] = []

#region Setup
func _validate_connections() -> void:
	if not (ship_manager and obstacles_manager and \
	morse_code_manager and space_conversion_manager):
		push_error("lighthouseManager missing [manager] @export connection(s)")
	
	if not (obstacles_tile_map_layer and fog_tile_map_layer and \
	lighthouse_light_circle and lighthouse_light_way_polygon_2d and 
	lighthouse_sprite_2d):
		push_error("lighthouseManager missing [other] @export connection(s)")

func _connect_signals() -> void:
	ship_manager.ship_finished_moving.connect(update_ship_revealed_zone)
	SignalBus.light_switched.connect(_light_toggled)

func setup() -> void:
	_prepare_circle()
	_reset_fog()
	_light_toggled(false)

func _prepare_circle() -> void:
	var circle_radius = \
		(lighthouse_light_radius - 1) * Global.TILE_CENTER_TO_CENTER_DISTANCE + \
		Global.TILE_SIDE / 2
	lighthouse_light_circle.set_circle(
		circle_radius,
		Color(1.0, 0.976, 0.753)
	)

func _reset_fog() -> void:
	fog_tile_map_layer.reset_fog()
	_reveal_zone(lighthouse_allways_revealed_zone)
	update_ship_revealed_zone()

func setup_lighthouse(at_loc : Vector2i, position_offset : Vector2) -> void:
	lighthouse_global_position = space_conversion_manager.board_loc_to_global_position(
		at_loc
	)
	lighthouse_sprite_2d.global_position = lighthouse_global_position - position_offset
	lighthouse_allways_revealed_zone = \
		space_conversion_manager.get_locations_in_radius_around_loc(
			at_loc , lighthouse_around_light_radius
		)
	_reset_fog()
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				SignalBus.light_switched.emit(true)
			elif event.is_released():
				SignalBus.light_switched.emit(false)
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_loc : Vector2i = space_conversion_manager.get_location_at_mouse_position()
			if last_light_location != mouse_loc:
				_update_lightbeam_visual()
				last_light_location = mouse_loc
				_update_lightbeam_revealed_zone(true)

func _light_toggled(to_on : bool) -> void:
	_toggle_lightbeam_visibility(to_on)
	if to_on:
		_update_lightbeam_visual()
		lighthouse_sprite_2d.set_state(LighthouseSprite2D.STATE.TURN_ON)
	else:
		lighthouse_sprite_2d.set_state(LighthouseSprite2D.STATE.TURN_OFF)
	_update_lightbeam_revealed_zone(to_on)

#region Lightbeam
func _update_lightbeam_revealed_zone(light_on : bool) -> void:
	var lightbeam_zone : Array[Vector2i] = []
	if light_on:
		lightbeam_zone = space_conversion_manager.get_locations_in_radius_around_loc(
			space_conversion_manager.get_location_at_mouse_position() ,
			lighthouse_light_radius
		)
	var zone_to_hide : Array[Vector2i] = lightbeam_revealed_zone.duplicate()
	for loc in lighthouse_allways_revealed_zone:
		zone_to_hide.erase(loc)
	for loc in ship_revealed_zone:
		zone_to_hide.erase(loc)
	_hide_zone(zone_to_hide)
	_reveal_zone(lightbeam_zone)
	lightbeam_revealed_zone = lightbeam_zone

func _update_lightbeam_visual():
	lighthouse_light_circle.global_position = \
		space_conversion_manager.board_loc_to_global_position(
			space_conversion_manager.get_location_at_mouse_position()
	)
	_update_lightway_polygon()
	#last_light_location = new_location

func _toggle_lightbeam_visibility(to_on : bool) -> void:
	lighthouse_light_circle.visible = to_on
	lighthouse_light_way_polygon_2d.visible = to_on

func _update_lightway_polygon() -> void:
	lighthouse_light_way_polygon_2d.polygon = _get_lightway_points()
	lighthouse_light_way_polygon_2d.queue_redraw()
	
func _get_lightway_points() -> PackedVector2Array:
	var light_sprite_center : Vector2 = lighthouse_light_circle.global_position
	var light_sprite_radius : float = lighthouse_light_circle.radius
	var lighthouse_light_source_position : Vector2 = lighthouse_global_position + LIGHT_BEAM_LIGHTSOURCE_OFFSET
	
	var direction_to_light : Vector2 = light_sprite_center - lighthouse_light_source_position
	var perpendicular_direction : Vector2 = Vector2.RIGHT
	
	if not is_equal_approx(direction_to_light.length_squared(), 0.0):
		perpendicular_direction = direction_to_light.rotated(deg_to_rad(90)).normalized()
	
	var first_edge_point : Vector2 = light_sprite_center + perpendicular_direction * light_sprite_radius
	var second_edge_point : Vector2 = light_sprite_center - perpendicular_direction * light_sprite_radius
	

	return PackedVector2Array([
		first_edge_point ,
		second_edge_point ,
		lighthouse_light_source_position
		])
#endregion

func update_ship_revealed_zone() -> void:
	var reveal_zone : Array[Vector2i] = \
		space_conversion_manager.get_locations_in_radius_around_loc(
			ship_manager.ship.current_on_board_location ,
			ship_light_radius
		)
	if ship_manager.ship.visible == false:
		reveal_zone = []
	elif ship_manager.ship.is_sinking:
		reveal_zone = [ship_manager.ship.current_on_board_location]
	var hide_zone : Array[Vector2i] = ship_revealed_zone
	for zone in [lightbeam_revealed_zone, lighthouse_allways_revealed_zone]:
		for loc in zone:
			hide_zone.erase(loc)
	_hide_zone(hide_zone)
	_reveal_zone(reveal_zone)
	ship_revealed_zone = reveal_zone

func _reveal_zone(zone : Array[Vector2i]) -> void:
	for loc in zone:
		if not fog_tile_map_layer.is_loc_valid(loc):
			continue
		fog_tile_map_layer.set_fog_at_loc(loc , false)
		obstacles_manager.toggle_obstacle_visibility_at_loc(loc , true)

func _hide_zone(zone : Array[Vector2i]) -> void:
	for loc in zone:
		if not fog_tile_map_layer.is_loc_valid(loc):
			continue
		if lighthouse_allways_revealed_zone.has(loc):
			continue
		fog_tile_map_layer.set_fog_at_loc(loc , true)
		obstacles_manager.toggle_obstacle_visibility_at_loc(loc , false)
