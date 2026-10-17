class_name SettingsPopup
extends PanelContainer

func _ready() -> void:
	get_tree().paused = true

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
