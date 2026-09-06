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
}

return config