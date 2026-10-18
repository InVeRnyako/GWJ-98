class_name ButtonWithSFX
extends Button

func _pressed() -> void:
	SoundManager.play_SFX(
		SoundManager.SFX.MOUSE_CLICK
	)
