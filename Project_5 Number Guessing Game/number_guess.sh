#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get a random number
number=$(( RANDOM % 1000 + 1 ))

# for test
echo "number is $number"

# get a username
echo "Enter your username:"
read username
# check if name in database
games_played=$($PSQL "SELECT games_played FROM games WHERE username = '$username'")
if [[ -z $games_played ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  new_user="yes"
else
  best_game=$($PSQL "SELECT best_game FROM games WHERE username = '$username'")
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# get a guess
echo "Guess the secret number between 1 and 1000:"
read guess

# number of guesses
guesses_no=1

while [[ $number -ne $guess ]]
do
  # in not an iteger
  if [[ ! $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read guess
  # if number lower
  elif [[ $guess -ge $number ]]
  then
    echo "It's lower than that, guess again:"
    read guess
  # if number higher
  elif [[ $guess -le $number ]]
  then
    echo "It's higher than that, guess again:"
    read guess
  fi

  # number of guesses count
  guesses_no=$((guesses_no+1))
done

# final message when guessed
echo "You guessed it in $guesses_no tries. The secret number was $number. Nice job!"

# result database check and update
if [[ $new_user ]]
then
  games_played=1
  best_game=$guesses_no
  INSERT_NEW_USER=$($PSQL "INSERT INTO games(username, games_played, best_game) VALUES('$username', $games_played, $best_game)")

# existing user
else
  games_played=$((games_played+1))
  # best game checking
  if [[ $guesses_no -le $best_game ]]
  then 
    best_game=$guesses_no
  fi
  UPDATE_USER=$($PSQL "UPDATE games SET games_played=$games_played, best_game=$best_game WHERE username='$username'")
  echo "existing user"
fi
