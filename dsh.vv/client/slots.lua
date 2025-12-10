local slots = require("shared.slots")

-- draw padlocks on all locked reroll slots, including the vanilla one
umg.on("rendering:drawEntity", function (selfEnt, x,y, rot, sx,sy)
    if lp.isItemEntity(selfEnt) then
        local slotEnt = lp.itemToSlot(selfEnt)
        if not slotEnt then return end
        if not slotEnt:type() then return end
        if slots.REROLL_SLOTS[slotEnt:type()] and slotEnt.rerollLock then
            rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
        end
    end
end)