Gramophone
==========

A little bit of history...
--------------------------

The _phonograph_ or _gramophone_, is a device for recording and playing sound. It was invented in 1877 by Thomas Edison. The sound vibration waveforms are recorded as corresponding physical deviations of a spiral groove engraved, etched, incised, or impressed into the surface of a rotating cylinder or disc, called a "record". To recreate the sound, the surface is similarly rotated while a playback stylus traces the groove and is therefore vibrated by it, very faintly reproducing the recorded sound. In early acoustic phonographs, the stylus vibrated a diaphragm which produced sound waves which were coupled to the open air through a flaring horn, or directly to the listener's ears through stethoscope-type earphones. [1]

Edison's phonograph used a rotating cylinder to record/play back music. In the 1890s, Emile Berliner introduced the first gramophone or phonograph to use flat discs instead of cylinders. 

The Minetest mod
----------------

This Minetest mod is based on Emile Berliner's flat discs (which are, of course, the most popular) and deviates from the usual, classic phonograph style of having an external horn. The design of this gramophone or phonograph is based on devices that don't have an external horn and seems to reproduce from something that resembles a speaker [2]. The decision, of course, is to avoid something that would look entirely out of place in Minetest's cubic design. It also doesn't record music (for now).

This mod is highly inspired by the Jukebox. However, the Jukebox device is too minimalist for my taste, and has lots to explain in terms of crafting recipe and operation. This gramophone mod attempts to be more realistic.

How to use
----------

There are three vital components to make a gramophone work, those are:
- The music player (default is the gramophone),
- One or more speakers,
- One or more music discs (or vinyl records)

Place a gramophone wherever you like (it looks good on top of a speaker node), and then place a speaker node next to the gramophone. It can be at any position as long as it is next to it (top, bottom, left, right, etc.) Then punch the gramophone with a disc in hand, and the disc will be placed on top of it. To make it play, just right-click the gramophone, and the disc will start playing. To stop it, just right-click it again. To take a disc out, just punch the gramophone again and you will have the disc in you inventory again.

A disc shelf is also included. Each shelf has 10 slots for holding 10 different types of music discs.
*Caution*: The shelf, while it really looks nice, it could add to the lag on very low-end computers. This is because it uses entities to show how many discs are in the shelf (reduced to a 2:1 scale).

There are no crafting recipes as-of now. I don't want to add a flimsy crafting recipe for this as I find it very unrealistic. To get one, use `creative` mode or `/giveme` command. I plan to add crafting recipes in the future, where they will actually make sense.

Roadmap
-------
- Add decent crafting recipes
- Add support for finding pieces in dungeons as loot (for MTG 0.5.0 and up)
- Make available 2 or 3 extra music packs (as separate mods to avoid large download size)
- Add more variety of music players?


Licenses
--------
### Code
All code is copyright (C) 2016-2017 Hector Franqui (zorman2000), licensed under the LGPLv2.1 license. See `license.txt` for details.

Some inspiration (and due credit):
- `mcl_jukebox` mod by Wuzzy2 (metadata inventory for disc storage) 
- `itemframe` mod by TenPlus1 (disc entity texture persistance) 

### Textures
All textures are CC-BY-SA 3.0 by Zorman2000

### Music files

All music files below include the link to the original file. The following modifications has been made to these files (not all apply to all files):

- Changed to mono from stereo
- Tempo was tweaked to fit more my taste.
- Converted from MP3 to OGG

Licenses apply as below.

1. Bagatela nº 25 "Für Elise", WoO 59 (https://musopen.org/es/music/361/ludwig-van-beethoven/bagatelle-no-25-fur-elise-woo-59/)
    - License: CC-PD
    - Composer: Ludwig van Beethoven
    - Performer: Anonymous
2. King Stephen, Op. 117 - I. Overture (https://musopen.org/music/3094/ludwig-van-beethoven/king-stephen-op-117/)
    - License: CC-PD
    - Composer: Ludwig van Beethoven
    - Performer: European Archive
3. Brandenburg Concerto no. 2 in F major, BWV 1047 - I. Allegro (https://musopen.org/music/2726/johann-sebastian-bach/brandenburg-concerto-no-2-in-f-major-bwv-1047/)
    - License: CC-PD
    - Composer: Johann Sebastian Bach
    - Performer: Papalin
4. Brandenburg Concerto no. 2 in F major, BWV 1047 - II. Andante (https://musopen.org/music/2726/johann-sebastian-bach/brandenburg-concerto-no-2-in-f-major-bwv-1047/)
    - License: CC-PD
    - Composer: Johann Sebastian Bach
    - Performer: Papalin
5. Tiento de medio registro de bajo (https://musopen.org/es/music/3135/sebastian-aguilera-de-heredia/tiento-de-medio-registro-de-bajo/)
    - License: CC-BY-SA 3.0
    - Composer: Sebastian Aguilera de Heredia
    - Performer: Rob Peters
6. Concerto No.1 in F major - III. Rondo (https://musopen.org/es/music/1325/wolfgang-amadeus-mozart/piano-concerto-no-1-in-f-k-37/)
    - License: CC-BY-SA 3.0
    - Composer: Wolfgang Amadeus Mozart
    - Performer: Simone Renzi
7. Nocturne in E flat major, Op. 9 no. 2 (https://musopen.org/music/245/frederic-chopin/nocturnes-op-9/)
    - License: CC-PD
    - Composer: Frederic Chopin
    - Performer: Frank Levy
8. Piano Concerto no. 21 in C major, K. 467 (https://https://musopen.org/music/2635-piano-concerto-no-21-in-c-major-k-467/#recordings/)
    - License: CC-BY-3.0
    - Composer: Wolfgang Amadeus Mozart
    - Performer: Markus Staab
9. String Quartet no. 2 in A major - III. Minuetto scherzo (https://musopen.org/music/3115/juan-crisostomo-de-arriaga/string-quartet-no-2-in-a-major/)
    - License: CC-PD
    - Composer: Juan Crisostomo de Arriaga
    - Performer: European Archive

### Christmas records

Added for MeseCraft's Christmas holiday pack. All four are by Kevin MacLeod
(incompetech.com), licensed under Creative Commons: By Attribution 4.0
(https://creativecommons.org/licenses/by/4.0/), converted to mono OGG and in some cases
shortened:

- "Deck the Halls B" (christmas_record_deck_the_halls.ogg)
- "Jingle Bells" (christmas_record_jingle_bells.ogg)
- "Silent Night" (christmas_record_silent_night.ogg)
- "We Wish You" (christmas_record_we_wish.ogg)

References
----------
  - [1] https://en.wikipedia.org/wiki/Phonograph
  - [2] https://www.google.com/search?q=amberola+30&client=ubuntu&hs=5Wd&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjf0KXT3YzYAhWDON8KHZtTDREQ_AUICigB&biw=1366&bih=622
