extends Control


func _on_play_button_pressed() -> void:
	SceneManager.change_to_scene(
		SceneManager.SCENE.GAME_SCENE
	)
