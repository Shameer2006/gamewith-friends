# Quick Start - Baking Navigation

## The NavigationMesh is now created! Follow these steps:

### Step 1: Open Scene in Godot
1. Open `scenes/world.tscn` in Godot Editor

### Step 2: Select NavigationRegion3D
1. In the Scene tree (left panel), find and click on **NavigationRegion3D**
2. It should be a child of the "world" node

### Step 3: Bake the Navigation Mesh
1. Look at the **top of the 3D viewport** (center panel)
2. You should see a button that says **"Bake NavigationMesh"**
3. **Click it!**
4. Wait a few seconds while Godot processes your GridMap
5. You should see a **blue overlay** appear on your dungeon floor

### Step 4: Save and Test
1. Press **Ctrl+S** (or Cmd+S on Mac) to save
2. Press **F5** to run the game
3. Enemy should now move smoothly without sticking to walls!

## What the Blue Overlay Means

The blue overlay shows:
- ✅ **Where the enemy CAN walk** (blue areas)
- ❌ **Where the enemy CANNOT walk** (no blue = walls/obstacles)

## If You Don't See "Bake NavigationMesh" Button

Try this:
1. Select **NavigationRegion3D** in scene tree
2. Look at **Inspector** panel (right side)
3. Find **NavigationMesh** property
4. It should say "NavigationMesh_nav"
5. If it says "empty", click the dropdown and select "NavigationMesh_nav"
6. The bake button should appear at top of 3D viewport

## If Enemy Still Doesn't Move

Check console for errors:
1. Run game (F5)
2. Look at **Output** panel at bottom
3. Should see: "Enemy initialized with X patrol points"
4. If you see navigation errors, the mesh needs to be baked

## Alternative: Manual Bake

If button doesn't appear:
1. Select **NavigationRegion3D**
2. **Inspector** → **NavigationMesh** → Click dropdown
3. Select **"Edit"**
4. A panel appears at bottom
5. Click **"Bake NavMesh"** in that panel

## Verification Checklist

After baking, verify:
- [ ] Blue overlay visible on dungeon floor
- [ ] Blue overlay does NOT cover walls
- [ ] Enemy spawns on blue area
- [ ] Patrol points are on blue areas
- [ ] Console shows "Enemy initialized..."
- [ ] Enemy moves when game runs

## Expected Behavior

Once baked correctly:
1. **Enemy patrols** - Walks between patrol points smoothly
2. **Enemy chases** - Follows player around obstacles
3. **Enemy searches** - Continues in player's direction
4. **No wall sticking** - Navigates around walls automatically
5. **Smooth rotation** - Turns naturally, no snapping

## Troubleshooting

### "Navigation mesh should be set or created"
**Solution:** The NavigationMesh is now set! Just need to bake it.

### Enemy doesn't move at all
**Solution:** 
1. Bake the navigation mesh (blue overlay must appear)
2. Check enemy Y position (should be 1.5, on the floor)
3. Check console for errors

### Blue overlay doesn't appear
**Solution:**
1. Ensure GridMap has collision shapes in mesh library
2. Try increasing Cell Size to 0.5 in NavigationMesh settings
3. Re-bake

### Enemy moves but still sticks to walls
**Solution:**
1. Re-bake navigation mesh
2. Check Agent Radius in NavigationMesh settings (should be 0.5)
3. Verify safe_margin = 0.001 on enemy

## Next Steps

After successful baking:
1. Test patrol behavior
2. Test chase behavior  
3. Test search behavior
4. Adjust patrol points if needed
5. Tweak speeds in enemy scene if desired

The navigation system is now ready - just needs that one-time bake!
