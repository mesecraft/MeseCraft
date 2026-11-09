Real Torch by TenPlus1

This mod changes minetest torches so that they have a life of 20-30 minutes which
is configurable using the torch_min_duration and torch_max_duration settings.

- 2x coal lumps can be crafted into 12x coal powder
- coal powder and an unlit torch can be crafted into a lit torch again
- punching an unlit torch with coal powder relights it
- punching an unlit torch with flint & steel relights it
- punching an unlit torch with gunpowder explodes and relights it
- never punch a lit torch with gunpowder, ow!
- water near torches make them drop as unlit torches
- coal powder can also be used for fuel or crafted into black dye

https://forum.minetest.net/viewtopic.php?f=11&t=15721

Changelog:

- 0.1 - Initial upload
- 0.2 - Punching unlit torch with coal powder relights torch
- 0.3 - Torches are 2D and override any that are 3D
- 0.4 - Changed my mind, now detects old 2D or new 3D torches and works accordingly
- 0.5 - 2x coal lumps give 10x coal dust, also fixed check for ethereal mod
- 0.6 - Burnout and extinguish sounds added by tacotexmex :)
- 0.7 - Torches can be re-lit using flint & steel and gunpowder, settings added
- 0.8 - Updated to newer functions, requires Minetest 0.4.16 to run

## Textures

`mesecraft_torch_coal_powder.png` is original art for MeseCraft (AGPLv3), drawn by
`utils/skingen/items.py`. It replaced a darkened copy of Minecraft's gunpowder icon.
