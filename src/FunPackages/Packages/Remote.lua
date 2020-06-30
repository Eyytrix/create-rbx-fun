-- Remote
-- @Author Eyytrix

--[[
	Forked from ModRemote
		ModuleScript for handling networking via client/server
		Link: https://github.com/roblox-aurora/ModRemote/blob/master/ModRemote.lua
		@Author Vorlias
]]
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkServer = game:FindService("NetworkServer")

-- Dependencies
local Import = require(ReplicatedStorage:WaitForChild("Resources")).LoadLibrary
local Promise = Import("Promise")
local Ready = Import("Ready")

-- Localize Functions
local time = os.time
local Instance_New = Instance.new

-- Constants
local DEFAULT_CLIENT_CACHE_TTL = 10

local Remote = {Event = {}, Function = {}}

-- For setting up methods
local _RemoteEvent = Remote.Event
local _RemoteFunction = Remote.Function

-- For Client side RemoteFunction cache
local _FunctionCache = {}

assert(
	workspace.FilteringEnabled or not NetworkServer,
	"[Remote] Remote does not work with filterless games due to security vulnerabilties. Please consider using Filtering or use Remote"
)

-- Utility functions

-- @param classType The type of class to instantiate
-- @param properties The properties to use
local function make(classType, properties)
	assert(type(properties) == "table", "Properties is not a table")

	local Object = Instance_New(classType)

	for Index, Value in next, properties do
		Object[Index] = Value
	end

	return Object
end

-- make an empty folder under a parent. If a folder of the same name already exists, it will be destroyed and recreated as an empty folder
-- @param folderName Name of the folder
-- @param parent For setting the parent of the created folder
local function makeEmptyFolder(folderName, parent)
	local instance = parent:FindFirstChild(folderName)

	if instance and instance:IsA("Folder") then
		instance:Destroy()
	end

	return make(
		"Folder",
		{
			Parent = parent,
			Name = folderName
		}
	)
end

local function getRemoteFolder(folderName)
	assert(
		folderName == "RemoteFunctions" or folderName == "RemoteEvents",
		"Folder name must be 'RemoteFunctions' or 'RemoteEvents'"
	)

	-- If on server, create the two Folders
	if NetworkServer then
		return makeEmptyFolder(folderName, ReplicatedStorage)
	end

	-- On client, wait for server to create the folder
	return ReplicatedStorage:WaitForChild(folderName)
end

-- Get storage or create if nonexistent
local RemoteFunctionsFolder = getRemoteFolder("RemoteFunctions")
local RemoteEventsFolder = getRemoteFolder("RemoteEvents")

-- Ensure all Remote Folders's children are replicated to the client
if not NetworkServer then
	local checkReady = Promise.promisify(Ready.Wait)

	Promise.all(
		{
			checkReady(Ready, RemoteFunctionsFolder),
			checkReady(Ready, RemoteEventsFolder)
		}
	):await()
end

-- Metatables
local functionMetatable = {
	__index = function(self, i)
		if rawget(_RemoteFunction, i) then
			return rawget(_RemoteFunction, i)
		else
			return rawget(self, i)
		end
	end,
	__newindex = function(self, i, v)
		if i == "OnInvoke" and type(v) == "function" then
			self:OnInvoke(v)
		end
	end,
	__call = function(self, ...)
		assert(
			not NetworkServer,
			"[Remote] RemoteFunction must be called from the Client side."
		)

		return self:InvokeServer(...)
	end
}

local eventMetatable = {
	__index = function(self, i)
		if rawget(_RemoteEvent, i) then
			return rawget(_RemoteEvent, i)
		else
			return rawget(self, i)
		end
	end
}

-- Helper Functions
local function wrapRemote(remoteType, instance)
	assert(
		remoteType == "Function" or remoteType == "Event",
		"remoteType must be 'Function' or 'Event'"
	)
	return setmetatable(
		{Instance = instance},
		remoteType == "Function" and functionMetatable or eventMetatable
	)
end

-- check if the remote Function/Event exists and valid
local function remoteExists(remoteType, name)
	assert(
		remoteType == "Function" or remoteType == "Event",
		"remoteType must be 'Function' or 'Event'"
	)
	assert(type(name) == "string", "name must be a string")

	local remoteFolder =
		remoteType == "Function" and RemoteFunctionsFolder or RemoteEventsFolder

	local remoteInstance = remoteFolder:FindFirstChild(name)

	return remoteInstance or false
end

local function createFunction(name)
	local remoteFunction = Instance_New("RemoteFunction")

	remoteFunction.Parent = RemoteFunctionsFolder
	remoteFunction.Name = name

	return wrapRemote("Function", remoteFunction)
end

local function createEvent(name)
	local remoteEvent = Instance_New("RemoteEvent")
	remoteEvent.Parent = RemoteEventsFolder
	remoteEvent.Name = name

	return wrapRemote("Event", remoteEvent)
end

--- Gets a function if it exists, otherwise errors
-- @param string name - the name of the function.
function Remote:GetFunction(name)
	assert(type(name) == "string", "[Remote] GetFunction - Name must be a string")

	local remoteFunction = remoteExists("Function", name)

	assert(
		remoteFunction,
		"[Remote] GetFunction - Function " ..
			name .. " not found, create it using CreateFunction."
	)

	return wrapRemote("Function", remoteFunction)
end

--- Gets an event if it exists, otherwise errors
-- @param string name - the name of the event.
function Remote:GetEvent(name)
	assert(type(name) == "string", "[Remote] GetEvent - Name must be a string")

	local remoteEvent = remoteExists("Event", name)

	assert(
		remoteEvent,
		"[Remote] GetEvent - Event " ..
			name .. " not found, create it using CreateEvent."
	)

	return wrapRemote("Event", remoteEvent)
end

--- Creates a function
-- @param string name - the name of the function.
function Remote:CreateFunction(name)
	if not NetworkServer then
		error("[Remote] CreateFunction must be used by the server.")
	end

	return createFunction(name)
end

--- Creates an event
-- @param string name - the name of the event.
function Remote:CreateEvent(name)
	if not NetworkServer then
		error("[Remote] CreateEvent must be used by the server.")
	end

	return createEvent(name)
end

-- RemoteEvent Object Methods
function _RemoteEvent:SendToPlayer(player, ...)
	assert(
		NetworkServer,
		"[Remote] SendToPlayers must be called from the Server side."
	)
	self.Instance:FireClient(player, ...)
end

function _RemoteEvent:SendToAll(...)
	assert(
		NetworkServer,
		"[Remote] SendToPlayers must be called from the Server side."
	)
	self.Instance:FireAllClients(...)
end

function _RemoteEvent:SendToPlayers(playerList, ...)
	assert(
		NetworkServer,
		"[Remote] SendToPlayers must be called from the Server side."
	)
	for a = 1, #playerList do
		self.Instance:FireClient(playerList[a], ...)
	end
end

function _RemoteEvent:SendToServer(...)
	assert(not NetworkServer, "SendToServer must be called from the Client side.")
	self.Instance:FireServer(...)
end

function _RemoteEvent:Connect(callbackFn)
	if NetworkServer then
		return self.Instance.OnServerEvent:Connect(callbackFn)
	end
	return self.Instance.OnClientEvent:Connect(callbackFn)
end

function _RemoteEvent:Wait()
	if NetworkServer then
		self.Instance.OnServerEvent:Wait()
	else
		self.Instance.OnClientEvent:Wait()
	end
end

function _RemoteEvent:Destroy()
	self.Instance:Destroy()
end

-- RemoteFunction Object Methods
function _RemoteFunction:OnInvoke(callbackFn)
	assert(
		NetworkServer,
		"[Remote] RemoteFunction:OnInvoke must be called from the Server side."
	)

	self.Instance.OnServerInvoke = callbackFn
end

function _RemoteFunction:Destroy()
	self.Instance:Destroy()
end

function _RemoteFunction:SetClientCacheTTL(seconds)
	assert(NetworkServer, "SetClientCacheTTL must be called on the Server side.")

	seconds = seconds or DEFAULT_CLIENT_CACHE_TTL

	assert(
		type(seconds) == "number" and seconds >= 0,
		"Arguemnt seconds must be a number than greater than or equal to zero"
	)

	local instance = self.Instance
	local cache

	if seconds == 0 then
		cache = instance:FindFirstChild("ClientCacheTTL")
		if cache then
			cache:Destroy()
		end
	else
		cache =
			instance:FindFirstChild("ClientCacheTTL") or
			make(
				"IntValue",
				{
					Parent = instance,
					Name = "ClientCacheTTL",
					Value = seconds
				}
			)
	end
end

function _RemoteFunction:ResetClientCacheTTL()
	assert(
		not NetworkServer,
		"ResetClientCacheTTL must be used on the Client side."
	)

	local instance = self.Instance

	if instance:FindFirstChild("ClientCacheTTL") then
		_FunctionCache[instance:GetFullName()] = {Expires = 0, Value = nil}
	else
		warn(instance:GetFullName() .. " does not have a cache.")
	end
end

function _RemoteFunction:InvokeServer(...)
	assert(
		not NetworkServer,
		"[Remote] InvokeServer should be called from the Client side."
	)

	local instance = self.Instance
	local clientCacheTTL = instance:FindFirstChild("ClientCacheTTL")

	if clientCacheTTL then
		local cacheName = instance:GetFullName()

		local cache = _FunctionCache[cacheName]
		if cache and time() < cache.Expires then
			-- If the cache exists in FuncCache and the time hasn't expired
			-- Return cached arguments
			return unpack(cache.Value)
		else
			-- The cache isn't in FuncCache or time has expired
			-- Invoke the server with the arguments
			-- Cache Arguments

			local cacheValue = {instance:InvokeServer(...)}
			_FunctionCache[cacheName] = {
				Expires = time() + clientCacheTTL.Value,
				Value = cacheValue
			}
			return unpack(cacheValue)
		end
	else
		return instance:InvokeServer(...)
	end
end

return Remote
