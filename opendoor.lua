-- [[ OpenDoor.lua - The Anchor-Lock Bunker ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function AnchorBunkerBreach()
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
        
        -- Bunker coordinates: 4 studs back, 15 studs DOWN
        local bunkerCF = main.CFrame * CFrame.new(0, 15, 4) 

        -- [1. THE FORCE SNAP]
        if wasHiding then char:SetAttribute("Hiding", false) end
        
        -- Anchor prevents the closet script from yanking you back immediately
        root.Anchored = true 
        root.CFrame = bunkerCF
        
        -- [2. THE INTERACTION]
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        -- Give the server 2 frames to acknowledge you are "at the door"
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

        -- [3. THE RELEASE & RETURN]
        root.Anchored = false
        root.CFrame = oldPos
        
        if wasHiding then char:SetAttribute("Hiding", true) end
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

task.spawn(function()
    pcall(AnchorBunkerBreach)
end)
