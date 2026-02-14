-- [[ OpenDoor.lua - The Final "Deleted Layers" Edition ]]
-- Features: Underworld Snap, Hiding Bypass, Instant Return, & Multi-Entity Debounce.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function FullBreach()
    -- [1. DEBOUNCE & VALIDATION]
    if _G.DoorBreaching then return end
    _G.DoorBreaching = true

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _G.DoorBreaching = false return end

    -- [2. TARGETING CURRENT ROOM]
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then 
        _G.DoorBreaching = false 
        return 
    end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    -- Check if the door is actually closed before proceeding
    if main and main.CanCollide == true then
        local oldPos = root.CFrame
        local wasHiding = char:GetAttribute("Hiding")
        
        -- Bunker coordinates: 2 studs back from door, 15 studs UNDER the floor
        local bunkerCF = main.CFrame * CFrame.new(0, -15, 2) 

        -- [3. PREPARE THE GHOST]
        if wasHiding then char:SetAttribute("Hiding", false) end
        
        root.Anchored = true -- Lock position to prevent closet-logic from pulling us back
        root.CFrame = bunkerCF

        -- [4. INTERACTION LOOP]
        -- We pulse the interaction for 2-3 frames to sync with Server Latency
        for i = 1, 3 do
            -- Fire the Remote
            local remote = door:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            -- Fire the Proximity and Touch Triggers
            for _, v in pairs(door:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(root, v.Parent, 0)
                    firetouchinterest(root, v.Parent, 1)
                end
            end
            
            if main.CanCollide == false then break end
            RunService.Heartbeat:Wait() -- Sync with the server's physics step
        end

        -- [5. SECURE RETURN]
        root.Anchored = false
        root.CFrame = oldPos
        
        -- Restore hiding state if they were in a closet
        if wasHiding then char:SetAttribute("Hiding", true) end
        
        -- Kill any momentum so the player doesn't slide upon return
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

-- Execute in a safe thread
task.spawn(function()
    local success, err = pcall(FullBreach)
    if not success then
        warn("Door Breach Failed: " .. tostring(err))
        _G.DoorBreaching = false
    end
end)
