extends Control

@export_group("Connections")
@export var exit_button: Button

func _ready() -> void:
	_update_buttons_visibility()

func _update_buttons_visibility() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _on_play_button_pressed() -> void:
	SceneManager.change_to_scene(
		SceneManager.SCENE.GAME_SCENE
	)


func _on_settings_button_pressed() -> void:
	SceneManager.pop_subscene(
		SceneManager.SUBSCENE.SETTINGS,
		self
	)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
