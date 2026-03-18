@echo off
setlocal enabledelayedexpansion
title Batch Tic-Tac-Toe
mode con: cols=40 lines=22

:NewGame
:: Initialize board - empty cells are blank
for /L %%i in (1,1,9) do set "B[%%i]= "
set "turn=X"
set "moves=0"
:: Coin flip: 0=Easy AI, 1=Hard AI (fork detection)
set /a "aiLevel=!random! %% 2"

:GameLoop
call :DrawBoard

:: Check for winner (need at least 5 total moves)
set "result="
if !moves! GEQ 5 (
    call :CheckWin X
    if "!winner!"=="1" set "result=X"
    call :CheckWin O
    if "!winner!"=="1" set "result=O"
)

if "!result!"=="X" (
    echo       * YOU WIN! *
    goto EndGame
)
if "!result!"=="O" (
    echo     * COMPUTER WINS! *
    goto EndGame
)
if !moves! EQU 9 (
    echo      * IT'S A DRAW! *
    goto EndGame
)

:: Whose turn?
if "!turn!"=="X" goto PlayerTurn
goto ComputerTurn

:PlayerTurn
echo    Your turn [X]
echo    Pick a cell [1-9]:
choice /C 123456789Q /N
set "key=!errorlevel!"
if "!key!"=="10" exit
:: Check if cell is already taken
for %%C in (!key!) do (
    if "!B[%%C]!"=="X" goto GameLoop
    if "!B[%%C]!"=="O" goto GameLoop
    set "B[%%C]=X"
)
set /a "moves+=1"
set "turn=O"
goto GameLoop

:ComputerTurn
echo    Computer thinking...
call :AI
for %%M in (!ai_move!) do set "B[%%M]=O"
set /a "moves+=1"
set "turn=X"
goto GameLoop

:EndGame
echo.
if "!aiLevel!"=="0" (
    echo    AI was: EASY mode
) else (
    echo    AI was: HARD mode
)
echo.
echo    [R] Play Again  [Q] Quit
choice /C RQ /N
if !errorlevel!==1 goto NewGame
exit

:: ========== SUBROUTINES ==========

:DrawBoard
cls
echo.
echo      ==============================
echo          TIC - TAC - TOE
echo      ==============================
echo.
echo   Guide:          Game:
echo   1^|2^|3       !B[1]! ^| !B[2]! ^| !B[3]!
echo   -+-+-      ---+---+---
echo   4^|5^|6       !B[4]! ^| !B[5]! ^| !B[6]!
echo   -+-+-      ---+---+---
echo   7^|8^|9       !B[7]! ^| !B[8]! ^| !B[9]!
echo.
goto :eof

:CheckWin
set "winner=0"
set "p=%~1"
:: Rows
if "!B[1]!"=="!p!" if "!B[2]!"=="!p!" if "!B[3]!"=="!p!" set "winner=1"
if "!B[4]!"=="!p!" if "!B[5]!"=="!p!" if "!B[6]!"=="!p!" set "winner=1"
if "!B[7]!"=="!p!" if "!B[8]!"=="!p!" if "!B[9]!"=="!p!" set "winner=1"
:: Columns
if "!B[1]!"=="!p!" if "!B[4]!"=="!p!" if "!B[7]!"=="!p!" set "winner=1"
if "!B[2]!"=="!p!" if "!B[5]!"=="!p!" if "!B[8]!"=="!p!" set "winner=1"
if "!B[3]!"=="!p!" if "!B[6]!"=="!p!" if "!B[9]!"=="!p!" set "winner=1"
:: Diagonals
if "!B[1]!"=="!p!" if "!B[5]!"=="!p!" if "!B[9]!"=="!p!" set "winner=1"
if "!B[3]!"=="!p!" if "!B[5]!"=="!p!" if "!B[7]!"=="!p!" set "winner=1"
goto :eof

:AI
set "ai_move="

:: Priority 1: Can we win? (two O's + one empty)
call :FindMove O
if defined ai_move goto :eof

:: Priority 2: Must we block? (two X's + one empty)
call :FindMove X
if defined ai_move goto :eof

:: Priority 2.5 (Hard AI only): Try to CREATE a fork for O
if "!aiLevel!" NEQ "1" goto SkipFork1
call :CheckFork O
if defined forkMove set "ai_move=!forkMove!"
if defined ai_move goto :eof
:SkipFork1

:: Priority 2.6 (Hard AI only): BLOCK opponent's fork
if "!aiLevel!" NEQ "1" goto SkipFork2
call :CheckFork X
if defined forkMove set "ai_move=!forkMove!"
if defined ai_move goto :eof
:SkipFork2

:: Priority 3: Take center
if "!B[5]!"==" " (
    set "ai_move=5"
    goto :eof
)

:: Priority 4: Take a corner
for %%C in (1 3 7 9) do (
    if not defined ai_move if "!B[%%C]!"==" " set "ai_move=%%C"
)
if defined ai_move goto :eof

:: Priority 5: Take any edge
for %%C in (2 4 6 8) do (
    if not defined ai_move if "!B[%%C]!"==" " set "ai_move=%%C"
)
goto :eof

:FindMove
set "fm=%~1"
for %%W in ("1 2 3" "4 5 6" "7 8 9" "1 4 7" "2 5 8" "3 6 9" "1 5 9" "3 5 7") do (
    if not defined ai_move (
        for /F "tokens=1-3" %%a in (%%W) do (
            set "cnt=0"
            set "emp="
            if "!B[%%a]!"=="!fm!" set /a cnt+=1
            if "!B[%%a]!" NEQ "X" if "!B[%%a]!" NEQ "O" set "emp=%%a"
            if "!B[%%b]!"=="!fm!" set /a cnt+=1
            if "!B[%%b]!" NEQ "X" if "!B[%%b]!" NEQ "O" set "emp=%%b"
            if "!B[%%c]!"=="!fm!" set /a cnt+=1
            if "!B[%%c]!" NEQ "X" if "!B[%%c]!" NEQ "O" set "emp=%%c"
            if "!cnt!"=="2" if defined emp set "ai_move=!emp!"
        )
    )
)
goto :eof

:CheckFork
:: For each empty cell, simulate placing a piece there.
:: Count how many winning threats it creates (lines with 2 of that player + 1 empty).
:: If 2+ threats = that's a fork.
set "forkMove="
set "fp=%~1"
for /L %%i in (1,1,9) do (
    if not defined forkMove if "!B[%%i]!"==" " (
        set "B[%%i]=!fp!"
        call :CountThreats
        set "B[%%i]= "
        if !threats! GEQ 2 set "forkMove=%%i"
    )
)
goto :eof

:CountThreats
:: Count lines where fp has 2 pieces and 1 is empty (= a threat)
set "threats=0"
for %%W in ("1 2 3" "4 5 6" "7 8 9" "1 4 7" "2 5 8" "3 6 9" "1 5 9" "3 5 7") do (
    for /F "tokens=1-3" %%a in (%%W) do (
        set "tc=0"
        set "te=0"
        if "!B[%%a]!"=="!fp!" set /a tc+=1
        if "!B[%%a]!"==" " set /a te+=1
        if "!B[%%b]!"=="!fp!" set /a tc+=1
        if "!B[%%b]!"==" " set /a te+=1
        if "!B[%%c]!"=="!fp!" set /a tc+=1
        if "!B[%%c]!"==" " set /a te+=1
        if "!tc!"=="2" if "!te!"=="1" set /a threats+=1
    )
)
goto :eof
