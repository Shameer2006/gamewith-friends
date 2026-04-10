# Navigation System Setup Guide

## Why NavigationAgent3D?

### Problems It Solves:
✅ **No more wall sticking** - Pathfinding avoids walls automatically
✅ **Smooth movement** - Uses `basis.slerp()` for rotation
✅ **Professional AI** - Industry-standard navigation
✅ **No manual collision detection** - NavigationServer handles it
✅ **Obstacle avoidance** - Built-in avoidance system

## Setup Steps (REQUIRED)

### Step 1: Bake Navigation Mesh

1. **Open your world scene** in Godot
2. **Select the NavigationRegion3D** node (already added to world.tscn)
3. **In the Inspector**, look for "NavigationMesh" property
4. **Click "New NavigationMesh"**
5. **At the top of the 3D viewport**, click **"Bake NavigationMesh"** button
6. **Wait for baking** - Godot will analyze your GridMap and create walkable areas
7. **You should see blue overlay** showing where the enemy can walk

### Step 2: Verify NavigationAgent3D

The enemy already has NavigationAgent3D configured with:
- `path_desired_distance`: 0.5
- `target_desired_distance`: 0.5
- `avoidance_enabled`: true
- `radius`: 0.5 (matches enemy capsule)
- `height`: 2.0 (matches enemy capsule)
- `max_speed`: 3.5

### Step 3: Check Safe Margin

Enemy CharacterBody3D has:
- `safe_margin`: 0.001 (prevents getting stuck in walls)

## How It Works

### Navigation Flow:
1. **Enemy sets target** → `nav_agent.target_position = target`
2. **NavigationServer calculates path** → Finds route around walls
3. **Enemy follows path** → `nav_agent.get_next_path_position()`
4. **Smooth rotation** → `basis.slerp()` prevents snapping
5. **Automatic avoidance** → Stays away from walls

### Key Functions:

```gdscript
# Set where enemy wants to go
nav_agent.target_position = player.global_position

# Get next step in path
var next_pos = nav_agent.get_next_path_position()

# Check if reached destination
if nav_agent.is_navigation_finished():
    # Arrived!
```

## Baking Tips

### For GridMap Dungeons:

1. **Select NavigationRegion3D**
2. **Inspector → NavigationMesh → Parameters:**
   - Cell Size: 0.25 (smaller = more precise)
   - Cell Height: 0.2
   - Agent Height: 2.0 (matches enemy)
   - Agent Radius: 0.5 (matches enemy)
   - Agent Max Climb: 0.5 (can step up small obstacles)
   - Agent Max Slope: 45.0 (degrees)

3. **Click "Bake NavigationMesh"**

### Troubleshooting Baking:

**No blue overlay appears:**
- Ensure GridMap has collision shapes
- Check NavigationRegion3D is parent of GridMap
- Try increasing Cell Size to 0.5

**Enemy still walks through walls:**
- Re-bake navigation mesh
- Check Agent Radius matches enemy collision
- Verify safe_margin is 0.001

**Enemy can't reach certain areas:**
- Decrease Cell Size for more precision
- Check Agent Max Climb if there are steps
- Verify those areas have collision

## Testing Navigation

### Console Messages:
- "Enemy initialized with X patrol points"
- "Enemy moving to patrol point X"
- "Enemy spotted player during patrol!"
- "Enemy lost player, searching in direction: (x, y, z)"

### Visual Debugging:
1. **Enable navigation debug** in Godot:
   - Debug → Visible Collision Shapes
   - Shows navigation mesh in blue
   - Shows agent paths in green

2. **Watch enemy movement**:
   - Should smoothly navigate around corners
   - Should never push against walls
   - Should rotate smoothly (no snapping)

## Benefits of This System

### Before (Manual):
- ❌ Enemy hits wall → gets stuck
- ❌ Manual `is_on_wall()` detection
- ❌ Instant rotation → collision issues
- ❌ Complex wall avoidance code

### After (NavigationAgent3D):
- ✅ Enemy avoids walls automatically
- ✅ NavigationServer handles pathfinding
- ✅ Smooth rotation with `slerp()`
- ✅ Clean, simple code

## Advanced Configuration

### NavigationAgent3D Properties:

```gdscript
# Distance thresholds
path_desired_distance = 0.5      # How close to path points
target_desired_distance = 0.5    # How close to final target

# Avoidance
avoidance_enabled = true         # Enable obstacle avoidance
radius = 0.5                     # Agent size for avoidance
height = 2.0                     # Agent height

# Performance
path_max_distance = 3.0          # Max distance for path updates
```

### CharacterBody3D Properties:

```gdscript
safe_margin = 0.001              # Collision margin (IMPORTANT!)
```

## Common Issues

### Issue: Enemy still sticks to walls
**Solution:**
1. Re-bake NavigationMesh
2. Set `safe_margin = 0.001`
3. Increase `agent_radius` in NavigationMesh settings

### Issue: Enemy takes weird paths
**Solution:**
1. Decrease Cell Size (more precision)
2. Re-bake NavigationMesh
3. Check for gaps in GridMap collision

### Issue: Enemy can't find player
**Solution:**
1. Ensure player is on navigable surface
2. Check vision radius (8 units)
3. Verify NavigationMesh covers player area

### Issue: Enemy moves through walls
**Solution:**
1. **BAKE THE NAVIGATION MESH!** (most common issue)
2. Verify GridMap has collision
3. Check NavigationRegion3D encompasses GridMap

## Final Checklist

Before testing:
- [ ] NavigationRegion3D added to world
- [ ] NavigationMesh baked (blue overlay visible)
- [ ] Enemy has NavigationAgent3D child
- [ ] Enemy safe_margin = 0.001
- [ ] GridMap has collision shapes
- [ ] Player is in "player" group

## Performance Notes

- Navigation baking is done once in editor
- Runtime pathfinding is very efficient
- NavigationServer runs on separate thread
- Suitable for multiple enemies (though you have one)

## Next Steps

1. **Bake the navigation mesh** (most important!)
2. **Test enemy patrol** - should navigate smoothly
3. **Test chase** - should path around obstacles
4. **Test search** - should continue in player direction
5. **Adjust parameters** if needed
