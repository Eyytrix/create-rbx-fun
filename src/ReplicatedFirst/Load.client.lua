local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

-- TODO: USE Resources GetLocalTable  for Game Configuration
_G.gameConfiguration = {
	env = "development"
}

while not _G.gameConfiguration do
	Heartbeat:Wait()
end

local function loadGame()
	local gameConfiguration = _G.gameConfiguration

	if gameConfiguration.env == "production" then
		return
	end

	print("Loading...")

	print("Game loaded")
end

loadGame()
