@icon("res://Assets/ProjectIcons/Folder2D.svg")
class_name Folder2D
extends Node2D

func _ready() -> void:
	check_position()

func check_position() -> void:
	if position != Vector2.ZERO:
		push_error("Folder's position isn't Vector2.ZERO")
