class_name LighthouseSprite2D
extends Sprite2D

enum STATE {
	TURN_ON, 
	TURN_OFF, 
}

const STATE_FRAMES : Dictionary[STATE , int] = {
	STATE.TURN_ON : 1 ,
	STATE.TURN_OFF : 0 ,
}

var top_light : LighthouseSprite2D

func _ready() -> void:
	for child in get_children():
		if child is LighthouseSprite2D:
			child.top_light = null
			child.frame = 2
			top_light = child
			return

func set_state(new_state : STATE) -> void:
	frame = STATE_FRAMES[new_state]
	#top_light.visible = new_state == STATE.TURN_ON
