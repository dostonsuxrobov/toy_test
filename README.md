
A cozy building game inspired by Tiny Glade, built with Godot 4.5 using simple primitive shapes.

## Features

- **3D Building Placement**: Place three types of structures in a 3D environment
- **Interactive Camera**: Rotate, pan, and zoom around your creations
- **Object Editing**: Select and modify placed objects (scale, rotate, delete)
- **Simple UI**: Easy-to-use button interface for selecting building types

## Building Types

1. **🏰 Large Building**: Brown/beige box structure (4x6x4 units)
2. **🛣️ Road**: Gray flat path (6x0.2x2 units)
3. **💧 Lake**: Blue semi-transparent water (8x0.5x8 units)

## Controls

### Camera Controls
- **Middle Mouse Button**: Rotate camera around the scene
- **Shift + Middle Mouse Button**: Pan camera
- **Scroll Wheel**: Zoom in/out

### Building Controls
- **Left Click**: Place selected building type OR select existing object
- **Building Buttons**: Click bottom panel buttons to select building type

### Editing Controls (when object is selected)
- **+/= Key**: Scale object up
- **- Key**: Scale object down
- **Q Key**: Rotate object left (counterclockwise)
- **E Key**: Rotate object right (clockwise)
- **Delete/Backspace Key**: Remove selected object

## How to Play

1. Open the project in Godot 4.5
2. Press F5 or click the "Play" button to run the game
3. Select a building type from the bottom panel
4. Move your mouse around to preview placement
5. Left-click to place the building
6. Click "Select" button (✋) to enter selection mode
7. Left-click on placed objects to select and edit them

## Project Structure

```
toy_test/
├── project.godot          # Project configuration
├── icon.svg               # Project icon
├── scenes/
│   └── main.tscn         # Main game scene
├── scripts/
│   ├── main.gd           # Main game logic
│   ├── ui.gd             # UI controller
│   └── editable_object.gd # Object editing logic
└── README.md             # This file
```

## Technical Details

- **Engine**: Godot 4.5
- **Rendering**: Forward+ renderer with MSAA 3D x2
- **Resolution**: 1920x1080 (fullscreen mode 2)
- **3D Primitives Used**:
  - BoxMesh for all structures
  - StaticBody3D for collision detection
  - StandardMaterial3D for coloring and transparency

## Future Enhancements

Possible additions to make the game more like Tiny Glade:
- More building types (towers, walls, bridges)
- Terrain modification (hills, valleys)
- Vegetation (trees, grass, flowers)
- Path/road snapping and curve tools
- Water flow and dynamic effects
- Lighting and time-of-day system
- Save/load functionality
- Screenshot mode

## License

This project is provided as-is for educational and entertainment purposes.
>>>>>>> origin/claude/godot-tiny-glade-game-011CUqh1VLdG45yK2Yu2pAtV
