# Batch Games

A collection of classic games written in pure Windows Batch. No external libraries, no DLLs, no dependencies — just `.bat` files that run on any Windows machine with `cmd.exe`.

## Philosophy

These games are built to work anywhere: a locked-down corporate machine, an old Windows XP box, or a bare SSH session. Copy a single `.bat` file and play. Nothing to install, no admin rights needed.

## Games

### Falling Blocks (`falling_blocks.bat`)

A falling-block puzzle game. Rotate and place pieces to clear lines.

- **Controls:** Configurable at start (arrow keys or WASD)
- **Features:** 7 piece types, rotation, line clearing, scoring, progressive speed

### Flappy Bat (`flappy_bat.bat`)

Guide a bat through gaps in vertical pipes.

- **Controls:** W to flap, S to fall, Q to quit
- **Features:** Scrolling pipes, score tracking, collision detection

### Tic-Tac-Toe (`tic_tac_toe.bat`)

Classic X vs O against an AI opponent.

- **Controls:** 1-9 to place your mark, Q to quit
- **Features:** AI with randomized difficulty (Easy or Hard, revealed at game over), fork detection

## Requirements

- Windows (any version with `cmd.exe` and the `choice` command)

## Usage

Double-click any `.bat` file, or run from the command line:

```cmd
falling_blocks.bat
flappy_bat.bat
tic_tac_toe.bat
```

## License

See [LICENSE](LICENSE) for details.
