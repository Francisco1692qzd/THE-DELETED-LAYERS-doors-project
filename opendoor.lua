-- [[ OpenDoor.lua - The Bunker Breach ]]
-- Position: 4 studs back, 15 studs down.
-- Safety: Raycast-proof, Hitbox-proof, Entity-proof.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function BunkerBreach()
    if _G.DoorBreaching then return end
    _G.DoorBreaching = true

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _G.DoorBreaching = false return end

    -- [1. WAIT FOR SAFETY EXIT]
    if char:GetAttribute("Hiding") == true then
        repeat task.wait() until char:GetAttribute("Hiding") ~= true
    end

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
        
        -- [2. THE BUNKER SNAP]
        -- 4 studs back (Backside) AND 15 studs down (Underworld)
        -- This is a "Dead Zone" where nothing can kill you.
        local bunkerCF = main.CFrame * CFrame.new(0, -15, 4) 

        -- Instant Snap
        root.CFrame = bunkerCF
        
        -- Fire Remote immediately
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        -- Stay for 2 frames so the server acknowledges the 'Touch'
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()

        -- Trigger all proximity and touch events
        for _, v in pairs(door:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("TouchTransmitter") then
                -- Touch interests ignore walls and floors!
                firetouchinterest(root, v.Parent, 0)
                firetouchinterest(root, v.Parent, 1)
            end
        end

        -- [3. THE SECURE RETURN]
        root.CFrame = oldPos
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

task.spawn(function()
    pcall(BunkerBreach)
end)
