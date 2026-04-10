# GridMap Dungeon Setup

## Current Configuration

The game now uses the **GridMap** node for the dungeon instead of a separate ground plane.

### What Changed
- ✅ Removed StaticBody3D ground plane
- ✅ Enemy uses GridMap collision
- ✅ Player uses GridMap collision
- ✅ All physics handled by GridMap mesh library

### GridMap Node
Located at: `world → MeshInstance3D → GridMap`
- Uses mesh library: `res://liberary/tileset.meshlib`
- Cell size: 1x1x1
- Contains dungeon layout data

## How It Works

### Collision
The GridMap's mesh library (`tileset.meshlib`) contains:
- 3D mesh geometry for walls, floors, ceilings
- Collision shapes for each tile
- Automatically handles physics

### Enemy Patrol
- Enemy walks on GridMap floors
- Collides with GridMap walls
- Uses `is_on_floor()` to detect GridMap surface
- Uses `is_on_wall()` to detect GridMap walls

### Player Movement
- Player walks on GridMap floors
- Collides with GridMap walls
- Gravity pulls player to GridMap surface

## Ensuring Proper Collision

### Check GridMap Collision
1. Open `liberary/tileset.meshlib` in Godot
2. Verify each tile has collision shapes
3. Collision layer should be 1 (default)

### Check Enemy Position
- Enemy Y position should be slightly above GridMap floor
- Current: Y = 1.5
- Adjust if enemy falls through or floats

### Check Player Position
- Player spawns at: (-3.81, 1.58, 0)
- Should be on GridMap surface

## Troubleshooting

### Enemy Falls Through Floor
**Solution:**
1. Check GridMap tiles have collision
2. Increase enemy Y position
3. Verify `collision_mask = 1` on enemy

### Enemy Floats Above Floor
**Solution:**
1. Decrease enemy Y position
2. Check gravity value (should be 9.8)
3. Ensure `is_on_floor()` returns true

### Enemy Stuck in Walls
**Solution:**
1. Check enemy spawn position
2. Ensure not spawning inside GridMap wall
3. Verify collision shapes in mesh library

### Player Falls Through
**Solution:**
1. Check player collision_mask includes layer 1
2. Verify GridMap collision_layer is 1
3. Check player Y position

## GridMap Advantages

✅ **Integrated collision** - No separate collision objects needed
✅ **Efficient** - Single node handles entire dungeon
✅ **Easy editing** - Paint tiles to modify dungeon
✅ **Automatic physics** - Collision built into mesh library
✅ **Performance** - Optimized for tile-based levels

## Patrol Points on GridMap

When adding patrol points:
1. Place Marker3D nodes in world
2. Position them on GridMap floor (Y ≈ 1.0)
3. Avoid placing inside walls
4. Test patrol route in-game

Example positions for GridMap patrol:
```gdscript
patrol_points = [
    Vector3(0, 1, 0),      # Center
    Vector3(5, 1, 5),      # NE room
    Vector3(-5, 1, 5),     # NW room
    Vector3(-5, 1, -5),    # SW room
    Vector3(5, 1, -5),     # SE room
]
```

## Testing

1. Run game
2. Enemy should walk on GridMap floor
3. Enemy should collide with GridMap walls
4. Player should walk on GridMap floor
5. Check console for "is_on_floor" status
