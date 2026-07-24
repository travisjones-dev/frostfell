# FrostFell — Echoes of the North

A browser-based 3D action-RPG built in a single HTML file. Norse/Skyrim-inspired:
explore a snowbound open world, fight the risen draugr, cast spells, raid barrow
tombs, and grow strong enough to face the long night.

No build step, no install — open the file (or serve it locally) and play.

## Play

Serve the folder over HTTP and open `frostfell.html`. A tiny local dev server is
included:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/server.ps1
```

Then visit **http://localhost:8321/**.

Opening `frostfell.html` directly via `file://` will not work — the game loads
Three.js as an ES module, which requires an HTTP origin.

## Controls

| Key | Action |
| --- | --- |
| `W A S D` | Move |
| Mouse | Look |
| `Shift` | Sprint (stamina) |
| `Space` | Jump |
| Left click | Melee attack (stamina) |
| Right click | Cast spell (magicka) |
| `1` – `3` | Sword / Axe / Bow |
| `4` – `6` | Firebolt / Ice Spike / Lightning |
| `E` | Interact / loot / enter–exit barrow |
| `Q` | Drink potion |
| `T` | Equip torch |
| `Tab` | Inventory |

## Features

- Procedural snow terrain with height/slope material blending
- Day/night cycle, drifting clouds, night aurora, volumetric god rays
- Post-processing: bloom, SSAO, cinematic color grade, vignette, film grain
- Melee + ranged + spell combat with screen shake, hit-stop, knockback, floating damage
- Enemies: draugr, archers, and a Draugr Lord boss
- Explorable barrow **dungeon interiors** — torch-lit corridors and vaulted burial
  chambers, entered through a fade transition from the overworld
- Points of interest, compass discovery, a merchant, quests, and a skill system
- Fully synthesized audio (Web Audio API) — wind bed, music drone, combat SFX. No audio files.
- Save/load via `localStorage`

## Tech

- **JavaScript (ES modules)** — all game logic
- **[Three.js](https://threejs.org/)** — WebGL 3D rendering
- **GLSL** — custom shaders (sky, aurora, clouds, terrain, water)
- **HTML + CSS** — UI, HUD, menus

Everything lives in one file: [`frostfell.html`](frostfell.html).
