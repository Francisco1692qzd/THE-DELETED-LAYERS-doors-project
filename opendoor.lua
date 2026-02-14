-- [[ OpenDoor.lua - Sticky Bunker Edition ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function StickyBunkerBreach()
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
        
        -- Move the bunker closer: 2 studs back instead of 4, 15 studs down.
        local bunkerCF = main.CFrame * CFrame.new(0, -15, 2) 

        -- [1. THE STICKY SNAP]
        if wasHiding then char:SetAttribute("Hiding", false) end
        
        root.Anchored = true
        root.CFrame = bunkerCF

        -- [2. BRUTE FORCE LOOP]
        -- We stay here and spam until the door opens (CanCollide false)
        local timeout = 0
        while main.CanCollide == true and timeout < 15 do 
            timeout = timeout + 1
            
            -- Fire every interaction type
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
            
            -- Wait exactly one physics frame before retrying
            RunService.Heartbeat:Wait()
        end

        -- [3. RETURN]
        root.Anchored = false
        root.CFrame = oldPos
        
        if wasHiding then char:SetAttribute("Hiding", true) end
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

task.spawn(function()
    pcall(StickyBunkerBreach)
end)
