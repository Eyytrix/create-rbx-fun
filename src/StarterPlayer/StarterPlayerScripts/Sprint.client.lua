local inputService = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:wait()

local normalSpeed = 18 -- The player's speed while not sprinting
local sprintSpeed = 26 -- The player's speed while sprinting

inputService.InputBegan:Connect(
	function(key)
		if
			key.KeyCode == Enum.KeyCode.LeftShift or
				key.KeyCode == Enum.KeyCode.RightShift
		 then
			if char.Humanoid then
				char.Humanoid.WalkSpeed = sprintSpeed
			end
		end
	end
)

inputService.InputEnded:Connect(
	function(key)
		if
			key.KeyCode == Enum.KeyCode.LeftShift or
				key.KeyCode == Enum.KeyCode.RightShift
		 then
			if char.Humanoid then
				char.Humanoid.WalkSpeed = normalSpeed
			end
		end
	end
)
