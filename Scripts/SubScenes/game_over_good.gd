extends PanelContainer

func _ready() -> void:
	get_tree().paused = true
	SoundManager.play_SFX(
		SoundManager.SFX.WIN
	)

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_to_scene(
		SceneManager.SCENE.MAIN_MENU
	)
