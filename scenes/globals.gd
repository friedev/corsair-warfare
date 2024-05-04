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

var options := {}

var players := {}
var time_limit_seconds := 0
var game_mode := self.DEFAULT_GAME_MODE
var max_points := 5


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


func is_joy(player: int) -> bool:
	return player >= 0


func get_winner() -> PlayerDetails:
	var ships := self.get_tree().get_nodes_in_group(&"ships")
	if len(ships) == 1:
		return null

	var winner: PlayerDetails = null
	if Globals.game_mode == Globals.GameMode.LAST_MAN_STANDING:
		var max_health_percent := 0.0
		for ship_node in ships:
			var ship := ship_node as Ship
			var health_percent := ship.health / ship.max_health
			if health_percent > max_health_percent:
				winner = ship.details
				max_health_percent = health_percent
			elif (
				health_percent == max_health_percent
				and max_health_percent > 0.0
			):
				winner = null
	elif Globals.game_mode == Globals.GameMode.DEATHMATCH:
		var max_score := -2^63
		for details in Globals.players.values():
			if details.score > max_score:
				winner = details
				max_score = details.score
			elif details.score == max_score:
				winner = null
	return winner
