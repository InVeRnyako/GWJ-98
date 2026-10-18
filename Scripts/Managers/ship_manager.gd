class_name ShipManager
extends Manager

signal ship_finished_moving()

@export_group("Settings")
@export_range(0.1 , 10.0, 0.1) var ship_movement_time : float = 2.0
@export_group("Connections")
@export var ship: Ship
@export var space_conversion_manager: SpaceConversionManager
@export var lighthouse_manager: LighthouseManager
@export var obstacles_manager: ObstaclesManager
@export var ui_canvas_layer: CanvasLayer

var ship_tween : Tween = null
var ship_movement_queue : Array[Global.DIRECTIONS] = []

func _validate_connections() -> void:
	if not (ship and \
	space_conversion_manager and lighthouse_manager and obstacles_manager):
		push_error("Ship manager missing @export connection(s)")

func setup() -> void:
	_update_ship_position()

func test_rotate_ship() -> void:
	var next_direction_id : int = (ship.current_direction as int + 1) % Global.DIRECTIONS.size()
	ship.set_visual_direction(next_direction_id)

func _update_ship_position() -> void:
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
	if not ship.can_move:
		return
	if ship_movement_queue.is_empty():
		return
	var direction = ship_movement_queue.pop_front()
	var new_ship_location : Vector2i = space_conversion_manager.get_location_of_adjacent_tile(
		ship.current_on_board_location, direction
	)
	if not obstacles_manager.is_location_movable_to(new_ship_location):
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
	ship_finished_moving.emit()
	ship_tween.kill()
	if obstacles_manager.is_location_deadly(new_ship_location):
		ship.can_move = false
		_sink_ship()
	else:
		var frog_attacking_loc = obstacles_manager.find_frog_at_attack_distance(new_ship_location)
		if frog_attacking_loc != Vector2i(-1,-1):
			ship.can_move = false
			obstacles_manager.toggle_frog_sprite(frog_attacking_loc, true)
			await obstacles_manager.drag_ship_into_frog(
				ship, 
				frog_attacking_loc ,
				ship_movement_time * 5
			)
			ship.current_on_board_location = frog_attacking_loc
			_sink_ship()
		else:
			_process_next_ship_movement()

func _on_temp_test_pressed() -> void:
	test_rotate_ship()

func _sink_ship() -> void:
	ship.start_sinking()
	ship.ship_sinked.connect(_ship_finished_sinking, CONNECT_ONE_SHOT)
	lighthouse_manager.update_ship_revealed_zone()


func advance_ship_sinking_animation() -> void:
	if ship.is_sinking:
		ship.advance_sinking_animation()

func _on_sink_ship_button_pressed() -> void:
	_sink_ship()

func _ship_finished_sinking() -> void:
	lighthouse_manager.update_ship_revealed_zone()
	SceneManager.pop_subscene(
		SceneManager.SUBSCENE.GAME_OVER_LOSE, ui_canvas_layer
	)
