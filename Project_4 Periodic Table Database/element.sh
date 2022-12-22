#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# getting datas from argument and database
if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")

elif [[ ! $1 =~ ^[0-9]+$ ]] && [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  SYMBOL=$1
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
  NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")

elif [[ ! $1 =~ ^[0-9]+$ ]] && [[ $1 =~ ^[A-Z][a-z]+$ ]]
then
  NAME=$1
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME'")
fi

# if does not exist
if [[ -z $ATOMIC_NUMBER ]] || [[ -z $NAME ]] || [[ -z $SYMBOL ]]
then
  echo "I could not find that element in the database."
  exit
fi

# get other element's datas
ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
MELT_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
BOIL_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")

TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")

# final output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
