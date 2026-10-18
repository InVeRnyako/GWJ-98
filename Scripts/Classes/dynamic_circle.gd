class_name DynamicCircle
extends Node2D

var radius : float = 0.0
var color : Color = Color.GREEN

func set_circle(new_radius : float , new_color : Color) -> void:
	radius = new_radius
	color = new_color
	show()
	#queue_redraw()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO , 
		radius , 
		color
	)
