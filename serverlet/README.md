# Bomberman Server

Serveur Golang pour le jeu Flash Bomberman.

## Démarrage

```bash
cd serverlet
go run .
```

## Ports

- TCP: 6897 (XMLSocket pour le jeu)
- HTTP: 8080 (admins.txt et badwords.txt)

## Configuration

Le jeu se connecte automatiquement à 127.0.0.1:6897 via index.html.
