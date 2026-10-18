extends Node2D

@export_group("Connections")
@export var canvas_layer: CanvasLayer
@export var managers_folder: Folder

func _ready() -> void:
	for manager in managers_folder.get_children():
		if manager is Manager:
			manager.setup()

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


func _on_settings_pressed() -> void:
	SceneManager.pop_subscene(
		SceneManager.SUBSCENE.SETTINGS ,
		canvas_layer
	)
