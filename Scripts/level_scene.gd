extends Node2D

@export_group("Connections")
@export var canvas_layer: CanvasLayer
@export var managers_folder: Folder

func _ready() -> void:
	for manager in managers_folder.get_children():
		if manager is Manager:
			manager.setup()

func _on_settings_texture_button_pressed() -> void:
	SceneManager.pop_subscene(
		SceneManager.SUBSCENE.SETTINGS ,
		canvas_layer
	)
