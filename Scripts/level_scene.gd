extends Node2D

@export_group("Connections")
@export var canvas_layer: CanvasLayer
@export var managers_folder: Folder

func _ready() -> void:
	SoundManager.toggle_ambient(
		SoundManager.AMBIENT.OCEAN_WAVES , true
	)
	for manager in managers_folder.get_children():
		if manager is Manager:
			manager.setup()

func _on_settings_texture_button_pressed() -> void:
	SceneManager.pop_subscene(
		SceneManager.SUBSCENE.SETTINGS ,
		canvas_layer
	)

func _exit_tree() -> void:
	SoundManager.toggle_ambient(
		SoundManager.AMBIENT.LIGHTHOUSE_HUM , false
	)
	SoundManager.toggle_ambient(
		SoundManager.AMBIENT.OCEAN_WAVES , false
	)
