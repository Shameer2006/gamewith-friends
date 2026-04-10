# Enemy AI Behavior

## States

### 1. WANDER (Default)
- Enemy walks randomly around spawn point
- Wander radius: 6 units
- Speed: 1.5 units/sec
- Pauses briefly between movements

### 2. CHASE (Player Detected)
- Triggered when player enters 8-unit vision radius
- Enemy moves directly toward player
- Speed: 3.0 units/sec
- Continuously tracks player position and direction
- Stores last known player position and direction

### 3. ATTACK (Close Range)
- Triggered when player is within 2 units
- Enemy stops moving
- Faces player
- Deals 20 damage every 1.5 seconds
- Still tracks player position

### 4. SEARCH (Player Lost) ⭐ NEW
- Triggered when player leaves vision radius
- Enemy continues moving in the **last known direction** of the player
- Searches for 5 units in that direction
- Speed: 1.5 units/sec (same as wander)
- After reaching search point, returns to WANDER

## Wall Collision Handling

When enemy hits a wall:
- Detects wall normal
- Rotates 90° away from wall
- Updates target to avoid getting stuck
- Works in both WANDER and SEARCH states

## Smart Tracking

The enemy remembers:
- **Last known player position**: Where player was last seen
- **Last player direction**: Direction player was moving
- Uses this info to search intelligently instead of random wandering

## Example Scenario

1. Player approaches enemy → **CHASE** (enemy follows)
2. Player runs behind wall → **SEARCH** (enemy continues in that direction)
3. Enemy reaches search point → **WANDER** (returns to patrol)
4. Player appears again → **CHASE** (cycle repeats)

## Benefits

✅ No more random wandering when player escapes
✅ Enemy searches in logical direction
✅ No more sticking to walls
✅ More realistic pursuit behavior
✅ Creates tension - player must truly escape, not just hide

## Configuration

Adjust in enemy scene:
- `search_distance`: 5.0 (how far to search)
- `move_speed`: 3.0 (chase speed)
- `wander_speed`: 1.5 (wander/search speed)
- Vision radius: 8.0 units
- Attack range: 2.0 units
