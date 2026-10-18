class_name SettingsPopup
extends PanelContainer

const MAIN_MENU_NAME : String = "mainmenu"

@export_group("Connections")
@export var main_menu_button: Button
@export var line_time_h_slider: HSlider
@export var confirmation_time_h_slider: HSlider
@export var line_time_label: Label
@export var confirmation_time_label: Label


func _ready() -> void:
	get_tree().paused = true
	_update_buttons_visibility()
	_update_morsecode_values()

func _update_buttons_visibility() -> void:
	if get_tree().current_scene.name.to_lower() == MAIN_MENU_NAME:
		main_menu_button.hide()

func _update_morsecode_values() -> void:
	confirmation_time_h_slider.value = Global.overhold_time
	confirmation_time_label.text = String.num(Global.overhold_time, 2)
	line_time_h_slider.value = Global.line_time
	line_time_label.text = String.num(Global.line_time , 2)

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_to_scene(
		SceneManager.SCENE.MAIN_MENU
	)


func _on_confirmation_time_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.overhold_time = confirmation_time_h_slider.value


func _on_line_time_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.line_time = line_time_h_slider.value

func _on_line_time_h_slider_value_changed(value: float) -> void:
	line_time_label.text = String.num(value , 2)

func _on_confirmation_time_h_slider_value_changed(value: float) -> void:
	confirmation_time_label.text = String.num(value , 2)
