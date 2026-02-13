-- [[ OpenDoor.lua - The Sync-Corrected Invisible Breach ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function GuaranteedInvisibleBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. Hiding Watcher]
    if char:GetAttribute("Hiding") == true then
        repeat task.wait() until char:GetAttribute("Hiding") ~= true
    end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then return end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        local oldPos = root.CFrame
        
        -- [2. THE STICKY SNAP]
        -- We snap for exactly 2 physics frames. 
        -- This is fast enough to be invisible but long enough for the server to "catch up".
        local targetCF = main.CFrame * CFrame.new(0, 0, -4)

        -- Fire triggers immediately
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        -- Snapshot the snap
        root.CFrame = targetCF
        
        -- Use Heartbeat to wait exactly 2 frames (approx 0.03s)
        -- This is the "Sweet Spot" for Doors anti-cheat/lag
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()

        -- Trigger physical interactions while we are 'there'
        for _, v in pairs(door:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("TouchTransmitter") then
                firetouchinterest(root, v.Parent, 0)
                firetouchinterest(root, v.Parent, 1)
            end
        end

        -- [3. THE RETURN]
        root.CFrame = oldPos
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

task.spawn(function()
    pcall(GuaranteedInvisibleBreach)
end)
