local query = {
	searchText = nil
}

function query.isActive()
	return query.searchText and query.searchText ~= ""
end

function query.isMatch(entity)
	if not query.searchText then return false end

	if query.searchText then
		if entity.name and type(entity.name) == "string" and entity.name:lower():find(query.searchText) then
			return true
		end

		if entity.description then
			local description = ""
			if type(entity.description) == "string" then
				description = entity.description:lower()
			elseif type(entity.description) == "function" then
				description = entity.description():lower()
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
				description = entity.activateDescription():lower()
			end
			if description:find(query.searchText) then
				return true
			end
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

return query