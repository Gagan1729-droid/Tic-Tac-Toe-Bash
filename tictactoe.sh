#! /bin/bash

declare -a board
declare -i pieces=0
declare header="Bash TicTacToe v1.3 - Gagan Gupta"

declare -i start_time=$(date +%s)

declare -i board_size=3
declare -i boxes_total=9
declare -i flag_invalid=0
declare -i row
declare -i col
declare -i pVsc=0         # player vs computer flag
declare p1="X"
declare p2="O"
declare color_X='\033[0;31m'         # red color for player 1
declare color_O='\033[0;34m'         # blue color for player 2
declare color_NC='\033[0m'

declare col=$(($(tput cols) / 2))           # mid column in the current terminal
declare lin=4
declare start_col

exec 3>/dev/null     # no logging by default

# Get input from the user
function getUserInput {
    while true ; do 
        echo -e "\n$1 turn: "
        read row col < /dev/tty
        let lin+=3
        if (( $row > board_size  ||  $row < 1 || $col > board_size || $col < 1))
        then
            echo Enter valid values between 1 and $board_size
            let lin++
            continue
        else
            checkForValidity $row $col
            if [ $flag_invalid -eq 1 ]
            then 
                flag_invalid=0
                echo The inputted box is already filled. Try again!
                let lin++
                continue
            fi
            break
        fi
    done
    let lin++
}


# Get input from computer
function getCompInput {    
    while true ; do
        row=$((RANDOM % $board_size))
        col=$((RANDOM % $board_size))
        checkForValidity $row $col
        if [ $flag_invalid -eq 1 ]
        then 
            flag_invalid=0
            continue
        fi
        break
    done
    echo -e "\nMy Turn: $row $col\n"
    let lin+=2
}


# To play 2 - player game
function p_vs_p {
    init
    print_board
    echo -e "\n"Enter the row and column respectively 
    let lin+=2
    while true
    do
        getUserInput "Player 1"
        assign_value $row $col $p1
        let pieces++
        print_board
        check_win $p1
        getUserInput "Player 2"
        assign_value $row $col $p2
        print_board
        let pieces++
        check_win $p2
    done
}


# To play single player game - with computer
function p_vs_comp {
    pVsc=1
    init
    tmp=$(($col-18))
    tput cup 3 $tmp
    echo -e So you have chosen to play with me :D "\n"
    lin=6
    print_board
    echo -e "\n"Enter the row and column respectively 
    while true
    do
        getUserInput "Your"
        assign_value $row $col $p1
        let pieces++
        print_board
        check_win $p1
        getCompInput
        assign_value $row $col $p2
        print_board
        let pieces++
        check_win $p2
    done
}


# Check if the move is valid or not
function checkForValidity {
    _row=`expr $1 - 1`
    _col=`expr $2 - 1`
    y=`expr $board_size \* $_row + $_col`
    if [ "${board[$y]}" == "$p1" ] || [ "${board[$y]}" == "$p2" ]
    then
        flag_invalid=1
    fi
}


# Assign the value
function assign_value {
    _row=`expr $1 - 1`
    _col=`expr $2 - 1`
    y=`expr $board_size \* $_row + $_col`
    board[$y]=$3
}


# Print the board
function print_board {
    x=`expr $board_size - 1`
    for (( i=0; i<$x; i++ ))
    do
        printf "\n"
        tput cup $lin $start_col
        printf "  %c  " ${board[$i*$board_size]}
        for (( j=1; j<$board_size; j++ ))
        do
            printf "|  %c  " ${board[$i*$board_size+$j]}
        done
        printf "\n"
        let lin++
        tput cup $lin $start_col
        printf "_____"
        for (( j=1; j<$board_size; j++ ))
        do
            printf "|_____"
        done
        printf "\n"
        let lin++
        tput cup $lin $start_col
        printf "     "
        for (( j=1; j<$board_size; j++ ))
        do
            printf "|     "
        done
        let lin++
    done
    printf "\n"
    tput cup $lin $start_col
    printf "  %c  " ${board[$x*$board_size]}
    for (( j=1; j<$board_size; j++ ))
    do
        printf "|  %c  " ${board[$x*$board_size+$j]}
    done
    printf "\n"
    let lin++
}

 
# Check if a player is winning
function check_win {
    x=`expr $board_size - 1`
    for i in $(seq 0 $x); do 
        y=`expr $i \* $board_size`    # Starting index of the row
        z=`expr $y + $board_size`    # Terminating condition to stop while checking row-wise
        
        # Check row-wise winning
        for (( j=$y; j<$z; j++ ))
        do
            if [ "${board[$j]}" != "$1" ]
            then
                break
            fi
        done
        if [ $j -eq $z ]
        then
            print_win $1
        fi

        # Check column-wise winning
        for (( j=$i; j<$boxes_total; j+=$board_size ))
        do
            if [ "${board[$j]}" != "$1" ]
            then
                break
            fi
        done
        if [ $j -ge $boxes_total ]
        then
            print_win $1
        fi
    done

    # Check for diagonals
    x=0                                 # Left diagonal
    y=`expr $board_size - 1`            # Right diagonal
    l=0                                 # Counter for left diagonal
    r=0                                 # Counter for right diagonal
    inc_l=`expr $board_size + 1`        # Increment for left diagonal
    inc_r=`expr $board_size - 1`        # Increment for right diagonal

    for (( i=0; i<$board_size; i++ ))
    do
        if [ "${board[$x]}" == "$1" ]
        then
            let l++
        fi        
        if [ "${board[$y]}" == "$1" ]
        then
            let r++
        fi
        let x+=$inc_l
        let y+=$inc_r
    done
    if [ $l -eq $board_size ] || [ $r -eq $board_size ]
    then
        print_win $1
    fi

    # When all the boxes are filled
    if [ $pieces -eq $boxes_total ]
    then
        printf "\nGot stuck! No one wins\n"
        end_time=$(date +%s) 
        let total_time=end_time-start_time
        printf "This game lasted "
        `date --version > /dev/null 2>&1`
        if [[ "$?" -eq 0 ]]; then
            date -u -d @${total_time} +%T
        else
            date -u -r ${total_time} +%T
        fi
        exit
    fi
}


# Print the win message
function print_win {
    end_time=$(date +%s) 
    let total_time=end_time-start_time
    echo -e "\n"
    printf "This game lasted "
    `date --version > /dev/null 2>&1`
    if [[ "$?" -eq 0 ]]; then
        date -u -d @${total_time} +%T
    else
        date -u -r ${total_time} +%T
    fi
    printf "\n"
    x=1
    if [ $pVsc -eq 1 ]; then
        if [ "$1" == "$p1" ]
        then
            echo Congratulations! You won!!
        else
            echo You lose! Better luck next time!
        fi
    else 
        if [ "$1" == "$p1" ]
        then
            echo Player 1 won!!
        else
            echo Player 2 won!!
        fi
    fi
    printf "\n"
    exit
}


# Help commandline function
function help {
  cat <<END_HELP

Usage: $1 [-s INTEGER] [-c] [-h]

  -s		specify game board size (sizes 3-9 allowed - Default:3)
  -c		play with computer
  -h		this help

END_HELP
}


function init {
    i=0
    start_col=$(($col-$board_size*3+1))
    while [ $i -lt $boxes_total ]
    do
        board[$i]='.'
        i=`expr $i + 1`
    done
    clear
    tmp=$(($col-16))
    RED='\033[0;34m'
    NC='\033[0m'        # No Color
    BOLD='\033[1m'
    tput cup 1 $tmp
    printf "${BOLD}${RED}$header${NC}\n"
}


# Parse command-line options
while getopts "hs:c" opt
do
    case $opt in 
    s ) arg=$OPTARG
        clear
        if [ $arg -ge 3 ] && [ $arg -le 9 ]
        then
            board_size=$arg
            boxes_total=`expr $arg \* $arg`
        else
            echo -e Board size can be [3,9] only... choosing default value "\n" 
        fi;;
    c ) p_vs_comp
        exit 0;;
    h ) help $0
        exit 0;;
    \?) printf "Invalid option: -"$opt", try $0 -h\n" >&2
            exit 1;;
    : ) printf "Option -"$opt" requires an argument, try $0 -h\n" >&2
            exit 1;;
    esac
done

# If no choice provided ,  default is player vs player
p_vs_p
