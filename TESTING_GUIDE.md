# Enemy AI Testing Guide

## What I Fixed

### Simplified AI
- Removed complex raycasting and vision cone calculations
- Using simple Area3D detection (8 unit radius)
- Basic state machine: WANDER → CHASE → ATTACK
- Removed stuck detection (was causing issues)

### Better Physics
- Proper gravity (9.8)
- Small downward force when grounded (-0.1)
- Smooth rotation with lerp
- Simple movement without complex pathfinding

### Ground Collision
- Added StaticBody3D ground plane (100x100)
- Ensures enemies don't fall through floor
- BoxShape3D collision

## How to Test

### 1. Check Enemy Spawning
- Run the game
- You should see 3 RED capsule enemies
- They should be standing on the ground, not glitching

### 2. Test Wandering
- Watch enemies from a distance
- They should walk around slowly in random directions
- Should pause briefly between movements

### 3. Test Detection
- Walk within 8 units of an enemy
- Enemy should turn RED and start chasing you
- Console should print "Enemy spotted player!"

### 4. Test Chase
- Enemy should follow you smoothly
- Should rotate to face you
- Moves at 3.0 speed (faster than wander)

### 5. Test Attack
- Let enemy get close (within 2 units)
- Should stop moving and attack
- Health bar should decrease
- Console prints "Enemy attacked!"

### 6. Test Escape
- Run away from enemy (more than 8 units)
- Enemy should stop chasing
- Should return to wandering
- Console prints "Enemy lost player"

## Troubleshooting

### Enemy Not Detecting Player
**Check:**
1. Player has `collision_layer = 3` (includes layer 2)
2. Player is in "player" group
3. Enemy VisionArea has `collision_mask = 2`
4. Get within 8 units of enemy

### Enemy Glitching/Falling
**Check:**
1. Ground StaticBody3D exists in world scene
2. Enemy Y position is above 0 (try Y=1.5 or Y=2)
3. Gravity is set to 9.8

### Enemy Not Moving
**Check:**
1. Enemy is on ground (is_on_floor() returns true)
2. Wander target is being set
3. Check console for errors

## Debug Console Messages

You should see:
- "Enemy spotted player!" - when entering vision
- "Enemy lost player" - when leaving vision  
- "Enemy in attack range!" - when close enough
- "Enemy attacked! Damage: 20" - when attacking

## Quick Fixes

### If enemies still glitch:
1. Select each enemy in the scene
2. Set Transform Y to 2.0
3. Save scene

### If enemies don't detect:
1. Select player in scene tree
2. Check Inspector → Node → Groups
3. Add "player" group if missing
4. Check collision_layer = 3

### If nothing works:
1. Delete all enemies from world scene
2. Re-add Enemy scene instances
3. Position at Y=2, spread out on X/Z
