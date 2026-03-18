@echo off
setlocal enabledelayedexpansion
title Batch Flappy Bat
mode con: cols=38 lines=22

:: --- Initialization ---
set "W=30"
set "H=15"
set "bx=5"
set "by=7"
set "score=0"
set "tick=0"

:: Initialize empty pipe array (0 means no pipe in that column)
:: T[] tracks column type: 0=empty, 1=wall, 2=interior
for /L %%x in (1,1,%W%) do (
    set "P[%%x]=0"
    set "T[%%x]=0"
)

:GameLoop
:: --- 1. Move Pipes Left ---
set /a "tick+=1"
for /L %%x in (1,1,29) do (
    set /a "nx=%%x+1"
    :: Safe array expansion trick to copy the next column into the current one
    for %%N in (!nx!) do (
        set "P[%%x]=!P[%%N]!"
        set "T[%%x]=!T[%%N]!"
    )
)

:: --- 2. Spawn New Pipes ---
:: Every 8 ticks, generate a new pipe gap.
:: Pipes are 3 columns wide. T[]=1 for walls, T[]=2 for interior.
set /a "spawn=tick %% 8"
if "!spawn!"=="0" (
    set /a "gap=(!random! %% 7) + 5"
    set "P[30]=!gap!"
    set "T[30]=1"
    set "P[29]=!gap!"
    set "T[29]=2"
    set "P[28]=!gap!"
    set "T[28]=1"
) else (
    set "P[%W%]=0"
    set "T[%W%]=0"
)

:: --- 3. Scoring ---
:: Score once when the RIGHT EDGE of the pipe just cleared the bird column.
:: That happens when P[bx-1]!=0 (right wall just slid to bx-1) AND P[bx]==0.
set /a "scoreCol=%bx%-1"
for %%S in (!scoreCol!) do (
    if "!P[%%S]!" NEQ "0" if "!P[%bx%]!"=="0" set /a "score+=10"
)

:: --- 4. Collision Detection ---
:: Hit the floor or ceiling?
if %by% LSS 1 goto GameOver
if %by% GTR %H% goto GameOver

:: Hit a pipe?
set "g=!P[%bx%]!"
if "!g!" NEQ "0" (
    set /a "gt=g - 3", "gb=g + 3"
    :: gt is top pipe bottom, gb is bottom pipe top
    if %by% LEQ !gt! goto GameOver
    if %by% GEQ !gb! goto GameOver
)

:: --- 5. Render Screen ---
cls
echo   SCORE: %score%
echo  ==================================
for /L %%y in (1,1,%H%) do (
    set "line=  "
    for /L %%x in (1,1,%W%) do (
        set "c=."
        :: Draw Bird
        if "%%x"=="%bx%" if "%%y"=="%by%" set "c=>"
        
        :: Draw Pipes (Only if bird isn't currently overwriting that pixel)
        if "!c!"=="." (
            set "g=!P[%%x]!"
            if "!g!" NEQ "0" (
                set /a "gt=g - 3", "gb=g + 3"
                set "isPipe=1"
                :: If Y is inside the gap, it's not a pipe pixel
                if %%y GTR !gt! if %%y LSS !gb! set "isPipe=0"
                if "!isPipe!"=="1" (
                    :: T[x]=1 means wall, T[x]=2 means interior space
                    if "!T[%%x]!"=="2" ( set "c= " ) else ( set "c=|" )
                )
            )
        )
        set "line=!line!!c!"
    )
    echo !line!
)
echo  ==================================
echo   [W] Flap Up   [S] Fall / Wait
echo   [Q] Quit

:: --- 6. Input & Physics ---
:: Waits 1 second maximum. Defaults to S (Fall)
choice /C WSQ /N /T 1 /D S
set "key=!errorlevel!"

if "!key!"=="3" exit

if "!key!"=="1" (
    :: Flap up (moves up by 2 units)
    set /a "by-=2"
) else (
    :: Gravity (pulls down by 1 unit)
    set /a "by+=1"
)

goto GameLoop

:GameOver
echo.
echo    * THUD *
echo    GAME OVER!
echo    Final Score: %score%
echo    Press [Q] to quit.
choice /C Q /N >nul
exit