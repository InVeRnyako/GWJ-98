class_name Ship
extends Sprite2D

signal ship_sinked

const DIRECTIONS_FRAMES : Dictionary[Global.DIRECTIONS , int] = {
	Global.DIRECTIONS.NORTH_EAST : 0,
	Global.DIRECTIONS.EAST : 1,
	Global.DIRECTIONS.SOUTH_EAST : 2,
	Global.DIRECTIONS.NORTH_WEST : 0,
	Global.DIRECTIONS.WEST : 1,
	Global.DIRECTIONS.SOUTH_WEST : 2 ,
}
const DIRECTIONS_FLIP_H : Dictionary[Global.DIRECTIONS , bool] = {
	Global.DIRECTIONS.NORTH_EAST : true,
	Global.DIRECTIONS.EAST : true,
	Global.DIRECTIONS.SOUTH_EAST : true,
	Global.DIRECTIONS.NORTH_WEST : false,
	Global.DIRECTIONS.WEST : false,
	Global.DIRECTIONS.SOUTH_WEST : false ,
}

const SINKING_ANIMATION_FRAME_START : int = 4
const SINKING_ANIMATION_FRAME_FINISH : int = 7

var current_on_board_location : Vector2i = Vector2i(-1,-1)
var current_direction : Global.DIRECTIONS = Global.DIRECTIONS.NORTH_WEST
var can_move : bool = true
var is_sinking : bool = false

func set_visual_direction(direction : Global.DIRECTIONS) -> void:
	frame = DIRECTIONS_FRAMES[direction]
	flip_h = DIRECTIONS_FLIP_H[direction]
	current_direction = direction

func start_sinking() -> void:
	is_sinking = true
	frame = SINKING_ANIMATION_FRAME_START

func advance_sinking_animation() -> void:
	if frame < SINKING_ANIMATION_FRAME_FINISH:
		frame += 1
	else:
		hide()
		#is_sinking = false
		ship_sinked.emit()
