class_name ShipManager
extends Manager

const TILEMAP_BORDERS : Rect2i = Rect2i(
	0 , 0 ,
	19 , 14
)

@export_group("Settings")
@export var ship_movement_time : float = 2.0
@export_group("Connections")
@export var ship: Ship
@export var space_conversion_manager: SpaceConversionManager


var ship_tween : Tween = null
var ship_movement_queue : Array[Global.DIRECTIONS] = []


func _ready() -> void:
	super._ready()
	update_ship_position()

func _validate_connections() -> void:
	if not (ship):
		push_error("Ship manager missing @export connection(s)")

func test_rotate_ship() -> void:
	var next_direction_id : int = (ship.current_direction as int + 1) % Global.DIRECTIONS.size()
	ship.set_visual_direction(next_direction_id)

func update_ship_position() -> void:
	ship.global_position = space_conversion_manager.snap_global_position(
		ship.global_position
	)
	ship.current_on_board_location = space_conversion_manager.board_loc_at_global_position(
		ship.global_position
	)

func move_ship(direction : Global.DIRECTIONS):
	ship_movement_queue.append(direction)
	if not (ship_tween != null and ship_tween.is_valid()):
		_process_next_ship_movement()

func _process_next_ship_movement() -> void:
	if ship_movement_queue.is_empty():
		return
	var direction = ship_movement_queue.pop_front()
	var new_ship_location : Vector2i = space_conversion_manager.get_location_of_adjacent_tile(
		ship.current_on_board_location, direction
	)
	if not TILEMAP_BORDERS.has_point(new_ship_location):
		_process_next_ship_movement()
		return
	var new_ship_position = space_conversion_manager.board_loc_to_global_position(
		new_ship_location
	) 
	ship.set_visual_direction(direction)
	if ship_tween != null and ship_tween.is_valid():
		push_error("ShipManager: Ship tween exists while next movement called")
		ship_tween.kill()
	
	ship_tween = create_tween()
	ship_tween.tween_property(
		ship , "global_position" , new_ship_position , ship_movement_time
	)
	ship_tween.finished.connect(_ship_tween_finished.bind(new_ship_location))

func _ship_tween_finished(new_ship_location : Vector2i) -> void:
	ship.current_on_board_location = new_ship_location
	ship_tween.kill()
	_process_next_ship_movement()

func _on_temp_test_pressed() -> void:
	test_rotate_ship()
