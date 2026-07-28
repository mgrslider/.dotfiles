#!/bin/sh

echo "Rozpoczynamy 25-minutową sesję Pomodoro"
sleep 1500 && notify-send "Pomodoro zakończone!" "Czas na 5-minutową przerwę" &
sleep 300 && notify-send "Koniec przerwy" "Czas na kolejne Pomodoro"
