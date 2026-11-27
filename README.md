# MOBN: Blox Legends 5v5 (Godot 4.7 Engine Edition)

Full 3D Isometric 5v5 MOBA game inspired by Mobile Legends: Bang Bang in Roblox R6 Anime Style — now powered natively by **Godot Engine 4.7** (`GL Compatibility` / Forward+ ready) with 100+ generated game assets, modular GDScript 4.x static-typed architecture, procedural 3D R6 Hero Rigs, and real-time `AudioStreamGenerator` BGM + MLBB Voice Announcer.

## How to Run (CachyOS Linux)
- **Play Native Godot 4.7 Game**:
  ```bash
  /home/nza/.gemini/antigravity/scratch/mobn_blox_legends/start.sh
  ```
  *(or directly: `godot --path /home/nza/.gemini/antigravity/scratch/mobn_blox_legends`)*
- **Open in Godot 4.7 Editor**:
  ```bash
  /home/nza/.gemini/antigravity/scratch/mobn_blox_legends/start.sh --editor
  ```
- **Run Automated Headless Verification**:
  ```bash
  /home/nza/.gemini/antigravity/scratch/mobn_blox_legends/start.sh --test
  ```

## Architecture & Generated Assets (`res://assets/`)
- **12 Playable Roblox R6 Heroes**: *Laylul, Sabro, Yu Zong, Kajee, Yeen, Kimee, Minotor, Esteez, Master Yee, Ketootoo, Alucardox, Gusionox* — each with custom skins (`DEFAULT`, `ELITE`, `EPIC`, `COLLECTOR`, `LEGEND`), 3D weapons, and 4 unique skills.
- **Complete Required Asset Pack (`res://assets/`)**:
  - `assets/icons/game_icon.png` & `assets/ui/lobby_splash_banner.png`: High-res AI-generated App Icon & Season 1 MOBA Lobby Splash Banner.
  - `assets/portraits/*.png`: 12 Roblox R6 hero portrait cards.
  - `assets/skills/*.png`: 48 custom skill & basic attack icons (4 per hero).
  - `assets/items/*.png` & `assets/spells/*.png`: 11 MOBA equipment icons + 5 battle spell icons (*Flicker, Vengeance, Execute, Recall, Regen*).
  - `assets/textures/faces/*.png`, `assets/textures/torsos/*.png`, `assets/textures/terrain/*.png`: 12 R6 anime face textures, 12 armor/corset torso textures, and 3 arena terrain textures (*grass, stone, brick*).
- **Modular Godot 4.7 Scripts (`res://scripts/`)**:
  - `scripts/autoload/game_database.gd` & `audio_synthesizer.gd`: Resource database and procedural BGM/SFX + TTS Voice Announcer (*First Blood, Double Kill, Triple Kill, Maniac, Savage, Wipe Out, Victory*).
  - `scripts/components/health_component.gd` & `skill_component.gd`: Modular health, mana, damage mitigation, and cooldown components.
  - `scripts/builders/roblox_hero_builder.gd` & `roblox_hero_rig.gd`: Procedural 3D R6 blocky mesh builder & limb/twintail animation controller.
  - `scripts/arena/arena_battle_world.gd`: 3D Lobby pedestal + Full 5v5 MOBA Arena (river pools, stealth bushes, rock clusters, 8 turrets/nexuses, 4 jungle buff camps, minion waves, AI lane bots, projectiles, laser beams, and isometric camera shake).
