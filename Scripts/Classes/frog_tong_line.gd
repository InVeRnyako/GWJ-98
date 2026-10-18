class_name FrogTong
extends Line2D

const FROG_TONG_START_ADJUSMENT : Vector2 = Vector2(0,-2)

var start : Vector2


func _ready() -> void:
	hide()


func prepare_to_grab(start_global_pos : Vector2) -> void:
	start = start_global_pos + FROG_TONG_START_ADJUSMENT
	points = PackedVector2Array([
		start , start
		])
	show()

func change_tong_end_global_pos(new_end_pos : Vector2) -> void:
	points = PackedVector2Array(
		[start , new_end_pos]
	)
	queue_redraw()
