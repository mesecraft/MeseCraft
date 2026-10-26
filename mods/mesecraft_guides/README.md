# MeseCraft Guides

Guide books written by MeseCraft players on the [mesecraft.com forums](https://www.mesecraft.com/discussions/), proofread and updated for the current game. New players start with *How to Play MeseCraft*. Shelves in newly generated settlements get guides, and market buildings get the market reference. The settlements book ABM shelves a guide when it has no ledger or travel guide to write.

Each book ends with its author and a link to the forum thread it came from. Texts are in `books/`. Add a guide by adding a text file there and an entry to `mesecraft_guides.books` in `init.lua`.

API:

- `mesecraft_guides.make_book(id)` returns a written book `ItemStack`.
- `mesecraft_guides.add_random_book(inv, listname, filter)` adds a guide the list doesn't already hold.

## Credits

| Book | Author | Forum thread |
|---|---|---|
| An Introduction to MeseCraft | Fane | [An introduction to Mesecraft](https://www.mesecraft.com/discussions/topic/an-introduction-to-mesecraft/) |
| How to Play MeseCraft | Kiopy7 | [Guide to Mesecraft - How to play](https://www.mesecraft.com/discussions/topic/guide-to-mesecraft-how-to-play/) |
| Tips and Tricks | Kiopy7 | [Random Tips and Trick in Mesecraft](https://www.mesecraft.com/discussions/topic/random-tips-and-trick-in-mesecraft/), [Kip's Simple Tips and Tricks](https://www.mesecraft.com/discussions/topic/kips-simple-tips-and-tricks/) |
| A Guide to Minerals, Alloys, Rocks and Crystals | Kiopy7, with notes from Charlie_Blockhead | [A Guide to Minerals, Alloys, Rocks, and Crystals](https://www.mesecraft.com/discussions/topic/a-guide-to-minerals-alloys-rocks-and-crystals/) |
| The Layers of the World | Komodo | [Biomes](https://www.mesecraft.com/discussions/topic/biomes/) |
| A Guide to Taming | mesecraft, with notes from Charlie_Blockhead | [Guide on Taming Part 1](https://www.mesecraft.com/discussions/topic/guide-on-taming-part-1/) |
| Market Reference, Vol. 1 and 2 | Odie | [Market reference book](https://www.mesecraft.com/discussions/topic/market-reference-book/) |
| Farmer's Almanac, Vol. 1 to 6; Garlic: Bane of Vampires | Keihdra | [Farmer's Almanac](https://www.mesecraft.com/discussions/topic/farmers-almanac/) |

Licensed with the rest of MeseCraft (AGPLv3).
