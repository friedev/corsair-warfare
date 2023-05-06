extends Node

# TODO localize player registration code
signal player_registered(player: int)
signal player_deregistered(player: int)

enum GameMode {
	LAST_MAN_STANDING = 0,
	DEATHMATCH = 1,
}

const KEYBOARD_1_PLAYER := -1
const KEYBOARD_2_PLAYER := -2
const NO_PLAYER := -3

const DEFAULT_GAME_MODE := GameMode.LAST_MAN_STANDING

var players := {}
var time_limit_seconds := 0
var game_mode := self.DEFAULT_GAME_MODE
var vibrate := true


func register_player(player: int, ship_details: PlayerDetails) -> void:
	if player == self.NO_PLAYER:
		return
	self.players[player] = ship_details
	self.player_registered.emit(player)


func deregister_player(player: int) -> void:
	if player == self.NO_PLAYER:
		return
	self.players.erase(player)
	self.player_deregistered.emit(player)


func reset_game_settings() -> void:
	self.players.clear()
	self.time_limit_seconds = 0
	self.game_mode = self.DEFAULT_GAME_MODE


func is_joy(player: int) -> bool:
	return player >= 0
