extends PanelContainer

func _ready() -> void:
	get_tree().paused = true

func _on_try_again_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_to_scene(
		SceneManager.SCENE.GAME_SCENE
	)


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_to_scene(
		SceneManager.SCENE.MAIN_MENU
	)
