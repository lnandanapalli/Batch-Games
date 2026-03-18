@echo off
setlocal enabledelayedexpansion
title Batch Falling Blocks
mode con: cols=30 lines=26

:Menu
cls
echo ==============================
echo    WELCOME TO FALLING BLOCKS
echo ==============================
echo.
echo Select your control configuration:
echo.
echo  [1] Left-Handed (WASD)
echo      W = Spin
echo      A = Move Left
echo      D = Move Right
echo      S = Drop
echo.
echo  [2] Right-Handed (IJKL)
echo      I = Spin
echo      J = Move Left
echo      L = Move Right
echo      K = Drop
echo.
choice /C 12 /N /M "Press 1 or 2 to start: "

:: Set dynamic keys based on choice
if "!errorlevel!"=="1" (
    set "bLeft=A"
    set "bRight=D"
    set "bDrop=S"
    set "bSpin=W"
    set "cKeys=ADSWQ"
) else (
    set "bLeft=J"
    set "bRight=L"
    set "bDrop=K"
    set "bSpin=I"
    set "cKeys=JLKIQ"
)

:: --- Game Initialization ---
set "W=10"
set "H=18"
set "score=0"

:: Initialize empty board
for /L %%y in (1,1,%H%) do for /L %%x in (1,1,%W%) do set "B[%%x][%%y]=."

:: Define all 7 Tetrominoes (x y pairs). The 2nd pair (x2, y2) is the rotation pivot.
set "T1=0 1 1 1 2 1 3 1" & :: I
set "T2=0 0 1 1 0 1 2 1" & :: J
set "T3=2 0 1 1 0 1 2 1" & :: L
set "T4=0 0 1 0 0 1 1 1" & :: O
set "T5=1 0 1 1 2 0 0 1" & :: S
set "T6=1 0 1 1 0 1 2 1" & :: T
set "T7=0 0 1 1 1 0 2 1" & :: Z

:Spawn
set /a "cx=4", "cy=1"
set /a "p=(%random% %% 7) + 1"
for /F "tokens=1-8" %%a in ("!T%p%!") do (
    set "x1=%%a" & set "y1=%%b"
    set "x2=%%c" & set "y2=%%d"
    set "x3=%%e" & set "y3=%%f"
    set "x4=%%g" & set "y4=%%h"
)

:: Game Over check
for /L %%i in (1,1,4) do (
    set /a "tx=cx+x%%i", "ty=cy+y%%i"
    for %%X in (!tx!) do for %%Y in (!ty!) do if "!B[%%X][%%Y]!"=="O" goto :GameOver
)

:Draw
cls
echo   SCORE: %score%
echo  ----------------------
for /L %%y in (1,1,%H%) do (
    set "line=  |"
    for /L %%x in (1,1,%W%) do (
        set "c=!B[%%x][%%y]!"
        for /L %%i in (1,1,4) do (
            set /a "tx=cx+x%%i", "ty=cy+y%%i"
            if "%%x"=="!tx!" if "%%y"=="!ty!" set "c=O"
        )
        set "line=!line!!c!"
    )
    echo !line!^|
)
echo  ----------------------
echo   [%bLeft%]Left   [%bRight%]Right
echo   [%bDrop%]Drop   [%bSpin%]Spin
echo   [Q]Quit

:: Wait 1 second for input, default to your chosen drop key
choice /C %cKeys% /N /T 1 /D %bDrop%
set "key=!errorlevel!"

:: [Q] Quit
if "!key!"=="5" exit

:: Move Left (Key 1 in our dynamic list)
if "!key!"=="1" (
    set "can=1"
    for /L %%i in (1,1,4) do (
        set /a "tx=cx+x%%i-1", "ty=cy+y%%i"
        if !tx! LSS 1 set "can=0"
        for %%X in (!tx!) do for %%Y in (!ty!) do if "!B[%%X][%%Y]!"=="O" set "can=0"
    )
    if "!can!"=="1" set /a "cx-=1"
)

:: Move Right (Key 2 in our dynamic list)
if "!key!"=="2" (
    set "can=1"
    for /L %%i in (1,1,4) do (
        set /a "tx=cx+x%%i+1", "ty=cy+y%%i"
        if !tx! GTR %W% set "can=0"
        for %%X in (!tx!) do for %%Y in (!ty!) do if "!B[%%X][%%Y]!"=="O" set "can=0"
    )
    if "!can!"=="1" set /a "cx+=1"
)

:: Spin (Key 4 in our dynamic list) - 90 deg math around pivot
if "!key!"=="4" if not "!p!"=="4" (
    set "can=1"
    for /L %%i in (1,1,4) do (
        set /a "nx%%i=-(y%%i - y2) + x2", "ny%%i=(x%%i - x2) + y2"
        set /a "tx=cx+nx%%i", "ty=cy+ny%%i"
        if !tx! LSS 1 set "can=0"
        if !tx! GTR %W% set "can=0"
        if !ty! GTR %H% set "can=0"
        for %%X in (!tx!) do for %%Y in (!ty!) do if "!B[%%X][%%Y]!"=="O" set "can=0"
    )
    if "!can!"=="1" for /L %%i in (1,1,4) do (set "x%%i=!nx%%i!" & set "y%%i=!ny%%i!")
)

:: Gravity (Runs every tick unless blocked)
set "can_drop=1"
for /L %%i in (1,1,4) do (
    set /a "tx=cx+x%%i", "ty=cy+y%%i+1"
    if !ty! GTR %H% set "can_drop=0"
    for %%X in (!tx!) do for %%Y in (!ty!) do if "!B[%%X][%%Y]!"=="O" set "can_drop=0"
)

if "!can_drop!"=="1" (
    set /a "cy+=1"
    goto :Draw
)

:: Lock Piece to Board
for /L %%i in (1,1,4) do (
    set /a "tx=cx+x%%i", "ty=cy+y%%i"
    for %%X in (!tx!) do for %%Y in (!ty!) do set "B[%%X][%%Y]=O"
)

:: Check for Line Clears
set "cleared=0"
for /L %%y in (1,1,%H%) do (
    set "full=1"
    for /L %%x in (1,1,%W%) do if "!B[%%x][%%y]!"=="." set "full=0"
    
    if "!full!"=="1" (
        set /a "cleared+=1"
        for /L %%Y in (%%y,-1,2) do (
            set /a "above=%%Y-1"
            for %%A in (!above!) do for /L %%x in (1,1,%W%) do set "B[%%x][%%Y]=!B[%%x][%%A]!"
        )
        :: Clear the very top row
        for /L %%x in (1,1,%W%) do set "B[%%x][1]=."
    )
)

:: Update Score
if "!cleared!"=="1" set /a "score+=100"
if "!cleared!"=="2" set /a "score+=300"
if "!cleared!"=="3" set /a "score+=500"
if "!cleared!"=="4" set /a "score+=800"

goto :Spawn

:GameOver
echo.
echo    GAME OVER!
echo    Final Score: %score%
echo.
choice /C Q /N /M "Press Q to quit"
exit