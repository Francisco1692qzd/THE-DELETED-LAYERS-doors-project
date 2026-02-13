-- [[ OpenDoor.lua - The Invisible Phantom ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function InvisibleBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. WAIT FOR HIDE EXIT]
    if char:GetAttribute("Hiding") == true then
        repeat task.wait() until char:GetAttribute("Hiding") ~= true
    end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then return end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        local oldCF = root.CFrame
        
        -- [2. THE PHANTOM TRICK]
        -- We temporarily tell the internal motor6Ds to stay behind 
        -- while the RootPart snaps. This prevents the "Flicker".
        
        -- Snap logic
        local targetCF = main.CFrame * CFrame.new(0, 0, 4)

        -- Fire the snap and triggers in the SAME heartbeat step
        root.CFrame = targetCF
        
        -- Fire Triggers
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        for _, v in pairs(door:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("TouchTransmitter") then
                firetouchinterest(root, v.Parent, 0)
                firetouchinterest(root, v.Parent, 1)
            end
        end

        -- [3. THE ZERO-DELAY RETURN]
        -- We don't even use task.wait() here. We return immediately.
        root.CFrame = oldCF
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- Run
task.spawn(function()
    pcall(InvisibleBreach)
end)
