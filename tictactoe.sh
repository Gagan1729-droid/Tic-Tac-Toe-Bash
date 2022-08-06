#! /bin/bash

declare -a board
declare -i pieces
declare header="Bash TicTacToe v1.1 - Gagan Gupta"

declare -i start_time=$(date +%s)

declare -i board_size=3
declare -i boxes_total=9
declare -i fields_total=8
declare -i flag_invalid=0
declare -i row
declare -i col
declare p1="X"
declare p2="O"

exec 3>/dev/null     # no logging by default

# Print the board
function print_board {
    x=$board_size
    printf "\n"
    printf "  %c  |  %c  |  %c  \n" ${board[0*$x+0]} ${board[0*$x+1]} ${board[0*$x+2]}
    printf "_____|_____|_____\n"
    printf "     |     |     \n"
    printf "  %c  |  %c  |  %c  \n" ${board[1*$x+0]} ${board[1*$x+1]} ${board[1*$x+2]}
    printf "_____|_____|_____\n"
    printf "     |     |     \n"
    printf "  %c  |  %c  |  %c  \n" ${board[2*$x+0]} ${board[2*$x+1]} ${board[2*$x+2]}
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


# Print the win message
function print_win {
    echo -e "\n"
    if [ "$1" == "$p1" ]
    then
        echo Congratulations! You won!!
    else
        echo You lose! Better luck next time!
    fi
    exit
}

 
# Check if a player is winning
function check_win {
    for i in $(seq 0 2); do 
        y=`expr $i \* $board_size`
        z=`expr $y + 1`
        w=`expr $z + 1`
        if [ "${board[$y]}" == "$1" ] && [ "${board[$z]}" == "$1" ] && [ "${board[$w]}" == "$1" ]
        then
            print_win $1
        fi
    done
    if [ "${board[0]}" == "$1" ] && [ "${board[3]}" == "$1" ] && [ "${board[6]}" == "$1" ]
    then
        print_win $1
    fi
    if [ "${board[1]}" == "$1" ] && [ "${board[4]}" == "$1" ] && [ "${board[7]}" == "$1" ]
    then
        print_win $1
    fi
    if [ "${board[2]}" == "$1" ] && [ "${board[5]}" == "$1" ] && [ "${board[8]}" == "$1" ]
    then
        print_win $1
    fi

    if [ "${board[0]}" == "$1" ] && [ "${board[4]}" == "$1" ] && [ "${board[8]}" == "$1" ]
    then
        print_win $1
    fi
    if [ "${board[2]}" == "$1" ] && [ "${board[4]}" == "$1" ] && [ "${board[6]}" == "$1" ]
    then
        print_win $1
    fi
}


# Init
i=0
while [ $i -le $fields_total ]
do
    board[$i]='.'
    i=`expr $i + 1`
done

print_board
while true
do
    while true ; do 
        echo -e "\nEnter the row and column respectively: "
        read row col
        if (( $row > board_size  ||  $row < 1 || $col > board_size || $col < 1))
        then
            echo Enter valid valid values between 1 and $board_size
            continue
        else
            checkForValidity $row $col
            if [ $flag_invalid -eq 1 ]
            then 
                flag_invalid=0
                echo The inputted box is already filled. Try again!
                continue
            fi
            break
        fi
    done
    assign_value $row $col $p1
    print_board
    check_win $p1
    echo -e "\n My Turn: \n"
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
    assign_value $row $col $p2
    print_board
    check_win $p2
done
