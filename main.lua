--by jrmysz

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

-- Billboard setup
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

-- Animal names
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

-- Webhook
local webhookUrl = "https://discord.com/api/webhooks/1397169099536072757/Cmh3wedwWt6FLFUWdkzDhq_uEg4IlV02lIdJERFAvBOMM0mcXfU0KT8jXB6q13KplYuw"
local lastSent = {}
local webhookCooldown = 30 -- seconds

local function sendWebhook(animalName)
	local data = {
		content = "**Animal Detected:** " .. animalName
	}
	local headers = {
		["Content-Type"] = "application/json"
	}
	local body = HttpService:JSONEncode(data)

	local success, err = pcall(function()
		HttpService:PostAsync(webhookUrl, body, Enum.HttpContentType.ApplicationJson)
	end)

	if not success then
		warn("Webhook failed:", err)
	end
end

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

				-- Check webhook cooldown
				local now = tick()
				if not lastSent[index] or now - lastSent[index] > webhookCooldown then
					sendWebhook(index)
					lastSent[index] = now
				end
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

-- Main loop
task.spawn(function()
	while true do
		label.Text = "Still Looping, " .. count
		count += 1

		local target = getNearestTarget()

		if target then
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
