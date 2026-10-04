local slots = require("shared.slots")
local RENDER_AFTER_ENTITY_ORDER = 1

-- draw padlocks on all locked reroll slots
umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function (selfEnt, x,y, rot, sx,sy)
    if lp.isItemEntity(selfEnt) then
        local slotEnt = lp.itemToSlot(selfEnt)
        if not slotEnt then return end
        if not slotEnt:type() then return end
        if slots.REROLL_SLOTS[slotEnt:type()] and slotEnt.rerollLock then
            rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
        end
        return
    end

    if lp.isSlotEntity(selfEnt) then
        if slots.REROLL_SLOTS[selfEnt:type()] and selfEnt.rerollLock then
            if not lp.slotToItem(selfEnt) then
                rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
            end
        end
    end
end)