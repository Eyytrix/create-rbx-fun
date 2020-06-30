local Set = {}

function Set:Add(value)
	if not self._set[value] then
		self._set[value] = true
	end
end

function Set:Delete(value)
	if self._set[value] then
		self._set[value] = nil
	end
end

function Set:Has(value)
	return self._set[value] ~= nil
end

function Set:Clear()
	self._set = {}
	return self._set
end

function Set:Entries()
	local entries = {}

	for k, v in pairs(self._set) do
		table.insert(entries, {k, v})
	end

	return entries
end

function Set:Values()
	local values = {}

	for _, v in pairs(self._set) do
		table.insert(values, v)
	end

	return values
end

function Set:Keys()
	local keys = {}

	for k, _ in pairs(self._set) do
		table.insert(keys, k)
	end

	return keys
end

function Set:ForEach(callbackFn)
	assert(type(callbackFn) == "function", "Second argument must be a function")

	for key, _ in pairs(self._set) do
		callbackFn(key)
	end
end

function Set.new(list)
	assert(
		type(list) == "table",
		"Argument list must be a table, but a :" .. type(list)
	)

	local _values = {}

	local set = setmetatable({_set = _values}, {__index = Set})

	for _, v in pairs(list) do
		_values[v] = true
	end

	return set
end

return Set
