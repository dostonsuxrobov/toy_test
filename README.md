# Chain Reaction Tycoon

A 3D physics puzzle game where you build Rube Goldberg machines to complete simple tasks for customers. Build elaborate chain reactions, test your designs, and optimize for cost, speed, and efficiency!

## Game Overview

**Chain Reaction Tycoon** is an automation puzzle game about building the world's most satisfying Rube Goldberg machines. Players design elaborate chain reaction machines in 3D space to complete simple tasks (like "press a button"). The twist: you're building these for paying customers who rate your machines on efficiency, creativity, and satisfaction.

## Core Gameplay Loop

1. **BUILD** - Select parts from the menu and place them in the 3D workspace
2. **TEST** - Run your machine and watch the physics simulation
3. **OPTIMIZE** - Get rated on Cost, Speed, and Parts Used, then improve your design

## How to Play

### Opening the Game
1. Open this project in **Godot 4.3+**
2. Press F5 or click "Run Project"
3. The game will open with the first level ready to play

### Building Your Machine

**Objective:** Build a chain reaction that makes the blue ball press the red button!

**Available Parts:**
- **Ball** ($50) - Rolls and collides with other objects
- **Ramp** ($100) - Angled surface for balls to roll down
- **Domino** ($25) - Falls when hit, can trigger chain reactions
- **Lever** ($150) - Pivoting arm for complex mechanisms

### Controls

**Placing Parts:**
1. Click a part button in the left menu
2. Move your mouse in the 3D view (a ghost preview will appear)
3. Press **Q** or **E** to rotate the part
4. **Left-click** to place the part
5. **Right-click** to cancel placement

**Deleting Parts:**
- With no part selected, **left-click** on a placed part to delete it

**Camera Controls:**
- **Middle Mouse Button + Drag** - Rotate camera around the workspace
- **Mouse Wheel** - Zoom in/out
- **W/A/S/D** - Pan camera

**Testing:**
- Click **Test Machine** to start physics simulation
- Click **Stop Test** to return to build mode
- Click **Reset** to clear all placed parts and start over

### Scoring System

After completing a level, you'll be rated on three metrics:

- **Cost** ⭐⭐⭐ - How much money did your machine cost?
- **Time** ⭐⭐⭐ - How long did it take to complete the task?
- **Parts** ⭐⭐⭐ - How many parts did you use?

**Goal:** Get 9/9 stars by optimizing all three metrics!

## Game Features

### Physics-Based Building
- Realistic 3D physics simulation
- Deterministic behavior - your machine works the same way every time
- Satisfying collisions and reactions

### Creative Freedom
- No single "correct" solution
- Build complex, inefficient machines or elegant, minimalist designs
- The choice is yours!

### Optimization Challenge
- Beat the level, then beat your own score
- Compete for the best Cost/Time/Parts ratio
- Multiple approaches to every puzzle

## Technical Details

### Built With
- **Godot 4.3+**
- **GDScript**
- **3D Physics Engine**

### Project Structure
```
toy_test/
├── scenes/
│   └── main.tscn          # Main game scene
├── scripts/
│   ├── game_manager.gd     # Core game state management
│   ├── workspace.gd        # 3D building workspace
│   ├── camera_rig.gd       # Camera controls
│   ├── ui_controller.gd    # UI and menus
│   ├── goal_button.gd      # Goal detection
│   └── level_setup.gd      # Level initialization
├── project.godot           # Godot project config
└── README.md              # This file
```

### Key Systems

**Game Manager** (`game_manager.gd`)
- Manages game states (BUILD, TEST, REVIEW)
- Tracks placed parts and costs
- Calculates star ratings
- Handles level progression

**Workspace** (`workspace.gd`)
- Handles part placement and deletion
- Creates physics objects
- Grid snapping system
- Ghost preview rendering

**Camera Rig** (`camera_rig.gd`)
- Orbital camera system
- Smooth zoom and rotation
- Keyboard panning

**UI Controller** (`ui_controller.gd`)
- Part selection menu
- Control buttons
- Stats display
- Results screen

## Design Philosophy

This game is built around three core concepts:

1. **Physics Sandbox** (like Besiege/Poly Bridge)
   - Joy of building and watching machines work (or fail spectacularly)
   - Spectacular failures are a feature, not a bug!

2. **Optimization Puzzle** (like Opus Magnum)
   - Intellectual reward of making solutions better
   - "Easy to solve, hard to master"

3. **Progression System** (like Factorio)
   - Long-term hook of unlocking new parts (in future updates)
   - Taking on harder challenges

## Tips for Success

1. **Start Simple** - Get a basic working machine first, then optimize
2. **Use Ramps** - Great for directing balls and building momentum
3. **Domino Chains** - Cheap way to transfer motion across distance
4. **Rotate Parts** - Don't forget Q and E keys for rotation!
5. **Test Often** - Physics can be surprising - test early and often
6. **Think in 3D** - Use all three dimensions of space
7. **Experiment** - There's no wrong way to solve a puzzle!

## Future Enhancements

Potential features for future versions:
- More part types (gears, pistons, conveyor belts, springs, balloons)
- Multiple levels with increasing difficulty
- Part unlock/tech tree progression
- Time manipulation (slow-mo, rewind)
- Leaderboards and sharing
- Level editor
- Sound effects and music
- Particle effects for impacts
- More visual polish

## Troubleshooting

**Parts won't place:**
- Make sure you're in Build mode (not Test mode)
- Check that you're clicking within the workspace bounds
- Ensure the ghost preview is visible (green tint = valid placement)

**Physics acting weird:**
- Reset the level and try again
- Make sure parts aren't overlapping when placed
- Some configurations may be unstable - that's part of the challenge!

**Camera is stuck:**
- Use WASD to pan if you lose the workspace
- Zoom out with mouse wheel
- The workspace is centered at (0,0,0)

## Credits

Built with Godot Engine (https://godotengine.org)

Game Design Inspired by:
- Besiege
- Poly Bridge
- Opus Magnum
- The Incredible Machine
- Factorio

---

## Quick Start Guide

1. **Open in Godot 4.3+**
2. **Press F5 to run**
3. **Click "Ball" in the left menu**
4. **Place parts to connect the blue ball to the red button**
5. **Click "Test Machine"**
6. **Watch your creation come to life!**

Have fun building! 🎢⚙️🎯
