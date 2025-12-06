# DSH Lootplot Mods #

A collection of small mods for the Lootplot game.

## Vanilla Variety ##

![Showcase](dsh.vv/assets/images/dsh_vv_showcase.png)

A mod I've made as an exercise with Lootplot modding API. Adds several new slots, a couple new foods to spawn those slots, and an assortment of items.

## DSH Debug ##

A devtools mod, which adds a couple of commands to spawn items and slots in a more convenient manner:
- `/ss [slot_type="slot"] [radius=0]` - spawns a slot with the given type in a (radius * 2 + 1) x (radius * 2 + 1) grid. If radius is omitted, will spawn a single slot. If slot type is omitted, will spawn a normal slot.
- `/si item_type` - spawns an item with the given item type at the center of the screen. If there's no slot available, traverses the screen in a spiral, looking for a suitable slot.
- `/` - repeats the last `si` or `ss` command.

## Credits ##

- All graphical assets are simply recolored or otherwise slightly adjusted assets from the [official sources](https://github.com/UntitledModGame/umg-mods/tree/master/lootplot.s0).
- Some code snippets are borrowed from the official [sources](https://github.com/UntitledModGame/umg-mods/tree/master).

### Installation ###

1. Download this repository.
2. Copy any mod folder you'd like to `%APPDATA%/lootplot/mods`.
3. Copy the `dsh.lib` to `%APPDATA%/lootplot/mods`. 

Or simply run `install.bat`, which will copy all mods.