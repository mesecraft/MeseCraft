# Fruit Tools
Adds a variety of fruit tools and other fruit-related items to Minetest.

![alt text](https://github.com/ChimneySwift/fruit_tools/blob/master/screenshot.png "All of the Fruit Tools")

**Code license:** [MIT](https://opensource.org/licenses/MIT)

**Textures license:** [MIT](https://opensource.org/licenses/MIT)

**Dependencies:** farming, default, bucket, vessels

**Optional Dependencies:** mobs, 3d_armor, mesecraft_toolranks

## Tools:
Fruit tools will occasionally drop the fruit they are made when used, this fuctionality can be adjusted in init.lua (See "Settings" section of this document).

- Admin pick (IMPORTANT NOTE: Please see "Settings" section of this document)
  - Tool capabilities:
      - full_punch_interval: 0.1
      - max_drop_level: 3
      - groupcaps: 0 for everything
      - fleshy: 100
      - Note: can break cloud, requires additional privs for use (picklepick/dealer depending on which pick is enabled)
- Corn pick
  - Tool capabilities:
      - full_punch_interval: 0.9
      - max_drop_level: 3
      - cracky: {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}
      - fleshy: 5
- Bean hoe
  - Tool capabilities:
      - uses: 1000
- Raspberry axe
  - Tool capabilities:
      - full_punch_interval: 0.9
      - max_drop_level: 1
      - choppy: {times={[1]=1.90, [2]=0.80, [3]=0.40}, uses=50, maxlevel=2}
      - fleshy: 7
- Melon axe
  - Tool capabilities:
      - full_punch_interval: 0.9
      - max_drop_level: 1
      - choppy: {times={[1]=1.80, [2]=0.70, [3]=0.30}, uses=70, maxlevel=2}
      - fleshy: 7
- Grape shovel
  - Tool capabilities:
      - full_punch_interval: 1.0
      - max_drop_level: 1
      - crumbly: {times={[1]=1.00, [2]=0.40, [3]=0.20}, uses=50, maxlevel=3}
      - fleshy: 4
- Apple shovel
  - Tool capabilities:
      - full_punch_interval: 1.0
      - max_drop_level: 1
      - crumbly: {times={[1]=0.9, [2]=0.30, [3]=0.10}, uses=80, maxlevel=3}
      - fleshy: 4
- Chili sword
  - Tool capabilities:
      - full_punch_interval: 0.5
      - max_drop_level: 1
      - snappy: {times={[1]=1.85, [2]=0.80, [3]=0.25}, uses=60, maxlevel=3}
      - fleshy: 8
- Carrot sword
  - Tool capabilities:
      - full_punch_interval: 0.5
      - max_drop_level: 1
      - snappy: {times={[1]=1.70, [2]=0.70, [3]=0.20}, uses=80, maxlevel=3}
      - fleshy: 9
- Golden carrot sword
  - Tool capabilities:
      - full_punch_interval: 0.4
      - max_drop_level: 1
      - snappy: {times={[1]=1.65, [2]=0.60, [3]=0.15}, uses=100, maxlevel=3}
      - fleshy: 10

### Crafting:
Pick:

m|m|m
-|-|-
r|s|r
r|s|r

m = Pick material (Eg: for Corn Pick it would be Corn on the Cob)

s = Stick

r = Tool Resin

Hoe:

m|m|×
-|-|-
r|s|r
r|s|r

m = Hoe material (Eg: for Bean Hoe it would be Green Beans)

s = Stick

r = Tool Resin

Axe:

r|m|m
-|-|-
r|s|m
r|s|r

m = Axe material (Eg: for Melon Axe it would be Melon Slice)

s = Stick

r = Tool Resin

Shovel:

×|m|×
-|-|-
r|s|r
r|s|r

m = Shovel material (Eg: for Apple Shovel it would be Apple)

s = Stick

r = Tool Resin

Sword:

×|m|×
-|-|-
r|m|r
r|m|r

m = Sword material (Eg: for Carrot Sword it would be Carrot)

r = Tool Resin

## Shields:
Fruit sheilds will occasionally drop the fruit they are made when hit (fruit placed in hitter's inventory), this fuctionality can be adjusted in init.lua (See "Settings" section of this document).

- Orange Sheild
  - Shield Capabilities:
      - armor_heal: 16
      - armor_use: 100
      - fleshy: 16
      - cracky: 2
      - snappy: 1
      - level: 3
- Tomato Sheild
  - Shield Capabilities:
      - armor_heal: 15
      - armor_use: 150
      - fleshy: 15
      - cracky: 2
      - snappy: 1
      - level: 3

### Crafting:

m|r|m
-|-|-
r|m|r
×|r|×

m = Sheild material (Eg: for Carrot Sword it would be Carrot)

r = Tool Resin

## Throwing Foods:

Throwing foods can be crafted from regular food. They look like regular food, but instead of being eaten they are thrown. If a throwing food lands on an unprotected dirt block, it may plant the thrown food if the food can be planted (Eg: if you throw a throwing tomato, it may plant a tomato plant) this fuctionality can be adjusted in init.lua (See "Settings" section of this document). Each throwing food does 2 fleshy damage.

* Throwing donut apple
* Throwing tomato
* Throwing blueberries
* Throwing grapes
* Throwing raspberries
* Throwing melon_slice
* Throwing orange
* Throwing strawberry

### Crafting

Throwing food:

f|f|f
-|-|-
f|s|f
f|f|f

f = Food material (Eg: for Throwing Tomato it would be Tomato)

s = Stone

Regular food (to revert back):

f|f|f
-|-|-
f|f|f
f|f|f

f = Throwing food (Eg: for Tomato it would be Throwing Tomato)

## Settings
### Admin Pick Settings:
By default the admin pick is set to the "Weed Pick", if you do not wish for your world to contain cannabis (aka weed) references, simply set the `say_no_to_cannabis` variable on line 8 of init.lua to `true`, this will replace the "Weed Pick" with the "Pickle Pick" (both tools have the same capabilities), if you do not wish for your world to contain pickle references then we can't help you, sorry.

### Extra Drops:
By default when a shield is hit, or a fruit tool is used, there is a 1 in 5 chance that between 1 and 5 of the shield/tool's food is also dropped. To enable/disable this set `extra_drops` on line 12 of `init.lua` to `false`. To change the drop chance change `extra_drop_chance` on line 14 of `init.lua`, to change the drop maximum change `extra_drop_max` on line 16 of `init.lua` and to change the drop minimum change `extra_drop_min` on line 18 of `init.lua`.

### Throwable Food Planting:
By default, when a throwable food hits an unprotected dirt node, it will place a fully grown plant of the throwable food's origin (Eg: Throwing Tomato plants a fully grown tomato plant) on top of the dirt 1 out of 5 times. To enable/disable this set `plant` on line 22 of `init.lua` to `false`. To make the mod first hoe the dirt, then place a new plant on top (instead of a fully grown one), set `plant_whole` on line 24 of `init.lua` to `false`. To change the chance of a plant being planted change `plant_chance` on line 26 of `init.lua`

## Notes
* This mod is a work in progress, tool capabilities etc. are subject to change, the code is still slightly messy, if you have any suggestions for improvements, start a GitHub issue, comment on the minetest forums (forum.minetest.net) or modify the code and create a pull request.

* Satisfy optional dependency "mobs" for throwing foods and optional dependency "3darmor" for sheilds.

* The dependancy "farming" refers to TenPlus1's farming_redo, not the farming mod from minetest_game.

## Changelog
* No changes yet!

MeseCraft changes
-----------------

`melon_slice.png` was removed because it was a mirrored copy of Minecraft's melon slice.
Thrown foods without their own texture here use the food item's inventory image, so the
thrown melon now shows Farming Redo's melon slice.
