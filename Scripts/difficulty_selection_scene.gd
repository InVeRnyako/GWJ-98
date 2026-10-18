extends Control


func _on_easy_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.EASY
	_go_to_game_scene()

func _on_normal_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.NORMAL
	_go_to_game_scene()

func _on_hard_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.HARD
	_go_to_game_scene()

func _on_impossible_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.IMPOSSIBLE
	_go_to_game_scene()

func _go_to_game_scene() -> void:
	SceneManager.change_to_scene(
		SceneManager.SCENE.GAME_SCENE
	)
