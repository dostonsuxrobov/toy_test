# Chain Reaction Tycoon

A 3D physics puzzle game where you build Rube Goldberg machines to complete simple tasks for customers. Build elaborate chain reactions, test your designs, and optimize for cost, speed, and efficiency!

## Game Overview

**Chain Reaction Tycoon** is an automation puzzle game about building the world's most satisfying Rube Goldberg machines. Players design elaborate chain reaction machines in 3D space to complete simple tasks (like "press a button"). The twist: you're building these for paying customers who rate your machines on efficiency, creativity, and satisfaction.

## Core Gameplay Loop

1. **BRIEFING** - View the challenge with an establishing camera shot
2. **BUILD** - Select parts from the menu and place them in the 3D workspace
3. **TEST** - Run your machine and watch the physics simulation with time controls
4. **REVIEW** - Get rated on Cost, Speed, and Parts Used
5. **OPTIMIZE** - Improve your design for a better score

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

#### Briefing Mode
- **Start Building** button - Begin building phase

#### Build Mode Camera (Professional 3D Controls)
- **MMB + Drag** - Orbit camera around focal point
- **Shift + MMB + Drag** - Pan/truck camera (moves focus point)
- **Mouse Wheel** - Dolly zoom in/out

**Placing Parts:**
1. Click a part button in the left menu
2. Move your mouse in the 3D view (a ghost preview will appear)
3. **Grid Feedback**: Blue = valid, Red = invalid placement
4. Press **R** or **Right-Click** to rotate 90°
5. Press **Q** or **E** to rotate 45° (fine adjustment)
6. **Left-click** to place the part
7. **Right-click** to cancel placement

**Editing Placed Parts (3D Gizmo System):**
- **Left-click** on a placed part to select it
- **3D Gizmo** appears with colored arrows (Red=X, Green=Y, Blue=Z)
- **Click + Drag Arrow** - Move part along that axis (snaps to grid)
- **CTRL (hold)** - Disable snapping for precise placement
- **G Key** - Switch to move mode
- **DELETE** - Delete selected part
- **Left-click empty space** - Deselect

**Testing:**
- Click **Test Machine** to start physics simulation
- Click **Stop Test** to return to build mode
- Click **Reset** to clear all placed parts and start over

#### Test Mode Time Controls
- **0.25x / 0.5x / 1x / 2x / 4x** - Set simulation speed
- **|| Pause** - Freeze simulation for inspection
- **▶ Resume** - Continue from paused state
- **Camera** - Automatically follows active objects (can still orbit manually)

### Scoring System

After completing a level, you'll be rated on three metrics:

- **Cost** ⭐⭐⭐ - How much money did your machine cost?
- **Time** ⭐⭐⭐ - How long did it take to complete the task?
- **Parts** ⭐⭐⭐ - How many parts did you use?

**Goal:** Get 9/9 stars by optimizing all three metrics!

## Game Features

### 🎥 Cinematic Camera System
- **Establishing Shot**: Level opens with framed view of start and end points
- **Professional Controls**: Industry-standard orbital camera (Blender/Maya style)
- **Smart Follow Mode**: Camera automatically tracks physics objects during simulation
- **Dynamic Focal Point**: Snaps to last-placed or selected object
- **Locked Briefing Phase**: View the challenge before building

### 🛠️ Advanced Building Tools
- **Ghost Preview System**: Semi-transparent preview with color-coded grid feedback
- **3D Gizmo Editor**: Move/rotate placed parts with visual axis handles
- **Smart Snapping**: Grid-based placement with CTRL to disable for precision
- **Multiple Rotation Modes**: 90° (R key/RMB) or 45° (Q/E keys)
- **One-Click Selection**: Edit any placed part with gizmo tools

### ⏱️ Time Control System
- **Slow Motion**: 0.25x and 0.5x speeds for debugging
- **Fast Forward**: 2x and 4x speeds for testing
- **Pause**: Freeze simulation at any moment for inspection
- **Deterministic Physics**: 60 Hz fixed timestep for 100% repeatable results

### 💥 Satisfying Feedback
- **Particle Effects**: Sparks, dust puffs, and debris on impacts
- **Breakable Parts**: High-speed collisions fragment objects into pieces
- **Failure Detection**: Auto-pause and highlight failed parts with visual feedback
- **Material-Specific Effects**: Wood, metal, and plastic react differently

### 🎮 User Experience
- **Four Game States**: BRIEFING → BUILD → TEST → REVIEW
- **Smart UI**: Context-sensitive interface that shows only relevant controls
- **Instant Feedback**: Blue/red grid indicators, real-time gizmo updates
- **Professional Feel**: Based on industry-standard 3D modeling tools

### 🎯 Optimization Challenge
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
│   └── main.tscn               # Main game scene
├── scripts/
│   ├── game_manager.gd          # Game state machine (BRIEFING/BUILD/TEST/REVIEW)
│   ├── workspace.gd             # Building system + ghost preview + gizmo integration
│   ├── camera_rig.gd            # Orbital camera with follow mode
│   ├── ui_controller.gd         # UI + time controls
│   ├── gizmo_3d.gd              # 3D move/rotate gizmo system
│   ├── failure_detector.gd      # Failure detection & auto-pause
│   ├── particle_manager.gd      # Particle effects spawner
│   ├── sound_manager.gd         # Audio playback system (ready for sounds)
│   ├── collision_monitor.gd     # Collision effects & part breaking
│   ├── goal_button.gd           # Goal detection
│   └── level_setup.gd           # Level initialization
├── project.godot                # Project config + deterministic physics settings
└── README.md                    # This file
```

### Key Systems

**Game Manager** (`game_manager.gd`)
- Four-state machine: BRIEFING → BUILD → TEST → REVIEW
- Tracks placed parts and costs
- Calculates star ratings
- Time scale management
- Physics freeze/unfreeze

**Workspace** (`workspace.gd`)
- Ghost preview with blue/red grid feedback
- Gizmo integration for editing
- Part placement and selection
- Creates physics objects with collision monitors
- Grid snapping system

**Camera Rig** (`camera_rig.gd`)
- Spherical orbital camera system
- Establishing shot calculation
- Follow mode for TEST state
- Shift+MMB panning
- Dynamic focal point

**Gizmo 3D** (`gizmo_3d.gd`)
- Move arrows (RGB for XYZ axes)
- Rotate rings (torus meshes)
- Snapping with CTRL override
- Ray-cast axis detection
- Real-time target following

**UI Controller** (`ui_controller.gd`)
- State-aware UI visibility
- Time control panel (0.25x - 4x speed)
- Pause/resume system
- Part selection menu
- Stats display and results screen

**Failure Detector** (`failure_detector.gd`)
- Monitors parts falling off map (Y < -10)
- Timeout detection (60s max)
- Auto-pause on failure
- Visual highlighting (red emission)
- Center-screen failure messages

**Particle Manager** (`particle_manager.gd`)
- GPUParticles3D effects
- Material-specific particles (wood/metal/dust)
- Impact effects based on velocity
- Spark and dust puff spawners
- Auto-cleanup system

**Sound Manager** (`sound_manager.gd`)
- AudioStreamPlayer3D pool (20 players)
- Collision sound system
- Volume based on impact velocity
- Pitch variation for variety
- Ready for audio file integration

**Collision Monitor** (`collision_monitor.gd`)
- Attached to each RigidBody3D
- Triggers particle/sound effects
- Break detection (>15 m/s)
- Creates fragment pieces
- Material-aware responses

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

## Implemented Features ✅

- ✅ **Advanced Camera System**: Establishing shot, orbital controls, follow mode
- ✅ **3D Gizmo Editing**: Move/rotate placed parts with visual handles
- ✅ **Time Controls**: Slow motion (0.25x-0.5x), fast forward (2x-4x), pause
- ✅ **Particle Effects**: Sparks, dust, debris on collisions
- ✅ **Breakable Parts**: High-speed impacts fragment objects
- ✅ **Failure Detection**: Auto-pause with visual feedback
- ✅ **Deterministic Physics**: 60 Hz fixed timestep
- ✅ **Smart UI**: State-aware interface with grid feedback
- ✅ **Professional Controls**: Industry-standard camera and editing tools

## Future Enhancements

Potential features for future versions:
- 🎵 **Audio Integration**: Add sound files for collisions and mechanics
- 🎨 **More Part Types**: Gears, pistons, conveyor belts, springs, balloons
- 📚 **Multiple Levels**: Increasing difficulty with varied challenges
- 🎄 **Part Unlock System**: Tech tree progression
- 🏆 **Leaderboards**: Online sharing and competition
- 🛠️ **Level Editor**: Create and share custom challenges
- 🎶 **Music System**: Dynamic soundtrack
- ✨ **Enhanced Visuals**: More particle variety and shader effects

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
