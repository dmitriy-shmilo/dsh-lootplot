# Daunting Difficulty #

![Cover](../images/dsh_dd_thumbnail.png)

Increases the game difficulty, and makes some game-breaking mechanics less viable.

## Overrides and Effects ##

- **Stable Injunctions.** You may no longer spawn shop or reroll slots under injunctions. They will be immediately turned into doomed null slots. Magic wand may no longer target injunctions. This makes injunctions much harder to completely remove.
- **Edible Sacks.** All sack items are treated as food. This disables some interactions for sacks, like easy cloning.
- **Rare Sacks.** Big and epic sacks have an increased rarity, which makes them spawn less often in shops. You can also no longer find a big or epic sack in an uncommon sack loot.
- **One Sided Keys.** Keys no longer have two targets by default. This makes you either produce and spawn more keys, or find ways to rotate them more often.
- **Shields Don't Affect Shields.** Shields no longer can target each other or themselves. This reduces your ability to create cheap repeater and doom counter machines.
- **Pies Don't Affect Food.** All pies will no longer work on food. This reduces your ability to create extremely powerful one time use items.
- **Stars Don't Affect Food.** Star and star card item won't work on food. Same rationale as above.
- **Mild Nacho.** Nacho has legendary rarity, higher base price and a single target. Vanilla nacho is overpowered, especially considering its low rarity.
- **Mild Pepper.** Chilli pepper no longer destroys curses after draining their lives. Player will have to use destructive items to finish off affected curses.
- **Weaker Curse Button.** Curse button earns less money, and has only two max activations. This reduces player's ability to cheese the game with dozens of curses.
- **Brittle Chests.** Golden chests have a doom counter of 1. This turns chests into one-use items, similar to other chests. Unless player spends extra effort to preserve them, that is.
- **Sticky Consistency.** Item spawning items become sticky, similar to the square basket. Triple dice become sticky, similar to grubby coins.


## Customizing ##

All overrides are in effect by default. You can toggle any of them off by opening `dsh.dd/shared/config.lua` with any text editor and editing the config table.


## Known Issues ##

This mod has to redefine some existing items, which will screw up your compendium: some items might show up as undiscovered. This is a benign issue. If the mod is uninstalled, or the redefined item is encountered in a run again, it will begin showing up correctly.