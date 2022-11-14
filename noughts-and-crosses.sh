#!/bin/bash
declare -A gameBoard
boardSize=3
movesPerformed=0
movePerformedSuccessfully=false
moveRow=0
moveColumn=0
isGameOver=false
playerSignature="x"
computerSignature="o"
blankSignature=" "

announceRound() {
	echo -en "\n\nRound #$((movesPerformed/2+1))\n\n"
}

announceWinner() {
	clear
	echo "$1 is the winner!"
	printBoard
	isGameOver=true
}

printBoard() {
	echo "Example:            Board: (${playerSignature} - you, ${computerSignature} - computer)"
	echo "-------------       -------------"
	echo "| 1 | 2 | 3 |       | ${gameBoard[0,0]} | ${gameBoard[0,1]} | ${gameBoard[0,2]} |"
	echo "-------------       -------------"
	echo "| 4 | 5 | 6 |       | ${gameBoard[1,0]} | ${gameBoard[1,1]} | ${gameBoard[1,2]} |"
	echo "-------------       -------------"
	echo "| 7 | 8 | 9 |       | ${gameBoard[2,0]} | ${gameBoard[2,1]} | ${gameBoard[2,2]} |"
	echo "-------------       -------------"
}

initializeBoard() {
	for ((row=0;row<boardSize;++row))
	do
		for ((column=0;column<boardSize;++column))
		do
			gameBoard["${row}","${column}"]="${blankSignature}"
		done
	done
}

tryPerformPlayerMove() {
	[ $((9-$1)) -le 8 ] && [ $((9-$1)) -ge 0 ] && positionIsValid=true || positionIsValid=false

	if ! $positionIsValid
	then
		movePerformedSuccessfully=false
		return
	fi

	convertMovePositionToIndexes "$1"

	if [ "${gameBoard[${moveRow},${moveColumn}]}" != "${blankSignature}" ]
	then
		movePerformedSuccessfully=false
		return
	fi

	gameBoard["${moveRow},${moveColumn}"]="${playerSignature}"
	movePerformedSuccessfully=true
}

tryPerformComputerMove() {
	convertMovePositionToIndexes "$1"

	if [ "${gameBoard[${moveRow},${moveColumn}]}" != "${blankSignature}" ]
	then
		movePerformedSuccessfully=false
		return
	fi

	gameBoard["${moveRow},${moveColumn}"]="${computerSignature}"
	movePerformedSuccessfully=true
}

checkWinCondition() {
	[[ "${gameBoard[${moveRow},0]}" == "$1" ]] &&
	[[ "${gameBoard[${moveRow},1]}" == "$1" ]] &&
	[[ "${gameBoard[${moveRow},2]}" == "$1" ]] &&
	announceWinner "$2" && return

	[[ "${gameBoard[0,${moveColumn}]}" == "$1" ]] &&
	[[ "${gameBoard[1,${moveColumn}]}" == "$1" ]] &&
	[[ "${gameBoard[2,${moveColumn}]}" == "$1" ]] &&
	announceWinner "$2" && return

	if 
	[[ "${moveRow}" == "${moveColumn}" ]] ||
	[[ "${moveRow}${moveColumn}" == "02" ]] ||
	[[ "${moveRow}${moveColumn}" == "20" ]]
	then
		if [[ "${gameBoard[0,2]}" == "$1" ]] &&
		[[ "${gameBoard[1,1]}" == "$1" ]] &&
		[[ "${gameBoard[2,0]}" == "$1" ]] 
		then
			announceWinner "$2"
			return
		fi

		if [[ "${gameBoard[0,0]}" == "$1" ]] &&
		[[ "${gameBoard[1,1]}" == "$1" ]] &&
		[[ "${gameBoard[2,2]}" == "$1" ]]
		then
			announceWinner "$2"
			return
		fi
	fi
}

checkDrawCondition() {
	if [ "${movesPerformed}" -ge 9 ]
	then
		echo -en "\nIt's a draw!\n\n"
		isGameOver=true
	fi
}

convertMovePositionToIndexes() {
	case $1 in
		1)
			moveRow=0
			moveColumn=0
			;;
		2)
			moveRow=0
			moveColumn=1
			;;
		3)
			moveRow=0
			moveColumn=2
			;;
		4)
			moveRow=1
			moveColumn=0
			;;
		5)
			moveRow=1
			moveColumn=1
			;;
		6)
			moveRow=1
			moveColumn=2
			;;
		7)
			moveRow=2
			moveColumn=0
			;;
		8)
			moveRow=2
			moveColumn=1
			;;
		9)
			moveRow=2
			moveColumn=2
			;;
	esac
}

startPlayerTurn() {
	echo "Your turn"
	printBoard

	until [ $movePerformedSuccessfully = true ]
	do
		echo "Choose your move:"
		read -r movePosition

		tryPerformPlayerMove "${movePosition}"

		if ! $movePerformedSuccessfully
		then
			echo "Move specified is invalid. Try again"
		fi
	done

	finishMove "${playerSignature}" "Player"
	[[ "${isGameOver}" == "false" ]] && 
	checkDrawCondition
}

startComputerTurn() {
	echo -en "\nComputer's turn\n"

	until [ $movePerformedSuccessfully = true ]
	do
		movePosition="$(shuf -i 1-9 -n 1)"

		tryPerformComputerMove "${movePosition}"
	done

	finishMove "${computerSignature}" "Computer"
	[[ "${isGameOver}" == "false" ]] && 
	printBoard &&
	sleep 2s
}

finishMove() {
	checkWinCondition "$1" "$2"
	movePerformedSuccessfully=false
	((movesPerformed++))
}

finishRound() {
	checkDrawCondition
	((round++))
}

main() {
	initializeBoard

	until [ $isGameOver = true ]
	do
		clear
		announceRound
		startPlayerTurn
		[[ "${isGameOver}" == "false" ]] &&
		startComputerTurn &&
		finishRound
	done
}

main