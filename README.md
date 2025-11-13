# Dorfromantik Clone

A mechanically perfect recreation of Dorfromantik built in Godot 4.5.

## About

This is a faithful recreation of the peaceful puzzle game Dorfromantik, featuring hexagonal tile placement, scoring mechanics, quest system, and beautiful 3D visuals.

## Features

### Core Mechanics
- **Hexagonal Grid System**: Using axial coordinates for accurate hex tile placement
- **Tile Placement**: Place tiles adjacent to existing tiles with proper validation
- **Terrain Matching**: Tiles must match adjacent terrains (fields, forests, villages, water, railways)
- **Tile Rotation**: Rotate tiles before placement (Q/E keys or on-screen controls)
- **50 Tiles per Game**: Standard game length with turn tracking

### Scoring System
- **Area-Based Scoring**: Points awarded based on connected area sizes
- **Perfect Placement Bonus**: +50 points when all 6 sides of a tile match neighbors
- **Quest Completion**: Bonus points for completing quests (e.g., "Create an area of 10 forest tiles")
- **Progressive Scoring**: Larger areas grant more points per tile

### Visual Features
- **3D Hexagonal Tiles**: Procedurally generated with colored segments for each terrain type
- **Five Terrain Types**:
  - Fields (Yellow) - Farmland and crops
  - Forests (Green) - Trees
  - Villages (Red) - Houses and buildings
  - Water (Blue) - Rivers and lakes
  - Railways (Gray) - Train tracks
- **Quest Markers**: Visual flags indicate tiles with quests
- **Placement Preview**: Semi-transparent preview showing valid/invalid placements
- **Beautiful Environment**: Sky, lighting, and atmosphere

### Camera Controls
- **Pan**: Middle mouse button drag or WASD/Arrow keys
- **Zoom**: Mouse wheel
- **Rotate**: Right mouse button drag

### Quest System
- Random quest tiles appear during gameplay (~15% chance)
- Quests require completing connected areas of specific terrain types
- Quest markers clearly show required terrain and target size
- Bonus points awarded upon quest completion

## Controls

| Action | Input |
|--------|-------|
| Place Tile | Left Mouse Click |
| Rotate Tile Left | Q |
| Rotate Tile Right | E |
| Pan Camera | Middle Mouse Drag / WASD / Arrow Keys |
| Zoom Camera | Mouse Wheel |
| Rotate Camera | Right Mouse Drag |

## How to Play

1. **Start the Game**: Launch the project in Godot 4.5 or export and run
2. **View Current Tile**: The next tile to place is shown as a preview
3. **Position the Tile**: Move your mouse over the grid to preview placement
4. **Rotate if Needed**: Use Q/E to rotate the tile before placing
5. **Place the Tile**: Click to place when the preview shows valid (white tint)
6. **Score Points**: Match terrain types to create large connected areas
7. **Complete Quests**: Fulfill quest requirements for bonus points
8. **Play Until End**: Continue until all 50 tiles are placed

## Technical Implementation

### Architecture
- **Autoload Singletons**: GameManager and ScoringSystem for global state
- **Hexagonal Coordinate System**: Axial coordinates with cube coordinate support
- **Tile Data Structure**: Each tile has 6 sides + center terrain
- **Procedural Mesh Generation**: Dynamic 3D tile meshes with vertex colors
- **Signal-Based Communication**: Event-driven architecture for loose coupling

### Key Systems

#### HexGrid (scripts/hex_grid/)
- `hex_coord.gd`: Hexagonal coordinate math and conversions
- `hex_grid.gd`: Grid management, tile storage, and validation

#### Tiles (scripts/tiles/)
- `terrain_type.gd`: Terrain type enum and color definitions
- `tile_data.gd`: Tile data structure with rotation support
- `tile_generator.gd`: Procedural tile generation with multiple patterns
- `hex_tile_3d.gd`: 3D visual representation of tiles

#### Autoload (scripts/autoload/)
- `game_manager.gd`: Game flow, turn management, tile generation
- `scoring_system.gd`: Score calculation, quest tracking

#### Camera (scripts/camera/)
- `camera_controller.gd`: Full camera control system

#### Scenes
- `main.tscn`: Main game scene with grid, camera, and UI
- `ui.tscn`: HUD displaying score, tiles remaining, and controls

### Algorithms

#### Tile Generation
- Multiple pattern types: single terrain, two-terrain split, three-terrain, complex
- Weighted random generation for natural distribution
- Quest tile generation ensures quest terrain is present

#### Area Calculation
- Depth-first search to calculate connected area sizes
- Used for scoring and quest completion checking
- Efficient visited tracking prevents duplicate counting

#### Placement Validation
- Checks all adjacent tiles for terrain matching
- First tile can be placed anywhere
- Subsequent tiles must have at least one neighbor and all sides must match

## Project Structure

```
dorfromantik-clone/
├── project.godot
├── icon.svg
├── README.md
├── scenes/
│   ├── main.tscn
│   └── ui.tscn
└── scripts/
    ├── game_scene.gd
    ├── autoload/
    │   ├── game_manager.gd
    │   └── scoring_system.gd
    ├── camera/
    │   └── camera_controller.gd
    ├── hex_grid/
    │   ├── hex_coord.gd
    │   └── hex_grid.gd
    └── tiles/
        ├── terrain_type.gd
        ├── tile_data.gd
        ├── tile_generator.gd
        └── hex_tile_3d.gd
```

## Requirements

- Godot Engine 4.3 or higher (tested with 4.5)
- OpenGL 3.3 / Vulkan compatible graphics

## Future Enhancements

Possible additions for even more accuracy:
- Biome-specific tiles (mountains, plains, etc.)
- Animated water and environment effects
- Sound effects and music
- Save/load game state
- High score tracking
- Procedural decoration objects (trees, houses, etc.)
- Multiple game modes (endless, challenge, etc.)

## License

Created as an educational recreation of Dorfromantik mechanics. Original game by Toukana Interactive.

## Credits

Built with Godot Engine 4.5 using GDScript.
