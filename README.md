# Tiny Glade Clone

A technical clone of the cozy castle-building game **Tiny Glade**, built with Godot 4.5.

## Features

- **Gridless Building System**: Place walls, towers, and gates anywhere on the terrain
- **Intuitive Camera Controls**: Orbit, pan, and zoom to view your creation from any angle
- **Wall Chaining**: Click to place wall points and create connected wall segments
- **Multiple Building Types**:
  - Walls: Create connected wall segments
  - Towers: Cylindrical towers with decorative roofs and flags
  - Gates: Archways with pillars
- **Procedural Details**: Buildings include windows, flags, and decorative elements
- **Save/Load System**: Save your creations and load them later
- **Path Painting**: Hold Shift and click to paint paths on the ground

## Controls

### Camera
- **Right Mouse Button + Drag**: Rotate camera around the scene
- **Middle Mouse Button + Drag**: Pan camera
- **Mouse Wheel**: Zoom in/out

### Building
- **Left Click**: Place building piece at cursor location
- **1 Key**: Switch to Wall mode
- **2 Key**: Switch to Tower mode
- **3 Key**: Switch to Gate mode
- **X Key**: Switch to Delete mode
- **ESC Key**: Clear current wall chain
- **Shift + Left Click**: Paint path on ground

### UI Buttons
- **Wall/Tower/Gate/Delete Buttons**: Switch between building modes
- **Clear Chain**: End the current wall chain
- **Save**: Save your creation to disk
- **Load**: Load a previously saved creation

## Building Guide

### Walls
1. Click the "Wall" button or press `1`
2. Click on the terrain to place the first wall point
3. Click again to create a wall segment to the new point
4. Continue clicking to chain wall segments together
5. Press `ESC` or click "Clear Chain" to start a new wall chain

### Towers
1. Click the "Tower" button or press `2`
2. Click anywhere on the terrain to place a tower
3. Towers include decorative roofs and flags

### Gates
1. Click the "Gate" button or press `3`
2. Click on the terrain to place a gate archway
3. Gates consist of two pillars and a top arch

### Deleting
1. Click the "Delete" button or press `X`
2. Click on any building piece to remove it

### Paths
1. Hold `Shift` and click to paint brown path tiles on the ground
2. Create pathways between your buildings

## Technical Details

### Project Structure
```
toy_test/
├── project.godot          # Godot project configuration
├── scenes/
│   └── main.tscn         # Main game scene
├── scripts/
│   ├── main.gd           # Main scene controller
│   ├── camera_controller.gd      # Camera movement and controls
│   ├── building_manager.gd       # Building placement logic
│   ├── building_piece.gd         # Building piece base class
│   ├── building_decorator.gd     # Procedural decoration system
│   ├── path_painter.gd           # Path painting system
│   ├── ui_manager.gd             # UI and button handling
│   └── game_manager.gd           # Game state and save/load
└── assets/
    ├── models/           # 3D models (procedurally generated)
    ├── textures/         # Textures
    └── materials/        # Materials
```

### System Requirements
- Godot Engine 4.3+ (compatible with 4.5)
- OpenGL 3.3 compatible graphics card

## How to Run

1. Install [Godot Engine 4.3+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this project folder and select `project.godot`
4. Click "Import & Edit"
5. Press `F5` or click the "Play" button to run the game

## Save Files

Save files are stored in the user data directory:
- **Linux**: `~/.local/share/godot/app_userdata/Tiny Glade Clone/`
- **Windows**: `%APPDATA%\Godot\app_userdata\Tiny Glade Clone\`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/Tiny Glade Clone/`

## Future Enhancements

Potential features to add:
- Terrain sculpting and elevation changes
- More building types (houses, bridges, stairs)
- Dynamic ivy and vegetation growth
- Ambient animals (sheep, birds)
- Weather effects and time of day
- Procedural texture variations
- Undo/Redo system
- Multiple save slots
- Screenshot/export functionality

## Credits

Inspired by [Tiny Glade](https://store.steampowered.com/app/2198150/Tiny_Glade/) by Pounce Light.

Built with [Godot Engine](https://godotengine.org/).

## License

This project is a technical demonstration and educational clone. All rights to the original Tiny Glade game belong to Pounce Light.
