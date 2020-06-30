--[[
Script Name: LazyLoad

Description:
For setting up lazy loading for ModuleScripts in a Folder

Usage:
local LazyLoad = Resources.LoadLibrary("FunPackages").LazyLoad
local lazyloadedModules = LazyLoad(folder)

Author: Eyytrix
Github: https://github.com/eyytrix
Youtube: WIP
Roblox: https://www.roblox.com/users/1629054200/profile

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Import = Resources.LoadLibrary

local Debug = Import("Debug")
local Typer = Import("Typer")
local Table = Import("Table")

-- Set up module scripts in folder to be lazyloaded to a table
local function setUpLazyLoad(table, folder)
	setmetatable(
		table,
		{
			__index = function(t, i)
				local child = folder:FindFirstChild(i)

				Debug.Assert(
					child,
					"! %s Folder does have a child named %s",
					script:GetFullName(),
					folder.Name,
					tostring(i)
				)

				if (child:IsA("ModuleScript")) then
					local obj = require(child)

					rawset(t, i, obj)
					return obj
				elseif (child:IsA("Folder")) then
					local nestedTable = {}

					rawset(t, i, nestedTable)
					setUpLazyLoad(nestedTable, child)
					return nestedTable
				end
			end
		}
	)
end

-- @param folder RBX Folder Instance
-- @return userdata a read-only table that has lazy-loaded modules
local function LazyLoad(folder)
	Debug.Assert(
		Typer.InstanceOfClassFolder(folder),
		"! Argument folder must be a Folder Instance, but got: %s",
		script:GetFullName(),
		tostring(folder)
	)

	local modulesTable = {}

	setUpLazyLoad(modulesTable, folder)

	return Table.Lock(modulesTable)
end

return LazyLoad
