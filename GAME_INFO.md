# Game Mechanics

## Enemy AI System

### Vision-Based Detection
- Enemies have a **vision cone** (120° field of view, 10 units range)
- Enemies will only chase you if you're **within their vision cone**
- If you escape their line of sight, they'll stop chasing and return to wandering

### Enemy States

1. **WANDER** (Default)
   - Enemy walks randomly around their spawn point
   - Wander radius: 8 units
   - Wander speed: 1.5 units/sec
   - Pauses briefly between movements

2. **CHASE** (Player spotted)
   - Enemy moves directly toward player
   - Chase speed: 3.5 units/sec
   - Will chase as long as player is in vision cone
   - Returns to WANDER if player escapes vision

3. **ATTACK** (Player in range)
   - Triggers when player is within 2 units
   - Deals 20 damage per attack
   - Attack cooldown: 1.5 seconds
   - Enemy stops moving during attack

## Player Mechanics

### Controls
- **WASD / Arrow Keys**: Move
- **Mouse**: Look around
- **Space**: Jump
- **L or F**: Toggle flashlight
- **ESC**: Toggle mouse capture

### Health System
- Starting health: 100 HP
- Health bar displayed in top-left corner
- Game restarts when health reaches 0

### Survival Strategy
- **Stay out of enemy vision cones**
- **Use the environment** to break line of sight
- **Listen for enemy movements**
- **Keep moving** - standing still makes you an easy target
- **Use your flashlight wisely** - it helps you see but might attract attention

## Game Objective
**SURVIVE** - Avoid enemies and stay alive as long as possible!

## Tips
- Enemies can only see you if you're in front of them
- Circle around enemies to stay out of their vision
- Use corners and obstacles to break line of sight
- The faster you move, the harder it is for enemies to catch you
