-- [[ OpenDoor.lua - The True Bunker Breach ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function TrueBunkerBreach()
    if _G.DoorBreaching then return end
    _G.DoorBreaching = true

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _G.DoorBreaching = false return end

    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then 
        _G.DoorBreaching = false 
        return 
    end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        local oldPos = root.CFrame
        local wasHiding = char:GetAttribute("Hiding")
        
        -- [1. THE BUNKER SNAP]
        -- Note: Ensure it's -15 to go UNDER the floor. 
        -- Positive 15 would put you in the ceiling!
        local bunkerCF = main.CFrame * CFrame.new(0, 15, 4) 

        -- [2. TEMPORARY UN-HIDE]
        -- We disable the attribute just for the interaction frames
        if wasHiding then char:SetAttribute("Hiding", false) end

        root.CFrame = bunkerCF
        
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        -- Wait 2 frames for server to register "Not Hiding" + "Position"
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()

        for _, v in pairs(door:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("TouchTransmitter") then
                firetouchinterest(root, v.Parent, 0)
                firetouchinterest(root, v.Parent, 1)
            end
        end

        -- [3. THE SECURE RETURN]
        root.CFrame = oldPos
        
        -- Restore hiding state immediately upon return
        if wasHiding then char:SetAttribute("Hiding", true) end
        
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

task.spawn(function()
    pcall(TrueBunkerBreach)
end)
