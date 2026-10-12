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

func _ready() -> void:
	reset_sectors()

func set_sector_state(
	sector_direction : Global.DIRECTIONS , state : SECTOR_STATE
) -> void:
	sectors[sector_direction].self_modulate = STATE_MODULATES[state]

func reset_sectors() -> void:
	for sector in sectors:
		set_sector_state(sector, SECTOR_STATE.NORMAL)
