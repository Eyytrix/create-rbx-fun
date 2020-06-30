local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Import = Resources.LoadLibrary

local FunPackages = Import("FunPackages")
local Thread = FunPackages.Thread

local dayLength = 250 -- How many real-time seconds an in-game day will last
local nightLength = 150 -- How many real-time seconds an in-game night will last

function tween(l, p)
	TweenService:Create(
		Lighting,
		TweenInfo.new(l, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		p
	):Play()
end

Lighting.ClockTime = 6

while dayLength ~= nil do
	tween(dayLength, {ClockTime = 18})
	Thread.Sleep(dayLength)

	tween(
		4,
		{
			OutdoorAmbient = Color3.new(60 / 255, 60 / 255, 60 / 255),
			FogColor = Color3.new(25 / 255, 25 / 255, 25 / 255),
			FogEnd = 700
		}
	)
	tween(nightLength / 2, {ClockTime = 24})
	Thread.Sleep(nightLength / 2)
	tween(nightLength / 2, {ClockTime = 6})
	Thread.Sleep(nightLength / 2)
	tween(
		4,
		{
			OutdoorAmbient = Color3.new(140 / 255, 140 / 255, 140 / 255),
			FogColor = Color3.new(195 / 255, 195 / 255, 195 / 255),
			FogEnd = 4500
		}
	)
end
