extends Node2D

#region temp Testing movement
@export var ship_manager: ShipManager

func _on_nw_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.NORTH_WEST)

func _on_ne_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.NORTH_EAST)

func _on_w_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.WEST)

func _on_e_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.EAST)

func _on_se_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.SOUTH_EAST)

func _on_sw_pressed() -> void:
	ship_manager.move_ship(Global.DIRECTIONS.SOUTH_WEST)
#endregion
