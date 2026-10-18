class_name BusSlider
extends HSlider

@export var bus : SoundManager.BUS

func _ready() -> void:
	min_value = 0.0
	max_value = 1.0
	step = 0.01
	value = SoundManager.get_bus_volume(bus)
	print(SoundManager.get_bus_volume(bus))

func _value_changed(new_value: float) -> void:
	SoundManager.set_bus_volume(bus, new_value)
