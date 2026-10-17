class_name DirectionalCompass
extends Node2D

enum SECTOR_STATE{
	NORMAL , PARTIAL , COMPLETE , FAILED
}

const STATE_MODULATES : Dictionary[SECTOR_STATE , Color] = {
	SECTOR_STATE.NORMAL : Color.WHITE ,
	SECTOR_STATE.PARTIAL : Color.YELLOW ,
	SECTOR_STATE.COMPLETE : Color.GREEN ,
	SECTOR_STATE.FAILED : Color.RED ,
}

@export_group("Internal connections")
@export var sectors : Dictionary[Global.DIRECTIONS , Sprite2D]
@export var hints : Dictionary[Global.DIRECTIONS , Sprite2D]
@export var center_out_sprite_2d: Sprite2D
@export var center_in_sprite_2d: Sprite2D


func _ready() -> void:
	reset_sectors()

func set_sector_state(
	direction : Global.DIRECTIONS , state : SECTOR_STATE
) -> void:
	sectors[direction].self_modulate = STATE_MODULATES[state]

func set_hint_state(
	direction : Global.DIRECTIONS , state : SECTOR_STATE
) -> void:
	hints[direction].self_modulate = STATE_MODULATES[state]

func toggle_center_highlight(inner_on : bool , outer_on : bool) -> void:
	if inner_on:
		center_in_sprite_2d.self_modulate = STATE_MODULATES[
			SECTOR_STATE.COMPLETE
		]
	else:
		center_in_sprite_2d.self_modulate = STATE_MODULATES[
			SECTOR_STATE.NORMAL
		]
	
	if outer_on:
		center_out_sprite_2d.self_modulate = STATE_MODULATES[
			SECTOR_STATE.COMPLETE
		]
	else:
		center_out_sprite_2d.self_modulate = STATE_MODULATES[
			SECTOR_STATE.NORMAL
		]

func reset_sectors() -> void:
	for sector in sectors:
		set_sector_state(sector, SECTOR_STATE.NORMAL)
	for hint in hints:
		set_hint_state(hint , SECTOR_STATE.NORMAL)
