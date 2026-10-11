class_name ShipManager
extends Manager

@export_group("Connections")
@export var ship: Ship
@export var space_conversion_manager: SpaceConversionManager


func _ready() -> void:
	super._ready()
	update_ship_position()

func _validate_connections() -> void:
	if not (ship):
		push_error("Ship manager have missing @export connection(s)")

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
	var new_ship_location = space_conversion_manager.get_location_of_adjacent_tile(
		ship.current_on_board_location, direction
	)
	ship.global_position = space_conversion_manager.board_loc_to_global_position(
		new_ship_location
	)
	ship.current_on_board_location = new_ship_location
	ship.set_visual_direction(direction)


func _on_temp_test_pressed() -> void:
	test_rotate_ship()
