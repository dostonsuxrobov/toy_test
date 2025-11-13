# TinyGlade-Style Wall System Implementation

## Overview

This document describes the improved wall placement system inspired by Tiny Glade's building mechanics. The system provides intelligent wall snapping, visual feedback, and constraint-based placement for creating connected wall structures.

## Key Features

### 1. Automatic Endpoint Snapping (TinyGlade-Style)

Walls automatically snap to nearby wall endpoints, making it easy to create connected structures.

**How it works:**
- When placing a wall endpoint, the system searches for nearby existing endpoints within a configurable radius (default: 1.5 units)
- If an endpoint is found within the snap radius, the new wall snaps to it
- A green glowing sphere indicator shows when snapping will occur

**Controls:**
- **Hold CTRL** to temporarily disable snapping (like in TinyGlade)

**Configuration:**
- `wall_snap_enabled` (bool): Toggle automatic snapping on/off
- `snap_radius` (float): Distance within which snapping occurs (default: 1.5)

### 2. Visual Snap Feedback

A green glowing sphere appears at snap points to show where walls will connect.

**Features:**
- Automatically appears when hovering near a snap point
- Emission-enabled material for high visibility
- Only visible during wall placement mode

### 3. Angle Constraints (45°/90° Snapping)

Requested by TinyGlade community - allows creating straight walls at standard angles.

**How it works:**
- Walls can be constrained to 45-degree increments (0°, 45°, 90°, 135°, 180°, etc.)
- Helps create clean, architectural layouts

**Controls:**
- **Hold SHIFT** while placing second wall point to enable angle snapping

### 4. Minimum Wall Length

Prevents accidentally creating tiny walls that are hard to see or work with.

**Configuration:**
- `min_wall_length` (float): Minimum allowed wall length (default: 0.5)
- Walls shorter than this cannot be placed
- Preview becomes invisible if below minimum

### 5. Endpoint and Segment Tracking

The system maintains a graph of all wall connections for intelligent snapping.

**Data Structures:**
- `wall_endpoints`: Array of all wall endpoint positions
- `wall_segments`: Array of dictionaries containing {start, end, wall} for each wall
- Automatically cleaned up when walls are deleted

## Usage Instructions

### Basic Wall Placement

1. Select Wall Mode from the UI
2. Click to place the first endpoint
3. Move mouse to desired second endpoint
4. Click to create the wall
5. Continue clicking to chain walls together

### Advanced Controls

| Control | Function |
|---------|----------|
| **Left Click** | Place wall endpoint |
| **Hold CTRL** | Disable automatic snapping |
| **Hold SHIFT** | Enable 45°/90° angle constraints |
| **ESC / Clear Button** | Cancel current wall chain |
| **Delete Mode** | Remove placed walls |

### Visual Indicators

- **Blue semi-transparent preview**: Shows where the wall will be placed
- **Green glowing sphere**: Indicates active snap point
- **Small preview post**: Shows starting point position

## Technical Implementation

### Core Functions

#### `find_snap_point(pos: Vector3) -> Vector3`
Searches for the nearest endpoint within snap_radius and returns it, or returns the original position if none found.

#### `apply_angle_constraint(start: Vector3, end: Vector3) -> Vector3`
When SHIFT is held, constrains the wall angle to 45-degree increments.

#### `update_snap_indicator(pos: Vector3)`
Updates the visual snap indicator sphere position and visibility.

#### `cleanup_orphaned_endpoints(endpoint: Vector3)`
Removes endpoints from the tracking system when their connected walls are deleted.

### Configuration Variables

```gdscript
@export var wall_snap_enabled: bool = true
@export var snap_radius: float = 1.5
@export var min_wall_length: float = 0.5
```

## Comparison to TinyGlade

### Implemented Features
- ✅ Automatic endpoint snapping
- ✅ Visual snap feedback
- ✅ CTRL to disable snapping
- ✅ Angle constraints (SHIFT for 45°/90°)
- ✅ Endpoint tracking system
- ✅ Clean wall chaining

### Future Enhancements
- 🔄 Terrain elevation support (currently flat y=0)
- 🔄 Procedural wall decoration (windows, crenellations)
- 🔄 Wall thickness variation
- 🔄 Curved wall segments
- 🔄 Mid-segment snapping
- 🔄 Auto-fill enclosed areas with roofs

## Known Limitations

1. **Flat Terrain Only**: All walls are placed on y=0 plane
2. **No Wall Merging**: Overlapping walls are allowed (no collision detection)
3. **Basic Geometry**: Walls are simple boxes without procedural detail
4. **No Adaptive Decoration**: Unlike TinyGlade's procedural system

## Examples

### Creating a Simple Square Castle
1. Enable Wall Mode
2. Place first corner (click)
3. Move 90° and place second corner (or hold SHIFT for perfect 90°)
4. Continue around the square
5. For the last wall, it will automatically snap to the starting point

### Building Connected Rooms
1. Create first room using 4 walls
2. Start new wall chain from any existing endpoint
3. The green snap indicator shows connection points
4. Build second room connected to first

### Organic Freehand Walls
1. Hold CTRL to disable snapping
2. Click rapidly to create curved, organic wall patterns
3. Release CTRL to re-enable snapping when needed

## Troubleshooting

**Walls not snapping:**
- Check that `wall_snap_enabled` is true in BuildingManager
- Ensure snap_radius is large enough (try increasing to 2.0)
- Make sure CTRL key is not being held

**Can't place short walls:**
- This is intentional - check `min_wall_length` setting
- Walls must be at least 0.5 units long by default

**Snap indicator not appearing:**
- Ensure you have at least one wall endpoint placed
- Check that you're within snap_radius of an existing endpoint

## API Reference

### Exported Variables
```gdscript
wall_snap_enabled: bool      # Toggle snapping feature
snap_radius: float           # Snap detection radius
min_wall_length: float       # Minimum wall length
```

### Arrays
```gdscript
wall_endpoints: Array[Vector3]      # All wall endpoints
wall_segments: Array[Dictionary]    # All wall segments
```

### Key Methods
```gdscript
find_snap_point(pos: Vector3) -> Vector3
apply_angle_constraint(start: Vector3, end: Vector3) -> Vector3
update_snap_indicator(pos: Vector3)
cleanup_orphaned_endpoints(endpoint: Vector3)
```

## Credits

Inspired by **Tiny Glade** by Pounce Light (Anastasia Opara & Tomasz Stachowiak)
- Custom Rust engine with Bevy ECS
- Procedural generation using Wave Function Collapse
- Organic, freehand building philosophy

## Version History

**v1.0** - Initial TinyGlade-style implementation
- Endpoint snapping system
- Visual snap feedback
- Angle constraints
- Minimum wall length
- Endpoint tracking and cleanup
