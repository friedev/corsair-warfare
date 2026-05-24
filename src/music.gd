class_name Music
extends Node

@export var combat_timer: Timer
@export var transition_duration: float

@export var menu_music: AudioStreamPlayer
@export var noncombat_music: AudioStreamPlayer
@export var combat_music: AudioStreamPlayer

@onready var active_track := menu_music


func _process(delta: float) -> void:
	for music_track in [menu_music, noncombat_music, combat_music]:
		var volume_linear := db_to_linear(music_track.volume_db)
		var increment := delta / transition_duration
		if music_track == active_track:
			volume_linear += increment
		else:
			volume_linear -= increment
		volume_linear = clampf(volume_linear, 0.0, 1.0)
		music_track.volume_db = linear_to_db(volume_linear)


func enter_combat() -> void:
	combat_timer.start()
	active_track = combat_music


func enter_noncombat() -> void:
	active_track = noncombat_music


func enter_menu() -> void:
	combat_timer.stop()
	active_track = menu_music


func _on_pause_menu_menu_pressed(previous: Menu) -> void:
	enter_menu()


func _on_game_over_menu_menu_pressed(previous: Menu) -> void:
	enter_menu()


func _on_lobby_menu_play_pressed(previous: Menu) -> void:
	enter_noncombat()


func _on_combat_timer_timeout() -> void:
	enter_noncombat()


func _on_ship_cannon_fired() -> void:
	enter_combat()


func _on_ship_damage_taken(_damage: float) -> void:
	enter_combat()
