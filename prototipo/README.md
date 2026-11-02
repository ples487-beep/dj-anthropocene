# Apocapedia prototype

Open `project.godot` in Godot 4.7 and press **F5** to play.

| Control | Action |
| --- | --- |
| WASD / arrow keys | Walk around the room |
| Mouse | Slightly pan the view |
| E near the desk | Interact with the computer |

The computer currently has only a proximity-gated interaction event. Pressing E nearby emits `Main.computer_interacted` and prints a message in Godot's Output panel. It keeps the room visible and movement enabled. There is no HUD text.

## Scene structure

```text
scenes/main.tscn               Main: world scene switching and interaction hook
└── Room                      Instance of scenes/room.tscn
    ├── Room geometry         Walls, floor, and ceiling
    ├── Camera                Slightly elevated perspective view with mouse pan
    ├── pessoa                Player scene with an unscaled physics body
    └── Computer              Instance of scenes/pc.tscn
        └── InteractionArea   Detects the nearby player on physics layer 2
```

`scripts/main.gd` retains a general `change_scene(scene: PackedScene)` method for future world scenes. The computer's interaction request is forwarded through the room to Main.

## Camera

The camera sits just inside the front wall at a height of 2.8 units, tilted downward by 10°. Perspective projection and the enclosed room fill the viewport. The camera stays in place while the player walks. The enlarged character keeps its previous size using explicit sprite and collision dimensions, with no scale applied to the physics body. Its sprite stays upright as the camera pans.

Move the cursor away from the center to look slightly in that direction. The view smoothly returns to center when the mouse leaves the window. In the room scene, select **Camera** to adjust:

- **Max Pan Degrees**: horizontal and vertical limits, initially 4° and 2.5°.
- **Pan Response**: smoothing speed, initially 14.
- **FOV**: perspective field of view, initially 70°.

## Rendering and movement

The project uses Godot's Mobile Vulkan renderer and one interior light. The ceiling enclosed the previous directional light, so its shadow pass has been removed. The game renders at the window's resolution without canvas stretching.

Player physics runs at 60 ticks per second with render interpolation enabled. The camera updates directly on rendered frames so mouse movement stays responsive. Walking follows the camera's horizontal directions, diagonal input keeps the same speed, and releasing a key stops immediately. Losing window focus clears held movement.

## Verification

```sh
godot --headless --editor --path . --quit
godot --headless --path . --script tests/game_flow_test.gd
godot --headless --path . --script tests/movement_test.gd
```

The checks cover room movement, computer proximity and interaction, scene switching, camera height, bounded mouse panning, and room coverage in landscape and portrait viewports. The movement regression also checks idle floor stability, immediate stopping, equal diagonal speed, camera-relative direction, lost focus, and disabled controls.

For screenshots during a rendered test run:

```sh
godot --path . --script tests/game_flow_test.gd -- --screenshots=/tmp/apocapedia-room-review
```
