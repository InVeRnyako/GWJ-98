class_name MorseCodeManager
extends Manager

enum MORSE_SIGN{
	DOT , LINE
}

enum MORSE_STATE{
	NONE , DOT , LINE
}

@export_group("Settings")
@export var directions_morse_combinations : Dictionary[Global.DIRECTIONS, MorseCombination]
@export_group("Connections")
@export var line_timer: Timer
@export var over_hold_timer: Timer
@export var force_reset_timer: Timer
@export var directional_compass: DirectionalCompass
@export var ship_manager: ShipManager

var current_morse_combination : Array[MORSE_SIGN] = []
var possible_directions_from_current_code : Array[Global.DIRECTIONS] = []
var ignore_signal : bool = false

func _ready() -> void:
	super._ready()
	_set_timer_settings()

func _validate_connections() -> void:
	if not (line_timer and over_hold_timer):
		push_error("MorseCodeManager missing @export connection(s)")
	_directions_morse_combinations_check()

func _connect_signals() -> void:
	SignalBus.light_switched.connect(light_switched)

func light_switched(to_on : bool) -> void:
	if force_reset_timer.is_stopped():
		if to_on:
			line_timer.start()
			_update_hint_on_morse_character_changed(MORSE_STATE.DOT)
			over_hold_timer.start()
		else:
			if ignore_signal:
				ignore_signal = false
			else:
				if line_timer.is_stopped():
					add_sign_to_combination(MORSE_SIGN.LINE)
				else:
					add_sign_to_combination(MORSE_SIGN.DOT)
					line_timer.stop()
				over_hold_timer.start()

func add_sign_to_combination(new_sign : MORSE_SIGN) -> void:
	current_morse_combination.append(new_sign)
	update_directional_compass()

func update_directional_compass() -> void:
	if current_morse_combination.is_empty():
		directional_compass.reset_sectors()
		return
	var failed_directions : Array[Global.DIRECTIONS] = Global.ALL_DIRECTIONS.duplicate()
	var partially_completed_directions : Array[Global.DIRECTIONS] = _find_partially_completed_directions()
	var fully_completed_direction : Array[Global.DIRECTIONS] = _find_fully_completed_direction()
	
	for direction in partially_completed_directions:
		failed_directions.erase(direction)
	if fully_completed_direction.size() == 1:
		failed_directions.erase(fully_completed_direction[0])
		_set_compass(
			fully_completed_direction[0],
			DirectionalCompass.SECTOR_STATE.COMPLETE
		)
		
	
	for direction in partially_completed_directions:
		_set_compass(
			direction , DirectionalCompass.SECTOR_STATE.PARTIAL
		)
	for direction in failed_directions:
		_set_compass(
			direction , DirectionalCompass.SECTOR_STATE.FAILED
		)
	if failed_directions.size() == Global.ALL_DIRECTIONS.size():
		force_reset_timer.start()

func _find_partially_completed_directions() -> Array[Global.DIRECTIONS]:
	var possible_directions : Array[Global.DIRECTIONS] = []
	var code_size : int = current_morse_combination.size()
	for direction in directions_morse_combinations.keys():
		var combination : Array[MORSE_SIGN] = directions_morse_combinations[direction].combination
		if combination.size() > code_size and \
		combination.slice(0, code_size) == current_morse_combination:
			possible_directions.append(direction)
	return possible_directions

func _find_fully_completed_direction() -> Array[Global.DIRECTIONS]:
	for direction in directions_morse_combinations.keys():
		if directions_morse_combinations[direction].combination == current_morse_combination:
			return [direction]
	return []

func apply_combination() -> void:
	var fully_completed_direction = _find_fully_completed_direction()
	if fully_completed_direction.size() != 1:
		return
	ship_manager.move_ship(fully_completed_direction[0])

func reset_combination() -> void:
	current_morse_combination.clear()
	update_directional_compass()

func _on_over_hold_timer_timeout() -> void:
	if _is_light_on():
		ignore_signal = true
	else:
		apply_combination()
	_update_hint_on_morse_character_changed(MORSE_STATE.NONE)
	reset_combination()

func _directions_morse_combinations_check() -> bool:
	for direction in Global.DIRECTIONS.values():
		if not directions_morse_combinations.keys().has(direction):
			push_error("MorseCodeManager: Missing morse combination for %s" % [
				Global.DIRECTIONS.find_key(direction)])
			continue
		var combination = directions_morse_combinations[direction].combination
		if combination.is_empty():
			push_error("MorseCodeManager: Combination for %s is empty" % [
				Global.DIRECTIONS.find_key(direction)])
			continue
	return false

func _is_light_on() -> bool:
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _on_force_reset_timer_timeout() -> void:
	reset_combination()
	ignore_signal = false

func _set_compass(direction : Global.DIRECTIONS , state : DirectionalCompass.SECTOR_STATE) -> void:
	directional_compass.set_sector_state(direction , state)
	#directional_compass.set_hint_state(direction , state)

func _update_hint_on_morse_character_changed(next_character : MORSE_STATE) -> void:
	match next_character:
		MORSE_STATE.NONE:
			directional_compass.toggle_center_highlight(false, false)
		MORSE_STATE.DOT:
			directional_compass.toggle_center_highlight(true, false)
		MORSE_STATE.LINE:
			directional_compass.toggle_center_highlight(false, true)

func _debug_print_directions(directions : Array[Global.DIRECTIONS]) -> void:
	var string_to_print : String = ""
	for d in directions:
		if not string_to_print.is_empty():
			string_to_print += ", "
		string_to_print += Global.DIRECTIONS.find_key(d)
	print(string_to_print)

func _debug_string_of_current_combination() -> String:
	var result : String = ""
	for s in current_morse_combination:
		if not result.is_empty():
			result += ", "
		result += MORSE_SIGN.find_key(s)
	return result


func _on_line_timer_timeout() -> void:
	_update_hint_on_morse_character_changed(MORSE_STATE.LINE)

func _set_timer_settings() -> void:
	line_timer.wait_time = Global.line_time
	over_hold_timer.wait_time = Global.overhold_time
