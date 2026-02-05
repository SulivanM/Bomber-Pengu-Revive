package main

type GameSession struct {
	ID      string
	Player1 *Player
	Player2 *Player
	Active  bool
}
