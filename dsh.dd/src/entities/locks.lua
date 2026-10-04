local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.sturdyLocks then return end
local function triggerUnlock(ent)
	return lp.tryTriggerEntity("UNLOCK", ent)
end

---@param ppos lootplot.PPos
---@param x integer
---@param y integer
local function consider(ppos, x, y)
	local targPPos = ppos:move(x, y)
	if targPPos then
		local slotEnt = lp.posToSlot(targPPos)
		if slotEnt and lp.hasTrigger(slotEnt, "UNLOCK") then
			lp.queueWithEntity(slotEnt, triggerUnlock)
			lp.wait(ppos, 0.2)
		end
	end
end

local DESC = interp("Can be unlocked with a {lootplot:INFO_COLOR}key{/lootplot:INFO_COLOR}! Needs %{neededActivations} more key(s).")
lp.defineSlot("dsh.dd:double_locked_slot", {
	image = "dsh_double_locked_slot",
	name = loc("Locked Slot"),
	activateDescription = function (ent)
		return DESC(ent)
	end,
	triggers = { "UNLOCK" },
	audioVolume = 0,
	neededActivations = 2,
	canAddItemToSlot = function()
		return false
	end,
	rarity = lp.rarities.UNIQUE,

	---@param self lootplot.SlotEntity
	onActivate = function(self)
		local ppos = lp.getPos(self)
		if not ppos then
			return
		end

		self.neededActivations = self.neededActivations - 1

		if self.neededActivations > 1 then return end
		if self.neededActivations == 1 then
			self.image = "locked_slot"
			return
		end

		local tslot = self.targetSlot
		local titem = self.targetItem

		self:removeComponent("targetSlot")
		self:removeComponent("targetItem")
		self.targetSlot = nil
		self.targetItem = nil
		lp.destroy(self)

		if tslot then
			tslot:removeComponent("audioVolume")
			lp.setSlot(ppos, tslot)
		end

		if titem then
			if lp.forceSetItem(ppos, titem) then
				titem:removeComponent("audioVolume")
			else
				titem:delete()
			end
		end

		consider(ppos, -1, 0)
		consider(ppos, 0, -1)
		consider(ppos, 1, 0)
		consider(ppos, 0, 1)
	end
})
