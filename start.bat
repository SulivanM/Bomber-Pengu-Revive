@echo off
cd /d "%~dp0"
go run serverlet\main.go serverlet\player.go serverlet\game.go
