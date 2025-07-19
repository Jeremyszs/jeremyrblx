local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local animalFolder = workspace:WaitForChild("MovingAnimals")

local interactDistance = 10
local walkUpdateInterval = 0.2

-- List of valid animal names
local targetNames = {
    ["La Vacca Saturno Saturnita"] = true,
    ["Chimpanzini Spiderini"] = true,
    ["Los Tralaleritos"] = true,
    ["Las Tralaleritas"] = true,
    ["Graipus Medussi"] = true,
    ["La Grande Combinasion"] = true,
    ["Nuclearo Dinossauro"] = true,
    ["Garama and Madundung"] = true,
    ["Lucky Block"] = true,
    ["Ballerino Lololo"] = true,
    ["Trenostruzzo Turbo 3000"] = true,
    ["Statutino Libertino"] = true,
    ["Odin Din Din Dun"] = true,
    ["Espresso Signora"] = true,
    ["Tralalero Tralala"] = true,
    ["Matteo"] = true,
    ["Gattatino Neonino"] = true,
    ["Girafa Celestre"] = true,
    ["Cocofanto Elefanto"] = true
}

-- Find the nearest target animal
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

-- Accept ProximityPrompt
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
        -- Move a bit forward and backward to show it's still running
        root.CFrame = root.CFrame * CFrame.new(2, 0, 0)
        task.wait(1)
        root.CFrame = root.CFrame * CFrame.new(-2, 0, 0)
        task.wait(1)

        local target = getNearestTarget()
        if target then
            local distance = (root.Position - target.HumanoidRootPart.Position).Magnitude

            if distance > 4 then
                humanoid:MoveTo(target.HumanoidRootPart.Position)
            end

            tryPrompt(target)
        end

        task.wait(walkUpdateInterval)
    end
end)
