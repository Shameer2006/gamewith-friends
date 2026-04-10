# Single Enemy Patrol System

## Overview
One enemy monitors the entire dungeon by following a patrol route with multiple waypoints.

## How It Works

### Patrol Behavior
1. **Enemy follows patrol points** in sequence
2. **Waits 2 seconds** at each patrol point (looking around)
3. **Moves to next point** and repeats
4. **Loops continuously** through all patrol points

### Default Patrol Route
If no custom patrol points are defined, enemy creates a square pattern:
- 9 patrol points in a large square
- Covers approximately 20x20 unit area
- Centered on enemy's spawn position

### States

**PATROL** (Default)
- Follows patrol route at 2.0 speed
- Waits at each point
- Monitors surroundings

**CHASE** (Player Detected)
- Abandons patrol
- Chases player at 3.5 speed
- Tracks player position

**ATTACK** (Close Range)
- Stops moving
- Attacks player (20 damage/1.5s)
- Continues tracking

**SEARCH** (Player Lost)
- Moves 8 units in last known player direction
- Searches area
- Returns to nearest patrol point after search

## Custom Patrol Points

### Method 1: Add Marker3D Children (In Godot Editor)
1. Select the Enemy node in scene tree
2. Right-click → Add Child Node → Marker3D
3. Name it "PatrolPoint1", "PatrolPoint2", etc.
4. Position each marker where you want patrol stops
5. Enemy will automatically detect and use them

### Method 2: Edit Default Route (In Code)
Edit `_setup_patrol_points()` in `enemy.gd`:

```gdscript
patrol_points = [
    Vector3(0, 0, 0),      # Point 1
    Vector3(10, 0, 5),     # Point 2
    Vector3(5, 0, 15),     # Point 3
    Vector3(-5, 0, 10),    # Point 4
    # Add more points...
]
```

## Dungeon Coverage Strategy

### For Small Dungeon (< 30x30)
- 4-6 patrol points
- Square or circular pattern
- Covers main areas

### For Medium Dungeon (30x50)
- 8-12 patrol points
- Figure-8 or zigzag pattern
- Covers corridors and rooms

### For Large Dungeon (> 50x50)
- 12-20 patrol points
- Complex route through all areas
- Strategic placement at intersections

## Example Patrol Routes

### Corridor Patrol
```
Start → Corridor End → Room 1 → Room 2 → Corridor Middle → Start
```

### Room-to-Room Patrol
```
Room A → Hallway → Room B → Hallway → Room C → Room D → Back to A
```

### Perimeter Patrol
```
NW Corner → NE Corner → SE Corner → SW Corner → Center → Repeat
```

## Configuration

Adjust in enemy scene or script:
- `patrol_speed`: 2.0 (normal patrol speed)
- `move_speed`: 3.5 (chase speed)
- `patrol_wait_time`: 2.0 (seconds at each point)
- `search_distance`: 8.0 (how far to search)
- Vision radius: 8.0 units

## Tips

1. **Place patrol points at intersections** - maximizes coverage
2. **Include hiding spots** - enemy should check them
3. **Vary wait times** - makes patrol less predictable
4. **Test the route** - ensure enemy doesn't get stuck
5. **Cover key areas** - doors, corridors, treasure rooms

## Behavior Notes

- Enemy **returns to nearest patrol point** after losing player
- Enemy **skips to next point** if stuck on wall
- Enemy **searches intelligently** in player's last direction
- Enemy **never stops patrolling** unless chasing/searching

## Console Messages

Watch for:
- "Enemy initialized with X patrol points"
- "Enemy reached patrol point X, waiting..."
- "Enemy moving to patrol point X"
- "Enemy spotted player during patrol!"
- "Enemy lost player, searching..."
- "Enemy finished searching, returning to patrol"
- "Enemy returning to patrol at point X"
