extends Node

# TODO localize player registration code
signal player_registered(player: int)
signal player_deregistered(player: int)

const KEYBOARD_1_PLAYER := -1
const KEYBOARD_2_PLAYER := -2
const NO_PLAYER := -3

var players := {}


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
