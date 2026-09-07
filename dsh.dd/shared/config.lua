-- change any "true" to "false" in order to disable that particular option
local config = {
	-- makes item sacks be treated as food, which prevents certain interactions
	edibleSacks = true,

	-- bump epic and big sacks rarity by one level
	rareSacks = true,

	-- makes all keys target a single slot
	oneSidedKeys = true,

	-- makes all shields ignore shields when targeting
	shieldsDontAffectShields = true,

	-- makes injunctions more resistant to removal
	stableInjunctions = true,

	-- makes pies ignore food items when targeting
	piesDontAffectFood = true,

	-- makes the star and the star card ignore food when targeting
	starsDontAffectFood = true,

	-- nacho is of highest rarity, expensive and single-target
	mildNacho = true,

	-- chilli pepper will no longer destroy curses after draining their lives
	mildPepper = true,

	-- curse button has only two max activations, and earns less money
	weakerCurseButton = true,

	-- makes golden chest items DOOMED-1
	brittleChests = true,

	-- makes item-generating items and triple dice sticky
	stickyConsistency = true,

	-- marble chest and urns have severely reduced max number of activations
	nobleMarble = true,

	-- furnace has less activations, destroys items to turn them into stone, turns organic items into useless ash
	groundedFurnace = true
}

return config