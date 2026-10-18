extends Node

enum SCENE{
	MAIN_MENU ,
	GAME_SCENE ,
	DIFFICULTY_SELECT ,
}

enum SUBSCENE{
	SETTINGS ,
	GAME_OVER_LOSE ,
	GAME_OVER_WIN ,
}

const SCENE_PATHS : Dictionary[SCENE , String] = {
	SCENE.MAIN_MENU : "res://Scenes/main menu.tscn" ,
	SCENE.GAME_SCENE : "res://Scenes/level_scene.tscn" ,
	SCENE.DIFFICULTY_SELECT : "res://Scenes/difficulty_selection_scene.tscn" ,
}

const SUBSCENE_PATHS : Dictionary[SUBSCENE, String] = {
	SUBSCENE.SETTINGS : "res://Scenes/SubScenes/settings_popup.tscn" ,
	SUBSCENE.GAME_OVER_LOSE : "res://Scenes/SubScenes/game_over_bad.tscn" ,
	SUBSCENE.GAME_OVER_WIN : "res://Scenes/SubScenes/game_over_good.tscn" ,
}

func _ready() -> void:
	_validate_paths()

func _validate_paths() -> void:
	for path in SCENE_PATHS.values():
		if not FileAccess.file_exists(path):
			push_error("SceneManager: file for scene %s doesn't exist" % [
				SCENE.find_key(
					SCENE_PATHS.find_key(path)
				)])
	for path in SUBSCENE_PATHS.values():
		if not FileAccess.file_exists(path):
			push_error("SceneManager: file for subscene %s doesn't exist" % [
				SUBSCENE.find_key(
					SUBSCENE_PATHS.find_key(path)
				)])

func change_to_scene(scene : SCENE) -> void:
	get_tree().change_scene_to_file(
		SCENE_PATHS[scene]
	)

func pop_subscene(subscene : SUBSCENE, parent : Node) -> void:
	var pop_up_subscene : Node = (
			load((SUBSCENE_PATHS[subscene])
		) as PackedScene).instantiate()
	parent.add_child(pop_up_subscene)
