#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~Welcome to the Number Guessing Game~~~\n"

echo "Enter your username: "
read USERNAME

USER=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")

if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert player
  INSERT_USER=$($PSQL "INSERT INTO number_guess(username) VALUES('$USERNAME')")
  INSERT_GAME=$($PSQL "UPDATE number_guess SET games_played=1 WHERE username='$USERNAME'")
else  
  GAMES=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USER'")
  BEST=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USER'")
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
  UPDATE_GAMES=$($PSQL "UPDATE number_guess SET games_played=$GAMES+1 WHERE username='$USER'")
fi

SECRET=$(( 1 + $RANDOM % 999 ))
echo -e "\nGuess the secret number between 1 and 1000:\n"

TRIES=0
while :
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS < $SECRET ]]
    then
      echo "It's higher than that, guess again:"
      TRIES=$(($TRIES + 1 ))
    elif [[ $GUESS > $SECRET ]]
    then
      echo  "It's lower than that, guess again:"
      TRIES=$(($TRIES + 1 ))
    else
      TRIES=$(($TRIES + 1 ))
      if [[ -z $BEST ]]
      then
      INSERT_BEST=$($PSQL "UPDATE number_guess SET best_game=$TRIES WHERE username='$USERNAME'")
      else
        if [[ $BEST > $TRIES ]]
        then
          UPDATE_BEST=$($PSQL "UPDATE number_guess SET best_game=$TRIES WHERE username='$USERNAME'")
        fi 
      fi                
      break
    fi  
  fi
done
echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!" 