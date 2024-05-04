class_name Music extends Node

@export var combat_timer: Timer
@export var transition_duration: float

@export var menu_music: AudioStreamPlayer
@export var noncombat_music: AudioStreamPlayer
@export var combat_music: AudioStreamPlayer

@onready var active_track := self.menu_music


func _process(delta: float) -> void:
	for music_track in [self.menu_music, self.noncombat_music, self.combat_music]:
		var volume_linear := db_to_linear(music_track.volume_db)
		var increment := delta / self.transition_duration
		if music_track == self.active_track:
			volume_linear += increment
		else:
			volume_linear -= increment
		volume_linear = clampf(volume_linear, 0.0, 1.0)
		music_track.volume_db = linear_to_db(volume_linear)


func enter_combat() -> void:
	self.combat_timer.start()
	self.active_track = self.combat_music


func enter_noncombat() -> void:
	self.active_track = self.noncombat_music


func enter_menu() -> void:
	self.combat_timer.stop()
	self.active_track = self.menu_music


func _on_pause_menu_menu_pressed(previous: Menu) -> void:
	self.enter_menu()


func _on_game_over_menu_menu_pressed(previous: Menu) -> void:
	self.enter_menu()


func _on_lobby_menu_play_pressed(previous: Menu) -> void:
	self.enter_noncombat()


func _on_combat_timer_timeout() -> void:
	self.enter_noncombat()


func _on_ship_cannon_fired() -> void:
	self.enter_combat()


func _on_ship_damage_taken(_damage: float) -> void:
	self.enter_combat()
