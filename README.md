# Opus Mechanicus

A puzzle game inspired by Opus Magnum, built in Godot.

## About

This is an unpolished but mechanically functional clone of Opus Magnum's core mechanics. The game features a hexagonal grid where you place mechanical arms to transport atoms from input zones to output zones.

## How to Play

### Objective
Move all atoms from the green input zone to the red output zone.

### Controls
1. **Place Arm** - Click the "Place Arm (Click)" button, then click on any hex tile to place a mechanical arm
2. **Play** - Start the simulation
3. **Pause** - Pause the simulation
4. **Reset** - Reset the level to initial state

### Mechanical Arms
Each arm has a pre-programmed instruction set:
- Grab an atom at the arm's end
- Rotate clockwise 180° (3 steps of 60°)
- Drop the atom
- Rotate clockwise another 180° to return to starting position
- Repeat

### Strategy
Position your arms so they can:
1. Grab atoms from the green input zone
2. Rotate to face the red output zone
3. Drop atoms into the red zone

## Technical Details

### Core Mechanics Implemented
- Hexagonal grid system with axial coordinates
- Mechanical arms with rotation and grab/drop
- Step-by-step simulation execution
- Atom transport system
- Win condition detection

### Project Structure
```
scripts/
  - hex_grid.gd       # Hexagonal grid utilities
  - atom.gd           # Atom/molecule entities
  - mechanical_arm.gd # Programmable mechanical arm
  - game_manager.gd   # Main game logic and simulation
  - ui_controller.gd  # User interface
  - main.gd           # Scene initialization

scenes/
  - main.tscn         # Main game scene
```

## Running the Game

Open the project in Godot 4.3 or later and press F5 to run.

## Future Enhancements (Not Implemented)
- Custom instruction programming for arms
- Multiple atom types and bonding
- Glyphs (calcification, bonding, etc.)
- Multiple levels with varying difficulty
- Optimization metrics (cycles, area, cost)
- Save/load contraption designs
