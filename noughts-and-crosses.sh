#!/bin/bash
# Declaration of a game board utilizing associative array for matrix simulation
# Оголошення ігрового поля як асоціативного масиву для імітації матриці
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

# Announce current round by calculating it as the amount of all moves performed by players 
# int divided by 2 add increased by 1
# Оголошення теперішнього раунду, порядок якого вираховується шляхом цілочисельного ділення 
# загальної кількості кроків на 2 та додавання 1
announceRound() {
	clear
	echo -en "Round #$((movesPerformed/2+1))\n\n"
}

# Announce winner of the game by using first argument provided during invocation as the name of winner,
# print game board, and declare game over by assigning isGameOver true
# Оголосити переможця, використовуючи перший наданий аргумент як ім'я переможця, вивести ігрове поле
# та оголосити кінець гри присвоєнням isGameOver true
announceWinner() {
	clear
	echo "$1 is the winner!"
	printBoard
	isGameOver=true
	exit 0
}

# Announce draw, print the game board, and declare game over by assigning isGameOver true
# Оголосити нічию, вивести ігрове поле та оголосити кінець гри присвоєнням isGameOver true
announceDraw() {
	clear
	echo -en "\nIt's a draw!\n\n"
	printBoard
	isGameOver=true
	exit 0
}

# Print game board and example of how to refer to game field's cells
# Виведення ігрового поля з прикладом того, як вказати певне місце на ньому
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

# Fill the game board's cells with empty values to signify them not being marked by any of the players
# Заповнення клітинок ігрового поля пустим значенням як знак того, що ви не заняті жодним із гравців
initializeBoard() {
	for ((row=0;row<boardSize;++row))
	do
		for ((column=0;column<boardSize;++column))
		do
			gameBoard["${row}","${column}"]="${blankSignature}"
		done
	done
}

# Try to finish player's move by using the position on the board provided as first argument
# Спробувати завершити хід гравця користуючись номером позиції, що передана як перший аргумент функції
tryPerformPlayerMove() {
	# Check whether move position provided as first argument is withing range of 1 to 9 inclusive
	# Перевірка, чи позиція задана першим аргументом функції належить до проміжку від 1 до 9 включно	
	[ $((9-$1)) -le 8 ] && [ $((9-$1)) -ge 0 ] && positionIsValid=true || positionIsValid=false

	if ! $positionIsValid
	then
		movePerformedSuccessfully=false
		return
	fi

	# Convert int move position provided to corresponding indexes in gameBoard matrix
	# Конвертація наданої позиції кроку в індекси gameBoard матриці
	convertMovePositionToIndexes "$1"

	if [ "${gameBoard[${moveRow},${moveColumn}]}" != "${blankSignature}" ]
	then
		movePerformedSuccessfully=false
		return
	fi

	gameBoard["${moveRow},${moveColumn}"]="${playerSignature}"
	movePerformedSuccessfully=true
}

# Works exactly like tryPerformPlayerMove() but without a check whether or not the move position provided is in range of 1 to 9 inclusive
# Such check is ommitted due to the fact that computer already generates movePosition values in this range
# Працює ідентично до tryPerformPlayerMove() за винятком відсутності перевірки на належність позиції кроку до інтервалу від 1 до 9 включно
# Цю перевірку недоцільно виконувати, адже програма і так генерує значення movePosition у цьому проміжку 
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

	if [[ "${moveRow}" == "${moveColumn}" ]] ||
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
		announceDraw
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

		*)
			moveRow=-1
			moveColumn=-1
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
}

startComputerTurn() {
	echo -en "\nComputer's turn\n"

	until [ $movePerformedSuccessfully = true ]
	do
		movePosition="$(shuf -i 1-9 -n 1)"

		tryPerformComputerMove "${movePosition}"
	done

	finishMove "${computerSignature}" "Computer"
}

finishMove() {
	((movesPerformed++))
	checkWinCondition "$1" "$2"
	checkDrawCondition
	movePerformedSuccessfully=false
	printBoard
	sleep 2s
}

main() {
	initializeBoard
	until [ $isGameOver = true ]
	do
		announceRound
		startPlayerTurn
		startComputerTurn
	done
}

main