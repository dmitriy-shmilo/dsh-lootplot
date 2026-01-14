local query = {
	searchText = nil,
	triggerFilters = {
	}
}

function query.isSearchActive()
	return query.searchText and query.searchText ~= ""
end

function query.isSearchMatch(entity)
	if not query.searchText or #query.searchText == 0 then return false end

	if entity.name and type(entity.name) == "string" and entity.name:lower():find(query.searchText) then
		return true
	end

	if entity.description then
		local description = ""
		if type(entity.description) == "string" then
			description = entity.description:lower()
		elseif type(entity.description) == "function" then
			description = entity.description(entity):lower()
		end
		if description:find(query.searchText) then
			return true
		end
	end

	if entity.activateDescription then
		local description = ""
		if type(entity.activateDescription) == "string" then
			description = entity.activateDescription:lower()
		elseif type(entity.activateDescription) == "function" then
			description = entity.activateDescription(entity):lower()
		end
		if description:find(query.searchText) then
			return true
		end
	end

	return false
end

function query.search(text)
	if not text or not #text then 
		query.searchText = nil
		return
	end
	query.searchText = text:lower()
end

function query.isTriggerFilterActive()
	for t, _ in pairs(query.triggerFilters) do
		if query.triggerFilters[t] then return true end
	end
	return false
end

function query.isTriggerMatch(entity)
	if not entity.triggers then return false end
	for _, t in pairs(entity.triggers) do
		if query.triggerFilters[t] then return true end
	end
	return false
end

function query.setTriggerFilter(trigger, isActive)
	query.triggerFilters[trigger] = isActive
end

function query.clearTriggerFilters()
	for t, _ in pairs(query.triggerFilters) do
		query.triggerFilters[t] = false
	end
end

function query.isActive()
	return query.isSearchActive() or query.isTriggerFilterActive()
end

function query.isMatch(entity)
	return query.isTriggerMatch(entity) or query.isSearchMatch(entity)
end

return query