package main

import (
	"bufio"
	"encoding/xml"
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

type Server struct {
	players    map[string]*Player
	mu         sync.RWMutex
	admins     []string
	badWords   []string
	games      map[string]*GameSession
	challenges map[string]map[string]bool
}

var server *Server

func main() {
	server = &Server{
		players:    make(map[string]*Player),
		games:      make(map[string]*GameSession),
		challenges: make(map[string]map[string]bool),
		admins:     []string{"Admin1", "Admin2"},
		badWords:   []string{"badword1", "badword2"},
	}

	go startHTTPServer()
	startTCPServer()
}

func startTCPServer() {
	listener, err := net.Listen("tcp", ":6897")
	if err != nil {
		log.Fatal("TCP server error:", err)
	}
	defer listener.Close()

	log.Println("TCP server listening on :6897")

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Println("Accept error:", err)
			continue
		}
		go handleClient(conn)
	}
}

func handleClient(conn net.Conn) {
	defer conn.Close()

	reader := bufio.NewReader(conn)
	var player *Player

	for {
		message, err := reader.ReadString('\n')
		if err != nil {
			if player != nil {
				server.removePlayer(player)
			}
			return
		}

		message = strings.TrimSpace(message)
		if message == "" {
			continue
		}

		response, newPlayer := processMessage(message, player, conn)
		if newPlayer != nil {
			player = newPlayer
		}

		if response != "" {
			conn.Write([]byte(response + "\n"))
		}
	}
}

func processMessage(message string, player *Player, conn net.Conn) (string, *Player) {
	decoder := xml.NewDecoder(strings.NewReader(message))
	token, err := decoder.Token()
	if err != nil {
		return "", nil
	}

	if se, ok := token.(xml.StartElement); ok {
		switch se.Name.Local {
		case "auth":
			return handleAuth(se, conn)
		case "beat":
			return handleBeat(player)
		case "challenge":
			return handleChallenge(se, player)
		case "remChallenge":
			return handleRemChallenge(se, player)
		case "challengeAll":
			return handleChallengeAll(player)
		case "remChallengeAll":
			return handleRemChallengeAll(player)
		case "startGame":
			return handleStartGame(se, player)
		case "msgAll":
			return handleMsgAll(se, player)
		case "msgPlayer":
			return handleMsgPlayer(se, player)
		case "playAgain":
			return handlePlayAgain(player)
		case "toRoom":
			return handleToRoom(player)
		case "surrender":
			return handleSurrender(player)
		case "drawGame":
			return handleDrawGame(player)
		case "winGame":
			return handleWinGame(player)
		case "ping":
			return handlePing()
		default:
			return handleGameAction(message, player)
		}
	}

	return "", player
}

func handleAuth(se xml.StartElement, conn net.Conn) (string, *Player) {
	var name, hash string
	for _, attr := range se.Attr {
		switch attr.Name.Local {
		case "name":
			name = attr.Value
		case "hash":
			hash = attr.Value
		}
	}

	if name == "" {
		return "<errorMsg>Invalid name</errorMsg>", nil
	}

	server.mu.Lock()
	if _, exists := server.players[name]; exists {
		server.mu.Unlock()
		return "<errorMsg>Name already taken</errorMsg>", nil
	}

	player := &Player{
		Name:       name,
		Conn:       conn,
		State:      0,
		Skill:      1000,
		Hash:       hash,
		LastBeat:   time.Now(),
		InGame:     false,
		Opponent:   nil,
	}
	server.players[name] = player
	server.mu.Unlock()

	config := "<config badWordsUrl=\"\" replacementChar=\"*\" deleteLine=\"false\" floodLimit=\"1000\"/>"
	player.Send(config)

	userList := server.getUserListXML()
	player.Send(userList)

	server.broadcastExcept(fmt.Sprintf("<newPlayer name=\"%s\" skill=\"%d\" state=\"%d\"/>", name, player.Skill, player.State), name)

	log.Printf("Player authenticated: %s", name)
	return "", player
}

func handleBeat(player *Player) (string, *Player) {
	if player == nil {
		return "", nil
	}
	player.LastBeat = time.Now()
	return "", player
}

func handleChallenge(se xml.StartElement, player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	var targetName string
	for _, attr := range se.Attr {
		if attr.Name.Local == "name" {
			targetName = attr.Value
			break
		}
	}

	server.mu.Lock()
	target, exists := server.players[targetName]
	if exists && !target.InGame {
		if server.challenges[player.Name] == nil {
			server.challenges[player.Name] = make(map[string]bool)
		}
		server.challenges[player.Name][targetName] = true
		player.State = 1
		target.Send(fmt.Sprintf("<request name=\"%s\"/>", player.Name))
		server.broadcastPlayerUpdate(player)
	}
	server.mu.Unlock()

	return "", player
}

func handleRemChallenge(se xml.StartElement, player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	var targetName string
	for _, attr := range se.Attr {
		if attr.Name.Local == "name" {
			targetName = attr.Value
			break
		}
	}

	server.mu.Lock()
	if server.challenges[player.Name] != nil {
		delete(server.challenges[player.Name], targetName)
		if len(server.challenges[player.Name]) == 0 {
			player.State = 0
			server.broadcastPlayerUpdate(player)
		}
	}
	target, exists := server.players[targetName]
	if exists {
		target.Send(fmt.Sprintf("<remRequest name=\"%s\"/>", player.Name))
	}
	server.mu.Unlock()

	return "", player
}

func handleChallengeAll(player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	server.mu.Lock()
	if server.challenges[player.Name] == nil {
		server.challenges[player.Name] = make(map[string]bool)
	}
	for name, p := range server.players {
		if name != player.Name && !p.InGame {
			server.challenges[player.Name][name] = true
			p.Send(fmt.Sprintf("<request name=\"%s\"/>", player.Name))
		}
	}
	player.State = 1
	server.broadcastPlayerUpdate(player)
	server.mu.Unlock()

	return "", player
}

func handleRemChallengeAll(player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	server.mu.Lock()
	if server.challenges[player.Name] != nil {
		for targetName := range server.challenges[player.Name] {
			if target, exists := server.players[targetName]; exists {
				target.Send(fmt.Sprintf("<remRequest name=\"%s\"/>", player.Name))
			}
		}
		delete(server.challenges, player.Name)
	}
	player.State = 0
	server.broadcastPlayerUpdate(player)
	server.mu.Unlock()

	return "", player
}

func handleStartGame(se xml.StartElement, player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	var opponentName string
	for _, attr := range se.Attr {
		if attr.Name.Local == "name" {
			opponentName = attr.Value
			break
		}
	}

	server.mu.Lock()
	opponent, exists := server.players[opponentName]
	if !exists || opponent.InGame || player.InGame {
		server.mu.Unlock()
		return "", player
	}

	gameID := player.Name + "_vs_" + opponent.Name
	game := &GameSession{
		ID:      gameID,
		Player1: player,
		Player2: opponent,
		Active:  true,
	}
	server.games[gameID] = game

	player.InGame = true
	player.Opponent = opponent
	player.State = 3
	opponent.InGame = true
	opponent.Opponent = player
	opponent.State = 3

	delete(server.challenges, player.Name)
	delete(server.challenges, opponent.Name)

	server.broadcastPlayerUpdate(player)
	server.broadcastPlayerUpdate(opponent)
	server.mu.Unlock()

	player.Send(fmt.Sprintf("<startGame name=\"%s\"/>", opponent.Name))
	opponent.Send(fmt.Sprintf("<startGame name=\"%s\"/>", player.Name))

	log.Printf("Game started: %s vs %s", player.Name, opponent.Name)
	return "", player
}

func handleMsgAll(se xml.StartElement, player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	var msg string
	for _, attr := range se.Attr {
		if attr.Name.Local == "msg" {
			msg = attr.Value
			break
		}
	}

	broadcast := fmt.Sprintf("<msgAll name=\"%s\" msg=\"%s\"/>", player.Name, msg)
	server.broadcast(broadcast)

	return "", player
}

func handleMsgPlayer(se xml.StartElement, player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	var msg string
	for _, attr := range se.Attr {
		if attr.Name.Local == "msg" {
			msg = attr.Value
			break
		}
	}

	message := fmt.Sprintf("<msgPlayer name=\"%s\" msg=\"%s\"/>", player.Name, msg)
	player.Opponent.Send(message)

	return "", player
}

func handlePlayAgain(player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	player.Opponent.Send("<playAgain/>")
	return "", player
}

func handleToRoom(player *Player) (string, *Player) {
	if player == nil {
		return "", player
	}

	server.mu.Lock()
	if player.Opponent != nil {
		gameID := getGameID(player, player.Opponent)
		delete(server.games, gameID)

		player.Opponent.InGame = false
		player.Opponent.Opponent = nil
		player.Opponent.State = 0
		server.broadcastPlayerUpdate(player.Opponent)

		player.Opponent = nil
	}
	player.InGame = false
	player.State = 0
	server.broadcastPlayerUpdate(player)
	server.mu.Unlock()

	return "", player
}

func handleSurrender(player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	player.Opponent.Send(fmt.Sprintf("<surrender winner=\"%s\"/>", player.Opponent.Name))
	player.Send(fmt.Sprintf("<surrender winner=\"%s\"/>", player.Opponent.Name))

	return "", player
}

func handleDrawGame(player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	player.Opponent.Send("<draw/>")
	return "", player
}

func handleWinGame(player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	player.Opponent.Send(fmt.Sprintf("<endGame winner=\"%s\"/>", player.Name))
	player.Send(fmt.Sprintf("<endGame winner=\"%s\"/>", player.Name))

	return "", player
}

func handlePing() (string, *Player) {
	return "<pong/>", nil
}

func handleGameAction(message string, player *Player) (string, *Player) {
	if player == nil || player.Opponent == nil {
		return "", player
	}

	player.Opponent.Send(message)
	return "", player
}

func getGameID(p1, p2 *Player) string {
	if p1.Name < p2.Name {
		return p1.Name + "_vs_" + p2.Name
	}
	return p2.Name + "_vs_" + p1.Name
}

func (s *Server) getUserListXML() string {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var users []string
	for _, p := range s.players {
		users = append(users, fmt.Sprintf("<user name=\"%s\" skill=\"%d\" state=\"%d\"/>", p.Name, p.Skill, p.State))
	}
	return "<userList>" + strings.Join(users, "") + "</userList>"
}

func (s *Server) broadcast(message string) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, p := range s.players {
		p.Send(message)
	}
}

func (s *Server) broadcastExcept(message string, exceptName string) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	for name, p := range s.players {
		if name != exceptName {
			p.Send(message)
		}
	}
}

func (s *Server) broadcastPlayerUpdate(player *Player) {
	message := fmt.Sprintf("<playerUpdate name=\"%s\" skill=\"%d\" state=\"%d\"/>", player.Name, player.Skill, player.State)
	s.broadcast(message)
}

func (s *Server) removePlayer(player *Player) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if player.Opponent != nil {
		gameID := getGameID(player, player.Opponent)
		delete(s.games, gameID)

		player.Opponent.InGame = false
		player.Opponent.Opponent = nil
		player.Opponent.State = 0
		s.broadcastPlayerUpdate(player.Opponent)
	}

	delete(s.players, player.Name)
	delete(s.challenges, player.Name)

	s.broadcast(fmt.Sprintf("<playerLeft name=\"%s\"/>", player.Name))
	log.Printf("Player disconnected: %s", player.Name)
}

func startHTTPServer() {
	http.HandleFunc("/admins.txt", handleAdmins)
	http.HandleFunc("/badwords.txt", handleBadWords)
	http.Handle("/", http.FileServer(http.Dir(".")))

	log.Println("HTTP server listening on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("HTTP server error:", err)
	}
}

func handleAdmins(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintf(w, "admins=%s", strings.Join(server.admins, ","))
}

func handleBadWords(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintf(w, strings.Join(server.badWords, ","))
}
