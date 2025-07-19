local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local webhookUrl = "https://discord.com/api/webhooks/1350721059527327786/cwYdE1l3Ch_NZQ36S2sV4_XijtW2C32p2SPsVh51BOQqDAEcM72UGG9Lix-CA5ohihgV" -- replace this

local targetNames = {
	"Noobini", "La Vacca Saturno Saturnita", "Chimpanzini Spiderini", "Los Tralaleritos", "Las Tralaleritas",
	"Graipus Medussi", "La Grande Combinasion", "Nuclearo Dinossauro", "Garama and Madundung", "Lucky Block",
	"Ballerino Lololo", "Trenostruzzo Turbo 3000", "Statutino Libertino", "Odin Din Din Dun", "Espresso Signora",
	"Tralalero Tralala", "Matteo", "Gattatino Neonino", "Girafa Celestre", "Cocofanto Elefanto"
}

local function isTargetName(name)
	for _, target in ipairs(targetNames) do
		if name:lower():find(target:lower()) then
			return true
		end
	end
	return false
end

local function getClosest()
	local nearest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and isTargetName(v.Name) then
			local hrp = v:FindFirstChild("HumanoidRootPart")
			if hrp and root then
				local d = (hrp.Position - root.Position).Magnitude
				if d < dist then
					dist = d
					nearest = hrp
				end
			end
		end
	end
	return nearest
end

-- Main Loop
task.spawn(function()
	while task.wait(0.1) do
		if not root or not root.Parent then
			root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		end
		local target = getClosest()
		if target and root then
			root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
		end
	end
end)

-- Heartbeat to Discord every 30 seconds
local function sendHeartbeat()
	local pos = root and root.Position or Vector3.new(0, 0, 0)
	local embed = {
		embeds = {{
			title = "AutoFarm Heartbeat 💓",
			description = "Loop is running smoothly!",
			color = 65280, -- green
			fields = {
				{ name = "Player", value = LP.Name, inline = true },
				{ name = "Position", value = `X: {math.floor(pos.X)} Y: {math.floor(pos.Y)} Z: {math.floor(pos.Z)}`, inline = true },
				{ name = "Time", value = os.date("%X"), inline = true }
			}
		}}
	}
	local success, err = pcall(function()
		HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(embed), Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("❌ Failed to send heartbeat:", err)
	end
end

-- Start Heartbeat Loop
task.spawn(function()
	while true do
		sendHeartbeat()
		task.wait(30)
	end
end)
