#!/bin/bash

###############################################################################
##                              Unix User Maker                              ##
##                                                                           ##
## Create Unix users using useradd from a CSV file.                          ##
## (C) 2023 David Cutting, all rights reserved.                              ##
## http://davecutting.uk/                                                    ##
##                                                                           ##
## Released under the GNU GPL v3 - see LICENCE file for details.             ##
##                                                                           ##
## Project home and repo: https://github.com/purplepixie/unix-user-maker     ##
##                                                                           ##
## Version: 0.01 06/07/2023                                                  ##
###############################################################################

# Default Parameters
FILENAME=""
STRIP_QUOTES=0
HEADER_ROW=0
SET_EXISTING_PASSWORD=0
FIELD_USERNAME=2
FIELD_PASSWORD=3
EXECUTE=0

# Usage Message
function Usage() {
    echo "** Unix User Maker, github.com/purplepixie/unix-user-maker **"
    echo "Usage: ./user-maker.sh --filename=input.csv [options]"
    echo 
    echo "Options:"
    echo " -f | --filename     REQUIRED specifies the input CSV file"
    echo "                     Use with = i.e. -f=filename.csv"
    echo " -e | --execute      Actually execute commands, otherwise will"
    echo "                     just show proposed command changes"
    echo " -q | --stripquotes  Strips quotes from fields in CSV file"
    echo " -h | --header       CSV file has a header row (ignore first line)"
    echo " -sep | --setexistingpassword"
    echo "                     If a user exists sets their password"
    echo "                     (note if a user does not exist, they are"
    echo "                     created and have their password set always)"
    echo " -uf | --userfield   Set the field number (from 1) of the username"
    echo "                     (default to 2), use = i.e. -uf=5"
    echo " -pf | --passfield   Set the field number (from 1) of the password"
    echo "                     (default to 3), use = i.e. -pf=5"
}

# Strip first and last characters from a string
function StripFirstLast() {
    INSTR=$1
    LEN=${#INSTR}
    TAKE=$((${LEN} - 2))
    STR=${INSTR:1:$TAKE}
    echo $STR
}

# Process arguments, from: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

for i in "$@"; do
  case $i in
    -f=*|--filename=*)
      FILENAME="${i#*=}"
      shift # past argument=value
      ;;
    -uf=*|--userfield=*)
      FIELD_USERNAME="${i#*=}"
      shift # past argument=value
      ;;
    -pf=*|--passfield=*)
      FIELD_PASSWORD="${i#*=}"
      shift # past argument=value
      ;;
    -q|--quotes)
      STRIP_QUOTES=1
      shift # past argument with no value
      ;;
    -h|--header)
      HEADER_ROW=1
      shift # past argument with no value
      ;;
    -sep|--setexistingpassword)
      SET_EXISTING_PASSWORD=1
      shift # past argument with no value
      ;;
    -*|--*|*)
      echo "Unknown option $i"
      Usage
      exit 1
      ;;
      esac
done

if [ -z "$FILENAME" ]
then
    echo "Error: no filename specified."
    Usage
    exit 1
fi

# Check for useradd
if ! command -v useradd &> /dev/null
then
 echo "useradd could not be found and is required for this script."
 exit 1
fi


# Test CSV file
if [ ! -f "$FILENAME" ]; then
  echo "CSV file specified does not exist: $FILENAME"
  exit 1
fi

# Read CSV file and loop
FIRSTLINE=1
while read -r line;
do
    if [ $FIRSTLINE -eq 1 ]; then
        FIRSTLINE=0
        if [ $HEADER_ROW -eq 1 ]; then
            continue
        fi
    fi

    USERNAME=$(echo $line | cut -d, -f${FIELD_USERNAME})
    PASSWORD=$(echo $line | cut -d, -f${FIELD_PASSWORD})

    if [ $STRIP_QUOTES -eq 1 ]; then
        USERNAME=$(StripFirstLast $USERNAME)
        PASSWORD=$(StripFirstLast $PASSWORD)
    fi

    USEREXISTS=0
    if id "$USERNAME" >/dev/null 2>&1; then
        USEREXISTS=1
    fi

    CREATEUSER=0
    SETPASSWORD=0

    echo -n "User: ${USERNAME} "
    if [ $USEREXISTS -eq 1 ]; then
        echo -n "exists on system, "
        if [ $SET_EXISTING_PASSWORD -eq 1 ]; then
            echo "will reset password."
            SETPASSWORD=1
        else
            echo "will NOT reset password."
        fi
    else
        echo "does not exist on system, will be created."
        CREATEUSER=1
        SETPASSWORD=1
    fi

    if [ $CREATEUSER -eq 1 ]; then
        echo "useradd -m ${USERNAME}"
        if [ $EXECUTE -eq 1 ]; then
            useradd -m ${USERNAME}
            echo "Executed."
        fi
    fi

    if [ $SETPASSWORD -eq 1 ]; then
        printf "%s:%s | chpasswd\n" "$USERNAME" "$PASSWORD" # example command line
        if [ $EXECUTE -eq 1 ]; then
            printf "%s:%s" "$USERNAME" "$PASSWORD" | chpasswd
            echo "Executed."
        fi
    fi

    #echo $USERNAME $PASSWORD
done < $FILENAME