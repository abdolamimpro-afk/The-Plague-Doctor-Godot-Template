🩺 The Plague Doctor — Godot 4 Horror Game Template

A reusable horror game development template for Godot 4.

The Plague Doctor is a 3D first-person horror game template designed to help developers understand, customize, and build their own horror games using Godot Engine 4.

Instead of starting from an empty project, developers can explore an existing gameplay foundation featuring enemy AI, maze exploration, player movement, interactive objects, survival mechanics, and horror atmosphere.

This repository is intended as a starting point for your own horror game projects. You can study the code, modify the gameplay systems, replace assets, customize the interface, and expand the project to fit your vision.

🎮 Features

👁️ Enemy AI

- Enemy patrol and investigation behavior.
- Player detection and chase mechanics.
- Configurable movement speeds and detection settings.
- Navigation-based enemy movement, depending on scene configuration.

🏃 Player Controller

- First-person movement.
- Walking and running.
- Stamina consumption and recovery.
- Movement effects and survival gameplay.

🔦 Flashlight and Battery System

- Flashlight battery management.
- Battery drain and recharge pickups.
- Low-battery flickering effects.
- Adjustable battery settings.

🧩 Interactive Fuse System

The project includes four colored fuse types with different gameplay effects:

- Orange Fuse: Contributes to the required fuse objective.
- Red Fuse: Can attract the monster or reveal the player's location.
- Blue Fuse: Provides a temporary stamina and speed boost.
- Green Fuse: Temporarily affects the monster's ability to hear.

The exact effects and requirements can be customized in the corresponding scripts.

🗺️ Horror Environments

- Maze exploration.
- Sewer-themed environment scenes.
- Atmospheric lighting and horror presentation.
- Enemy encounters and survival objectives.

🖥️ User Interface

- Main menu.
- Story screen.
- Pause menu.
- Settings and volume controls.
- Mouse sensitivity settings.
- Game-over screen.
- Victory screen.
- Gameplay counters and temporary ability timers.

🔊 Audio and Visual Atmosphere

- Horror sound effects and ambient audio.
- Visual effects and low-battery feedback.
- Textures, models, and environmental assets.

🛠️ Why Use This Template?

This project can help developers who want to:

- Learn how different gameplay systems work together in Godot.
- Build a horror game without creating every system from scratch.
- Experiment with enemy AI and player detection.
- Reuse or adapt gameplay mechanics for a new project.
- Study scene organization and GDScript.
- Customize an existing horror game foundation instead of beginning with an empty project.

Important: This is a starting template, not a universal plug-and-play framework. Some systems may need adjustments when you integrate them into a different game.

⚙️ Requirements

- Godot Engine 4.x.
- A compatible desktop environment.
- The project configuration currently declares Godot 4.7; verify compatibility with your installed version before making changes.

The project uses Godot's Compatibility rendering method. Performance depends on your hardware, scene complexity, and rendering settings.

🚀 Getting Started

1. Clone or download this repository.
2. Open Godot Project Manager.
3. Click Import and select the project's "project.godot" file.
4. Open the project and allow Godot to import its resources.
5. Press F6 to run the currently open scene or F5 to run the configured main scene.

If Godot reports missing resources, check that you downloaded the complete repository and are using a compatible engine version.

📁 Project Structure

The following overview highlights important project files. It is not an exhaustive inventory of every resource.

horror-doctor-maze/
├── project.godot
├── favicon.ico
├── main/
│   ├── Main.tscn
│   ├── Menu.tscn
│   ├── MonsterMenu.tscn
│   ├── Player.tscn
│   ├── Player.gd
│   ├── the_plague_doctor.tscn
│   ├── the_plague_doctor.gd
│   ├── maze.tscn
│   ├── the_sewer_maze.tscn
│   ├── batterie.tscn
│   ├── battery.gd
│   ├── fuses.tscn
│   ├── fuses.gd
│   ├── game_manager.gd
│   ├── UI.gd
│   ├── UIMenu.gd
│   ├── pause_menu.tscn
│   ├── pause_menu.gd
│   ├── settings.gd
│   ├── game_over.tscn
│   ├── game_over.gd
│   ├── won.tscn
│   └── won.gd
├── assets/
│   ├── generated/
│   ├── sounds/
│   ├── backrooms-maze-generator-script/
│   ├── low_poly_sewer_props.glb
│   └── simple_aa_battery.glb
├── scp-049/
│   ├── source/
│   └── textures/
└── textures/
    ├── floor/
    └── wall/

Godot may also generate a ".godot/" directory for editor metadata and imported resource caches.

📜 Important Scripts

Player System

File| Responsibility
"main/Player.gd"| Player movement, stamina, flashlight, battery behavior, and related player mechanics.
"main/Player.tscn"| Player scene and node hierarchy.

Useful variables to investigate include "walk_speed", "run_speed", "max_stamina", "stamina_drain", "stamina_recover", "max_battery", and "battery_drain_rate".

Enemy System

File| Responsibility
"main/the_plague_doctor.gd"| Enemy behavior, patrol, investigation, chasing, and player detection.
"main/the_plague_doctor.tscn"| Plague Doctor enemy scene.

Useful variables include "patrol_speed", "investigate_speed", "chase_speed", "vision_range", "vision_angle_deg", and "catch_distance".

Items and Game Progress

File| Responsibility
"main/fuses.gd"| Fuse types, effects, and related interactions.
"main/fuses.tscn"| Fuse scene.
"main/battery.gd"| Battery pickup and energy restoration behavior.
"main/batterie.tscn"| Battery scene.
"main/game_manager.gd"| Game progress, fuse requirements, and game-state transitions.

UI and Menus

File| Responsibility
"main/UI.gd"| Gameplay UI, counters, and temporary ability timers.
"main/UIMenu.gd"| Main menu and story-screen behavior.
"main/pause_menu.gd"| Pause menu and related controls.
"main/settings.gd"| Shared settings, including mouse sensitivity.
"main/game_over.gd"| Game-over screen behavior.
"main/won.gd"| Victory screen behavior.

Scene files (".tscn") define scene structures and resource connections, while GDScript files (".gd") implement gameplay logic. Some behavior also depends on nodes, signals, resources, and project settings configured in the Godot editor.

🎨 Customization Guide

Change Player Movement

Open "main/Player.gd" and inspect the exported movement settings, such as:

- "walk_speed"
- "run_speed"
- "exhausted_speed"

Adjust Stamina

Inspect these variables in "main/Player.gd":

- "max_stamina"
- "stamina_drain"
- "stamina_recover"

Customize Flashlight Behavior

Review flashlight-related variables in "main/Player.gd", including:

- "max_battery"
- "battery_drain_rate"
- "flicker_enabled"
- "flicker_low_battery_threshold"

Change Enemy Difficulty

Open "main/the_plague_doctor.gd" and investigate:

- "patrol_speed"
- "investigate_speed"
- "chase_speed"
- "vision_range"
- "vision_angle_deg"
- "catch_distance"

Test changes in the running game, especially navigation, collisions, and detection behavior.

Modify Fuse Mechanics

- Use "main/fuses.gd" to investigate fuse types and their gameplay effects.
- Use "main/game_manager.gd" to investigate fuse collection requirements and game progression.

Before modifying a system, inspect its associated scene and connected nodes to understand its dependencies.

📦 Assets and Third-Party Licenses

The project includes models, textures, audio, and other resources in folders such as "assets/", "scp-049/", and "textures/".

Before redistributing the template or using it commercially, verify the original license and attribution requirements for every third-party resource, including:

- Character and enemy models.
- Environmental models and textures.
- Music and sound effects.
- Fonts and other downloaded resources.
- Third-party scripts, plugins, and libraries.

The repository's MIT license does not automatically grant permission to redistribute third-party assets. Each resource must be checked against its own license.

A complete asset credits and license inventory should identify each external resource, its source, its author where required, and the applicable license.

📄 License

See the repository's "LICENSE" file for the license that applies to the project code.

Third-party assets may be governed by separate licenses. Check their terms before reusing, modifying, or redistributing them.

🐛 Bug Reports and Feedback

If you encounter a problem, include:

- Your Godot version.
- The steps required to reproduce the issue.
- The expected behavior and actual behavior.
- Relevant errors from Godot's Output or Debugger panels.

Feedback and suggestions that help improve the template are welcome.

🤝 Contributions

Contributions and suggestions are welcome, subject to the repository's license and the licenses of included assets.

When contributing, keep gameplay systems organized and document new configuration options where appropriate.

---

Built with Godot Engine 4.

The Plague Doctor is a horror game template intended to help developers learn, experiment, and build their own horror projects. Explore the code, customize the mechanics, and use the project as a foundation for your next horror game.
