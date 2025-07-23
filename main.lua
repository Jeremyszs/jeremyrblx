-- by jrmysz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local head = character:WaitForChild("Head")

local count = 1
local initialPosition = root.Position

-- Billboard
local billboard = Instance.new("BillboardGui")
billboard.Name = "LoopStatus"
billboard.Size = UDim2.new(0, 140, 0, 35)
billboard.StudsOffset = Vector3.new(0, 2, 0)
billboard.Adornee = head
billboard.AlwaysOnTop = true
billboard.Parent = head

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.SourceSansBold
label.Text = "Loop OK"
label.Parent = billboard

-- UI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "AnimalListGui"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0.6, 0)
frame.Position = UDim2.new(1, -260, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🐾 Animal Log"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local scrollingFrame = Instance.new("ScrollingFrame", frame)
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)

-- Track displayed animals
local displayedAnimals = {}

local function addAnimalToUI(name)
	if displayedAnimals[name] then return end
	displayedAnimals[name] = true

	local label = Instance.new("TextLabel", scrollingFrame)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
end

-- Animal filter
local targetNames = {
	["La Vacca Saturno Saturnita"] = true,
	["Chimpanzini Spiderini"] = true,
	["Los Tralaleritos"] = true,
	["Las Tralaleritas"] = true,
	["Graipus Medussi"] = true,
	["La Grande Combinasion"] = true,
	["Nuclearo Dinossauro"] = true,
	["Garama and Madundung"] = true,
	["Ballerino Lololo"] = true,
	["Trenostruzzo Turbo 3000"] = true,
	["Statutino Libertino"] = true,
	["Odin Din Din Dun"] = true,
	["Espresso Signora"] = true,
	["Tralalero Tralala"] = true,
	["Matteo"] = true,
	["Gattatino Neonino"] = true,
	["Girafa Celestre"] = true,
	["Cocofanto Elefanto"] = true,
	["Cavallo Virtuoso"] = false,
	["Brainrot God Lucky Block"] = true,
	["Secret Lucky Block"] = true
}

local animalFolder = workspace:WaitForChild("MovingAnimals")
local interactDistance = 10
local walkUpdateInterval = 0.2

local function getNearestTarget()
	local nearest = nil
	local shortestDist = math.huge
	for _, animal in pairs(animalFolder:GetChildren()) do
		local index = animal:GetAttribute("Index")
		if targetNames[index] and animal:FindFirstChild("HumanoidRootPart") then
			local dist = (root.Position - animal.HumanoidRootPart.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				nearest = animal
			end
		end
	end
	return nearest
end

local function tryPrompt(animal)
	if not animal then return end
	for _, obj in pairs(animal:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and (root.Position - animal.HumanoidRootPart.Position).Magnitude <= interactDistance then
			pcall(function()
				obj:InputHoldBegin()
				wait(0.5)
				obj:InputHoldEnd()
			end)
		end
	end
end

-- Main Loop
task.spawn(function()
	while true do
		label.Text = "Still Looping, " .. count
		count += 1

		local target = getNearestTarget()

		if target then
			local index = target:GetAttribute("Index")
			if index then
				addAnimalToUI(index)
			end

			local distance = (root.Position - target.HumanoidRootPart.Position).Magnitude
			if distance > 4 then
				humanoid:MoveTo(target.HumanoidRootPart.Position)
			end

			tryPrompt(target)
		else
			humanoid:MoveTo(initialPosition)
		end

		task.wait(walkUpdateInterval)
	end
end)
