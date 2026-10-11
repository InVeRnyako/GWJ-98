class_name Ship
extends Sprite2D

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

var current_on_board_location : Vector2i = Vector2i(-1,-1)
var current_direction : Global.DIRECTIONS = Global.DIRECTIONS.NORTH_WEST

func set_visual_direction(direction : Global.DIRECTIONS) -> void:
	frame = DIRECTIONS_FRAMES[direction]
	flip_h = DIRECTIONS_FLIP_H[direction]
	current_direction = direction
