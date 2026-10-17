class_name SettingsPopup
extends PanelContainer

const MAIN_MENU_NAME : String = "mainmenu"

@export_group("Connections")
@export var main_menu_button: Button

func _ready() -> void:
	get_tree().paused = true
	_update_buttons_visibility()

func _update_buttons_visibility() -> void:
	if get_tree().current_scene.name.to_lower() == MAIN_MENU_NAME:
		main_menu_button.hide()

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_to_scene(
		SceneManager.SCENE.MAIN_MENU
	)
