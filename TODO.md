# TODO

## 0.1.x

- Bugs
	- Tiebreak by percent health remaining, not total health remaining
	- Stop timer after game ends in Last Man Standing mode
- Juice
	- Add ship sinking effects
	- Add burning sound when a ship is at low health
- UI
	- Indicate player with most health
	- Highlight the nametag of the winning player
	- Indicate location of newly spawned ships
	- Set max upgrade points in the lobby
	- Pause on focus loss
	- Add option to disable particles
	- Access the options menu from the pause menu
	- Player info HUD
	- Scale rotation speed by controller axis strength
- Refactoring
	- Refactor styles
	- Refactor ship upgrades
	- Split player registration and options into two separate singletons
	- Add documentation

## 0.2.0

- Features
	- Shrinking arena
	- Improve sailing physics
	- Add predefined neutral spawn locations
	- Scale rotation speed by linear speed

## Unscheduled

- UI
	- Support custom controls
	- Allow players to customize their stats via their input device
	- Allow keyboard players to join via keypress
	- Player profiles
	- Start game when all players are ready
	- Preserve nametag scale relative to camera zoom level
- Music
	- Menu music (see `music_menu` branch on GitHub)