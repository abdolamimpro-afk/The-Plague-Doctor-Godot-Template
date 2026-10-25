The Plague Doctor — Godot 4 Horror Game Template

A feature-rich 3D first-person horror starter project built with Godot 4.

The Plague Doctor is a horror game project designed as a starting point for developers who want to explore and build their own atmospheric horror experiences. It combines enemy AI, first-person movement, stealth mechanics, interactive objects, resource management, and immersive horror effects in one playable project.

Use it to study the implementation, experiment with the gameplay systems, and develop your own horror game.

Features

👁️ Enemy AI System

- Patrol behavior with configurable patrol points
- Player vision detection with adjustable range and field of view
- Investigation behavior triggered by player-generated noise
- Chase behavior when the player is detected
- Configurable movement speeds and detection settings
- Navigation-based enemy movement

🎮 First-Person Controller

- Configurable walking and running speeds
- Stamina consumption and recovery
- Crouching and stealth movement
- Noise generation based on player movement
- Camera head bobbing and movement effects
- Adjustable mouse sensitivity

🔦 Flashlight & Battery System

- Usable flashlight with battery consumption
- Configurable battery capacity and drain rate
- Low-battery flickering effects
- Battery pickups to restore flashlight energy
- Dynamic lighting that supports the horror atmosphere

🫀 Immersive Horror Effects

- Heartbeat audio influenced by nearby danger
- Fear effects and tunnel vision
- Ambient whispers and randomized scare events
- Footstep and breathing audio
- Camera movement and visual feedback

🔋 Interactive Item System

- Interactable objects and collectible items
- Four colored fuse types with different gameplay effects
- Objective tracking through fuse collection
- Red fuses that can attract the monster and reveal the player's location
- Blue fuses that provide temporary movement and stamina boosts
- Green fuses that temporarily disable the monster's hearing
- Battery pickups and interaction prompts

🖥️ UI & Game Flow

- Main menu
- Pause menu with resume and retry options
- Audio volume controls
- Mouse sensitivity settings
- Win and game-over screens
- Objective counters and gameplay feedback

Built With

- Engine: Godot Engine 4
- Language: GDScript
- Dimension: 3D
- Perspective: First-person
- Rendering: Compatibility renderer

Requirements

- Godot Engine 4.7, matching the project configuration
- A computer capable of running the included 3D scenes and assets

Other Godot 4 versions have not been verified.

Getting Started

1. Download or clone this repository.
2. Open the Godot Project Manager.
3. Click Import.
4. Select the project's "project.godot" file.
5. Open the project and allow Godot to import the assets.
6. Run the project using the configured main scene.

If the project does not open correctly, check the Godot version and review any missing dependencies or import errors.

Customization

Many gameplay values are exposed through exported variables in GDScript, allowing developers to experiment with:

- Monster vision range, patrol speed, and chase speed
- Player movement speeds and stamina settings
- Flashlight battery drain and flickering
- Fear effects and audio behavior
- Fuse effects and temporary power-ups
- Menu audio and mouse sensitivity

The project can be used as a foundation for experiments, prototypes, and custom horror game projects.

Project Structure

- "main/Player.gd" — Player controller and horror gameplay mechanics
- "main/the_plague_doctor.gd" — Monster AI behavior
- "main/game_manager.gd" — Objective tracking and win/loss flow
- "main/fuses.gd" — Fuse interactions and gameplay effects
- "main/battery.gd" — Battery pickup behavior
- "main/pause_menu.gd" — Pause menu controls
- "main/settings.gd" — Settings data
- "main/" — Gameplay scenes and UI scenes
- "project.godot" — Godot project configuration

Important Notes

This is a reusable starting project, not a universal plug-and-play framework. Some systems are connected to the included scenes and node structure, so review the relevant scripts before moving them into another project.

The project has not been independently verified across every supported operating system or Godot version.

Credits & Third-Party Assets

Third-party models, textures, sounds, fonts, animations, plugins, and other resources may be included.

Please review the asset credits and individual licenses before redistributing or using this project commercially. Do not assume that the project's code license automatically covers third-party assets.

[Add a complete list of asset creators, source links, and applicable licenses here.]

License

See the "LICENSE" file for the license applicable to the project code.

Third-party assets remain subject to their respective licenses.

Feedback

Found an issue or have an idea for improving the project? Open an issue in this repository.

If you use this project as a learning resource or starting point, feedback and suggestions are welcome.

---

Created with Godot 4.

Explore the systems, learn from the implementation, and build your own horror experience.
