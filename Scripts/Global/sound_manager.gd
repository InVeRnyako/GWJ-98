extends Node

enum BUS{
	MASTER , 
	MUSIC ,
	SFX ,
	AMBIENT ,
}

const BUSES_STRING_NAMES : Dictionary[BUS , StringName] = {
	BUS.MASTER : "Master" , 
	BUS.MUSIC : "Music" ,
	BUS.SFX : "SFX" , 
	BUS.AMBIENT : "Ambient" ,
}

const BUSES_ID : Dictionary[BUS , int] = {
	BUS.MASTER : 0 ,
	BUS.MUSIC : 1 ,
	BUS.SFX : 2 ,
	BUS.AMBIENT : 3 ,
}

enum SFX {
	
}

enum MUSIC {
	
}

enum AMBIENT{
	LIGHTHOUSE_HUM ,
	OCEAN_WAVES ,
}

@export_group("Settings")
@export var sfx_streams : Dictionary[SFX , AudioStream]
@export_group("Connections")
@export var sfx_folder : Folder
@export var sfx_player_to_copy : AudioStreamPlayer
@export_subgroup("AudioPlayers")
@export var ambient_players : Dictionary[AMBIENT , AudioStreamPlayer]
@export var music_players : Dictionary[MUSIC , AudioStreamPlayer]

#region Setup
func _ready() -> void:
	_validate_connections()

func _validate_connections() -> void:
	if not (sfx_folder and sfx_player_to_copy):
		push_error("SoundManager missing @export connection(s)")
	for ambient in AMBIENT.values():
		if ambient_players.get(ambient) == null:
			push_error("SoundManager missing ambient player %s in Dictionary" % [
				AMBIENT.find_key(ambient)])
	for sfx in SFX.values():
		if sfx_streams.get(sfx) == null:
			push_error("SoundManager missing SFX stream %s in Dictionary" % [
				SFX.find_key(sfx)])
	for music in MUSIC.values():
		if music_players.get(music) == null:
			push_error("SoundManager missing music player %s in Dictionary" % [
				MUSIC.find_key(music)])
#endregion

#region Sound
func play_SFX(sfx : SFX) -> void:
	if not sfx_streams.has(sfx):
		push_error("SoundManager: missing AudioStream for SFX:
			 %s" % [SFX.find_key(sfx)])
	var new_stream_player : AudioStreamPlayer = sfx_player_to_copy.duplicate()
	sfx_folder.add_child(new_stream_player)
	new_stream_player.stream = sfx_streams[sfx]
	await new_stream_player.finished
	new_stream_player.queue_free()

func toggle_music(music : MUSIC, to_on : bool) -> void:
	var music_player : AudioStreamPlayer = music_players[music]
	if to_on:
		music_player.play()
	else:
		music_player.stop()

func toggle_ambient(ambient : AMBIENT , to_on : bool) -> void:
	var ambient_player : AudioStreamPlayer = ambient_players[ambient]
	if to_on:
		ambient_player.play()
	else:
		ambient_player.stop()
#endregion

#region Buses
func get_bus_volume(bus : BUS) -> float:
	return AudioServer.get_bus_volume_linear(
		BUSES_ID[bus])

#func get_bus_volume_by_bus_name(bus_name : StringName) -> float:
	#var id = AudioServer.get_bus_index("Ambient")

func set_bus_volume(bus : BUS , to_value : float) -> void:
	AudioServer.set_bus_volume_linear(
		BUSES_ID[bus] ,
		to_value
	)
#endregion
