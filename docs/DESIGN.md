# MeseCraft design notes

Working notes for where MeseCraft is going. Not a spec: ideas here are a direction, and change as they get built. See the README for the design philosophy.

## World layers

The goal is to use the whole world height, layering places to discover from the deep underground to the edge of the map, so there's always somewhere new to explore.

### Vertical layers

| Layer | Planned range | Current range | Mod |
|---|---|---|---|
| Red asteroids | 22001 to 30912 | 22001 to 30912 | `other_worlds` |
| Mars | 11000 to 22000 | terrain 11000 to 21000, sky to 22000 | `mesecraft_mars` |
| Asteroids | 3500 to 10999 | 3500 to 10999 | `other_worlds` |
| Moon | 2000 to 2300 | 2000 to 2300 | `mesecraft_lua` |
| Earth orbit (space) | 1000 to 2999 | vacuum from 1000 up | `vacuum` |
| Cloudlands | 200 and up | about 400 to 600 | `cloudlands` |
| Surface | | | Minetest Game biomes |
| Caverns | | down to about -4000 | `dfcaverns` |
| Nether | | -17000 to -31000 | `nether` |

Each layer should feel like its own place: its own sky, gravity where it makes sense, hazards, creatures and resources, and a way to get there (portals, flight, digging).

### Surface biomes

Grasslands, coniferous forest, deciduous forest, rainforest, savanna, desert, sandstone desert, cold desert, snowy grassland, taiga, tundra, ice sheet.

Edges and shores: grassland dunes, coniferous forest dunes, deciduous forest shore, rainforest swamp, savanna shore, taiga beach, tundra beach.

Oceans: tundra ocean and the other oceans.

Underground: pyramids.

## Story

An asteroid carrying a mysterious element tumbles through space and hits Earth, causing a mass extinction and reshaping the planet. The asteroid held a powerful, seemingly magical mineral: Mese. It emits energy unlike anything known.

After the impact, a race of reptilian shape-shifters came to Earth and, with the planet devastated, quickly established themselves. Greys from another galaxy built bases on the Moon to watch the humans and the reptilians' operations.

### Factions

**Reptilians**
- A brutal, warring race with mining operations on many planets; they enslave other races (in the spirit of the Goa'uld and Scarrans).
- On Earth they enslave the civilization and its military to mine Mese (a nod to *They Live*).
- They take on the personas of gods, with egos to match.
- Hellish reptilians moved deep within the Earth to mine Mese, took on the mythos of Hell and Satan, and created SynTek cyborgs to rule it.

**Greys**
- An ancient, benevolent humanoid race: short, thin, large heads, black eyes.
- They act as protective gods on primitive planets, rely on technology and science, and prefer diplomacy despite their military strength.
- They fought the reptilians but failed to stop them becoming a threat to the galaxy.
- Their technology relies on neutronium, a hypothetical substance made of neutrons.

**SynTek Corporation** (technology faction)
- A huge international technology company embodying the worst of crony capitalism, close to government through contracts.
- Its AI runs all its systems, becomes sentient and attacks (in the spirit of *Terminator* and *System Shock*): "The Many".

How the story reaches players (lore books, creature journal entries, quests) is still open.

### Player lore from the forums

Ideas players posted on the mesecraft.com forums (Lore & Theories, General). Credit the authors if any of it goes into the game.

- **Kiopy7's timeline:** goblins drove the dwarves underground into the Underworld, where a king ruled; wizards learned to use Mese; the King's Market is what is left of that kingdom's trade.
- **Reptilian mini-bosses:** evil lizards that drop mirror shards, tying the magic mirror to the Reptilians. Letters found in the Slade layer tell part of the story.
- **Komodo's themes:** harmony with nature against greed; adventure and growth. The world is just called "the world". A spreading corruption (the "Calamity") that bosses must be beaten to cleanse from a biome, and sky islands as "Bastions".
- **Progression:** tutorial, then the surface, caves, Hell, the Moon and Mars, then space.
- **Fossils:** the fossilized egg in sky-island caves is a rare trophy; players hoped it would hatch into a tameable dinosaur.
- **Mana as Mese:** replace the mana bar with traces of Mese absorbed into the blood of some creatures, which powers "magical" Mese technology. Sprinting could become a Mese ability rather than a basic move.

## Ideas

- **Creature journal:** players document creatures as they meet and defeat them, like the *Breath of the Wild* compendium.
- **Food as pictures:** show food as flat picture sprites rather than 3D models, the way *Super Smash Bros.* shows food items.
- **Thirst clarity:** a common complaint is that it's unclear how thirst works (how to drink, what fills it).
- **Engine UI settings:** a game can set server and gameplay defaults in its `minetest.conf` and control HUD, sky, zoom and formspec styling, but not players' client settings (GUI scale, fonts, graphics).
- **dfcaverns updates:** dfcaverns only works with MeseCraft's beds and buckets because its `df_dependencies` was edited to name `mesecraft_beds` and `mesecraft_bucket` items. Updating dfcaverns from upstream undoes that; MeseCraft should provide what dfcaverns expects instead of patching it.
