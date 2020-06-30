local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()

local Fun = {}

-- TODO: Test this method
-- Setup table to lazy load Roblox Lua ModuleScript on demand:
local function SetUpLazyLoadModuleScripts(table, folder)
	setmetatable(
		table,
		{
			__index = function(t, i)
				local child = folder[i]

				if (child:IsA("ModuleScript")) then
					local obj = require(child)

					rawset(t, i, obj)
					return obj
				elseif (child:IsA("Folder")) then
					local nestedTable = {}

					rawset(t, i, nestedTable)
					SetUpLazyLoadModuleScripts(nestedTable, child)
					return nestedTable
				end
			end
		}
	)
end

local function setUpEntityCollections()
	local entityCollections = {}

	Fun.EntityCollections =
		setmetatable(
		{},
		{
			__index = function(self, key)
				error(
					"[Fun.EntityCollections] Entity must be get via Fun.EntityCollections.Get(" ..
						key .. ")",
					2
				)
			end
		}
	)

	local function addCollection(entityName)
		local entityCollection = entityCollections[entityName]

		assert(
			not entityCollection,
			"[Fun.EntityCollections.Add] " .. entityName .. " already Exists."
		)

		entityCollections[entityName] = {}
	end

	-- TODO: Add client aspect of code
	-- Build EntityCollections table base on entity script name
	if IS_SERVER then
		local entityScripts = script.Server.Entities:GetChildren()
		for i = 1, #entityScripts do
			local entityScript = entityScripts[i]

			addCollection(entityScript.Name)
		end
	end

	function Fun.EntityCollections.Get(entityName)
		assert(type(entityName) == "string", "Argument entityName must be a string.")

		local entityCollection = entityCollections[entityName]

		assert(
			entityCollection,
			"[Fun.EntityCollections.Get] " .. entityName .. " does not exist."
		)

		return entityCollection
	end
end

local function setUpEntities()
	local clientEntities = {}
	local serverEntities = {}

	if IS_SERVER then
		SetUpLazyLoadModuleScripts(serverEntities, script.Server.Entities)
	else
		SetUpLazyLoadModuleScripts(clientEntities, script.Client.Entities)
	end

	Fun.Entities =
		setmetatable(
		{},
		{
			__index = function(self, key)
				error(
					"[Fun.Entities] Entity must be get via Fun.Entities.Get(" .. key .. ")",
					2
				)
			end
		}
	)

	function Fun.Entities.Get(entityName)
		assert(type(entityName) == "string", "Argument entityName must be a string.")

		local entity =
			IS_SERVER and serverEntities[entityName] or clientEntities[entityName]

		assert(entity, "[Fun.Entities.Get] Entity:" .. entityName .. " not found.")
		return entity
	end
end

local function startSystems()
	local clientSystems = {}
	local serverSystems = {}

	-- TODO: Add client aspect of code
	-- Build EntityCollections table base on entity script name
	if IS_SERVER then
		local systemScripts = script.Server.Systems:GetChildren()
		for i = 1, #systemScripts do
			local systemScript = systemScripts[i]

			serverSystems[systemScript.Name] = require(systemScript)
			serverSystems[systemScript.Name]:Start()
		end
	else
		local systemScripts = script.Client.Systems:GetChildren()
		for i = 1, #systemScripts do
			local systemScript = systemScripts[i]

			clientSystems[systemScript.Name] = require(systemScript)
			clientSystems[systemScript.Name]:Start()
		end
	end
end

-- Note: Framework SetUp and Start Login
-- Note: Framework is consider ready after setUpFun has been run
-- FIXME: Be mindful about scripts that has require(Fun), if Fun require those scrips, it cause circular dependency. Think about a better way other than lazyload 
local function setUpFun()
	setUpEntityCollections()
	setUpEntities()
	print("Let the Fun begin!")
end

setUpFun()

local isFunStarted = false

function Fun.Start()
	if isFunStarted then
		return
	end

	startSystems()
end

return Fun
